classdef LEDSpectrum  < ala_laurila_lab.entity.SpectralMeasurement
    
    properties
        powerFor100mv
        powerFor1v
        powerFor5v
        powerFor9v
    end
    
    methods
        function obj = LEDSpectrum(ledType)
            obj@ala_laurila_lab.entity.SpectralMeasurement(ledType);
            obj.ledType = ledType;
        end
                
        function addPowerSpectrum(obj, input, unit, data)
            field = strcat('powerFor', num2str(input), lower(unit));
            obj.(field) = data;
        end
        
        function [power, graph] = getPowerSpectrum(obj, input, unit)
            field = strcat('powerFor', num2str(input), lower(unit));
            [power, graph] = getPowerSpectrum@ala_laurila_lab.entity.SpectralMeasurement(obj, field);
        end
        
        function spectrum = getNormalizedPowerSpectrum(obj)
            spectrum = getNormalizedPowerSpectrum@ala_laurila_lab.entity.SpectralMeasurement(obj, obj.reference, 'v');
        end
        
    end
end

