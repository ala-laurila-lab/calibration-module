function tableout = importIntensity(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   DATA = IMPORTFILE(FILE) reads data from the first worksheet in the
%   Microsoft Excel spreadsheet file named FILE and returns the data as a
%   table.
%
%   DATA = IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   IntensityMeasurements = importfile('IntensityMeasurements.xlsx','Sheet1',1,51);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2016/05/20 21:28:15

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 1;
    endRow = 51;
end

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:O%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:O%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[2,10,11,12,13,14,15]);
raw = raw(:,[3,4,5,6,7,8,9]);
dates = dates(:,1);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),dates); % Find non-numeric cells
dates(R) = {NaN}; % Replace non-numeric Excel dates with NaN

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% Create table
tableout = table;

%% Allocate imported array to column variable names
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
tableout.calibrationDate = datetime([dates{:,1}].', 'ConvertFrom', 'Excel', 'Format', 'MM/dd/yyyy');
tableout.ledType = cellVectors(:,1);
tableout.voltages = data(:,1);
tableout.power = data(:,2);
tableout.wavelength = data(:,3);
tableout.responsivity = data(:,4);
tableout.diameterX = data(:,5);
tableout.diameterY = data(:,6);
tableout.spotFocus = data(:,7);
tableout.Note = cellVectors(:,2);
tableout.voltages1 = cellVectors(:,3);
tableout.voltages2 = cellVectors(:,4);
tableout.voltages3 = cellVectors(:,5);
tableout.voltages4 = cellVectors(:,6);
tableout.voltages5 = cellVectors(:,7);

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% tableout.calibrationDate=datenum(tableout.calibrationDate);

