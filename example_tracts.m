% Synthetic demonstration: no patient or reference-atlas data needed.
% Run this script, then open example.html in your browser.

% A family of curved tracks, in millimetres with RAS axes.
t = linspace(-1, 1, 100)';
reference = cell(1, 80);
for k = 1:numel(reference)
    angle = 2*pi*k/numel(reference);
    reference{k} = [65*t, ...
        -15 + 25*sin(angle) + 16*cos(pi*t/2), ...
        10 + 24*cos(angle) + 40*(1-t.^2)];
end

% A small spherical lesion, already in the same coordinate space.
centre = [24, 12, 62];
radius = 13;
[x, y, z] = meshgrid(linspace(-radius-1, radius+1, 25));
lesion = isosurface(x + centre(1), y + centre(2), z + centre(3), ...
    x.^2 + y.^2 + z.^2, radius^2);

% Mark curves with a sampled point inside the sphere, just for this example.
hit = cellfun(@(p) any(sum((p-centre).^2, 2) <= radius^2), reference);
output_file = fullfile(fileparts(mfilename('fullpath')), 'example.html');
plot_tracts(reference, reference(hit), lesion, output_file);
fprintf('Open in your browser: %s\n', output_file);
