classdef IntensityMeasurement < io.mpa.H5Entity
    
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
    
    properties
        group
        entityId = CalibrationPersistence.INTENSITY_MEASUREMENT
    end
    
    methods
        
        function obj = Intensity(ledType)
            obj.ledType = ledType;
            obj.identifier = ledType;
        end
        
        function group = get.group(obj)
            group = [obj.entityId obj.calibrationDate];
        end
    end
end

