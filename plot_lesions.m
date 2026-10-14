function figure_handle = plot_lesions(mask_files, output_folder)
%PLOT_LESIONS Make per-subject HTML viewers and an all-subject axial figure.
%   plot_lesions("mask_folder", "views") reads .nii / .nii.gz masks in that
%   folder, in alphabetical order. Alternatively, pass a string vector of
%   filenames to preserve your own order. Subfolders are not searched.
%   Saves <mask_name>.html for each mask and all_subjects.html / .png / .pdf.
%   The combined HTML embeds every subject, selectable from a dropdown.
%   All panels use the same MNI-mm scale and the plot_lesion colour scheme.
%   Returns the MATLAB figure, which remains open. Default folder: views.

arguments
    mask_files string
    output_folder (1,1) string = "views"
end

% Resolve the input list before creating any outputs.
assert(~isempty(mask_files) && isvector(mask_files) && ~any(ismissing(mask_files)), ...
    'Supply a mask folder or a vector of filenames.');
if isscalar(mask_files) && isfolder(mask_files)
    files = dir(mask_files);
    names = string({files.name});
    files = files(~[files.isdir] & endsWith(lower(names), [".nii", ".nii.gz"]));
    [~, order] = sort(lower(string({files.name})));
    files = files(order);
    mask_files = fullfile(string({files.folder}), string({files.name}));
end
mask_files = mask_files(:);
assert(~isempty(mask_files) && all(isfile(mask_files)), 'No masks found, or an input file is missing.');
assert(all(endsWith(lower(mask_files), [".nii", ".nii.gz"])), 'Use .nii or .nii.gz masks.');
[~, names, extensions] = fileparts(mask_files);
names = regexprep(names + extensions, '\.nii(\.gz)?$', '', 'ignorecase');
assert(numel(unique(lower(names))) == numel(names), ...
    'Mask filenames must be unique so subject HTML files cannot overwrite each other.');
assert(~any(strcmpi(names, 'all_subjects')), ...
    'Rename the mask named all_subjects; that filename is reserved for the combined report.');
assert(~ismissing(output_folder) && strlength(output_folder) > 0, 'Supply an output folder.');
if ~isfolder(output_folder), mkdir(output_folder); end

% Match the cohort's axial style, with a balanced grid up to eight columns.
n = numel(mask_files); columns = min(8, ceil(sqrt(n))); rows = ceil(n/columns);
labels = cellfun(@(name) regexp(name, '.{1,35}', 'match'), cellstr(names), 'UniformOutput', false);
label_lines = max(cellfun(@numel, labels));
background = [24 24 24]/255; grey = [175 175 175]/255;
orange = [245 160 96]/255; turquoise = [98 205 200]/255;
figure_handle = figure('Name', 'All subjects', 'NumberTitle', 'off', ...
    'Color', background, 'Units', 'inches', ...
    'Position', [.5 .5 max(6, 2.8*columns) (3.4+.15*label_lines)*rows+1.5]);
layout = tiledlayout(figure_handle, rows, columns, 'TileSpacing', 'compact', 'Padding', 'compact');
title(layout, 'Lesions in their structural context', 'Color', [.95 .95 .95], 'FontSize', 17);
subtitle(layout, 'Turquoise: lesion   |   Orange: intersecting tracks   |   Grey: reference', ...
    'Color', [.75 .75 .75], 'FontSize', 9);
axes_list = gobjects(n, 1);
subjects = cell(1, n);
% Start with the original MNI window, then expand for any outlying geometry.
low = [-82 -116 -75]; high = [82 83 95];
for k = 1:n
    [subject_file, g] = plot_lesion(mask_files(k), fullfile(output_folder, names(k) + ".html"));
    subjects{k} = struct('name', names(k), 'html', fileread(subject_file));
    ax = nexttile(layout); axes_list(k) = ax; hold(ax, 'on');
    for layer = ["reference", "affected"]
        curves = g.(layer);
        if isempty(curves), continue; end
        pieces = cellfun(@(p) [p; nan(1,3)], curves, 'UniformOutput', false);
        points = vertcat(pieces{:});
        color = [grey .22];
        if layer == "affected", color = [orange .85]; end
        plot3(ax, points(:,1), points(:,2), points(:,3), 'Color', color, 'LineWidth', .3);
        finite = points(all(isfinite(points),2), :);
        low = min(low, min(finite,[],1)-4); high = max(high, max(finite,[],1)+4);
    end
    patch(ax, 'Vertices', g.lesion.vertices, 'Faces', g.lesion.faces, ...
        'FaceColor', turquoise, 'FaceAlpha', .38, 'EdgeColor', 'none');
    low = min(low, min(g.lesion.vertices,[],1)-4);
    high = max(high, max(g.lesion.vertices,[],1)+4);
    view(ax, 0, 90); daspect(ax, [1 1 1]); axis(ax, 'off');
    ax.SortMethod = 'childorder'; ax.Projection = 'orthographic';
    label = repmat({''}, 1, label_lines+1);
    label(1:numel(labels{k})) = labels{k};
    label{end} = sprintf('%d / %d display tracks', numel(g.affected), numel(g.reference));
    title(ax, label, 'Interpreter', 'none', 'Color', [.94 .94 .94], 'FontSize', 9);
    fprintf('%d/%d: %s\n', k, n, names(k));
end
write_report(subjects, fullfile(output_folder, 'all_subjects.html'));

% One scale for every subject; R is on the right and A is at the top.
for ax = axes_list'
    xlim(ax, [low(1) high(1)]); ylim(ax, [low(2) high(2)]); zlim(ax, [low(3) high(3)]);
    x = mean([low(1) high(1)]); y = mean([low(2) high(2)]); z = high(3);
    text(ax, [x x low(1)+2 high(1)-2], [high(2)-2 low(2)+2 y y], z*ones(1,4), ...
        {'A','P','L','R'}, 'Color', grey, 'HorizontalAlignment', 'center', 'FontSize', 7);
end
xlabel(layout, {'Axial projection through all z; same MNI-mm scale. Display sample, not a full disconnection estimate.', ...
    'HCP-842 (Yeh et al., 2018), via LQT (Griffis et al., 2021). CC BY-SA 4.0 + HCP terms.', ...
    'Data credit: github.com/jvohryzek/tract-viewer/blob/main/data/README.md'}, ...
    'Interpreter', 'none', 'Color', [.7 .7 .7], 'FontSize', 7);
drawnow;
exportgraphics(figure_handle, fullfile(output_folder, 'all_subjects.png'), ...
    'Resolution', 200, 'BackgroundColor', background, 'Padding', 'figure');
exportgraphics(figure_handle, fullfile(output_folder, 'all_subjects.pdf'), ...
    'Resolution', 200, 'ContentType', 'image', 'BackgroundColor', background, 'Padding', 'figure');
fprintf('Saved subject viewers and all_subjects.html / .png / .pdf in %s\n', output_folder);
end

function write_report(subjects, output_file)
% Embed the existing pages so the dropdown report also works as one offline file.
template = fileread(fullfile(fileparts(mfilename('fullpath')), 'report.html'));
payload = strrep(jsonencode(subjects), '<', '\u003c'); % Keep HTML out of the JSON script tag.
page = strrep(template, '{{SUBJECTS}}', payload);
[fid, message] = fopen(output_file, 'w', 'n', 'UTF-8');
assert(fid >= 0, 'Cannot write output: %s', message);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s', page);
[message, code] = ferror(fid);
assert(code == 0, 'Could not finish writing output: %s', message);
end
