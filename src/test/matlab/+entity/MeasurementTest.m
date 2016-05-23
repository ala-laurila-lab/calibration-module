classdef MeasurementTest < matlab.unittest.TestCase
    
    properties(Constant)
        ID = 'A'
        FILE_NAME = 'test.h5'
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
            if exist(fname, 'file')
                 delete(which(fname));
            end
            util.importer;
        end
    end
    
    methods(Test)
        
        function testCalibrationDates(obj)
            s = obj.calibrationService;
            map = s.getCalibrationDates();
        end
    end
end

