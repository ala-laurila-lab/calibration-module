%% Script to visualize the ndf json as table

location = fileparts(mfilename('fullpath'));

% Load all the data

wheel1 = dir(fullfile(location, 'wheel1'));
data = {};
ndfMap = containers.Map();

for i = 3 : length(wheel1)
    data{end + 1} = loadjson(fullfile(location, 'wheel1', wheel1(i).name));
    ndfMap = ndf_data_util.addtoMap(ndfMap, data{end});
end

wheel2 = dir(fullfile(location, 'wheel2'));

for i = 3 : length(wheel2)
    data{end + 1} = loadjson(fullfile(location, 'wheel2', wheel2(i).name));
    ndfMap = ndf_data_util.addtoMap(ndfMap, data{end});
end

%% Table ndf wise
%
%       date         LedInput    powerWithNdf    PowerWithNdfExponent    powerWithoutNdf    powerWithoutNdfExponent
%   _____________    ________    ____________    ____________________    _______________    _______________________
%

% function handles
variables = {'ndf', 'date', 'LedInput', 'powerWithNdf', 'PowerWithNdfExponent', 'powerWithoutNdf', 'powerWithoutNdfExponent'};
toTable = @(d) table([d(:).ndf]', [d(:).calibrationDateArray]', [d(:).ledInput]', [d(:).powerWithNdf]', [d(:).powerWithNdfExponent]', [d(:).powers]', [d(:).powerExponent]', 'VariableNames', variables);

% Display ndf table
v = ndfMap.values;
toTable( [v{:}])


%% complete table
% 
%      ndfnames         od       calibrationDate
%    ____________    ________    _______________

ndfnames = cellfun(@(d) d.ndfName, data , 'UniformOutput', false)';
od = cellfun(@(d) d.opticalDensity, data , 'UniformOutput', false)';
calibrationDate = cellfun(@(d) d.calibrationDate, data , 'UniformOutput', false)';

% print ndf wheel as table
wheelData = table(ndfnames, od, calibrationDate)
