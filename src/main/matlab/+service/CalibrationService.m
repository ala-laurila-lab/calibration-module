classdef CalibrationService < handle
    
    properties(Access = private)
        dataManager
        logManager
    end
    
    methods
        
        function obj = CalibrationService(data, log)
            
            path = which('symphony-persistence.xml');
            obj.dataManager = mpa.factory.createEntityManager(data, path);
            obj.logManager = mpa.factory.createEntityManager(log, path);
        end
        
        function add(obj, entity, log)
            entity = obj.dataManager.persist(entity);
            log.id = entity.id;
            obj.logManager.persist(log);
        end
               
        function measurement = getLastMeasurement(obj, class, key)
            
            log = obj.logManager.createQuery('entity.AuditLog')...
                .where(@(e) strcmp(e.calibrationType, class) && strcmp(e.calibrationKey, key))...
                .LastOrDefault();
            constructor = str2func(class);
            measurement = constructor(log.calibrationId);
            measurement = obj.dataManager.find(measurement);
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