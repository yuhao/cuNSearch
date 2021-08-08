#include "cuNSearch.h"
#include "Timing.h"

#include <fstream>
#include <iostream>
#include <vector>
#include <array>
#include <cmath>
#include <limits>
#include <random>
#include <string>

using namespace cuNSearch;

using Real3 = std::array<Real, 3>;
std::vector<Real3> positions;

inline Real3 operator-(const Real3 & left, const Real3 & right)
{
  return Real3{ left[0] - right[0], left[1] - right[1], left[2] - right[2] };
}

//std::size_t const N = 120;
Real const r_omega = static_cast<Real>(0.15);
Real const r_omega2 = r_omega * r_omega;
Real radius;
//Real const radius = static_cast<Real>(2.0) * (static_cast<Real>(2.0) * r_omega / static_cast<Real>(N - 1));

void read_pc_data(const char* data_file) {
  std::ifstream file;

  file.open(data_file);
  if( !file.good() ) {
    std::cerr << "Could not read the frame data...\n";
    //assert(0);
  }

  char line[1024];
  unsigned int lines = 0;

  while (file.getline(line, 1024)) {
    lines++;
  }
  file.clear();
  file.seekg(0, std::ios::beg);
  //float3* points = new float3[lines];
  //*N = lines;

  lines = 0;
  while (file.getline(line, 1024)) {
    Real x, y, z;

    sscanf(line, "%lf,%lf,%lf\n", &x, &y, &z);
    std::array<Real, 3> t = { { static_cast<Real>(x), static_cast<Real>(y), static_cast<Real>(z) } };
    positions.push_back(t);
    //points[lines].x = x;
    //points[lines].y = y;
    //points[lines].z = z;
    //std::cerr << points[lines].x << "," << points[lines].y << "," << points[lines].z << std::endl;
    lines++;
  }

  file.close();

  //return points;
}

void testCuNSearch(const char* data_file)
{
  // read points
  read_pc_data(data_file);
  bool shuffle = false;
  if (shuffle) {
    unsigned seed = std::chrono::system_clock::now()
                        .time_since_epoch()
                        .count();
    std::shuffle(std::begin(positions), std::end(positions), std::default_random_engine(seed));
    //std::cerr << positions[0][0] << ", " << positions[0][1] << ", " << positions[0][2] << std::endl;
  }

  unsigned int numPrims = static_cast<int>(positions.size());
  printf("Number of particles: %d \n", numPrims);

  //Create neighborhood search instance
  NeighborhoodSearch nsearch(radius);
  printf("Radius: %lf \n", radius);

  //Add point set from the test data
  auto pointSetIndex = nsearch.add_point_set(positions.front().data(), positions.size(), true, true);

  for (size_t i = 0; i < 3; i++)
  {
    if (i != 0)
    {
      nsearch.z_sort();
      nsearch.point_set(pointSetIndex).sort_field((Real3*)nsearch.point_set(pointSetIndex).GetPoints());
    }

    Timing::reset();
    Timing::startTiming("Total time");
      nsearch.find_neighbors();
    Timing::stopTiming(true);
    Timing::printAverageTimes();
  }
}

int main(int argc, char* argv[])
{
#ifdef DEBUG
  std::cout << "Debug Build:" << std::endl;

  if(sizeof(Real) == 4)
    std::cout << "Real = float" << std::endl;
  else if (sizeof(Real) == 8)
    std::cout << "Real = double" << std::endl;
#endif

  int device_id = 1;
  cudaSetDevice(device_id);
  std::cerr << "\tUsing [" << device_id << "]: " << std::endl;

  std::string outfile;
  outfile = argv[1];
  radius = static_cast<Real>(std::stof(argv[2]));

  testCuNSearch(outfile.c_str());
  std::cout << "Finished Testing" << std::endl;
}
