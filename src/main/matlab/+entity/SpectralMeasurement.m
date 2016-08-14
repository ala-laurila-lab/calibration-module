classdef SpectralMeasurement < handle
    
    properties
        ledType
        calibrationDate
        note
        wavelength
        powerFor100mv
        powerFor1v
        powerFor5v
        powerFor9v
    end

    properties(Dependent)
        powerSpectrum
    end
    
    methods
        
        function obj = SpectralMeasurement(ledType)
            obj.ledType = ledType;
        end
        
        function addPowerSpectrum(obj, voltage, unit, data)
            field = strcat('powerFor', num2str(voltage), lower(unit));
            obj.(field) = data;
        end
        
        function [power, graph] = getPowerSpectrum(obj, voltage, unit)
            lambda = obj.wavelength;
            field = strcat('powerFor', num2str(voltage), lower(unit));
            power = obj.(field);
            power = util.angle_correction(power, lambda);
            [power, graph] = util.extrapolate_edges(power, lambda);
        end
    end
end