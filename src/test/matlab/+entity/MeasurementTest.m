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
        end
    end
    
    methods(Test)
        
        function testCalibrationDates(obj)
            s = obj.calibrationService;
            map = s.getCalibrationDates();
            actual = map(char(CalibrationSchema.LINEARITY_MEASUREMENT));
            obj.verifyEqual(datestr(actual), ['05-Dec-2015'; '31-Jan-2015']);
            e = entity.LinearityMeasurement('BlueLed', 'stim20ms');
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
                e = entity.NDFMeasurement(ndfs{i});
                actual = obj.calibrationService.get(e);
                obj.verifyEqual(actual.calibrationDate, expectedDate);
                obj.verifyEqual(actual.opticalDensity, ods(i));
            end
        end
    end
end

