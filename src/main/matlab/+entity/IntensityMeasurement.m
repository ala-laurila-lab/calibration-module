classdef IntensityMeasurement < entity.Measurement
    
    properties
        % Attributes
        calibrationDate
        ledType
        wavelength
        wavelengthExponent
        responsivity
        diameterX
        diameterY
        diameterExponent
        spotFocus
        spotFocusExponent
        note
        % Table
        voltages
        voltageExponent
        powers
        powerExponent
    end
    
    methods
        
        function obj = IntensityMeasurement(ledType)
            obj = obj@entity.Measurement(ledType, CalibrationPersistence.INTENSITY_MEASUREMENT);
            obj.ledType = ledType;
        end
        
        function area = getLedArea(obj)
            radius = (obj.diameterX + obj.diameterY) /2; 
            area = pi *(radius * obj.diameterExponent) ^2;
        end
    end
end

