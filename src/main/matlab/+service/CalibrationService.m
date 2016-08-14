classdef CalibrationService < handle
    
    properties
        entityManager
    end
    
    methods
        
        function obj = CalibrationService(rigName)
            
            path = which('symphony-persistence.xml');
            obj.entityManager = mpa.factory.createEntityManager(rigName, path);
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
        
        function e = getLinearityByStimulsDuration(obj, duration, date, ledType)
            import entity.*;
            
            query = LinearityMeasurement.getAvailableStimuli(date);
            result = obj.entityManager.executeQuery(query);
            
            idx = ismember(result.ledTypes, ledType);
            
            if sum(idx) == 0
                error(['stimuli:empty:' ledType]', 'No stimuls found for given ledType');
            end
            
            durations = sort(result.durations);
            issueWarning = false;
            matchedDuration = duration;
            
            if ~ ismember(duration, durations)
                issueWarning = true;
                matchedDuration = util.get_nearest_match(durations, duration);
            end
            stimulsType = [num2str(matchedDuration) '-ms'];
            e = LinearityMeasurement(ledType, stimulsType);
            e.calibrationDate = date;
            e = obj.get(e);
            
            if issueWarning
                warning('stimuli:notfound',...
                    ['No stimuls found for [' num2str(duration) '] nearest match is [' num2str(matchedDuration) ']']);
            end
        end
    end
end