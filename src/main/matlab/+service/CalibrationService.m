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
        
        function e = getLinearityByStimulsDuration(obj, duration, ledType, calibrationDate)
            
            if nargin < 4
                calibrationDate = [];
            end
            
            log = obj.getAuditLogByDate('entity.LinearityMeasurement', calibrationDate);
            
            keys = entity.LinearityMeasurement.getKey(log(:).calibrationKey);
            idx = ismember(keys.ledType, ledType);
            
            if sum(idx) == 0
                error(['stimuli:empty:' ledType]', 'No stimuls found for given ledType');
            end
            durations = sort(keys.durations);
            issueWarning = false;
            matchedDuration = duration;
            [present, index] = ismember(duration, durations);
            
            if ~ present
                issueWarning = true;
                [matchedDuration, index] = util.get_nearest_match(durations, duration);
            end
            
            e = obj.getMeasurement('entity.LinearityMeasurement', log(index).id);
            if issueWarning
                warning('stimuli:notfound',...
                    ['No stimuls found for [' num2str(duration) '] nearest match is [' num2str(matchedDuration) ']']);
            end
        end
        
        function add(obj, entity, log)
            entity = obj.dataManager.persist(entity);
            log.id = entity.id;
            obj.logManager.persist(log);
        end
        
        function measurement = getMeasurement(obj, entity, id)
            measurement = entity;
            
            if ischar(entity)
                constructor = str2func(entity);
                measurement = constructor();
            end
            measurement.id = id;
            measurement = obj.dataManager.find(measurement);
        end
        
        function log = getAuditLogByDate(obj, class, date)
            skipDate = isempty(date);
            
            log = obj.logManager.createQuery('entity.AuditLog')...
                .where(@(e) strcmp(e.calibrationType, class) && (strcmp(e.calibrationDate, key) || skipDate))...
                .toArray();
        end
        
        function log = getLastAuditLog(obj, class, key)
            skipKey = isempty(key);
            
            log = obj.logManager.createQuery('entity.AuditLog')...
                .where(@(e) strcmp(e.calibrationType, class) && (strcmp(e.calibrationKey, key) || skipKey))...
                .toArray();
        end
        
    end
end