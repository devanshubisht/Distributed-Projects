#include <vector>

#include "defs.h"

#define THREADS_PER_BLOCK 1024

// Unroll + int instead of size_t + shared bool
// __global__ void matchFile(const uint8_t* file_data, int file_len, 
// 	const char* sig_data, int sig_size, bool* flag_array, int sig_idx) 
// {
// 	__shared__ int shared_flag;
// 	if (threadIdx.x == 0) shared_flag = false;
// 	__syncthreads();

//     int file_start_byte_idx = blockIdx.x * blockDim.x + threadIdx.x;

// 	bool local_flag = true;
// 	for (int char_idx = 0; char_idx < sig_size; char_idx+=2) {

// 		int curr_file_byte_idx = file_start_byte_idx + (char_idx / 2);

// 		if (curr_file_byte_idx >= file_len){
// 			local_flag = false;
//  			break;
// 		}
		
// 		uint8_t curr_file_byte = file_data[curr_file_byte_idx];

// 		char sig_data_val1 = sig_data[char_idx];
// 		char sig_data_val2 = sig_data[char_idx + 1];

// 		uint8_t curr_sig_char_val1 = sig_data_val1 >= 'a' 
// 							? sig_data_val1 - 'a' + 10 
// 							: sig_data_val1 - '0';
		
// 		uint8_t curr_sig_char_val2 = sig_data_val2 >= 'a' 
// 							? sig_data_val2 - 'a' + 10 
// 							: sig_data_val2 - '0';
		
// 		uint8_t curr_sig_byte = (curr_sig_char_val1 << 4) | curr_sig_char_val2;

// 		if (sig_data_val1 != '?' && curr_file_byte != curr_sig_byte) {
// 			local_flag = false;
// 			break;
// 		}
// 	}

// 	if (local_flag) atomicOr(&shared_flag, 1);

// 	__syncthreads();

// 	if (threadIdx.x == 0) flag_array[sig_idx] = flag_array[sig_idx] || shared_flag;
// }


// Unroll + int instead of size_t
// __global__ void matchFile(const uint8_t* file_data, int file_len, 
// 	const char* sig_data, int sig_size, bool* flag_array, int sig_idx) 
// {
//     int file_start_byte_idx = blockIdx.x * blockDim.x + threadIdx.x;

// 	for (int char_idx = 0; char_idx < sig_size; char_idx+=2) {

// 		int curr_file_byte_idx = file_start_byte_idx + (char_idx / 2);

// 		if (curr_file_byte_idx >= file_len){
//  			return;
// 		}
		
// 		uint8_t curr_file_byte = file_data[curr_file_byte_idx];

// 		char sig_data_val1 = sig_data[char_idx];
// 		char sig_data_val2 = sig_data[char_idx + 1];

// 		// Convert the current signature char we are checking to uint8
// 		uint8_t curr_sig_char_val1 = sig_data_val1 >= 'a' 
// 							? sig_data_val1 - 'a' + 10 
// 							: sig_data_val1 - '0';
		
// 		uint8_t curr_sig_char_val2 = sig_data_val2 >= 'a' 
// 							? sig_data_val2 - 'a' + 10 
// 							: sig_data_val2 - '0';
		
// 		uint8_t curr_sig_byte = (curr_sig_char_val1 << 4) | curr_sig_char_val2;

		
// 		if (sig_data_val1 != '?' && curr_file_byte != curr_sig_byte) {
// 			return;
// 		}
// 	}
// 	// Set flag to true if the signature matches
// 	flag_array[sig_idx] = true;
// }

// unroll
__global__ void matchFile(const uint8_t* file_data, int file_len, 
	const char* sig_data, int sig_size, bool* flag_array, int sig_idx) 
{
    int file_start_byte_idx = blockIdx.x * blockDim.x + threadIdx.x;

	for (int char_idx = 0; char_idx < sig_size; char_idx+=2) {

		int curr_file_byte_idx = file_start_byte_idx + (char_idx / 2);

		if (curr_file_byte_idx >= file_len){
 			return;
		}
		
		uint8_t curr_file_byte = file_data[curr_file_byte_idx];

		char sig_data_val1 = sig_data[char_idx];
		char sig_data_val2 = sig_data[char_idx + 1];

		// Convert the current signature char we are checking to uint8
		uint8_t curr_sig_char_val1 = sig_data_val1 >= 'a' 
							? sig_data_val1 - 'a' + 10 
							: sig_data_val1 - '0';
		
		uint8_t curr_sig_char_val2 = sig_data_val2 >= 'a' 
							? sig_data_val2 - 'a' + 10 
							: sig_data_val2 - '0';
		
		uint8_t curr_sig_byte = (curr_sig_char_val1 << 4) | curr_sig_char_val2;

		
		if (sig_data_val1 != '?' && curr_file_byte != curr_sig_byte) {
			return;
		}
	}
	// Set flag to true if the signature matches
	flag_array[sig_idx] = true;
}

// Original
// __global__ void matchFile(const uint8_t* file_data, size_t file_len, 
// 	const char* sig_data, size_t sig_size, bool* flag_array, size_t sig_idx) 
// {
//     size_t file_start_byte_idx = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;

// 	for (size_t char_idx = 0; char_idx < sig_size; char_idx++) {

// 		size_t curr_file_byte_idx = file_start_byte_idx + (char_idx / 2);

// 		if (curr_file_byte_idx >= file_len){
//  			return;
// 		}
		
// 		uint8_t curr_file_char_val = (file_data[curr_file_byte_idx] >> 4 * (1 - (char_idx % 2))) & 0x0F;

