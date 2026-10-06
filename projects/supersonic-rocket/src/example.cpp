#include "aero_model.h"
#include <iomanip>
#include <iostream>

// Packaging example: query the supplied development table at five degrees.
int main() {
    constexpr double pi = 3.14159265358979323846;
    const AeroModel model;
    const auto coefficients = model.getCoefficients(5.0 * pi / 180.0);
    std::cout << std::fixed << std::setprecision(3)
              << "alpha=5 deg: CD=" << coefficients.CD
              << ", CN=" << coefficients.CN
              << ", Cm=" << coefficients.Cm << '\n';
}
