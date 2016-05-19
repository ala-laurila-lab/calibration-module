classdef NDFMeasurement < io.mpa.H5Entity
    
    properties
        % group
        calibrationDate
        % identifier
        ndfName
        % table
        voltages
        voltageExponent
        powers
        powerExponent
        referenceVoltages
        referencePowers
        referencePowerExponent
    end
    
    properties
        group
        entityId = CalibrationPersistence.NDF_MEASUREMENT
    end
    
    methods
        
        function obj = NDF(name)
            obj.ndfName = name;
            obj.identifier = name;
        end
        
        function group = get.group(obj)
            group = [obj.entityId obj.calibrationDate];
        end
    end
end

