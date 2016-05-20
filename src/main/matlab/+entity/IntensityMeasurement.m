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
        Note
        % Table
        voltages
        voltageExponent
        power
        powerExponent
    end
    
    methods
        
        function obj = IntensityMeasurement(ledType)
            obj = obj@entity.Measurement(ledType, CalibrationPersistence.INTENSITY_MEASUREMENT);
            obj.ledType = ledType;
        end
    end
end

