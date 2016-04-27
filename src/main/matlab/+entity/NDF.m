classdef NDF < H5Entity
    
    properties
        voltages
        powers
        referencePowers
        name
    end
    
    properties(Dependent)
        identifier % overridden properties => ndf
    end
    
    properties(Constant)
        NDF_GROUP = '/ndf/';
    end
    
    methods(Access = protected)
        
        function memtype = createSchema(~)
            
            intType = H5T.copy('H5T_NATIVE_INT');
            sz(1)= H5T.get_size(intType);
            
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(2)= H5T.get_size(doubleType);
            
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(3)= H5T.get_size(doubleType);
            
            offset(1)=0;
            offset(2:3)=cumsum(sz(1:2));
            
            memtype = H5T.create('H5T_COMPOUND', sum(sz));
            H5T.insert(memtype, 'voltage', offset(1), intType);
            H5T.insert(memtype, 'power', offset(2), doubleType);
            H5T.insert(memtype, 'referencePower', offset(3), doubleType);
        end
        
        function data = getPersistanceData(obj)
            data = struct('voltage', int32(obj.voltages),...
                'power', obj.powers,...
                'referencePower', obj.referencePowers);
        end
        
        function setQueryResponse(obj, rdata, n)
            obj.voltages = ones(1,n);
            obj.powers = ones(1, n);
            obj.referencePowers = ones(1, n);
            
            obj.voltages = rdata.voltage(:);
            obj.powers = rdata.power(:);
            obj.referencePowers = rdata.referencePower(:);
        end
    end
    
    methods
        
        function obj = NDF(name)
            obj.name = name;
        end
        
        function insertTable(obj, fname, path)
            
            if nargin < 3
                path = date;
            end
            
            path = strcat(obj.NDF_GROUP, path);
            insertTable@H5Entity(obj, fname, path);
        end
        
        function selectTable(obj, fname, date)
            
            if nargin < 3
                date = obj.lastEntry(fname, obj.NDF_GROUP);
            end
            path = [obj.NDF_GROUP, datestr(date), '/', obj.identifier];
            selectTable@H5Entity(obj, fname, path);
        end
      
        function id = get.identifier(obj)
            id  = obj.name;
        end
    end
end

