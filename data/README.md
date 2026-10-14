# Demo tract data

`hcp842_sample.mat` contains `reference`, a **600 × 1 cell array** of streamline
coordinates. Each cell is an **N × 3 double array in MNI/RAS millimetres**.
These are population-atlas trajectories, not individual patient data.

## Source

The tracks are used from the **Lesion Quantification Toolkit (LQT)**, accessed
at [the HCP-842 source folder](https://github.com/jcgriffis/lesion_quantification_toolkit/tree/050bc257d686d7e7cba28262429e583bf5be7454/Support_Tools/Tractography_Atlas/HCP_842).
The original file is `all_tracts_1mm.trk.gz` (approximately 156 MB compressed).
It belongs to the **HCP-842 population-averaged tractography atlas** by Yeh and
colleagues. No LQT software is bundled or needed to run this example.

| Preparation | Detail |
| --- | --- |
| Source revision | `050bc257d686d7e7cba28262429e583bf5be7454` |
| Eligible tracks | 138,408; 37 single-point records excluded |
| Track selection | `round(linspace(1,138408,600))` in valid-record order |
| Point selection | Every fourth stored point, plus each track's final point |
| Coordinate conversion | `[x,y,z] = native .* [-1,-1,1] + [78,76,-50]` |
| Precision | Rounded to 0.1 mm for display |

The conversion uses the paired LQT HCP842 FIB's voxel-to-MNI transform. The
legacy TRK header omits its translation; no half-voxel shift is applied. The
original files are unchanged. [source.json](source.json) records hashes and
the exact original record indices.

`example_lesion.nii.gz` is a simulated **0/1 NIfTI mask** on a 182 × 218 × 182,
1-mm grid with RAS voxel-zero position (−90, −126, −72) mm. It marks voxel
centres within 12 mm of (21.5261657875, −15.5020301940, 28.1522769432) mm.
The centre comes from MATLAB `RandStream('mt19937ar', 'Seed', 7)` and the
expression `[20+20*rand(s), -35+25*rand(s), 15+30*rand(s)]`. There are 7,232
lesion voxels. This mask was generated mathematically; no patient data are used.

`example_tracts.m` passes this file to `plot_lesion`. The function transforms
the mask surface into world coordinates and checks which **display segments**
pass through its lesion voxels. These are illustrative intersections in a
600-track subsample, not full-atlas disconnection estimates. The HTML retains
the atlas credit. `plot_tracts` remains available for callers with prepared
track/mesh geometry; see its MATLAB help.

## Attribution and terms

The [atlas authors' data page](https://brain.labsolver.org/hcp_trk_atlas.html)
licenses HCP-842 tractography under
[Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
The atlas-derived sample, embedded demo geometry and preview adaptation are
distributed under the same licence; the
[WU-Minn HCP Open Access Data Use Terms](https://www.humanconnectome.org/study/hcp-young-adult/document/wu-minn-hcp-consortium-open-access-data-use-terms)
also apply. Retain the source credit and these links when sharing the data.
The viewer's **code** is separately MIT-licensed.

- **Atlas:** Yeh FC et al. (2018). *Population-averaged atlas of the macroscale
  human structural connectome and its network topology.* NeuroImage 178:57–68.
  [DOI: 10.1016/j.neuroimage.2018.05.027](https://doi.org/10.1016/j.neuroimage.2018.05.027)
- **Access through LQT:** Griffis JC et al. (2021). *Lesion Quantification
  Toolkit: A MATLAB software tool for estimating grey matter damage and white
  matter disconnections in patients with focal brain lesions.* NeuroImage:
  Clinical 30:102639.
  [DOI: 10.1016/j.nicl.2021.102639](https://doi.org/10.1016/j.nicl.2021.102639)

Data were provided by the Human Connectome Project, WU-Minn Consortium
(Principal Investigators: David Van Essen and Kamil Ugurbil; 1U54MH091657) funded
by the 16 NIH Institutes and Centers that support the NIH Blueprint for
Neuroscience Research; and by the McDonnell Center for Systems Neuroscience at
Washington University.