// 		char curr_sig_char = sig_data[char_idx];

// 		// Convert the current signature char we are checking to uint8
// 		uint8_t curr_sig_char_val = curr_sig_char >= 'a' 
// 							? curr_sig_char - 'a' + 10 
// 							: curr_sig_char - '0';

		
// 		if (curr_sig_char != '?' && curr_file_char_val != curr_sig_char_val) {
// 			return;
// 		}
// 	}
// 	// Set flag to true if the signature matches
// 	flag_array[sig_idx] = true;
// }


void runScanner(std::vector<Signature>& signatures, std::vector<InputFile>& inputs)
{
	cudaDeviceProp prop;
	check_cuda_error(cudaGetDeviceProperties(&prop, 0));

	fprintf(stderr, "cuda stats:\n");
	fprintf(stderr, "  # of SMs: %d\n", prop.multiProcessorCount);
	fprintf(stderr, "  global memory: %.2f MB\n", prop.totalGlobalMem / 1024.0 / 1024.0);
	fprintf(stderr, "  shared mem per block: %zu bytes\n", prop.sharedMemPerBlock);
	fprintf(stderr, "  constant mem: %zu bytes\n", prop.totalConstMem);
	fprintf(stderr, "  max threads per block: %d\n", prop.maxThreadsPerBlock);
	fprintf(stderr, "  constant memory: %zu bytes\n", prop.totalConstMem);

	// Create one stream for each input file
	std::vector<cudaStream_t> streams(inputs.size());

	// Copy input files to device
	std::vector<uint8_t*> file_bufs(inputs.size());

    std::vector<char*> sig_bufs(signatures.size());
    check_cuda_error(cudaMallocManaged(sig_bufs.data(), signatures.size() * sizeof(char*)));

    for (size_t i = 0; i < signatures.size(); i++) {
        // Allocate managed memory for each signature
        char* ptr = nullptr;
        check_cuda_error(cudaMallocManaged(&ptr, signatures[i].size));

        // Copy data from signatures to managed memory
        std::memcpy(ptr, signatures[i].data, signatures[i].size);

        // Assign the managed memory pointer to sig_bufs
        sig_bufs[i] = ptr;
    }


	size_t total_flags = inputs.size() * signatures.size();
	bool* flat_flags_array = nullptr;
	check_cuda_error(cudaMallocManaged(&flat_flags_array, total_flags * sizeof(bool)));


	for(size_t file_idx = 0; file_idx < inputs.size(); file_idx++) {
		cudaStreamCreate(&streams[file_idx]);
		uint8_t* file_ptr = 0; 

		
		check_cuda_error(cudaMallocManaged(&file_ptr, sizeof(uint8_t) * inputs[file_idx].size));
		std::memcpy(file_ptr, inputs[file_idx].data, sizeof(uint8_t) * inputs[file_idx].size);
		file_bufs[file_idx]=file_ptr;

		bool* device_flag_array = &flat_flags_array[file_idx * signatures.size()];


		for(size_t sig_idx = 0; sig_idx < signatures.size(); sig_idx++) {
			size_t NUM_WINDOWS = (inputs[file_idx].size - (signatures[sig_idx].size / 2)) + 1;
			size_t NUM_BLOCKS = (NUM_WINDOWS + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;

			// NORMAL and UNROLL
			matchFile<<<NUM_BLOCKS, THREADS_PER_BLOCK, 0, streams[file_idx]>>>(
				file_bufs[file_idx], 
				static_cast<int>(inputs[file_idx].size), 
				sig_bufs[sig_idx], 
				static_cast<int>(signatures[sig_idx].size),
				device_flag_array,
				static_cast<int>(sig_idx)
			);

			// SIZE_T to INT
			// matchFile<<<NUM_BLOCKS, THREADS_PER_BLOCK, 0, streams[file_idx]>>>(
			// 	file_bufs[file_idx], 
			// 	static_cast<int>(inputs[file_idx].size), 
			// 	sig_bufs[sig_idx], 
			// 	static_cast<int>(signatures[sig_idx].size),
			// 	device_flag_arrays[file_idx],
			// 	static_cast<int>(sig_idx)
			// );

			// SIZE_T to INT + SHARED MEM
			// matchFile<<<NUM_BLOCKS, THREADS_PER_BLOCK, sizeof(int), streams[file_idx]>>>(
			// 	file_bufs[file_idx], 
			// 	static_cast<int>(inputs[file_idx].size), 
			// 	sig_bufs[sig_idx], 
			// 	static_cast<int>(signatures[sig_idx].size),
			// 	device_flag_arrays[file_idx],
			// 	static_cast<int>(sig_idx)
			// );
		}
	}

	// Synchronize streams
	for (size_t file_idx = 0; file_idx < inputs.size(); file_idx++) {
		cudaStreamSynchronize(streams[file_idx]);
		for (size_t sig_idx = 0; sig_idx < signatures.size(); sig_idx++) {
			if (flat_flags_array[file_idx * signatures.size() + sig_idx]) {
				printf("%s: %s\n", inputs[file_idx].name.c_str(), signatures[sig_idx].name.c_str());
			}
		}
		cudaFree(file_bufs[file_idx]);
	}

	// free the device memory, though this is not strictly necessary
	// (the CUDA driver will clean up when your program exits)
    
    for (size_t i = 0; i < signatures.size(); i++) {
        cudaFree(sig_bufs[i]); // Free individual signature buffers
    }

    cudaFree(sig_bufs.data()); // Free the managed memory for sig_bufs

	// clean up streams (again, not strictly necessary)
	for(auto& s : streams)
		cudaStreamDestroy(s);
}
