classdef LinearityMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        % attributes
        protocol
        stimulsDuration
        ledType
        stimulsSize
        % table
        ledInput
        ledInputExponent
        meanFlux
        stdOfFlux
    end
    
    properties(Access = protected)
        monotonicInput
        flux
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
        
        function [f, i] = getFluxAndInput(obj)
            
            %   Due to effect of ndf there will be non monotonic points in C
            %   To avoid it, compare the difference in voltage(x) between
            %   adjacent point. If it is lesser than 1 remove those indices
            
            if ~ isempty(obj.flux)
                i = obj.monotonicInput;
                f = obj.flux;
                return
            end
            
            [i, indices] = unique(obj.ledInput);
            uniqeFlux = obj.meanFlux(indices);
            removeIdx = find(diff(i) < 1);
            retainIdx = setdiff(1 : length(i), removeIdx);
            obj.monotonicInput = i(retainIdx) .* obj.ledInputExponent(retainIdx);
            obj.flux = uniqeFlux(retainIdx);
            
            i = obj.monotonicInput;
            f = obj.flux;
        end
        
        function flux = getFluxByInput(obj, input)
            import ala_laurila_lab.util.*;
            
            [f, i] = obj.getFluxAndInput();
            flux = interp1(f, i, input);
        end
        
        function error = getError(obj, old)
            error = obj.errorPercentage(obj.getFluxByInput(old.referenceInput), old.getFluxByInput(old.referenceInput));
        end
        
        function addLedInput(obj, ledInput, exponent)
            if nargin < 3
                exponent = 1;
            end
            obj.ledInput = [obj.ledInput, ledInput]; %# ok<AGROW>
            obj.ledInputExponent = [obj.ledInputExponent, exponent]; %# ok<AGROW>
        end
        
        function addFlux(obj, flux)
            obj.meanFlux = [obj.meanFlux, mean(flux)]; %# ok<AGROW>
            obj.stdOfFlux = [obj.stdOfFlux, std(flux)]; %# ok<AGROW>
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