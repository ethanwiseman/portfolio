# Adding Supporting Project Files

[Back to portfolio](../README.md)

The research project includes original source, models, saved parameters, the paper, and a validation figure. The rocket project includes a C++ aerodynamic lookup and runnable example. Additional engineering evidence can be added to the corresponding project folders.

| Folder | Contents |
| --- | --- |
| `src/` | MATLAB, Python, or C++ source code |
| `models/` | Additional simulation models |
| `drawings/` | CAD exports and dimensioned drawing PDFs |
| `figures/` | Assembly images, plots, contours, and build photos |
| `reports/` | Shareable papers and analysis summaries |
| `data/` | Small input datasets with units and provenance |

Existing research files are kept together in their project folder so the MATLAB script can use its expected filenames.

## Add next

1. **Research:** coefficient/load step-response plots and a confirmed MATLAB/Simulink execution record.
2. **Rocket:** CAD views, boundary conditions, mesh details, CFD/structural plots, and original flight-simulation source.
3. **Air engine:** assembly photos, before-and-after drawing excerpts, ECNs, and inspection records.

For executable work, record software versions, inputs, units, entry points, and expected outputs. For simulation results, include setup assumptions and the basis for checking accuracy. Credit collaborators, libraries, and external data. Only include materials suitable for distribution.

Keep regenerable caches and large solver outputs out of ordinary Git history. Document how to obtain any necessary large assets.

See [import notes](IMPORT_NOTES.md) for file provenance and the [optional profile README](profile-README.md) for a GitHub profile introduction.
