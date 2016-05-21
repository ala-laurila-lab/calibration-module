classdef LinearityMeasurement <  entity.Measurement
    
    properties
        % attributes
        calibrationDate
        stimulsType
        ledType
        % table
        voltages
        voltageExponent
        cmeans
        cstds
        info
    end
    
    methods
        
        function obj = LinearityMeasurement(ledType, stimulsType)
            id = [ledType '-' stimulsType];
            obj = obj@entity.Measurement(id, CalibrationPersistence.LINEARITY_MEASUREMENT);
            obj.ledType = ledType;
            obj.stimulsType = stimulsType;
        end
    end
end

