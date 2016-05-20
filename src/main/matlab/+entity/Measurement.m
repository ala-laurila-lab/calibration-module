classdef (Abstract) Measurement < io.mpa.H5Entity
    
    properties
        group
        entityId
    end
    
    properties(SetAccess = private)
        keySetCache
    end
    
    properties(Abstract)
        calibrationDate
    end
    
    methods
        function obj = Measurement(identifier, entityId)
            obj = obj@io.mpa.H5Entity(identifier);
            obj.entityId = entityId;
        end
        
        function group = get.group(obj)
            group = [obj.entityId.toPath() obj.calibrationDate];
        end
        
        function queryHandle = getAllCalibrationDate(obj)
            queryHandle = @(name) resultSet(h5info(name, obj.entityId.toPath()));
            start = length(obj.entityId.toPath()) + 1;
            
            function dates = resultSet(info)
                dates = arrayfun(@(g) g.Name(start : end), info.Groups, 'UniformOutput', false);
                obj.keySetCache = dates;
            end
        end
    end
end

