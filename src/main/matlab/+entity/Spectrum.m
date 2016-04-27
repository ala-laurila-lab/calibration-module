classdef Spectrum < H5Entity

    properties
        wavelength
        powerSpectrum
        ledType
    end
    
    properties(Dependent)
        identifier % overridden properties => ledType
        group      % overridden properties => Schema.SPECTRUM
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'power_for_'
    end
    
    methods
        
        function obj = Spectrum(ledType)
            obj.ledType = ledType;
        end
        
        function memtype = createSchema(obj)
            voltages = fieldnames(obj.powerSpectrum);
            
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(1) = H5T.get_size(doubleType);
            n = numel(voltages);
            
            for i = 1:n
                doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
                sz(i+1) = H5T.get_size(doubleType);
            end
            
            offset(1) = 0;
            offset(2:n+1) = cumsum(sz(1:n));
            memtype = H5T.create('H5T_COMPOUND', sum(sz));
            H5T.insert(memtype, 'wavelength', offset(1), doubleType);
            
            for i = 1:n
                H5T.insert(memtype, voltages{i}, offset(i+1), doubleType);
            end
        end
        
        function data = getPersistanceData(obj)
            
            data = obj.powerSpectrum;
            data.wavelength = obj.wavelength;
        end
        
        function setQueryResponse(obj, rdata, ~)
            
            obj.wavelength = rdata.wavelength(:);
            rdata = rmfield(rdata, 'wavelength');
            obj.powerSpectrum = rdata;
        end
        
        function addPowerSpectrum(obj, voltage, data)
            field = strcat(obj.KEY_STRING_PREFIX, num2str(voltage), 'V');
            obj.powerSpectrum.(field) = data;
        end
        
        function id = get.identifier(obj)
            id = obj.ledType;
        end
        
        function group = get.group(~)
            group = EntityDescription.SPECTRUM;
        end
    end
    
end

