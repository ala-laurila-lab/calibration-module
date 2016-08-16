classdef Measurement < handle
    
    properties
        id
        calibrationDate
        note
    end
    
    methods
        
        function obj = Measurement(id)
            obj.id = id;
        end
        
        function e = toExponent(obj, unit)
            unit = lower(unit);
            
            if hasString('milli')
                e = 1e-3;
            elseif hasString('macro')
                e = 1e-9;
            elseif hasString('nano')
                e = 1e-9;
            elseif hasString('pico')
                e = 1e-12;
            else
                e = 1;
            end
            
            function tf = hasString(str)
                tf = ~ isempty(strfind(unit, str));
            end
        end
        
        function e = errorPercentage(~, new, old)
            e = 0;
            if nargin < 3
                return;
            end
            e  = (abs(old - new) / old) * 100;
        end
    end
end