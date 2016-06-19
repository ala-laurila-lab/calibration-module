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
    
    properties(SetAccess = private)
        ledArea;
    end
    
    methods
        
        function obj = IntensityMeasurement(ledType)
            obj = obj@entity.Measurement(ledType, CalibrationSchema.INTENSITY_MEASUREMENT);
            obj.ledType = ledType;
        end
        
        function obj = postFind(obj)
            obj.setLedArea();
        end
        
        function setLedArea(obj)
            diameter = (obj.diameterX + obj.diameterY) /2; 
            radius = diameter / 2;
            obj.ledArea = pi *(radius * obj.diameterExponent) ^2;
        end
        
        function power = getPowerDensity(obj, voltage)
            
            v = voltage / obj.voltageExponent(1);
            i = find(obj.voltages == v);
            
            if isempty(i)
                % throw exception
            end
            power = obj.powers(i) * obj.powerExponent(i);
        end
    end
end