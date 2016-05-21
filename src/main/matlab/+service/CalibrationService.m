classdef CalibrationService < handle
    
    properties
        entityManager
    end
    
    methods
        
        function obj = CalibrationService(rigName)
            h5Properties = which('calibration-h5properties.json');
            obj.entityManager =  io.mpa.persistence.createEntityManager(rigName, h5Properties);
        end
        
        function addEntity(obj, entity)
            obj.entityManager.persist(entity);
        end
        
        function intensityMeasure = getIntensityMeasurement(obj, led, date)
            intensityMeasure = entity.IntensityMeasurement(led);
            em  = obj.entityManager;
            
            if nargin < 2
                query = intensityMeasure.getAllCalibrationDate();
                dates = em.executeQuery(query);
                date = dates{1};
            end
            intensityMeasure.calibrationDate = date;
            em.find(intensityMeasure);
        end
    end
end

