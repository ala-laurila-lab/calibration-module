classdef IntensityMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        % Attributes
        ledType
        wavelength
        wavelengthExponent
        responsivity
        diameterX
        diameterY
        diameterExponent
        spotFocus
        spotFocusExponent
        % Table
        voltages
        voltageExponent
        powers
        powerExponent
    end
    
    properties(Access = private)
        ledArea
    end
    
    properties(Constant)
        ERROR_MARGIN_PERCENT = 20
    end
    
    methods
        
        function obj = IntensityMeasurement(ledType)
            obj@ala_laurila_lab.entity.Measurement(ledType)
            obj.ledType = ledType;
        end
        
        function area = getLedArea(obj)
            
            if ~ isempty(obj.ledArea)
                area = obj.ledArea;
                return
            end
            
            diameter = (obj.diameterX + obj.diameterY) /2;
            radius = diameter / 2;
            area = pi *(radius * obj.diameterExponent) ^2;
        end
        
        function power = getPowerDensity(obj, voltage, unit)
            voltage = voltage * obj.toExponent(unit);
            voltages = obj.voltages .* obj.voltageExponent;
            i = find(voltages == voltage);
            
            if isempty(i)
                error('intensity:voltage:notfound', 'Intensity not found for given reference voltage');
            end
            power = obj.powers(i) * obj.powerExponent(i);
        end
        
        function error = getError(obj, old)
             error = obj.errorPercentage(obj.getPowerDensity(1, 'volt'), ...
                 old.getPowerDensity(1, 'volt'));
        end
    end
end