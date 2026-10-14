<div align="center">

# Tract Viewer

**From MATLAB coordinates to an interactive brain view.**<br>
One plotting function. One self-contained HTML file.

[**Try the live demo ↗**](https://jvohryzek.github.io/tract-viewer/) · [Download current source](https://github.com/jvohryzek/tract-viewer/archive/refs/heads/main.zip) · [Input reference](#inputs)

MATLAB · WebGL + Canvas · No add-on toolboxes · Works offline

</div>

[![Real HCP-842 reference tracks in grey, tracks intersecting a simulated lesion in orange, and the lesion surface in turquoise. Click to explore the interactive demo.](docs/preview.png)](https://jvohryzek.github.io/tract-viewer/)

Grey **reference tracks**, orange **affected tracks**, and a turquoise **lesion
surface**. Rotate, zoom and switch anatomical views in your browser. The viewer
preserves the appearance of the original Padova Stroke report.

## Quick start

Download or clone the repository, open its folder in MATLAB, and run:

```matlab
example_tracts
```

Open `docs/index.html`, or [try the same demo online](https://jvohryzek.github.io/tract-viewer/).
It uses **600 real HCP-842 atlas tracks** and a **simulated spherical lesion**.
The random seed is fixed for reproducibility; change `Seed` in the example to
move the lesion. No patient lesion data are included.

With your own geometry:

```matlab
lesion = struct('vertices', vertices, 'faces', faces);
plot_tracts(reference, affected, lesion, "view.html");
```

Share `view.html` on its own. Data, styles and the renderer are embedded;
recipients need only a browser with JavaScript enabled.

## Inputs

```matlab
output_file = plot_tracts(reference, affected, lesion, "view.html");
```

| Input | MATLAB type | Dimensions | Contents |
| :--- | :--- | :--- | :--- |
| `reference` | Cell vector | `Kref × 1` or `1 × Kref` | Grey streamlines; each cell contains an `Ni × 3` numeric array |
| `affected` | Cell vector | `Kaff × 1` or `1 × Kaff` | Orange streamlines, supplied by the caller; same per-cell format |
| `lesion` | Scalar struct | `1 × 1` | Contains the two fields below |
| `lesion.vertices` | Numeric matrix | `M × 3` | Surface vertex coordinates, one `[x y z]` per row |
| `lesion.faces` | Numeric matrix of integer values | `F × 3` | Triangles: each row contains three **1-based** vertex indices in `1:M` |
| `output_file` | String scalar or character row | One filename | Optional `.html` / `.htm` path; defaults to `"tracts.html"` |

`Kref` / `Kaff` count tracks; `Ni` counts points in track `i` and may vary between
tracks; `M` counts vertices; `F` counts triangles. Each track needs **at least
two points**. Coordinates must be **real, finite, full numeric arrays**.

| Optional layer | Pass |
| :--- | :--- |
| No reference tracks | `{}` |
| No affected tracks | `{}` |
| No lesion surface | `struct('vertices', zeros(0,3), 'faces', zeros(0,3))` |

At least one layer must contain geometry. Reference tracks may include affected
tracks. The function does not calculate which tracks are affected. The output
directory must exist; an existing output file is overwritten. The return value
is the output filename as a string.

## Coordinates & orientation

All tracks and mesh vertices must already share **MNI/RAS world coordinates in
millimetres**. Every coordinate row is `[x y z]`.

| Column | Positive direction | Negative direction | Unit |
| :--- | :--- | :--- | :--- |
| `x` | Right — **R** | Left — **L** | mm |
| `y` | Anterior — **A** | Posterior — **P** | mm |
| `z` | Superior — **S** | Inferior — **I** | mm |

- Supply **world coordinates**, not voxel indices. Apply your image's affine
  first, respecting its indexing convention.
- For coordinates already in **LPS world space**, negate `x` and `y` to express
  them in RAS. A change of convention does not perform anatomical registration.
- The camera and direction markers retain the original **MNI-centred framing**.
  The axial preset shows left on the left, right on the right, and anterior up.
- All supplied coordinates are preserved. The function does no registration,
  resampling, streamline selection, or lesion-intersection estimation.

## Controls

| Action | Mouse / touch | Keyboard, with the canvas focused |
| :--- | :--- | :--- |
| Rotate | Drag | Arrow keys |
| Zoom | Scroll | `+` / `-` |
| Reset | **Reset view** | `Home` |
| Anatomical view | **View** menu | Tab to the menu |
| Reference layer | **Reference** checkbox | Tab, then Space |

## Small by design

| File | Purpose |
| :--- | :--- |
| [`plot_tracts.m`](plot_tracts.m) | The only plotting function: validate geometry and write HTML |
| [`viewer.html`](viewer.html) | Readable HTML/CSS/JavaScript template; keep beside the function |
| [`example_tracts.m`](example_tracts.m) | Load the small atlas sample and add a reproducible simulated lesion |
| [`demo_caption.html`](demo_caption.html) | Demo-only introduction and source attribution |
| [`data/`](data/) | Small tract sample, source record and data attribution |
| [`docs/`](docs/) | Generated GitHub Pages demo and README preview |

Base MATLAB, tested in **R2026a**. No Python, JavaScript packages or add-on
toolboxes are needed. MATLAB generates the file; plain JavaScript renders it.

For large tractograms, prepare a display subset before plotting. The original
report used 600 reference tracks, up to 1,800 affected tracks, simplified curves
and at most 8,000 lesion triangles. Those are practical display settings, not
API limits. Transparent overlays provide context rather than occlusion-accurate
volume rendering.

## Demo data & credit

The tracks are used from the **[Lesion Quantification Toolkit (LQT)](https://github.com/jcgriffis/lesion_quantification_toolkit)**,
accessed at **[this HCP-842 source folder](https://github.com/jcgriffis/lesion_quantification_toolkit/tree/050bc257d686d7e7cba28262429e583bf5be7454/Support_Tools/Tractography_Atlas/HCP_842)**.
The underlying population-averaged tractography atlas is by **Yeh et al. (2018)**.
The demo keeps 600 tracks and every fourth point plus the endpoint, rounded to
0.1 mm. Its orange layer shows intersections with the simulated sphere within
this display sample; it is not a full-atlas disconnection estimate.

| Component | Licence / terms |
| :--- | :--- |
| Viewer code | [MIT](LICENSE) |
| Atlas-derived demo data and preview | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and [WU-Minn HCP data-use terms](https://www.humanconnectome.org/study/hcp-young-adult/document/wu-minn-hcp-consortium-open-access-data-use-terms) |

See **[data provenance, citations and HCP acknowledgment](data/README.md)** for
the exact source and modifications. Generated HTML embeds all supplied
coordinates; retain the data credit when sharing this demo.

<details>
<summary>Validation & release history</summary>

MATLAB export and input checks were validated in R2026a. Isolated JavaScript
checks match the original report's WebGL/Canvas draw commands and controls.

[v0.1.0](https://github.com/jvohryzek/tract-viewer/releases/tag/v0.1.0) contains
the initial, entirely synthetic example. The current `main` branch and live
demo use real atlas tracks with a simulated lesion; the plotting API is unchanged.

</details>
