classdef CalibrationService < handle & mdepin.Bean
    
    properties
        dataPersistence
        logPersistence
        persistenceXml
    end
    
    properties(Access = private)
        dataManager
        logManager
    end
    
    methods
        
        function obj = CalibrationService(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function instance = get.dataManager(obj)
            if isempty(obj.dataManager)
                obj.dataManager = mpa.factory.createEntityManager(obj.dataPersistence, obj.persistenceXml);
            end
            instance = obj.dataManager;
        end
        
        function instance = get.logManager(obj)
            if isempty(obj.logManager)
                obj.logManager = mpa.factory.createEntityManager(obj.logPersistence, obj.persistenceXml);
            end
            instance = obj.logManager;
        end

        function delete(obj)
            if ~ isempty(obj.dataManager)
                obj.dataManager.close();
            end
            if ~ isempty(obj.dataManager)
                obj.logManager.close();
            end
            obj.dataManager = [];
            obj.logManager = [];
        end
    end
    
    methods
        
        function addLinearityMeasurement(obj, entity, calibratedBy)
            err = 0;
            errorMarigin = ala_laurila_lab.entity.LinearityMeasurement.ERROR_MARGIN_PERCENT;
            
            try
                old = obj.getLinearityMeasurement(entity.protocol);
                err = entity.getError(old(end));
            catch exception
                if ~ strcmp(exception.identifier, 'query:tableempty')
                    rethrow(exception)
                end
            end
            
            if err > errorMarigin
                error('LinearityMeasurement:error:toohigh', ['error margin compared to older measurement '...
                    num2str(errorMarigin) ' exceeds threshold']);
            end
            
            obj.add(entity, calibratedBy, err, []);
        end
        
        function addIntensityMeasurement(obj, entity, calibratedBy)
            err = 0;
            errorMarigin = ala_laurila_lab.entity.IntensityMeasurement.ERROR_MARGIN_PERCENT;
            
            try
                old = obj.getIntensityMeasurement(entity.ledType);
                err = entity.getError(old(end));
            catch exception
                if ~ strcmp(exception.identifier, 'query:tableempty')
                    rethrow(exception)
                end
            end
            
            if err > errorMarigin
                error('IntensityMeasurement:error:toohigh', ['error margin compared to older measurement = '...
                    num2str(err) ' exceeds threshold ' ]);
            end
            obj.add(entity, calibratedBy, err, []);
        end
        
        function addSpectralMeasurement(obj, entity, calibratedBy)
            err = 0;
            errorMarigin = ala_laurila_lab.entity.SpectralMeasurement.ERROR_MARGIN_PERCENT;
            
            try
                old = obj.getSpectralMeasurement(entity.ledType, class(entity));
                err = entity.getError(old(end));
            catch exception
                if ~ strcmp(exception.identifier, 'query:tableempty')
                    rethrow(exception)
                end
            end
            
            if err > errorMarigin
                error('SpectralMeasurement:error:toohigh', ['error margin compared to older measurement '...
                    num2str(errorMarigin) ' exceeds threshold ']);
            end
            obj.add(entity, calibratedBy, err, []);
        end
        
        function addNDFMeasurement(obj, entity, calibratedBy)
            err = 0;
            errorMarigin = ala_laurila_lab.entity.NDFMeasurement.ERROR_MARGIN_PERCENT;
            
            try
                old = obj.getNDFMeasurement(entity.ndfName);
                err = entity.getError(old(end));
            catch exception
                if ~ strcmp(exception.identifier, 'query:tableempty')
                    rethrow(exception)
                end
            end
            
            if err > errorMarigin
                error('NDFMeasurement:error:toohigh', ['error margin compared to older measurement '...
                    num2str(errorMarigin) ' exceeds threshold ']);
            end
            obj.add(entity, calibratedBy, err, []);
        end
        
        function m = getLinearityMeasurement(obj, protocol, calibrationDate)
            CLASS = 'ala_laurila_lab.entity.LinearityMeasurement';
            import ala_laurila_lab.entity.*;

            if nargin < 3
                log = obj.getAuditLog(CLASS, 'calibrationKey', protocol);
            else
                log = obj.getAuditLog(CLASS, 'date', calibrationDate, 'calibrationKey', protocol);
            end

            m = obj.getMeasurement(CLASS, log);
        end
        
        function m = getLinearityByStimulsDuration(obj, duration, ledType, calibrationDate)
            
            CLASS = 'ala_laurila_lab.entity.LinearityMeasurement';
            import ala_laurila_lab.entity.*;
            
            if nargin < 4
                log = obj.getAuditLog(CLASS);
            else
                log = obj.getAuditLog(CLASS, 'date', calibrationDate);
            end 

            protocols = {log(:).calibrationKey};
            [~, protocolIndex] = LinearityMeasurement.getSimilarProtocol(protocols, duration, ledType);
            m = obj.getMeasurement(CLASS, log(protocolIndex));
        end
        
        function m = getIntensityMeasurement(obj, ledType, calibrationDate)
            
            CLASS = 'ala_laurila_lab.entity.IntensityMeasurement';
            import ala_laurila_lab.entity.*;

            if nargin < 3
                log = obj.getAuditLog(CLASS, 'calibrationKey', ledType);
            else
                log = obj.getAuditLog(CLASS, 'date', calibrationDate, 'calibrationKey', ledType);
            end
            m = obj.getMeasurement(CLASS, log);
        end
        
        function m = getSpectralMeasurement(obj, ledType, device, calibrationDate)
            
            CLASS = ala_laurila_lab.entity.SpectralMeasurement.getClass(device);
            import ala_laurila_lab.entity.*;
            
            if nargin < 4
                log = obj.getAuditLog(CLASS, 'calibrationKey', ledType);
            else
                log = obj.getAuditLog(CLASS, 'date', calibrationDate, 'calibrationKey', ledType);
            end
            m = obj.getMeasurement(CLASS, log);
        end
        
        function m = getNDFMeasurement(obj, ndfName, calibrationDate)
            
            CLASS = 'ala_laurila_lab.entity.NDFMeasurement';
            if nargin < 3
                log = obj.getAuditLog(CLASS, 'calibrationKey', ndfName);
            else
                log = obj.getAuditLog(CLASS, 'date', calibrationDate, 'calibrationKey', ndfName);
            end
            m = obj.getMeasurement(CLASS, log);
        end
        
        function date = getLastCalibrationDate(obj, class, key)
            date = obj.getCalibrationDate(class, key);
            date = date{end};
        end
        
        function map = getAllCalibrationDate(obj)
            query = obj.logManager.createQuery('ala_laurila_lab.entity.AuditLog');
            map = query.toDictionary(@(e) e.calibrationType, @(e) e.calibrationDate);
        end
        
        function dates = getCalibrationDate(obj, class, key)
            if nargin < 3
                key = [];
            end
            
            query = obj.logManager.createQuery('ala_laurila_lab.entity.AuditLog');
            if query.count == 0
                error('query:tableempty', 'No data found')
            end
            dates = query.where(@(e) strcmp(e.calibrationType, class) && isempty(key) || strcmp(e.calibrationKey, key))...
                .select(@(e) e.calibrationDate).toList();
        end
        
        function log = getAuditLog(obj, class, varargin)
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            ip.addParameter('date', [], @(x) ischar(x));
            ip.addParameter('calibrationKey', [],  @(x)ischar(x));
            
            ip.parse(varargin{:});
            date = ip.Results.date;
            calibrationKey = ip.Results.calibrationKey;
            
            compareType = @(e) strcmp(e.calibrationType, class);
            compareDate = @(e) isempty(date) || datenum(e.calibrationDate) == datenum(date);
            compareKey = @(e) isempty(calibrationKey) || strcmp(e.calibrationKey, calibrationKey);
            
            query = obj.logManager.createQuery('ala_laurila_lab.entity.AuditLog');
            
            if query.count == 0
                error('query:tableempty', 'No data found')
            end
            
            log = query.where(@(e) compareType(e) && compareDate(e) && compareKey(e))...
                .toArray();
            
            if isempty(log)
                error('query:tableempty', 'No data found')
            end
            [~, indices] = sort(datenum({log(:).calibrationDate}));
            log = log(indices);
        end
    end
    
    methods(Access = private)
        
        function add(obj, entity, calibratedBy, err, nextCalibrationDate)
            
            auditLog = struct('class', 'ala_laurila_lab.entity.AuditLog',...
                'calibrationKey', entity.id,...
                'calibrationDate', entity.calibrationDate,...
                'calibrationType', class(entity),...
                'calibratedBy', calibratedBy,...
                'errorWithPrevious', err,...
                'nextCalibrationDate', nextCalibrationDate,...
                'id', [],...
                'calibrationId', []);
            
            entity = obj.dataManager.persist(entity);
            auditLog.calibrationId = entity.id;
            obj.logManager.persist(auditLog);
        end
        
        function measurements = getMeasurement(obj, entity, auditLog)
            measurements = [];
            
            for i = 1 : numel(auditLog)
               m = entity;
               if ischar(entity)
                   constructor = str2func(entity);
                   m = constructor(auditLog(i).calibrationId);
               end
               m = obj.dataManager.find(m);
               measurements = [measurements, m]; %#ok
            end
        end
    end
end