path_to_scatnet = fileparts(mfilename('fullpath'));

addpath(fullfile(path_to_scatnet, 'classification'));
addpath(fullfile(path_to_scatnet, 'convolution'));
addpath(fullfile(path_to_scatnet, 'core'));
addpath(genpath(fullfile(path_to_scatnet, 'demo')));
addpath(fullfile(path_to_scatnet, 'display'));
addpath(fullfile(path_to_scatnet, 'filters'));
addpath(fullfile(path_to_scatnet, 'utils'));
addpath(genpath(fullfile(path_to_scatnet, 'papers')));
addpath(fullfile(path_to_scatnet, 'scatutils'));
addpath(genpath(fullfile(path_to_scatnet, 'unittest')));
addpath(fullfile(path_to_scatnet, 'utils'));

clear path_to_scatnet;

