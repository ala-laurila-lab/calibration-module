classdef EntityDescription
    
    enumeration
        SPECTRUM
        INTENSITY
        LINEARITY
        NDF
    end
    
    methods
        function path = toPath(obj)
            path = ['/' char(obj) '/'];
        end
    end
end

