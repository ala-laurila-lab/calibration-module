function e = loadSpectralFile(filePath)

if nargin < 1
   filePath = 'src\test\resources\spectrum';
end

d = dir(filePath);
d = d(arrayfun(@(d) d.bytes ~= 0 ,d));


fname = d(1).name;
strings = strsplit(fname, '_');
ledType = strings{1};

date = strings{4};
date = [date(5:end -4) '/' date(3:4) '/20' date(1:2)];

e = ala_laurila_lab.entity.SpectralMeasurement(ledType);
e.calibrationDate = datestr(datenum(date, 'dd/mm/yyyy')); 

for i = 1 : numel(d)
    
    fid = fopen(fullfile(filePath, d(i).name), 'r');
    
    strings = strsplit(d(i).name, '_');
    voltage = str2double(strings{2});
    voltageUnit = strings{3};
    
    lines = textscan(fid, '%s %s', 'Delimiter', '\t');
    col1 = lines{1, 1};
    col2 = lines{1, 2};
    
    metaInformation = col1(1: 17);
    e.wavelength = str2double(col1(18 : end - 1)) * 1e-2;
    e.addPowerSpectrum(voltage, voltageUnit, str2double(col2(18 : end -1 )));
end
end