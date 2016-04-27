cp = getClassPath();

% dependecies from git (or) math exchange
cd(cp.lib)
if ~ exist('mmockito', 'dir')
    git clone 'https://github.com/ragavsathish/mmockito.git'
end
if ~ exist('jsonlab', 'dir') && strcmp(scope, 'test')
    git clone 'https://github.com/fangq/jsonlab.git'
end
cd(cp.root)

% s = struct('rig', 'A', 'description', 'Patch Rig viikki', 'local_path', '', 'remotepath', '');
% s(2) = struct('rig', 'B', 'description', 'Suction Rig viikki', 'local_path', '', 'remotepath', '');
% s(3) = struct('rig', 'C', 'description', 'Patch Rig Aalto', 'local_path', '', 'remotepath', '');
% savejson('calibration_location',s, [cp.resources 'properties.json']);


