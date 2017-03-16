function e = loadSpectralFile(filePath, deviceType)

d = dir(filePath);
directory = d(arrayfun(@(d) d.bytes ~= 0 ,d));


fname = directory(1).name;
str = strsplit(fname, '_');
ledType = str{1};

if strfind(deviceType, 'projector')
    e = createProjectorSpectrum();
else
    e = createLedSpectrum();
end


    function e = createLedSpectrum()
        e = ala_laurila_lab.entity.LEDSpectrum(ledType);
        
        for i = 1 : numel(directory)
            
            fid = fopen(fullfile(filePath, directory(i).name), 'r');
            
            strings = strsplit(directory(i).name, '_');
            voltage = str2double(strings{2});
            voltageUnit = strings{3};
            
            lines = textscan(fid, '%s %s', 'Delimiter', '\t');
            col1 = lines{1, 1};
            col2 = lines{1, 2};
            
            metaInformation = col1(1: 17); %#ok
            e.wavelength = str2double(col1(18 : end - 1)) * 1e-2;
            e.addPowerSpectrum(voltage, voltageUnit, str2double(col2(18 : end -1 )));
            e.referenceInput = 1;
            
            date = strings{4};
            date = [date(5:end -4) '/' date(3:4) '/20' date(1:2)];
            e.calibrationDate = datestr(datenum(date, 'dd/mm/yyyy'));
        end
        
    end

    function e = createProjectorSpectrum()
        
        e = ala_laurila_lab.entity.ProjectorSpectrum(ledType);
        for i = 1 : numel(directory)
            
            fid = fopen(fullfile(filePath, directory(i).name), 'r');
            
            strings = strsplit(directory(i).name, '_');
            size = str2double(strings{2});
            pixel = strings{3};
            ledCurrent = str2double(strings{4});
            
            lines = textscan(fid, '%s %s', 'Delimiter', '\t');
            col1 = lines{1, 1};
            col2 = lines{1, 2};
            
            metaInformation = col1(1: 17); %#ok
            e.wavelength = str2double(col1(18 : end - 1)) * 1e-2;
            e.addPowerSpectrum(ledCurrent, size, pixel, str2double(col2(18 : end -1 )));
            e.referenceInput = 12;
            e.referenceSize = 500;
            
            date = strings{6};
            date = [date(5:end -4) '/' date(3:4) '/20' date(1:2)];
            e.calibrationDate = datestr(datenum(date, 'dd/mm/yyyy'));
        end
        
    end
end