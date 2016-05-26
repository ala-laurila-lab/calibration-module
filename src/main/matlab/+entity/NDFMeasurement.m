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
            n = numel(uniqueVoltages);
            obj.meanTransmitance = ones(1, n);
            obj.sdTransmitance = ones(1, n);
            
            for i = 1 : n
                indices = find(obj.voltages, v(i));
                powerNdf = obj.powerWithNdf(indices) .* obj.powerWithNdfExponent(indices);
                power = obj.power(indices) .* obj.powerExponent(indices);
                obj.meanTransmitance(i) = mean(powerNdf/power);
                obj.sdTransmitance = std(powerNdf/power);
            end
            obj.opticalDensity = -log10(mean(obj.meanTransmitance));
        end
    end
end

