/** @file correctness.cpp
 * @brief Test the tree and tree traversal by running an instance
 * of the UnitKernel with random points and charges
 */
#include "UnitKernel.kern"
#include "ExpKernel.kern"
#include "fmmtl/KernelMatrix.hpp"
#include "fmmtl/Direct.hpp"
#include "fmmtl/numeric/random.hpp"

#include <ctime>

class timer {
public:
  timer() {
    start_time = 0;
    end_time = 0;
  }

  void tic(){
    start_time = clock();
  }

  void tic(char * c) {
    printf("%s\n",c);
    start_time = clock();
  }
  void toc() {
    end_time = clock();
    printf("Time since Tic:%f s\n", (end_time - start_time) / CLOCKS_PER_SEC);
  }

  void toc(char * c) {
    printf("%s\n", c);
    end_time = clock();
    printf("Time since Tic:%f s\n", (end_time - start_time) / CLOCKS_PER_SEC);
  }

  double start_time;
  double end_time;
};

int main(int argc, char **argv)
{
  timer tt;
  tt.tic();
  int N = 10000;  // num sources
  int M = N;  // num targets
  bool checkErrors = true;

  // Parse custom command line args
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i],"-N") == 0) {
      N = atoi(argv[++i]);
    } else if (strcmp(argv[i],"-M") == 0) {
      M = atoi(argv[++i]);
    } else if (strcmp(argv[i],"-nocheck") == 0) {
      checkErrors = false;
    }
  }

  // Init the FMM Kernel and options
  FMMOptions opts = get_options(argc, argv);
  //typedef UnitExpansion kernel_type;
  typedef ExpExpansion kernel_type;
  kernel_type K;

  typedef kernel_type::point_type point_type;
  typedef kernel_type::source_type source_type;
  typedef kernel_type::target_type target_type;
  typedef kernel_type::charge_type charge_type;
  typedef kernel_type::result_type result_type;

  tt.tic("make random source");
  // Init sources
  std::vector<source_type> sources = fmmtl::random_n(N);

  // Init charges
  std::vector<charge_type> charges = fmmtl::random_n(N);

  // Init targets
  std::vector<target_type> targets = fmmtl::random_n(M);
  tt.toc("end random source");
  // Build the FMM
  tt.tic("make_matrix_start");
  fmmtl::kernel_matrix<kernel_type> A{ K,targets, sources };
  tt.toc("make_matrix_end");
  A.set_options(opts);
  std::vector<result_type> result = A * charges;
  // Execute the FMM
  for (int i = 0;i < 5;i++) {
    tt.tic();
    result = A * charges;
    tt.toc();
  }
  

  tt.tic();
  // Check the result
  if (checkErrors) {
    std::cout << "Computing direct matvec..." << std::endl;

    std::vector<result_type> exact(M);

    // Compute the result with a direct matrix-vector multiplication
    fmmtl::direct(K, sources, charges, targets, exact);
    tt.toc();
    int wrong_results = 0;
    for (unsigned k = 0; k < result.size(); ++k) {
      if ((exact[k] - result[k]) / exact[k] > 1e-13) {
        std::cout << "[" << std::setw(log10(M)+1) << k << "]"
                  << " Exact: " << exact[k]
                  << ", FMM: " << result[k] << std::endl;
        std::cout << (exact[k] - result[k]) / exact[k] << std::endl;
        ++wrong_results;
      }
    }
    std::cout << "Wrong counts: " << wrong_results << " of " << M << std::endl;
  }
}
