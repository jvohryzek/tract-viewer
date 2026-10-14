% Real HCP-842 atlas tracks from LQT; a randomly placed, simulated lesion.
% Run this script, then open docs/index.html. See data/README.md for credits.
folder = fileparts(mfilename('fullpath'));
sample = load(fullfile(folder, 'data', 'hcp842_sample.mat'), 'reference');
reference = sample.reference; % 600 display tracks in MNI/RAS millimetres.

% Fixed seed makes the demo reproducible; change it for another example.
stream = RandStream('mt19937ar', 'Seed', 7);
centre = [20 + 20*rand(stream), -35 + 25*rand(stream), 15 + 30*rand(stream)];
radius = 12;
[x, y, z] = meshgrid(linspace(-radius-1, radius+1, 25));
lesion = isosurface(x + centre(1), y + centre(2), z + centre(3), ...
    x.^2 + y.^2 + z.^2, radius^2);

% Highlight display curves whose line segments intersect the sphere.
hit = false(size(reference));
for k = 1:numel(reference)
    start = reference{k}(1:end-1, :);
    direction = diff(reference{k});
    t = sum((centre-start).*direction, 2) ./ max(sum(direction.^2, 2), eps);
    closest = start + max(0, min(1, t)).*direction;
    hit(k) = any(sum((closest-centre).^2, 2) <= radius^2);
end

output_file = fullfile(folder, 'docs', 'index.html');
plot_tracts(reference, reference(hit), lesion, output_file);

% Add the demo's source credit; the reusable plotting function stays generic.
page = fileread(output_file);
caption = fileread(fullfile(folder, 'demo_caption.html'));
caption = strrep(caption, '{{AFFECTED}}', num2str(nnz(hit)));
page = strrep(page, '<main class="viewer">', [caption newline '<main class="viewer">']);
fid = fopen(output_file, 'w', 'n', 'UTF-8');
assert(fid >= 0, 'Cannot write demo page.');
fprintf(fid, '%s', page);
fclose(fid);
fprintf('Open in your browser: %s\n', output_file);
