path = which('test-symphony-persistence.xml');
service = ala_laurila_lab.service.CalibrationService('patch-rig-data', 'patch-rig-log', path);

json = loadjson(which('intensity.json')) ;
m = json.intensity{1};

for i = 8 : numel(m)
    
    e = ala_laurila_lab.entity.IntensityMeasurement(m{i}.ledType);
    
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
    e.voltageExponent = 1e-3.*ones(1, 6);
    e.powers = [m{i}.power, str2double(m{i}.voltages1), str2double(m{i}.voltages2), str2double(m{i}.voltages3), str2double(m{i}.voltages4), str2double(m{i}.voltages5)];
    e.powerExponent = 1e-6.*ones(1, 6);
    
    service.addIntensityMeasurement(e, 'ala-laurila-lab');
end

json = loadjson(which('linearity.json')) ;
m = json.linearity;


for i = 1 : numel(m)
    e = ala_laurila_lab.entity.LinearityMeasurement(['BlueLed_' m{i}.stimulsType]);
    e.stdOfCharge =  m{i}.Cstd;
    e.meanCharge = m{i}.Cmean;
    e.calibrationDate =  m{i}.calibrationDate;
    e.voltages = m{i}.V;
    e.voltageExponent = 1e-3.*ones(1, numel(m{i}.V));
    e.note = m{i}.Info;
    service.addLinearityMeasurement(e, 'ala-laurila-lab');
end

e = util.loadSpectralFile();
service.addSpectralMeasurement(e, 'ala-laurila-lab');

json = loadjson(which('ndf_21-Apr-2016.json')) ;
m = json.ndf{1};
ndf = m{1}.ndf;
index = 1;

e = ala_laurila_lab.entity.NDFMeasurement(ndf);    
e.calibrationDate = json.calibrationDate;
for i = 1 : numel(m)
    ndf = m{i}.ndf;
    
    if ~ strcmp(ndf, e.ndfName)
        service.addNDFMeasurement(e, 'ala-laurila-lab');
        e = ala_laurila_lab.entity.NDFMeasurement(ndf);    
        e.calibrationDate = json.calibrationDate;
        index = 1;
    end
    e.voltages(index) =  m{i}.voltages;
    e.voltageExponent(index) =  m{i}.voltageExponent;
    e.powers(index) =  m{i}.powers;
    e.powerExponent(index) =  m{i}.powerExponent;
    e.powerWithNdf(index) =  m{i}.powerWithNdf;
    e.powerWithNdfExponent(index) =  m{i}.powerWithNdfExponent;
    index = index + 1;
end
service.addNDFMeasurement(e, 'ala-laurila-lab');