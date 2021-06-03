%% Script to visualize the ndf json as table

location = fileparts(mfilename('fullpath'));

% print ndf wheel 1 as table
wheel1 = dir(fullfile(location, 'wheel1'));
data = {};
for i = 3 : length(wheel1)
    data{end + 1} = loadjson(fullfile(location, 'wheel1', wheel1(i).name));
end

wheel2 = dir(fullfile(location, 'wheel2'));
for i = 3 : length(wheel2)
    data{end + 1} = loadjson(fullfile(location, 'wheel2', wheel2(i).name));
end

ndfnames = cellfun(@(d) d.ndfName, data , 'UniformOutput', false)';
od = cellfun(@(d) d.opticalDensity, data , 'UniformOutput', false)';
calibrationDate = cellfun(@(d) d.calibrationDate, data , 'UniformOutput', false)';

% print ndf wheel as table
wheelData = table(ndfnames, od, calibrationDate)
