# Tract Viewer

A small MATLAB function that writes an interactive tractogram to one offline
HTML file. Grey reference tracks, orange affected tracks, and a turquoise lesion
surface. Extracted from the Padova Stroke report viewer, preserving its colours,
transparency, camera presets and controls.

## Try it

Download [v0.1.0](https://github.com/jvohryzek/tract-viewer/releases/tag/v0.1.0)
or clone this repository. Open the folder in MATLAB and run:

```matlab
example_tracts
```

Open the generated `example.html` in your browser. The example is entirely
synthetic. Share the HTML file on its own; recipients only need a browser with
JavaScript enabled.

To try it without MATLAB, download the ready-made
[synthetic example.html](https://github.com/jvohryzek/tract-viewer/releases/download/v0.1.0/example.html)
and open it locally in your browser.

## Use your own geometry

```matlab
% reference and affected: cell vectors of N-by-3 coordinate arrays.
% lesion.vertices: M-by-3 coordinates; lesion.faces: F-by-3 triangle indices.
plot_tracts(reference, affected, lesion, "view.html");
```

- Coordinates must already share **MNI/RAS millimetres**: +x right, +y anterior,
  +z superior. The viewer retains the original MNI-centred camera and direction
  markers. It does not register images or convert voxel coordinates.
- Each track needs at least two points. Lesion faces use MATLAB's **1-based**
  vertex indices. Values must be finite and real.
- Supply affected tracks yourself; the function only plots. A reference layer
  can include those tracks, as in the original report.
- Use `{}` for an empty track layer. To omit the lesion, use
  `struct('vertices', zeros(0,3), 'faces', zeros(0,3))`.
- At least one layer must contain geometry. The optional output filename
  defaults to `tracts.html`; an existing output file is overwritten.

All supplied coordinates are preserved. For responsive viewing, prepare a
display subset before calling the function. The original reports used 600
reference tracks, up to 1,800 affected tracks, simplified curves, and at most
8,000 lesion triangles. These are display settings, not limits on the API.

Drag to rotate, scroll to zoom, choose an anatomical view, or toggle Reference.
With the canvas focused, use arrow keys, `+` / `-`, and `Home` to reset.

## Files and requirements

- `plot_tracts.m` — validates the geometry and writes the HTML.
- `viewer.html` — the template with CSS and plain JavaScript/WebGL, plus a Canvas
  fallback. Keep it beside `plot_tracts.m`; open a generated HTML to see data.
- `example_tracts.m` — a short synthetic example using base MATLAB.

No MATLAB add-on toolboxes, Python, JavaScript packages, server, or internet
connection are required. The browser renderer uses transparent overlays for
visual context; it is not an occlusion-accurate volume renderer. No patient data,
atlas data, or tractography libraries are included.

Verified with MATLAB R2026a, including empty layers, single-triangle meshes and
invalid-input rejection. Isolated JavaScript checks match the original viewer's
draw commands for both renderers and all controls. Live browser appearance has
not been inspected for this extraction.

## Sharing

Version **0.1.0**, [MIT licence](LICENSE). The release includes the source and a
ready-to-open synthetic HTML example. Generated HTML embeds every supplied
coordinate, so share a synthetic example when publishing the toolbox.
The `.gitignore` excludes the generated example from source control.
