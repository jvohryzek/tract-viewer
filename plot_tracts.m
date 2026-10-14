function output_file = plot_tracts(reference, affected, lesion, output_file)
%PLOT_TRACTS Write an interactive, self-contained HTML tractogram viewer.
%   plot_tracts(reference, affected, lesion, "view.html")
%   reference, affected: cell vectors of N-by-3 streamline coordinates (N >= 2).
%   lesion: struct with M-by-3 vertices and F-by-3 triangular faces (1-based).
%   All coordinates must share MNI/RAS millimetres: +x right, +y anterior,
%   +z superior. Tracks are grey/orange; the lesion is turquoise.
%   Use {} for an empty track layer; empty vertices/faces omit the lesion.
%   No sampling, registration or lesion-intersection calculation is performed.
%   Open the result in a browser. Default output: tracts.html.

arguments
    reference cell
    affected cell
    lesion (1,1) struct
    output_file (1,1) string = "tracts.html"
end

% Validate before writing. Each curve keeps its original coordinates.
layers = {reference, affected};
for layer = 1:2
    curves = layers{layer};
    assert(isempty(curves) || isvector(curves), 'Track inputs must be cell vectors.');
    for k = 1:numel(curves)
        validateattributes(curves{k}, {'numeric'}, ...
            {'real', 'finite', 'nonsparse', '2d', 'ncols', 3});
        assert(size(curves{k}, 1) >= 2, 'Each track needs at least two points.');
    end
end
assert(all(isfield(lesion, {'vertices', 'faces'})), ...
    'Lesion must have vertices and faces fields.');
validateattributes(lesion.vertices, {'numeric'}, ...
    {'real', 'finite', 'nonsparse', '2d', 'ncols', 3});
validateattributes(lesion.faces, {'numeric'}, ...
    {'real', 'finite', 'nonsparse', '2d', 'ncols', 3, 'integer', 'positive'});
assert(all(lesion.faces(:) <= size(lesion.vertices, 1)), ...
    'Lesion faces must index existing vertices.');
assert(isempty(lesion.vertices) == isempty(lesion.faces), ...
    'To omit the lesion, both vertices and faces must be empty.');
assert(~isempty(reference) || ~isempty(affected) || ~isempty(lesion.faces), ...
    'Supply at least one track or a lesion surface.');
assert(strlength(output_file) > 0 && ~ismissing(output_file), 'Supply an output filename.');
[~, ~, extension] = fileparts(output_file);
assert(any(strcmpi(extension, {'.html', '.htm'})), 'Output must be an HTML file.');

% Cell rows preserve the outer JSON array even for a single vertex or face.
geometry.reference = reshape(reference, 1, []);
geometry.affected = reshape(affected, 1, []);
geometry.vertices = num2cell(double(lesion.vertices), 2);
geometry.faces = num2cell(double(lesion.faces) - 1, 2); % JavaScript is zero-based.
template = fileread(fullfile(fileparts(mfilename('fullpath')), 'viewer.html'));
page = strrep(template, '{{GEOMETRY}}', jsonencode(geometry));

% The generated page embeds all data, styles and JavaScript; no server needed.
[fid, message] = fopen(output_file, 'w', 'n', 'UTF-8');
assert(fid >= 0, 'Cannot write output: %s', message);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s', page);
[message, code] = ferror(fid);
assert(code == 0, 'Could not finish writing output: %s', message);
end
