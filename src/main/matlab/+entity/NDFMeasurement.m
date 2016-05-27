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
            
            if n > 1
                diff = abs(obj.meanTransmitance(1) - obj.meanTransmitance(2));
                if diff > 0.1
                    error('diff:larger:transmittance',...
                        'mean transmitance seems to larger for desired and reference voltages');
                end
            end
            obj.opticalDensity = mean(-log10(obj.meanTransmitance));
        end
    end
end