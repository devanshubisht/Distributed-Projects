#include "runner.hpp"
#include <fstream>
#include <queue>
#include "algorithm"
#define TERMINATE_TAG 1

/*
 * ==========================================
 * | [START] OK TO MODIFY THIS FILE [START] |
 * ==========================================
 */

 // MPI message definitions for task_t
constexpr int task_t_num_blocks = 8;
constexpr int task_t_lengths[task_t_num_blocks] = { 1, 1, 1, 1, 1, 1, 4, 4 };
constexpr MPI_Aint task_t_displs[task_t_num_blocks] = {
    offsetof(struct task_t, id),
    offsetof(struct task_t, gen),
    offsetof(struct task_t, type),
    offsetof(struct task_t, arg_seed),
    offsetof(struct task_t, output),
    offsetof(struct task_t, num_dependencies),
    offsetof(struct task_t, dependencies),
    offsetof(struct task_t, masks) };
inline const MPI_Datatype task_t_types[task_t_num_blocks] = { MPI_UINT32_T, MPI_INT, MPI_INT, MPI_UINT32_T, MPI_UINT32_T, MPI_INT, MPI_UINT32_T, MPI_UINT32_T };

MPI_Datatype MPI_PARAMS_T, MPI_METRIC_T, MPI_TASK_T;

void run_all_tasks_seq(int rank, metric_t& stats, params_t& params) {
    if (rank == 0) {
        std::queue<task_t> task_queue;

        std::ifstream istrm(params.input_path, std::ios::binary);
        // Read initial tasks
        int count;
        istrm >> count;

        for (int i = 0; i < count; ++i) {
            task_t task;
            int type;
            istrm >> type >> task.arg_seed;
            task.type = static_cast<TaskType>(type);
            task.id = task.arg_seed;
            task.gen = 0;
            task_queue.push(task);
        }

        // Declare array to store generated descendant tasks
        int num_new_tasks = 0;
        std::vector<task_t> task_buffer(Nmax);
        while (!task_queue.empty()) {
            execute_task(stats, task_queue.front(), num_new_tasks, task_buffer);
            for (int i = 0; i < num_new_tasks; ++i) {
                task_queue.push(task_buffer[i]);
            }
            task_queue.pop();
        }
    }
}

int get_next_worker(std::vector<int>& worker_status) {
    // pick min
    auto minElement = std::min_element(worker_status.begin() + 1, worker_status.end());
    return std::distance(worker_status.begin(), minElement);
}


void run_all_tasks(int rank, int num_procs, metric_t& stats, params_t& params) {
    if (num_procs <= 2) {
        run_all_tasks_seq(rank, stats, params);
        return;
    }

    // Create the custom MPI data types
    MPI_Type_create_struct(task_t_num_blocks, task_t_lengths, task_t_displs, task_t_types,
        &MPI_TASK_T);
    MPI_Type_commit(&MPI_TASK_T);

    int num_new_tasks = 0;
    std::vector<task_t> task_buffer(Nmax);
    if (rank == 0) {  // master process
        std::queue<task_t> task_queue;

        // Read initial tasks
        std::ifstream istrm(params.input_path, std::ios::binary);
        int count;
        istrm >> count;
        for (int i = 0; i < count; ++i) {
            task_t task;
            int type;
            istrm >> type >> task.arg_seed;
            task.type = static_cast<TaskType>(type);
            task.id = task.arg_seed;
            task.gen = 0;
            task_queue.push(task);
        }

        // Initialize worker status array (0: free, 1: busy)
        std::vector<int> worker_status(num_procs, 0);

        // Send initial tasks to worker processes
        MPI_Request request;
        for (int i = 1; i < num_procs && !task_queue.empty(); ++i) {
            MPI_Isend(&task_queue.front(), 1, MPI_TASK_T, i, 0, MPI_COMM_WORLD, &request);
            task_queue.pop();
            worker_status[i] = 1;  // mark worker as busy
        }

        // Asynchronously receive results from worker processes and send new tasks
        while (!task_queue.empty() || std::any_of(worker_status.begin(), worker_status.end(), [](int ws) {return ws > 0;})) {

            // Isend all the tasks in the queue to workers
            while (!task_queue.empty()) {
                // Pick a worker to send to
                int target_worker = get_next_worker(worker_status);
                MPI_Isend(&task_queue.front(), 1, MPI_TASK_T, target_worker, 0, MPI_COMM_WORLD, &request);
                task_queue.pop(); // I think there is a mem leak here cus of tasks
                worker_status[target_worker]++;
            }

            // Start receiving again

            // Probe for next message and get count of tasks in data buffer
            MPI_Status status;
            MPI_Probe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
            int count;
            MPI_Get_count(&status, MPI_TASK_T, &count);


            task_buffer.resize(count);
            MPI_Recv(task_buffer.data(), count, MPI_TASK_T, status.MPI_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            for (int i = 0; i < count; ++i) {
                task_queue.push(task_buffer[i]);
            }
            worker_status[status.MPI_SOURCE]--;  // mark worker as free
        }

        // Send termination signal to worker processes
        for (int i = 1; i < num_procs; ++i) {
            MPI_Isend(NULL, 0, MPI_TASK_T, i, TERMINATE_TAG, MPI_COMM_WORLD, &request);  // use tag 1 for termination signal
        }
    }
    else {  // worker processes
        task_t task;
        MPI_Status status;
        std::vector<MPI_Request> reqs;
        std::vector<std::vector<task_t>> local_task_buffers;
        int buffer_index = 0;

        // Initialize local_task_buffers and reqs
        local_task_buffers.resize(10, std::vector<task_t>(Nmax));
        reqs.resize(local_task_buffers.size(), MPI_REQUEST_NULL);

        while (true) {
            // Receive task from master process
            MPI_Recv(&task, 1, MPI_TASK_T, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);

            // Check for termination signal
            if (status.MPI_TAG == TERMINATE_TAG) break;  // termination signal received

            // Execute task and send results back to master process
            if (reqs[buffer_index] != MPI_REQUEST_NULL) { // If this is not the first use of this buffer
                MPI_Wait(&reqs[buffer_index], MPI_STATUS_IGNORE); // Wait for the previous Isend operation to complete
            }
            execute_task(stats, task, num_new_tasks, local_task_buffers[buffer_index]);
            MPI_Isend(local_task_buffers[buffer_index].data(), num_new_tasks, MPI_TASK_T, 0, 0, MPI_COMM_WORLD, &reqs[buffer_index]);

            // Cycle to the next buffer
            buffer_index = (buffer_index + 1) % local_task_buffers.size();
        }
    }

    // Free the custom MPI data types at the end of the function
    MPI_Type_free(&MPI_TASK_T);
}
