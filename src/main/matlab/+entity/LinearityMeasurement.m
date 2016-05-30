classdef LinearityMeasurement <  entity.Measurement
    
    properties
        % attributes
        calibrationDate
        stimulsType
        ledType
        % table
        voltages
        voltageExponent
        meanCharge
        stdOfCharge
        info
    end
    
    properties(SetAccess = private)
        monotonicVoltages
        charges
    end
    
    methods
        
        function obj = LinearityMeasurement(ledType, stimulsType)
            id = [ledType '-' stimulsType];
            obj = obj@entity.Measurement(id, CalibrationSchema.LINEARITY_MEASUREMENT);
            obj.ledType = ledType;
            obj.stimulsType = stimulsType;
        end
        
        function postFind(obj)
            obj.setChargeMap();
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
    
    methods(Static)
        
        function queryHandle = getAvailableStimuli(date)
            key =  [CalibrationSchema.LINEARITY_MEASUREMENT.toPath() '/' datestr(date)];
            queryHandle = @(name) resultSet(h5info(name, key));
            
            function result = resultSet(info)
                result = struct();
                for i = 1 : numel(info.Datasets)
                    id = info.Datasets(i).Name;
                    string = strsplit(id, '-');
                    result.ledTypes{i} = string{1};
                    result.durations(i) = str2double(string{2});
                end
            end
        end
    end
end