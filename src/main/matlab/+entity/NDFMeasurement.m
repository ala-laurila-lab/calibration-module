classdef NDFMeasurement < entity.Measurement
    
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
    
    methods
        
        function obj = NDFMeasurement(name)
            obj = obj@entity.Measurement(ledType, CalibrationPersistence.NDF_MEASUREMENT);
            obj.ndfName = name;
        end
    end
end

