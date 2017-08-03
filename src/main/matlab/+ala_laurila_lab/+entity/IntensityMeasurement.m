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
        stageFocus
        stageFocusExponent
    end
    properties
        ledInput
        ledInputExponent
        powers
        powerExponent
    end
    
    properties(Access = private)
        stimulusArea
    end
    
    properties(Constant)
        ERROR_MARGIN_PERCENT = 10
    end
    
    methods
        
        function obj = IntensityMeasurement(ledType)
            obj@ala_laurila_lab.entity.Measurement(ledType)
            obj.ledType = ledType;
        end
        
        function area = getStimulsArea(obj)
            
            if ~ isempty(obj.stimulusArea)
                area = obj.stimulusArea;
                return
            end
            
            diameter = (obj.diameterX + obj.diameterY) /2;
            radius = diameter / 2;
            area = pi *(radius * obj.diameterExponent) ^2;
        end
        
        function power = getPowerDensity(obj, ledInput, unit)
            
            if nargin < 3
                unit = 'default';
            end
            
            ledInput = ledInput * obj.toExponent(unit);
            ledInputs = obj.ledInput .* obj.ledInputExponent;
            i = find(ledInputs == ledInput);
            
            if isempty(i)
                error('intensity:ledInput:notfound', 'Intensity not found for given reference input');
            end
            power = obj.powers(i) * obj.powerExponent(i);
        end

        function p = getPowerPerUnitArea(obj)
            p = obj.getPowerDensity(obj.referenceInput) / obj.getStimulsArea();
        end
        
        function error = getError(obj, old)
             error = obj.errorPercentage(obj.getPowerDensity(old.referenceInput), ...
                 old.getPowerDensity(old.referenceInput));
        end
    end
end