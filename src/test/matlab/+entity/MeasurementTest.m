classdef MeasurementTest < matlab.unittest.TestCase
    
    properties(Constant)
        ID = 'A'
        FILE_NAME = 'test-calibration.h5'
    end
    
    properties
        calibrationService
    end
    
    methods
        
        function obj = MeasurementTest()
            obj.calibrationService = service.CalibrationService(obj.ID);
        end
    end
    
    methods (TestClassSetup)
        
        function createHDF5(~)
            fname = entity.MeasurementTest.FILE_NAME;
            if ~ exist(fname, 'file')
                util.importer;
            end
            close all;
        end
    end
    
    methods(Test)
        
        function testCalibrationDates(obj)
            s = obj.calibrationService;
            map = s.getCalibrationDates();
            actual = map(char(CalibrationSchema.LINEARITY_MEASUREMENT));
            obj.verifyEqual(datestr(actual), '05-Dec-2015');
            e = entity.LinearityMeasurement('BlueLed', '20-ms');
            actual = s.get(e);
            obj.verifyEqual(datestr(actual.calibrationDate), '05-Dec-2015');
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
                try
                    e = entity.NDFMeasurement(ndfs{i});
                    actual = obj.calibrationService.get(e);
                    obj.verifyEqual(actual.calibrationDate, expectedDate);
                    obj.verifyEqual(actual.opticalDensity, ods(i), 'RelTol', 1e-7,'diff exceeds relative tolerance');
                catch ME
                    disp(ME.message);
                end
            end
        end
        
        function testTransmitanceError(obj)
            e = entity.NDFMeasurement('dummy');
            e.voltages = [1, 1, 9, 9];
            e.powerWithNdf = [10, 10, 10.4, 10.4];
            e.powers = [1, 1, 1, 1];
            e.powerExponent = ones(1, 4);
            e.powerWithNdfExponent = ones(1, 4);
            obj.verifyError(@() e.calculateOpticalDensity(), 'diff:larger:transmittance');
        end
        
        function testSpectrumNoise(obj)
            e = entity.SpectralMeasurement('blue');
            actual = obj.calibrationService.get(e);
            [~, graph] = actual.getPowerSpectrum(1, 'V');
            a = axes();
            graph(a);
        end
        
        function testLinearityCurve(obj)
            s = obj.calibrationService;
            linearityFor20Ms = s.getLinearityByStimulsDuration(20 ,datenum('05-Dec-2015'), 'BlueLed');
            figure;
            a = axes();
            subplot(2, 2, 1, a);
            loglog(a, linearityFor20Ms.monotonicVoltages, linearityFor20Ms.charges, '*');
            hold on;
            loglog(a, linearityFor20Ms.voltages, linearityFor20Ms.meanCharge);
            hold off;
            xlabel(a, 'voltage in milli volts');
            ylabel(a, 'charge');
            title(a, 'Linearity curve for 20 ms');
            
            linearityFor1000Ms = s.getLinearityByStimulsDuration(1000 ,datenum('05-Dec-2015'), 'BlueLed');
            a = axes();
            subplot(2, 2, 2, a);
            loglog(a, linearityFor1000Ms.monotonicVoltages, linearityFor1000Ms.charges, '*');
            hold on;
            loglog(a, linearityFor1000Ms.voltages, linearityFor1000Ms.meanCharge);
            hold off;
            title(a, 'Linearity curve for 5000 ms');
         
            a = axes();
            subplot(2,2,[3,4], a);
            [x, y] = normalize(linearityFor20Ms.monotonicVoltages, linearityFor20Ms.charges);
            loglog(a, x, y, '*');
            
            hold on;
            [x, y] = normalize(linearityFor1000Ms.monotonicVoltages, linearityFor1000Ms.charges);
            loglog(a, x, y, 'o');
            title(a, 'Linearity curve normalized');
            
            function [x, y] = normalize(v, c)
                vref = util.get_nearest_match(v, 1000);
                cref = c(v == vref);
                y = c / cref;
                x = v;
            end
            
        end
        
        function testGetLinearityByStimulsDuration(obj)
            s = obj.calibrationService;
            actual = s.getLinearityByStimulsDuration(20 ,datenum('05-Dec-2015'), 'BlueLed');
            obj.verifyEqual(actual.stimulsType, '20-ms');
            
            handle = @() s.getLinearityByStimulsDuration(10 ,datenum('05-Dec-2015'), 'BlueLed');
            actual = obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsType, '20-ms');
            
            handle = @() s.getLinearityByStimulsDuration(1000 ,datenum('05-Dec-2015'), 'BlueLed');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsType, '5000-ms');
            
            handle = @() s.getLinearityByStimulsDuration(2500 ,datenum('05-Dec-2015'), 'BlueLed');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsType, '5000-ms');
            
            handle = @() s.getLinearityByStimulsDuration(6000 ,datenum('05-Dec-2015'), 'BlueLed');
            actual =  obj.verifyWarning(handle, 'stimuli:notfound');
            obj.verifyEqual(actual.stimulsType, '5000-ms');
           
        end
    end
end