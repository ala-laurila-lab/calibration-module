classdef EntityManagerFactory < handle
    
    properties
        fname
        classpath
    end
    
    methods
        function obj = EntityManagerFactory(rig)
            cp = getClassPath();
            json = loadjson([cp.resources 'properties.json']);
            locations = json.calibration_location;
            for i = 1:numel(locations)
                if strcmp(locations{i}.rig, rig)
                    obj.fname = locations{i}.local_path;
                    break;
                end
            end
            obj.classpath = cp;
        end
        
        function em = create(obj)
            if isempty(obj.fname)
                msgID = 'Invalid File';
                msg = 'Unable to find File present in properties.json';
                throw (MException(msgID, msg));
            end
            em = H5EntityManager(obj.fname);
        end
    end
end


