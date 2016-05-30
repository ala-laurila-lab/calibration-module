classdef NDFMeasurement < entity.Measurement
    
    properties
        % group
        calibrationDate
        % identifier
        ndfName
        % table
        voltages
        voltageExponent
        powers
        powerExponent
        powerWithNdf
        powerWithNdfExponent
    end
    
    properties(SetAccess = private)
        meanTransmitance
        sdTransmitance
        opticalDensity
    end
    
    methods
        
        function obj = NDFMeasurement(name)
            obj = obj@entity.Measurement(name, CalibrationSchema.NDF_MEASUREMENT);
            obj.ndfName = name;
        end
        
        function postFind(obj)
            obj.calculateOpticalDensity();
        end
        
        function calculateOpticalDensity(obj)
            
            v = unique(obj.voltages);
            n = numel(v);
            obj.meanTransmitance = ones(1, n);
            obj.sdTransmitance = ones(1, n);
            
            for i = 1 : n
                indices = find(obj.voltages == v(i));
                powerNdf = obj.powerWithNdf(indices) .* obj.powerWithNdfExponent(indices);
                power = obj.powers(indices) .* obj.powerExponent(indices);
                obj.meanTransmitance(i) = mean(powerNdf ./ power);
                obj.sdTransmitance = std(powerNdf ./ power);
            end
            
            err = util.error_percentage(obj.meanTransmitance);
            if err > 3
                error('diff:larger:transmittance',...
                    ['mean transmittance for [' obj.ndfName '] seems to larger for desired and reference voltages with factor ' num2str(err)]);
            end           
            obj.opticalDensity = mean(-log10(obj.meanTransmitance));
        end
    end
end