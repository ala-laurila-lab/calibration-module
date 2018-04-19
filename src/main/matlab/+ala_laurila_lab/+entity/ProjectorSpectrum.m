classdef ProjectorSpectrum  < ala_laurila_lab.entity.SpectralMeasurement
    
    properties
        powerFor12LedCurrent50um
        powerFor12LedCurrent125um
        powerFor12LedCurrent250um
        powerFor12LedCurrent500um
        powerFor25LedCurrent500um
        powerFor100LedCurrent500um
        referenceSize
    end
    
    properties (Constant)
        REF_SPOT_DIAMETER = 500;
        REF_SPOT_LED_CURRENT = 12;
    end
    
    methods
        function obj = ProjectorSpectrum(ledType)
            obj@ala_laurila_lab.entity.SpectralMeasurement(ledType);
            obj.ledType = ledType;
            obj.referenceInput = obj.REF_SPOT_LED_CURRENT;
            obj.referenceSize = obj.REF_SPOT_DIAMETER;
        end
        
        function addPowerSpectrum(obj, ledCurrent, size, sizeUnit, data)
            field = obj.getProperty(ledCurrent, size, sizeUnit);
            obj.(field) = data;
        end
        
        function [power, graph] = getPowerSpectrum(obj, ledCurrent, size, sizeUnit)
            field = obj.getProperty(ledCurrent, size, sizeUnit);
            [power, graph] = getPowerSpectrum@ala_laurila_lab.entity.SpectralMeasurement(obj, field);
        end
        
        function spectrum = getNormalizedPowerSpectrum(obj)
            % To change the referenceInput, referenceSize, see util.loadSpectralFile
            field = obj.getProperty(obj.referenceInput, obj.referenceSize, 'um');
            spectrum = getNormalizedPowerSpectrum@ala_laurila_lab.entity.SpectralMeasurement(obj, field);
        end
    end
    
    methods (Access = private)
        function property = getProperty(obj, ledCurrent, size, sizeUnit)
            property = strcat('powerFor', num2str(ledCurrent), 'LedCurrent', num2str(size), sizeUnit);
        end
    end
end

