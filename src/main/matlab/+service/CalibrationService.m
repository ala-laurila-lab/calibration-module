classdef CalibrationService < handle
    
    properties
        entityManager
    end
    
    methods
        
        function obj = CalibrationService(rigName)
            h5Properties = which('calibration-h5properties.json');
            obj.entityManager =  io.mpa.persistence.createEntityManager(rigName, h5Properties);
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
            em.find(e);
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