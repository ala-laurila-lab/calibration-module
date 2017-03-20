classdef CalibrationServiceTest < matlab.unittest.TestCase
    
    properties(Constant)
        FILE_NAME = 'test-calibration-module.h5'
        READ_MODE = false;
    end
    
    properties
        calibrationService
        fixture
    end
    
    methods
        
    end
    
    methods (TestClassSetup)
        
        function setFixture(obj)
            import ala_laurila_lab.*;
            
            obj.fixture = [fileparts(which('test.m')) filesep 'fixtures'];
            obj.calibrationService = createInstance();
            
            if obj.READ_MODE && exist(obj.fixture, 'file')
                return
            end
            
            if exist(obj.fixture, 'file')
                rmdir(obj.fixture, 's');
            end
            mkdir(obj.fixture);
            util.seed(obj.calibrationService);
            
            function instance = createInstance()
                config = struct();
                config.service.class = 'ala_laurila_lab.service.CalibrationService';
                config.service.dataPersistence = 'test-rig-data';
                config.service.logPersistence = 'test-rig-log';
                config.service.persistenceXml = which('test-symphony-persistence.xml');
                instance = mdepin.createApplication(config, 'service');
            end
        end
    end
    
    methods(Test)
        
        function testCalibrationDates(obj)
            service = obj.calibrationService;
            
            map = service.getAllCalibrationDate();
            obj.verifyEqual(sort(map.keys), sort({'ala_laurila_lab.entity.IntensityMeasurement',...
                'ala_laurila_lab.entity.LinearityMeasurement', 'ala_laurila_lab.entity.NDFMeasurement',...
                'ala_laurila_lab.entity.LEDSpectrum', 'ala_laurila_lab.entity.ProjectorSpectrum'}));
            
            obj.verifyEqual(sort(map.values), sort({'01-Mar-2017', '02-May-2016', '05-Dec-2015', '20-Apr-2016', '21-Apr-2016'}));
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.IntensityMeasurement');
            obj.verifyNumElements(dates, 41);
            obj.verifyEqual(dates{end}, '02-May-2016');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.LinearityMeasurement');
            obj.verifyNumElements(dates, 2);
            obj.verifyEqual(dates{end}, '05-Dec-2015');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.NDFMeasurement');
            obj.verifyNumElements(dates, 6);
            obj.verifyEqual(dates{end}, '20-Apr-2016');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.LEDSpectrum');
            obj.verifyNumElements(dates, 1);
            obj.verifyEqual(dates{end}, '21-Apr-2016');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.LinearityMeasurement', 'BlueLed_20_ms');
            obj.verifyNumElements(dates, 1);
            obj.verifyEqual(dates{end}, '05-Dec-2015');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.LinearityMeasurement', 'RedLed_20_ms');
            obj.verifyEmpty(dates);
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.ProjectorSpectrum');
            obj.verifyNumElements(dates, 1);
            obj.verifyEqual(dates{end}, '01-Mar-2017');
            
            dates = service.getCalibrationDate('ala_laurila_lab.entity.Unknown');
            obj.verifyEmpty(dates);
            
        end
        
        function testOpticalDensity(obj)
            % reference = https://www.dropbox.com/home/AlaLaurila-Lab-Yoda/Patch%20rig?preview=NDFcalibration.xlsx
            
            expectedDate = '20-Apr-2016';
            ndfs = {'A4B', 'A1A', 'A1.3A', 'A2A', 'A3A', 'A4A'};
            % ods for 9 and 1 volt respectively
            ods = [ mean([4.59665341, 4.59109566]),...
                mean([0.82483257, 0.82794391]),...
                mean([1.16784979,1.1660786]),...
                mean([2.17724647, 2.17552497]),...
                mean([3.46644209, 3.45976838]),...
                mean([4.33342836, 4.32983545]) ];
            
            for i = 1 : numel(ndfs)
                
                actual = obj.calibrationService.getNDFMeasurement(ndfs{i}, expectedDate);
                obj.verifyEqual(actual.calibrationDate, expectedDate);
                obj.verifyEqual(actual.opticalDensity, ods(i), 'RelTol', 1e-7, 'diff exceeds relative tolerance');
                
            end
        end
        
        function testSpectrumNoise(obj)
            actual = obj.calibrationService.getSpectralMeasurement('blue', 'led', '21-Apr-2016');
            [~, graph] = actual.getPowerSpectrum(1, 'V');
            figure;
            a = axes();
            graph(a);
            %fig2plotly();
            figure;
            date = obj.calibrationService.getLastCalibrationDate('ala_laurila_lab.entity.ProjectorSpectrum', 'BlueLed');
            actual = obj.calibrationService.getSpectralMeasurement('BlueLed', 'projector', date);
            [~, graph] = actual.getPowerSpectrum(12, 500, 'um');
            a = axes();
            graph(a);
        end
        
        function testLinearityCurve(obj)
            s = obj.calibrationService;
            linearityFor20Ms = s.getLinearityByStimulsDuration(20 , 'BlueLed', '05-Dec-2015');
            figure;
            a = axes();
            subplot(2, 2, 1, a);
            [c, v] = linearityFor20Ms.getFluxAndInput();
            loglog(a, v, c, '*');
            hold on;
            loglog(a, linearityFor20Ms.ledInput .* linearityFor20Ms.ledInputExponent, linearityFor20Ms.meanFlux);
            hold off;
            xlabel(a, 'voltage in milli volts');
            ylabel(a, 'charge');
            title(a, 'Linearity curve for 20 ms');
            
            linearityFor1000Ms = s.getLinearityByStimulsDuration(1000 , 'BlueLed', '05-Dec-2015');
            a = axes();
            subplot(2, 2, 2, a);
            [c, v] = linearityFor1000Ms.getFluxAndInput();
            loglog(a, v, c, '*');
            hold on;
            loglog(a, linearityFor1000Ms.ledInput .* linearityFor1000Ms.ledInputExponent, linearityFor1000Ms.meanFlux);
            hold off;
            title(a, 'Linearity curve for 5000 ms');
            
            figure;
            a = axes();
            [c, v] = linearityFor20Ms.getFluxAndInput();
            [x, y] = normalize(v, c);
            loglog(a, x, y, '*');
            
            hold on;
            [c, v] = linearityFor1000Ms.getFluxAndInput();
            [x, y] = normalize(v, c);
            loglog(a, x, y, 'o');
            title(a, 'Linearity curve normalized');
            %fig2plotly();
            
            function [x, y] = normalize(v, c)
                vref = ala_laurila_lab.util.get_nearest_match(v, 1000);
                cref = c(v == vref);
                y = c / cref;
                x = v;
            end
        end
        
        function testGetLinearityByStimulsDuration(obj)
            s = obj.calibrationService;
            actual = s.getLinearityByStimulsDuration(20, 'BlueLed', '05-Dec-2015');
            obj.verifyEqual(actual.stimulsDuration, '20ms');
            
            actual = s.getLinearityByStimulsDuration(20, 'BlueLed');
            obj.verifyEqual(actual.stimulsDuration, '20ms');
            
            handle = @() s.getLinearityByStimulsDuration(10, 'BlueLed', '05-Dec-2015');
            actual = obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsDuration, '20ms');
            
            handle = @() s.getLinearityByStimulsDuration(1000, 'BlueLed', '05-Dec-2015');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsDuration, '5000ms');
            
            handle = @() s.getLinearityByStimulsDuration(2500, 'BlueLed', '05-Dec-2015');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsDuration, '5000ms');
            
            handle = @() s.getLinearityByStimulsDuration(6000, 'BlueLed', '05-Dec-2015');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsDuration, '5000ms');
        end
        
        function testGetMeasurement(obj)
            expectedLastCalibrationDate = '15-Sep-2016';
            
            m = obj.calibrationService.getIntensityMeasurement('Blue');
            obj.verifyEqual(length(m), 41);
            obj.verifyEqual(m(end).calibrationDate, expectedLastCalibrationDate);
        end
        
        function testGetAuditLog(obj)
            log = obj.calibrationService.getAuditLog('ala_laurila_lab.entity.IntensityMeasurement');
            dateChar = {log(:).calibrationDate};
            obj.verifyTrue(issorted(datenum(dateChar)));

            handler = @()obj.calibrationService.getAuditLog('unknown');
            obj.verifyError(handler, 'query:tableempty'); 

            % compare date
            expectedLastCalibrationDate = '15-Sep-2016';            
            log = obj.calibrationService.getAuditLog('ala_laurila_lab.entity.IntensityMeasurement', 'date', expectedLastCalibrationDate);
            obj.verifyNumElements(log, 1);
            obj.verifyEqual(log.calibrationDate, expectedLastCalibrationDate);

            % compare calibrationKey
            log = obj.calibrationService.getAuditLog('ala_laurila_lab.entity.IntensityMeasurement', 'calibrationKey', 'Blue');
            obj.verifyEqual(log(end).calibrationKey, 'Blue');
        end
    end
end