<div align="center">

# Tract Viewer

**One lesion mask → an interactive tract view.**

[**Try it online ↗**](https://jvohryzek.github.io/tract-viewer/) · [Download v0.3.0](https://github.com/jvohryzek/tract-viewer/releases/download/v0.3.0/tract-viewer-v0.3.0.zip)

</div>

[![Lesion in turquoise, intersecting tracks in orange, reference tracks in grey.](docs/preview.png)](https://jvohryzek.github.io/tract-viewer/)

## Setup

Requires **MATLAB with Image Processing Toolbox** (tested in R2026a).
You supply the lesion masks; **600 reference tracks are included**.

1. Create a folder called `lesion_visualisation`, with a `lesions` subfolder.
   Put one mask per subject there, using the format below.
2. [Download the toolbox ZIP](https://github.com/jvohryzek/tract-viewer/releases/download/v0.3.0/tract-viewer-v0.3.0.zip)
   and unzip it into `lesion_visualisation`:

   ```text
   lesion_visualisation/
   ├── lesions/
   │   ├── subject_01.nii.gz
   │   └── subject_02.nii.gz
   └── tract-viewer/
       └── ...toolbox files
   ```

3. In MATLAB, set **Current Folder** to `lesion_visualisation`, then run:

   ```matlab
   addpath("tract-viewer");
   plot_lesions("lesions", "results");
   ```

4. Open **`results/all_subjects.html`** and choose a subject from the dropdown.
   This single file contains every interactive view and can be shared on its own.
   Individual views remain in `results/subject_01.html`, etc. The **group figure**
   opens in MATLAB and is saved as `results/all_subjects.png` and `.pdf`.

Subjects follow alphabetical filename order, with the same axial scale in each
group panel. Drag the HTML views to rotate; scroll to zoom.

Each individual HTML also shows **lesion volume (mL)**, voxel count, and
**intersecting display tracks (count and % of the 600-track sample)**.
Volume is measured from the supplied MNI mask; track counts are not full-atlas
disconnection estimates.

For an **individual PNG/PDF** too, run one mask separately:

```matlab
plot_lesions("lesions/subject_01.nii.gz", "results/subject_01");
```

Its single-subject figure is saved as `all_subjects.png` / `.pdf` in that subfolder.

To try the two bundled simulated lesions, run `example_tracts` and open
`tract-viewer/views/all_subjects.html`, or [try it online](https://jvohryzek.github.io/tract-viewer/).

## Mask format

| Mask requirement | What to provide |
| :--- | :--- |
| File | One **3-D NIfTI** volume, `.nii` or `.nii.gz` (a singleton fourth dimension is accepted) |
| Values | **0** = background, **1** = lesion; at least one lesion voxel |
| Space | Already registered to **FSL MNI152 / MNI152NLin6Asym** space |
| Dimensions | Any 3-D grid, e.g. `182 × 218 × 182` at 1 mm or `91 × 109 × 91` at 2 mm |
| Orientation | A valid NIfTI **sform or qform**, with spatial units in **millimetres**; axis order and flips are read from the header |

No manual flipping or mesh preparation is needed. Native-space masks must be
registered beforehand. Orange tracks show intersections in the display sample;
this is a visualisation, not a full disconnection analysis.

## Where the tracks come from

The **HCP-842 atlas** ([Yeh et al., 2018](https://doi.org/10.1016/j.neuroimage.2018.05.027))
was accessed through the **[Lesion Quantification Toolkit (LQT)](https://github.com/jcgriffis/lesion_quantification_toolkit)**:
**[toolbox paper](https://doi.org/10.1016/j.nicl.2021.102639)** · **[original tract folder](https://github.com/jcgriffis/lesion_quantification_toolkit/tree/050bc257d686d7e7cba28262429e583bf5be7454/Support_Tools/Tractography_Atlas/HCP_842)**.

Code: [MIT](LICENSE). Atlas data: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
and HCP terms. [Full attribution and data preparation](data/README.md).

## Creators

- **Jakub Vohryzek** — [jakub.vohryzek@upf.edu](mailto:jakub.vohryzek@upf.edu)
- **Yonatan Sanz Perl** — [yonatan.sanz@upf.edu](mailto:yonatan.sanz@upf.edu)
