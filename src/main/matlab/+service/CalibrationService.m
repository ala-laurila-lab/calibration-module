classdef CalibrationService < handle
    
    properties
        entityManager
        cache
        useCache
    end
    
    methods
        
        function obj = CalibrationService(rigName, useCache)
            if nargin < 2
                useCache = 1;
            end
            h5Properties = which('calibration-h5properties.json');
            obj.entityManager =  io.mpa.persistence.createEntityManager(rigName, h5Properties);
            
            if useCache
                obj.cache = containers.Map();
            end
            obj.useCache = useCache;
        end
        
        function add(obj, entity)
            obj.entityManager.persist(entity);
        end
        
        function e = get(obj, e)
            em  = obj.entityManager;
            
            if isempty(e.calibrationDate)
                import entity.*;
                query = Measurement.getAllCalibrationDate(e.entityId);
                dates = em.executeQuery(query);
                e.calibrationDate = dates{1};
            end
            e.calibrationDate = date;
            key = [e.group '\' e.entityId];
            
            if obj.useCache && isKey(obj.cache, key)
                e = obj.cache(key);
                return
            end
            
            em.find(e);
            
            if obj.useCache 
                obj.cache(key, e);
            end
        end
        
        function map = getCalibrationDates(obj)
            map = containers.Map();
            [persistence, description] = enumeration('CalibrationPersistence');
            
            for i = 1 : numel(persistence)
                query = entity.Measurement.getAllCalibrationDate(persistence(i));
                dates = obj.entityManager.executeQuery(query);
                map(description{i}) = dates;
            end
        end
    end
end