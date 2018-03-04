
#include "fmmtl/meta/kernel_traits.hpp"

// Skeleton Expansion
#include "KernelSkeleton.kern"

// Testing Expansions
#include "UnitKernel.kern"
#include "ExpKernel.kern"

// User Expansions
#include "LaplaceSpherical.hpp"
#include "LaplaceCartesian.hpp"
#include "YukawaCartesian.hpp"

#include <iostream>

template <class Expansion>
void test_expansion(const Expansion& E) {
  (void) E;
  std::cout << std::endl;
  std::cout << typeid(Expansion).name() << ":" << std::endl;
  std::cout << ExpansionTraits<Expansion>() << std::endl;
}

int main() {
  test_expansion(ExpansionSkeleton());

  test_expansion(UnitExpansion());
  test_expansion(ExpExpansion());

  test_expansion(LaplaceSpherical());
  test_expansion(LaplaceCartesian<5>());
  test_expansion(YukawaCartesian());
  return 0;
}
