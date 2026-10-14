function output_file = plot_lesion(mask_file, output_file)
%PLOT_LESION View a binary MNI lesion mask with the bundled atlas tracks.
%   plot_lesion("lesion.nii.gz") writes lesion.html in the current folder.
%   Input: a 3-D 0/1 NIfTI mask already registered to FSL MNI152 space,
%   with a valid voxel-to-world transform in millimetres. Requires the
%   Image Processing Toolbox. No registration is performed.
%   Orange tracks intersect the mask within the 600-track display sample.

arguments
    mask_file (1,1) string
    output_file (1,1) string = "lesion.html"
end

% Read the mask and its spatial information; never change the input file.
assert(endsWith(lower(mask_file), [".nii", ".nii.gz"]), 'Use a .nii or .nii.gz mask.');
info = niftiinfo(mask_file);
assert(numel(info.ImageSize) == 3 && all(info.ImageSize >= 2), 'Use a 3-D mask.');
assert(strcmpi(info.SpaceUnits, 'Millimeter'), 'The NIfTI spatial units must be millimetres.');
assert(~strcmp(info.TransformName, 'None'), 'The mask needs a valid NIfTI sform or qform.');
T = double(info.Transform.T); % Zero-based voxel indices -> RAS world mm (row vectors).
assert(all(isfinite(T(:))) && rcond(T) > eps, 'Invalid voxel-to-world transform.');
mask = double(niftiread(info));
if isfinite(info.MultiplicativeScaling) && info.MultiplicativeScaling ~= 0
    mask = mask * info.MultiplicativeScaling + info.AdditiveOffset;
end
assert(all(mask(:) == 0 | mask(:) == 1) && any(mask(:) == 1), ...
    'Use a nonempty binary mask: 0 = background, 1 = lesion.');
mask = logical(mask);

% Pad with background so lesions touching the image edge have a closed surface.
padded = zeros(size(mask) + 2, 'single');
padded(2:end-1, 2:end-1, 2:end-1) = mask;
lesion = isosurface(permute(padded, [2 1 3]), 0.5);
xyz = [lesion.vertices - 2, ones(size(lesion.vertices, 1), 1)] * T;
lesion.vertices = xyz(:, 1:3);
if size(lesion.faces, 1) > 8000
    lesion = reducepatch(lesion, 8000);
end

% The small, bundled atlas is already in RAS world millimetres.
folder = fileparts(mfilename('fullpath'));
sample = load(fullfile(folder, 'data', 'hcp842_sample.mat'), 'reference');
reference = sample.reference;
hit = false(size(reference));
for k = 1:numel(reference)
    xyz = [reference{k}, ones(size(reference{k}, 1), 1)] / T;
    hit(k) = intersects_mask(xyz(:, 1:3) + 1, mask);
end
output_file = plot_tracts(reference, reference(hit), lesion, output_file);

% Keep the atlas credit with the self-contained HTML when it is shared.
page = fileread(output_file);
credit = fileread(fullfile(folder, 'data', 'credit.html'));
page = strrep(page, '</body>', [credit newline '</body>']);
[fid, message] = fopen(output_file, 'w', 'n', 'UTF-8');
assert(fid >= 0, 'Cannot write output: %s', message);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s', page);
[message, code] = ferror(fid);
assert(code == 0, 'Could not finish writing output: %s', message);
end

function hit = intersects_mask(points, mask)
% Split each line segment at voxel boundaries, then inspect each interval.
% This also finds lesions between the stored streamline points.
dim = size(mask);
hit = false;
for k = 1:size(points, 1)-1
    start = points(k, :);
    step = points(k+1, :) - start;
    cuts = [0; 1];
    for axis = 1:3
        if step(axis) == 0, continue; end
        low = max(0, ceil(min(points(k:k+1, axis)) - 0.5));
        high = min(dim(axis), floor(max(points(k:k+1, axis)) - 0.5));
        planes = (low:high)' + 0.5;
        cuts = [cuts; (planes - start(axis)) / step(axis)]; %#ok<AGROW>
    end
    cuts = unique(cuts(cuts >= 0 & cuts <= 1));
    t = [0; 1; (cuts(1:end-1) + cuts(2:end))/2];
    voxels = round(start + t .* step);
    voxels = voxels(all(voxels >= 1 & voxels <= dim, 2), :);
    if any(mask(sub2ind(dim, voxels(:,1), voxels(:,2), voxels(:,3))))
        hit = true;
        return;
    end
end
end
