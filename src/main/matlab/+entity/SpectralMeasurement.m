classdef SpectralMeasurement < entity.DynamicMeasurement
    
    properties
        calibrationDate
        ledType
        wavelength
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'powerSpectrum'
    end
    
    properties
        prefix
        extendedStruct
    end
    
    properties(Dependent)
        powerSpectrum
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
        
        function obj = set.powerSpectrum(obj, p)
            obj.extendedStruct = p;
        end
        
        function p = get.powerSpectrum(obj)
            p = obj.extendedStruct;
        end       
       
        function prefix = get.prefix(obj)
            prefix = obj.KEY_STRING_PREFIX;
        end
        
        function power = getPowerSpectrum(obj, voltage, unit, preProcess)
            if nargin < 4
                preProcess = 1;
            end
            lambda = obj.wavelength;
            field = strcat('for_', num2str(voltage), unit);
            power = obj.powerSpectrum.(field);
            power = util.angle_correction(power, lambda);
            
            if preProcess
                power = util.extrapolate_edges(power, lambda);
            end
        end
        
        function axes = compareSpectrumNoise(obj, voltage, unit)
            p = obj.getPowerSpectrum(voltage, unit);
            preProcess = false;
            pWithNoise = obj.getPowerSpectrum(voltage, unit, preProcess);
        end
    end
end