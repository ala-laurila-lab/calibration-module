classdef SpectralMeasurement < entity.DynamicMeasurement
    
    properties
        calibrationDate
        ledType
        wavelength
        powerSpectrum
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'powerSpectrum'
    end
    
    properties
        prefix
        extendedStruct
    end
    
    methods
        
        function obj = SpectralMeasurement(ledType)
            obj = obj@entity.DynamicMeasurement(ledType, CalibrationSchema.SPECTRAL_MEASUREMENT);
            obj.ledType = ledType;
        end
               
        function addPowerSpectrum(obj, voltage, unit, data)
            field = strcat('for_', num2str(voltage), unit);
            obj.powerSpectrum.(field) = data;
        end
        
        function prefix = get.prefix(obj)
            prefix = obj.KEY_STRING_PREFIX;
        end
        
        function extendedStruct = get.extendedStruct(obj)
            extendedStruct = obj.powerSpectrum;
        end
        
        function power = normalizePower(obj, voltage, unit)
            lambda = obj.wavelength;
            d_lambda = diff(lambda);
            d_lambda(end + 1) = lambda(end);

            field = strcat('for_', num2str(voltage), unit);
            data = obj.powerSpectrum.(field);
            
            power = util.angle_correction(data, lambda);
            power = util.extrapolate_edges(power, lambda);
            power = data / sum(power .* d_lambda);
        end
    end
end