classdef MeasurementTest < matlab.unittest.TestCase
    
    properties
    end
    
    methods
        
        function obj = MeasurementTest()
            h5Properties = which('test-calibration-h5properties.json');
            obj.entityManager =  io.mpa.persistence.createEntityManager(obj.ID, h5Properties);
        end
    end
end

