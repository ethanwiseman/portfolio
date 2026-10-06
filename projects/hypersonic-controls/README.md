# AI-Enhanced Control and Aerodynamic Optimization for Hypersonic Flight

[Back to portfolio](../../README.md)

**Authors:** Ethan A. Wiseman and Brian Lopez  
**Context:** AIAA student conference paper, published and presented  
**Tools:** MATLAB and Simulink

## Objective

Explore aerodynamic surrogate modeling and control-system integration for hypersonic flight, where nonlinear aerodynamic behavior, shock waves, heating, and coupled motion complicate analysis.

## My contribution

- Developed aerodynamic surrogate models for lift, drag, and pitching-moment coefficients.
- Integrated the surrogate into a Simulink model to evaluate coefficient and load responses.
- Examined step responses and developed a wind-screening decision tool using 20-second intervals.
- Addressed aeroelasticity, vibration, shock waves, and the implications of deformation for control behavior in the research.

## Modeling approach

Polynomial regression was used for aerodynamic coefficient surrogates; neural networks were considered as an alternative. The research also examined hybrid control approaches.

| Model variable | Reported range |
| --- | --- |
| Angle of attack, α | −5° to 20° |
| Mach number | 3 to 8 |
| Pitch rate, q | −2 to 2 rad/s |

The reported modeling range includes supersonic and hypersonic conditions. Here, q denotes pitch rate.

## Engineering reasoning

A surrogate approximates aerodynamic behavior in a form that can be integrated into a control simulation. Its usefulness depends on the underlying data and its accuracy across the intended operating range. Coefficient and load responses help connect the aerodynamic approximation to the simulated system behavior.

## Evidence and next additions

This page currently documents the project. Original model files and the paper are not included yet. Supporting material should include the shareable paper, MATLAB scripts, Simulink model, coefficient-response plots, fit-error metrics, and a description of the aerodynamic data source.

No flight-test validation or quantified improvement is claimed by this repository.
