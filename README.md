<div align="center">

# Tract Viewer

**One lesion mask → an interactive tract view.**

[**Try it online ↗**](https://jvohryzek.github.io/tract-viewer/) · [Download](https://github.com/jvohryzek/tract-viewer/archive/refs/heads/main.zip)

</div>

[![Lesion in turquoise, intersecting tracks in orange, reference tracks in grey.](docs/preview.png)](https://jvohryzek.github.io/tract-viewer/)

## Use your own lesion

Download the repository, open its folder in MATLAB, and run:

```matlab
plot_lesion("my_lesion.nii.gz")
```

Open the generated **`lesion.html`** in your browser. Drag to rotate; scroll to
zoom. You can share this single HTML file. Requires MATLAB with **Image
Processing Toolbox** (tested in R2026a).

**You supply only the lesion mask.** The 600 reference tracks are included;
the function draws the lesion and highlights intersecting tracks for you.

| Mask requirement | What to provide |
| :--- | :--- |
| File | One **3-D NIfTI** volume, `.nii` or `.nii.gz` (a singleton fourth dimension is accepted) |
| Values | **0** = background, **1** = lesion; at least one lesion voxel |
| Space | Already registered to **FSL MNI152 / MNI152NLin6Asym** space |
| Dimensions | Any 3-D grid, e.g. `182 × 218 × 182` at 1 mm or `91 × 109 × 91` at 2 mm |
| Orientation | A valid NIfTI **sform or qform**, with spatial units in **millimetres**; axis order and flips are read from the header |

No manual flipping or mesh preparation is needed. The function does **not**
register native-space masks. Orange tracks belong to the small display sample;
this is a visualisation, not a full disconnection analysis.

## Several subjects

Put the lesion masks in one folder, then run:

```matlab
plot_lesions("lesion_masks", "views");
```

This opens an all-subject figure and saves **one named HTML viewer per mask**,
plus **`all_subjects.png` and `all_subjects.pdf`** in `views`. Subjects appear in
alphabetical filename order, with the same axial view and scale in every panel.

## Try the example

```matlab
example_tracts
```

Open `example.html`. It uses real atlas tracks and a bundled **simulated lesion
mask**, with no patient data. The same example is [live here](https://jvohryzek.github.io/tract-viewer/).

## Where the tracks come from

The **HCP-842 atlas** ([Yeh et al., 2018](https://doi.org/10.1016/j.neuroimage.2018.05.027))
was accessed through the **[Lesion Quantification Toolkit (LQT)](https://github.com/jcgriffis/lesion_quantification_toolkit)**:
**[toolbox paper](https://doi.org/10.1016/j.nicl.2021.102639)** · **[original tract folder](https://github.com/jcgriffis/lesion_quantification_toolkit/tree/050bc257d686d7e7cba28262429e583bf5be7454/Support_Tools/Tractography_Atlas/HCP_842)**.

Code: [MIT](LICENSE). Atlas data: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
and HCP terms. [Full attribution and data preparation](data/README.md).
