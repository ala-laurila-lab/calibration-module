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
            emf = io.mpa.Persistence.getEntityManagerFactory(h5Properties);
            obj.entityManager = emf.create(rigName);     

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
                e.calibrationDate = dates(1);
            end
            
            key = e.key;
            
            if obj.useCache && isKey(obj.cache, key)
                e = obj.cache(key);
                return
            end
            
            em.find(e);
            
            if obj.useCache 
                obj.cache(key) = e;
            end
        end
        
        function map = getCalibrationDates(obj)
            map = containers.Map();
            em = obj.entityManager.entityMap;
            
            for key = em.keys()
                query = entity.Measurement.getAllCalibrationDate(em(key{:}));
                dates = obj.entityManager.executeQuery(query);
                map(key{:}) = dates;
            end
        end
    end
end