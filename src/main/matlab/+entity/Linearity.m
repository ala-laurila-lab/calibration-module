classdef Linearity < H5Entity
    %LINEARITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        voltage
        power
        xRadius
        yRadius
        ledType
    end
    
    properties(Dependent)
        identifier % overridden properties => ledType
        group      % overridden properties => EntityDescription.LINEARITY
    end
    
    methods
        
        function obj = Linearity(ledType)
            obj.ledType = ledType;
        end
        
        function filetype = createSchema(~)
            n = 4;
            sz = ones(1, n);
            
            for i = 1 : n
                doubleType = H5T.copy('H5T_NATIVE_DOUBLE');
                sz(i)= H5T.get_size(doubleType);
            end
            offset(1) = 0;
            offset(2 : n) = cumsum(sz(1 : n-1));
            
            filetype = H5T.create ('H5T_COMPOUND', sum(sz));
            H5T.insert(filetype, 'voltage', offset(1),doubleType);
            H5T.insert(filetype, 'power', offset(2), doubleType);
            H5T.insert(filetype, 'xRadius',offset(3), doubleType);
            H5T.insert(filetype, 'yRadius',offset(4), doubleType);
        end
        
        function data = getPersistanceData(obj)
            data = struct('voltage', obj.voltage,...
                'power', obj.power,...
                'xRadius', obj.xRadius,...
                'yRadius', obj.yRadius);
        end
        
        function setQueryResponse(obj, rdata, ~)
            obj.voltage = rdata.voltage;
            obj.power = rdata.power;
            obj.xRadius = rdata.xRadius;
            obj.yRadius = rdata.yRadius;
        end
        
        function id = get.identifier(obj)
            id  = obj.ledType;
        end
        
        function group = get.group(~)
            group = EntityDescription.LINEARITY;
        end
    end
end

