% Real atlas tracks with two simulated lesion masks; no patient data.
folder = fileparts(mfilename('fullpath'));
masks = fullfile(folder, 'data', ["example_lesion.nii.gz", "example_lesion_2.nii.gz"]);
plot_lesions(masks, fullfile(folder, 'views'));
fprintf('Open in your browser: %s\n', fullfile(folder, 'views', 'all_subjects.html'));
