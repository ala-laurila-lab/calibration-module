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
        powerWithNdf
        powerWithNdfExponent
    end
    
    methods
        
        function obj = NDFMeasurement(name)
            obj = obj@entity.Measurement(name, CalibrationPersistence.NDF_MEASUREMENT);
            obj.ndfName = name;
        end
    end
end

