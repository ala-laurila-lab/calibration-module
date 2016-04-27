classdef EntityManager < handle
    
    properties
        fname
    end
    
    methods
        function obj = EntityManager(fname)
            obj.fname = fname;
        end
        
        function createFile(obj)
            file = H5F.create(obj.fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            
            spectrum = H5G.create(file, '/spectrum', 0);
            H5G.close(spectrum);
            
            ndf = H5G.create(file, '/ndf', 0);
            H5G.close(ndf);
            
            intensity = H5G.create(file, '/intensity', 0);
            H5G.close(intensity);
            
            linearity = H5G.create(file, '/linearity', 0);
            H5G.close(linearity);
            
            H5F.close(file);
        end
    end
    
    methods(Static)
        function em = create(fname)
            em = EntityManager(fname);
        end
    end
end

