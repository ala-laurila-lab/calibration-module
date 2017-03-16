classdef NDFMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        ndfName
        % table
        ledInput
        ledInputExponent
        powers
        powerExponent
        powerWithNdf
        powerWithNdfExponent
    end
    
    properties(Access = private)
        meanTransmitance
        sdTransmitance
    end
    
    properties(Dependent)
        opticalDensity
    end
        
    properties(Constant)
        ERROR_MARGIN_PERCENT = 5
    end
    
    methods
        
        function obj = NDFMeasurement(name)
            obj@ala_laurila_lab.entity.Measurement(name);
            obj.ndfName = name;
        end
        
        function t = getMeanTransmitances(obj)
            
            if ~ isempty(obj.meanTransmitance)
                t = obj.meanTransmitance;
                return
            end
            
            input = unique(obj.ledInput);
            n = numel(input);
            obj.meanTransmitance = ones(1, n);
            obj.sdTransmitance = ones(1, n);
            
            for i = 1 : n
                indices = find(obj.ledInput == input(i));
                powerNdf = obj.powerWithNdf(indices) .* obj.powerWithNdfExponent(indices);
                power = obj.powers(indices) .* obj.powerExponent(indices);
                obj.meanTransmitance(i) = mean(powerNdf ./ power);
                obj.sdTransmitance = std(powerNdf ./ power);
            end
            
            err = obj.errorPercentage(obj.meanTransmitance);
            if err > 3
                error('diff:larger:transmittance',...
                    ['mean transmittance for [' obj.ndfName ...
                    '] seems to larger for desired and reference input with factor ' num2str(err)]);
            end
            t = obj.meanTransmitance;
        end
        
        function od = get.opticalDensity(obj)
            od =  mean(-log10(obj.getMeanTransmitances()));
        end
        
        function error = getError(obj, old)
             error = obj.errorPercentage(obj.opticalDensity, old.opticalDensity);
        end
    end
end