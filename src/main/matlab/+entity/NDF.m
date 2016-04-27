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
        
        function setQueryResponse(obj, rdata, ~)

            obj.voltages = rdata.voltage(:);
            obj.powers = rdata.power(:);
            obj.referencePowers = rdata.referencePower(:);
        end
    end
    
    methods
        
        function obj = NDF(name)
            obj.name = name;
        end
        
        function insert(obj, path)
            if nargin < 2
                path = date;
            end
            
            path = strcat(obj.NDF_GROUP, path);
            obj.insertTable(path);
        end
        
        function obj = select(obj, date)
            
            if nargin < 2
                date = obj.lastEntry(obj.NDF_GROUP);
            end
            path = [obj.NDF_GROUP, datestr(date), '/', obj.identifier];
            obj.selectTable(path);
        end
        
        function [power, reference] = groupByVoltage(obj, value)
            index = (obj.voltages == value);
            power = obj.powers(index);
            reference = obj.referencePowers(index); 
        end
      
        function id = get.identifier(obj)
            id  = obj.name;
        end
    end
end

