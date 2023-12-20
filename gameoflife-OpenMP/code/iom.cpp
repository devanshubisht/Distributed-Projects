#include "iom.h"
#include <omp.h>

int iom(int nThreads, int nGenerations, std::vector<std::vector<int>> &startWorld, int nRows, int nCols, int nInvasions, std::vector<int> invasionTimes, std::vector<std::vector<std::vector<int>>> invasionPlans)
{
    std::vector<std::vector<int>> currentWorld = startWorld;
    std::vector<std::vector<int>> newGeneration = currentWorld;
    int deaths = 0;
    int invasionPointer = 0;

    for (int gen = 1; gen <= nGenerations; gen++)
    {
        bool hasInvasion = nInvasions > 0 && invasionTimes[invasionPointer] == gen;
#pragma omp parallel for num_threads(nThreads) reduction(+ : deaths)
        for (int x = 0; x < nRows; x++)
        {
            for (int y = 0; y < nCols; y++)
            {
                // Reproduction Task
                if (currentWorld[x][y] == 0)
                {
                    std::vector<int> counts(10);
                    for (int di = -1; di <= 1; di++)
                    {
                        for (int dj = -1; dj <= 1; dj++)
                        {
                            if (di == 0 && dj == 0)
                                continue;
                            int ni = (x + di + nRows) % nRows;
                            int nj = (y + dj + nCols) % nCols;
                            counts[currentWorld[ni][nj]]++;
                        }
                    }
                    for (int k = counts.size() - 1; k > 0; k--)
                    {
                        if (counts[k] == 3)
                        {
                            newGeneration[x][y] = k;
                            break;
                        }
                    }
                }
                else
                {
                    // Other Tasks
                    int faction = currentWorld[x][y];
                    int hostileNeighborCount = 0;
                    int friendlyNeighbours = 0;
                    // Check all eight neighbors for hostility
                    for (int di = -1; di <= 1; ++di)
                    {
                        for (int dj = -1; dj <= 1; ++dj)
                        {
                            if (di == 0 && dj == 0)
                                continue;
                            int neighborRow = (x + di + nRows) % nRows;
                            int neighborCol = (y + dj + nCols) % nCols;

                            if (currentWorld[neighborRow][neighborCol] == faction)
                            {
                                friendlyNeighbours++;
                            }
                            else if (currentWorld[neighborRow][neighborCol] != 0)
                            {
                                hostileNeighborCount++;
                            }
                        }
                    }
                    if (hostileNeighborCount >= 1)
                    {
                        newGeneration[x][y] = 0;
                        // if there is invasion and the guys dies, dont add here
                        if (!(hasInvasion && invasionPlans[invasionPointer][x][y] != 0))
                        {
                            deaths++;
                        }
                    }
                    else if (friendlyNeighbours < 2 || friendlyNeighbours >= 4)
                    {
                        newGeneration[x][y] = 0;
                    }
                }
                if (hasInvasion && invasionPlans[invasionPointer][x][y] != 0)
                {
                    if (currentWorld[x][y] != 0)
                    {
                        deaths++;
                    }
                    newGeneration[x][y] = invasionPlans[invasionPointer][x][y];
                }
            }
        }
        if (hasInvasion)
        {
            invasionPointer++;
            nInvasions--;
        }
        currentWorld = newGeneration;
    }
    return deaths;
}