%% Script to visualize the non linearity json

% Replace this with actual file name present in the same directory as readme
NON_LINEARITY_FILE_NAME = 'x08_Jun_202115_45_56-non-linearity.json';

%Load a json file to structure
location = fileparts(mfilename('fullpath'));
nonLinearity  = loadjson([location filesep NON_LINEARITY_FILE_NAME]);

% Create ideal linear gamma vector.
linear = linspace(0, 1, length(nonLinearity.ledCurrent));

h = figure('Name', 'Gamma', 'NumberTitle', 'off');
a = axes(h);
plot(a, nonLinearity.ledCurrent, nonLinearity.normalizedMeasurements, '.', nonLinearity.ledCurrent, linear, '-');
legend(a, 'Measurements', 'Ideal');
title(a, 'Gamma');
set(a, ...
    'FontUnits', get(h, 'DefaultUicontrolFontUnits'), ...
    'FontName', get(h, 'DefaultUicontrolFontName'), ...
    'FontSize', get(h, 'DefaultUicontrolFontSize'));
xlabel(a, 'Led input')
ylabel(a, 'Normalized power')