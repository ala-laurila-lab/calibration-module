classdef (Abstract) DynamicMeasurement < entity.Measurement & io.mpa.DynamicEntity
    
    methods
        function obj = DynamicMeasurement(ledType, persistenceId)
            obj = obj@io.mpa.DynamicEntity();
            obj = obj@entity.Measurement(ledType, persistenceId);
        end
        
        function updateFinalSchema(obj, ~ , ~)
            json = loadjson(obj.dynamicSchema);
            obj.finalSchema = json.schema;
            obj.setStructureFields(obj.finalSchema)
        end
        
        function prePersist(obj)
            obj.setDynamicSchema(obj.entityId.schema, obj.extendedStruct);
        end
        
        function [data, size] = toStructure(obj, schema)
            
            if ~ obj.isSchemaDynamic(schema)
                [data, size] = toStructure@io.mpa.H5Entity(obj, schema);
                return;
            end
            [data, size] = toStructure@io.mpa.H5Entity(obj, rmfield(schema, obj.structureFields));
            data = obj.mergeStructure(data);
        end
        
        function setQueryResponse(obj, rdata, schema)
            
            if ~ obj.isSchemaDynamic(schema)
                setQueryResponse@io.mpa.H5Entity(obj, rdata, schema);
                return;
            end
            
            setQueryResponse@io.mpa.H5Entity(obj, rdata, rmfield(schema, obj.structureFields));
            obj.mergeProperties(rdata);
        end
    end
end