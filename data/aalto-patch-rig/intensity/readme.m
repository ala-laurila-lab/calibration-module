%% Script to visualize the ndf json as table

location = fileparts(mfilename('fullpath'));

% Load all the data

intensity = dir(fullfile(location, 'json'));
data = {};

for i = 3 : length(intensity)
    data{end + 1} = loadjson(fullfile(location,  'json', intensity(i).name));
end

%%  Intensity table
%                device                 ledType      spotSize    ledCurrent    calibratedBy    power    powerExponent
%    ______________________________    __________    ________    __________    ____________    _____    _____________


struct2table([data{:}])
