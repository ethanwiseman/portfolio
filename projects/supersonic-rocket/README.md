# Supersonic Rocket Design and Analysis

[Back to portfolio](../../README.md)

**Project period:** March–August 2026  
**Tools:** SolidWorks, Ansys Fluent, Ansys Mechanical, Python

## Objective

Explore how aerodynamic loading, temperature, structural response, and mechanical integration influence a supersonic rocket concept.

## My work

- Developed a SolidWorks assembly for component placement and mechanical integration.
- Simplified and repaired CAD geometry and prepared fluid domains around the cone and tail for Mach 2 CFD in Ansys Fluent.
- Examined solver residuals and pressure and flow distributions.
- Performed transient thermal and stress analysis of steel components in Ansys Mechanical and used hand calculations to check simulation results.
- Created a Python flight-dynamics simulation with a basic PID controller.

## Findings

The analysis identified regions of elevated stress and high cone temperatures. These findings helped identify areas requiring further design investigation.

## Evidence and scope

This page summarizes completed simulation work. The supplied C++ aerodynamic lookup source is included below. CAD, solver files, Python flight-simulation source, and CFD result plots have not yet been added to this repository. No physical rocket testing, demonstrated service life, or experimentally validated flight performance is claimed.

## Next documentation additions

Add representative geometry, mesh and boundary-condition images, relevant solver settings, convergence history, numerical results with units, and the hand-calculation comparison. Include mesh and time-step sensitivity results if performed.

## Included C++ aerodynamic lookup

- [aero_model.cpp](src/aero_model.cpp): supplied source, preserved unchanged.
- [aero_model.h](src/aero_model.h): matching declarations added during portfolio packaging because the supplied header was missing.
- [example.cpp](src/example.cpp): small query example added during packaging.

The code linearly interpolates CD, CN, and Cm versus angle of attack in radians, with endpoint clamping outside −10° to 15°. Its Mach 2 development table is explicitly marked for replacement with Fluent-derived values. It has no Mach or pitch-rate input and is separate from the hypersonic MATLAB surrogate.

### Build and run

From this project folder, use a C++17 compiler:

```bash
mkdir -p build
g++ -std=c++17 -Wall -Wextra -pedantic src/aero_model.cpp src/example.cpp -o build/aero-example
./build/aero-example
```

Expected output:

```text
alpha=5 deg: CD=0.315, CN=0.185, Cm=-0.070
```

Compilation, interior interpolation, table values, and endpoint clamping were checked during repository preparation. This checks the lookup implementation, not the physical accuracy of the development coefficients.
