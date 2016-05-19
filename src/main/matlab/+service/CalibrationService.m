classdef CalibrationService < handle
    
    properties
        entityManager;
    end
    
    methods
        
        function obj = CalibrationService(rigName)
            h5Properties = which('calibration-h5properties.json');
            obj.entityManager =  io.mpa.persistence.createEntityManager(rigName, h5Properties);
        end
        
        function addIntensityMeasurement(entity)
            em.persist(entity);
        end
        
        function getIntensityMeasurement()
        end
    end
    
end

