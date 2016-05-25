classdef (Abstract) Measurement < io.mpa.H5Entity
    
    properties
        group
        entityId
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
    end
    
    methods(Static)
        
        function queryHandle = getAllCalibrationDate(persistenceId)
            queryHandle = @(name) resultSet(h5info(name, persistenceId.toPath()));
            start = length(persistenceId.toPath()) + 1;
            
            function dates = resultSet(info)
                dates = arrayfun(@(g) g.Name(start : end), info.Groups, 'UniformOutput', false);
            end
        end
    end
end

