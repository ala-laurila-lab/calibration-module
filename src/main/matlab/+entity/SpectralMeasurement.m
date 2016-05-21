classdef SpectralMeasurement < entity.DynamicMeasurement
    
    properties
        calibrationDate
        ledType
        wavelength
        powerSpectrum
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'power_in'
    end
    
    properties
        prefix
        extendedStruct
    end
    
    methods
        
        function obj = SpectralMeasurement(ledType)
            obj = obj@entity.DynamicMeasurement(ledType, CalibrationPersistence.SPECTRAL_MEASUREMENT);
            obj.ledType = ledType;
        end
               
        function addPowerSpectrum(obj, voltage, unit, data, dataUnit)
            field = strcat(dataUnit, '_for_', num2str(voltage), unit);
            obj.powerSpectrum.(field) = data;
        end
        
        function prefix = get.prefix(obj)
            prefix = obj.KEY_STRING_PREFIX;
        end
        
        function extendedStruct = get.extendedStruct(obj)
            extendedStruct = obj.powerSpectrum;
        end
    end
end

