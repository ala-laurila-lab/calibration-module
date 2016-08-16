classdef SpectralMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        ledType
        wavelength
        powerFor100mv
        powerFor1v
        powerFor5v
        powerFor9v
    end
    
    properties(Dependent)
        powerSpectrum
    end
        
    properties(Constant)
        ERROR_MARGIN_PERCENT = 5
    end
    
    methods
        
        function obj = SpectralMeasurement(ledType)
            obj@ala_laurila_lab.entity.Measurement(ledType);
            obj.ledType = ledType;
        end
        
        function addPowerSpectrum(obj, voltage, unit, data)
            field = strcat('powerFor', num2str(voltage), lower(unit));
            obj.(field) = data;
        end
        
        function [power, graph] = getPowerSpectrum(obj, voltage, unit)
            import ala_laurila_lab.*;
            
            lambda = obj.wavelength;
            field = strcat('powerFor', num2str(voltage), lower(unit));
            power = obj.(field);
            power = util.angle_correction(power, lambda);
            [power, graph] = util.extrapolate_edges(power, lambda);
        end
        
        function error = getError(obj, old)
            % TODO caluclate error
            disp('TODO calculater error')
            error = 1;
        end
    end
end