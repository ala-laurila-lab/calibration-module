classdef LinearityMeasurement <  io.mpa.H5Entity
    
    properties
        % group path
        calibrationDate
        % identifier
        stimulsType
        ledType
        % table
        voltages
        voltageExponent
        cmeans
        cstds
    end
    
    properties
        group
        entityId = CalibrationPersistence.LINEARITY_MEASUREMENT
    end
    
    methods
        
        function obj = Linearity(ledType, stimulsType)
            obj.ledType = ledType;
            obj.stimulsType = stimulsType;
            obj.identifier = [ledType '-' stimulsType];
        end
        
        function group = get.group(obj)
            group = [obj.entityId obj.calibrationDate];
        end
    end
end

