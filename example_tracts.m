% Real atlas tracks with a simulated binary lesion mask; no patient data.
folder = fileparts(mfilename('fullpath'));
plot_lesion(fullfile(folder, 'data', 'example_lesion.nii.gz'), ...
    fullfile(folder, 'example.html'));
fprintf('Open in your browser: %s\n', fullfile(folder, 'example.html'));
