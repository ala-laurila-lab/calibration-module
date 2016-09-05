classdef LinearityMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        % attributes
        protocol
        stimulsDuration
        ledType
        % table
        voltages
        voltageExponent
        meanCharge
        stdOfCharge
    end
    
    properties(Access = private)
        monotonicVoltages
        charges
    end
    
    properties(Constant)
        ERROR_MARGIN_PERCENT = 5
    end
    
    methods
        
        function obj = LinearityMeasurement(protocol)
            obj@ala_laurila_lab.entity.Measurement(protocol);
            obj.protocol = protocol;
            
            substrings = strsplit(protocol, '_');
            obj.ledType = substrings{1};
            obj.stimulsDuration = [substrings{2:end}];
        end
        
        function [c, v] = getCharges(obj)
            
            % setChargeMap - set charge map with non monotonic voltage
            %
            %   Due to effect of ndf there will be non monotonic points in C
            %   To avoid it, compare the difference in voltage(x) between
            %   adjacent point. If it is lesser than 1 remove those indices
            
            if ~ isempty(obj.charges)
                v = obj.monotonicVoltages;
                c = obj.charges;
                return
            end
            
            [v, indices] = unique(obj.voltages);
            charge = obj.meanCharge(indices);
            removeIdx = find(diff(v) < 1);
            retainIdx = setdiff(1 : length(v), removeIdx);
            obj.monotonicVoltages = v(retainIdx) .* obj.voltageExponent(retainIdx);
            obj.charges = charge(retainIdx);
            
            v = obj.monotonicVoltages;
            c = obj.charges;
        end
        
        function charge = getChargeByVoltage(obj, voltage)
            import ala_laurila_lab.util.*;
            
            [c, v] = obj.getCharges();
            charge = interp1(v, c, voltage);
        end
        
        function error = getError(obj, old)
            import ala_laurila_lab.util.*;
            
            refVoltage = 1 * obj.toExponent('volt');
            error = obj.errorPercentage(obj.getReferenceCharge(refVoltage), old.getReferenceCharge(refVoltage));
        end
    end
    
    methods(Static)
        
        function [protocol, protocolIndex] = getSimilarProtocol(protocols, duration, ledType)
             import ala_laurila_lab.util.*;
             
            keys = struct('ledType', [], 'durations', []);
            
            for i = 1 : numel(protocols)
                substring = strsplit(protocols{i}, '_');
                keys(i).ledType = substring{1};
                keys(i).durations = str2double(substring(2));
            end
            
            if ~ ismember(ledType, {keys.ledType})
                error(['stimuli:empty:' ledType]', 'No stimuls found for given ledType');
            end
            durations = [keys.durations];
            [present, index] = ismember(durations, duration);
            
            if ~ present
                matchedDuration = get_nearest_match(durations, duration);
                index = durations == matchedDuration;
                warning('stimuli:notfound',...
                    ['No stimuls found for [' num2str(duration) '] nearest match is [' num2str(matchedDuration) ']']);
            end
            protocolIndex = find(index);
            protocol = protocols{protocolIndex};
        end
    end
end