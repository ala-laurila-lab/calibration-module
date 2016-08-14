classdef LinearityMeasurement <  handle
    
    properties
        % attributes
        protocol
        calibrationDate
        stimulsDuration
        ledType
        % table
        voltages
        voltageExponent
        meanCharge
        stdOfCharge
        note
    end
    
    properties(SetAccess = private)
        monotonicVoltages
        charges
    end
    
    methods
        
        function obj = LinearityMeasurement(ledType, stimulsDuration)
            obj.protocol = [ledType '-' stimulsDuration];
            obj.ledType = ledType;
            obj.stimulsDuration = stimulsDuration;
        end
        
        function setChargeMap(obj)
            % setChargeMap - set charge map with non monotonic voltage
            %
            %   Due to effect of ndf there will be non monotonic points in C
            %   To avoid it, compare the difference in voltage(x) between
            %   adjacent point. If it is lesser than 1 remove those indices
            
            [v, indices] = unique(obj.voltages);
            charge = obj.meanCharge(indices);
            removeIdx = find(diff(v) < 1);
            retainIdx = setdiff(1 : length(v), removeIdx);
            obj.monotonicVoltages = v(retainIdx);
            obj.charges = charge(retainIdx);
        end
    end
end