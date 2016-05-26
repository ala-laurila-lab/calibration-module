classdef LinearityMeasurement <  entity.Measurement
    
    properties
        % attributes
        calibrationDate
        stimulsType
        ledType
        % table
        voltages
        voltageExponent
        cmeans
        cstds
        info
    end
    
    properties(SetAccess = private)
        cValueMap;
    end
    
    methods
        
        function obj = LinearityMeasurement(ledType, stimulsType)
            id = [ledType '-' stimulsType];
            obj = obj@entity.Measurement(id, CalibrationSchema.LINEARITY_MEASUREMENT);
            obj.ledType = ledType;
            obj.stimulsType = stimulsType;
        end
        
        function postFind(obj)
            obj.setCValueMap();
        end
        
        function setCValueMap(obj)
            % To avoid non-monotonic point in C, avoid V less than 1mV
            % this is not the best way, but shouldn't cause a big problem
            
            [v, indices] = unique(obj.voltages);
            cmean = obj.cmeans(indices);
            removeIndices = find(diff(v) < 1);
            retainIndices = setdiff(1 : length(v), removeIndices);
            
            obj.cValueMap = containers.Map(v(retainIndices), cmean(retainIndices));
        end
    end
end