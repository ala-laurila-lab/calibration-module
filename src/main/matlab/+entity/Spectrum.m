classdef Spectrum < H5Entity
    %SPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wavelength
        powerSpectrum
        ledType
    end
    
    properties(Dependent)
        identifier % overridden properties => ledType
    end
    
    properties(Constant)
        KEY_STRING_PREFIX = 'power_for_'
        SPECTRUM_GROUP = '/spectrum/'
    end
    
    methods(Access = protected)
        
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
    end
    
    methods
        
        function obj = Spectrum(ledType)
            obj.ledType = ledType;
        end
        
        function id = get.identifier(obj)
            id = obj.ledType;
        end
        
        function insert(obj, path)
            if nargin < 2
                path = date;
            end
            
            path = strcat(obj.SPECTRUM_GROUP, path);
            obj.insertTable(path);
        end
        
        function obj = select(obj, date)
            
            if nargin < 2
                date = obj.lastEntry(obj.SPECTRUM_GROUP);
            end
            path = [obj.SPECTRUM_GROUP, date, '/', obj.identifier];
            obj.selectTable(path);
        end
        
        function addPowerSpectrum(obj, voltage, data)
            field = strcat(obj.KEY_STRING_PREFIX, num2str(voltage), 'V');
            obj.powerSpectrum.(field) = data;
        end
    end
    
end

