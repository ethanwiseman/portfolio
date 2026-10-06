#include "aero_model.h"
#include <algorithm>
#include <stdexcept>

namespace {
    constexpr double DEG_TO_RAD = 3.14159265358979323846 / 180.0;
}

AeroModel::AeroModel() {
    // Development dataset for a Mach 2 fin-stabilized rocket.
    // Replace these with Fluent-derived values later.
    //
    // Important:
    // - alpha is in radians.
    // - CD is drag coefficient.
    // - CN is normal-force coefficient.
    // - Cm is pitching-moment coefficient about CG.
    //
    // Sign convention:
    // Positive alpha -> positive normal force.
    // Negative Cm slope means restoring static stability.
    alpha_rad_ = {
        -10.0 * DEG_TO_RAD,
        -5.0  * DEG_TO_RAD,
        -2.0  * DEG_TO_RAD,
         0.0  * DEG_TO_RAD,
         2.0  * DEG_TO_RAD,
         5.0  * DEG_TO_RAD,
         10.0 * DEG_TO_RAD,
         15.0 * DEG_TO_RAD
    };

    CD_ = {0.350, 0.315, 0.303, 0.300, 0.303, 0.315, 0.350, 0.420};
    CN_ = {-0.370, -0.185, -0.074, 0.000, 0.074, 0.185, 0.370, 0.555};
    Cm_ = {0.140, 0.070, 0.028, 0.000, -0.028, -0.070, -0.140, -0.210};
}

AeroCoefficients AeroModel::getCoefficients(double alpha_rad) const {
    AeroCoefficients coeffs;
    coeffs.CD = interpolate(alpha_rad_, CD_, alpha_rad);
    coeffs.CN = interpolate(alpha_rad_, CN_, alpha_rad);
    coeffs.Cm = interpolate(alpha_rad_, Cm_, alpha_rad);
    return coeffs;
}

double AeroModel::interpolate(const std::vector<double>& x,
                              const std::vector<double>& y,
                              double x_query) const {
    if (x.size() != y.size() || x.empty()) {
        throw std::runtime_error("Invalid interpolation table.");
    }

    // Clamp outside the table range.
    if (x_query <= x.front()) return y.front();
    if (x_query >= x.back()) return y.back();

    auto upper = std::upper_bound(x.begin(), x.end(), x_query);
    size_t i = static_cast<size_t>(upper - x.begin()) - 1;

    double x0 = x[i];
    double x1 = x[i + 1];
    double y0 = y[i];
    double y1 = y[i + 1];

    double t = (x_query - x0) / (x1 - x0);
    return y0 + t * (y1 - y0);
}
