# Adding Supporting Project Files

[Back to portfolio](../README.md)

The project pages are ready to hold original engineering evidence. Place files under the corresponding project folder and link them from that project's README.

## Suggested organization

| Folder | Contents |
| --- | --- |
| `src/` | MATLAB, Python, or other source code |
| `models/` | Simulink models and manageable native model files |
| `drawings/` | CAD exports and dimensioned drawing PDFs |
| `figures/` | Assembly images, plots, contours, and build photos |
| `reports/` | Shareable papers and analysis summaries |
| `data/` | Small input datasets with units and provenance |

Create these folders when actual files are ready to add.

## Make each project reproducible

For executable work, document the required software version, entry-point file, inputs, units, and expected output. State assumptions and identify any data that cannot be distributed.

For simulation work, include geometry simplifications, material properties, boundary conditions, solver choices, mesh information, and the basis for checking the results.

For manufactured parts, show the relevant drawing, revision rationale, inspection evidence, and assembly behavior.

## Evidence to add first

1. **Hypersonic controls:** shareable paper, one representative response plot, and original MATLAB/Simulink files.
2. **Rocket analysis:** geometry view, pressure or temperature contour, and structural result with its setup.
3. **Air engine:** assembly image, drawing example, build photo, and an explained design revision.
4. **Numerical methods:** original rocket Euler script and an analytical comparison plot.

## Attribution and file size

Credit collaborators, libraries, and external data. Only upload materials you have permission to distribute, particularly employer files and coauthored research.

Keep large solver outputs and generated caches out of ordinary Git history. For large necessary assets, use an appropriate large-file workflow and provide instructions for obtaining them.
