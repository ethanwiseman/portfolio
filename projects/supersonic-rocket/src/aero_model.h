#pragma once

#include <vector>

// Supporting declarations added when packaging the supplied aero_model.cpp.
struct AeroCoefficients {
    double CD;
    double CN;
    double Cm;
};

class AeroModel {
public:
    AeroModel();
    AeroCoefficients getCoefficients(double alpha_rad) const;

private:
    double interpolate(const std::vector<double>& x,
                       const std::vector<double>& y,
                       double x_query) const;
    std::vector<double> alpha_rad_;
    std::vector<double> CD_;
    std::vector<double> CN_;
    std::vector<double> Cm_;
};
