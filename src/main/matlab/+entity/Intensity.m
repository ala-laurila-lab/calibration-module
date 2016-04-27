classdef Intensity < H5Entity
    
    properties
        voltages
        cmeans
        cstds
        ledType
    end
    
    properties(Dependent)
        identifier % overridden properties => ledType
        group      % overridden properties => Schema.INTENSITY
    end
    
    methods
       
        function obj = Intensity(ledType)
            obj.ledType = ledType;
        end
        
        function memtype = createSchema(obj)
            
            doubleType = H5T.copy('H5T_NATIVE_DOUBLE');
            sz(1)= H5T.get_size(doubleType);
            
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(2)= H5T.get_size(doubleType);
            
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(3)= H5T.get_size(doubleType);
            
            offset(1)=0;
            offset(2:3)=cumsum(sz(1:2));
            
            memtype = H5T.create('H5T_COMPOUND', sum(sz));
            H5T.insert(memtype, 'voltage', offset(1), doubleType);
            H5T.insert(memtype, 'cmean', offset(2), doubleType);
            H5T.insert(memtype, 'cstd', offset(3), doubleType);
        end
        
        function data = getPersistanceData(obj)
            data = struct('voltage', obj.voltages,...
                'cmean', obj.cmeans,...
                'cstd', obj.cstds);
        end
        
        function setQueryResponse(obj, rdata, ~)
            obj.voltages = rdata.voltage(:);
            obj.cmeans = rdata.cmean(:);
            obj.cstds = rdata.cstd(:);
        end
        
        function id = get.identifier(obj)
            id = obj.ledType;
        end
        
        function group = get.group(~)
            group = EntityDescription.INTENSITY;
        end
    end
end

