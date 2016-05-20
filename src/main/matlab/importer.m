clc
clear;

s = service.CalibrationService('A');

json = loadjson(which('intensity.json')) ;
m = json.intensity{1};

for i = 8 : numel(m)
    
    e = entity.IntensityMeasurement(m{i}.ledType);
    
    d = sprintf('%d/%d/%d', m{i}.calibrationDate.Day, m{i}.calibrationDate.Month, m{i}.calibrationDate.Year);
    e.calibrationDate = datestr(datenum(d, 'dd/mm/yyyy'));
    
    e.wavelength = m{i}.wavelength;
    e.responsivity = m{i}.responsivity;
    e.diameterX = m{i}.diameterX;
    e.diameterY = m{i}.diameterY;
    e.spotFocus = m{i}.spotFocus;
    e.note = m{i}.Note;
    
    e.wavelengthExponent = 1e-9;
    e.diameterExponent = 1e-6;
    e.spotFocusExponent = 1e-6;
    
    e.voltages = [m{i}.voltages, -10, 0, 20, 40, 60];
    e.voltageExponent = 1e-3.*ones(6, 1);
    e.powers = [m{i}.power, str2double(m{i}.voltages1), str2double(m{i}.voltages2), str2double(m{i}.voltages3), str2double(m{i}.voltages4), str2double(m{i}.voltages5)];
    e.powerExponent = 1e-9.*ones(6, 1);
    
    s.addIntensityMeasurement(e);
end