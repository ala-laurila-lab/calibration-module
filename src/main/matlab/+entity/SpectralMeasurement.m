classdef SpectralMeasurement < io.mpa.H5Entity
    
    properties
        calibrationDate
        ledType
        wavelength
        powerSpectrum
    end
    
    properties
        group
        entityId = CalibrationPersistence.SPECTRAL_MEASUREMENT
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'power_for_'
    end
    
    methods
        
        function obj = Spectrum(ledType)
            obj.ledType = ledType;
            obj.identifier = ledType;
        end
        
        function setQueryResponse(obj, rdata, ~)
            obj.wavelength = rdata.wavelength(:);
            obj.calibrationDate = rdata.calibrationDate;
            obj.ledType = rdata.ledType;
            rdata = rmfield(rdata, {'wavelength', 'calibrationDate', 'ledType'});
            obj.powerSpectrum = rdata;
        end
        
        function addPowerSpectrum(obj, voltage, data)
            field = strcat(obj.KEY_STRING_PREFIX, num2str(voltage), 'V');
            obj.powerSpectrum.(field) = data;
        end
        
        function group = get.group(obj)
            group = [obj.entityId obj.calibrationDate];
        end
        
        function schema = getFinalSchema(obj)
             schema = obj.entityId.schema;
             dataType = schema.(obj.KEY_STRING_PREFIX);
             schema = rmfield(schema, obj.KEY_STRING_PREFIX);
             
             fields = fieldnames(obj.powerSpectrum);
             for i = 1 : numel(fields)
                 schema.(fields{i}) = dataType;
             end
        end
    end
end

