classdef H5EntityManager < handle
    
    properties
        fname
    end
    
    methods
        
        function obj = H5EntityManager(fname)
            obj.fname = fname;
        end
        
        function persist(obj, h5Entity)
            
            if ~ exist(obj.fname, 'file')
                obj.createFile(obj.fname)
            end
            
            file = H5F.open(obj.fname, 'H5F_ACC_RDWR','H5P_DEFAULT');
            
            memtype = h5Entity.createSchema();
            data = h5Entity.getPersistanceData();
            size = h5Entity.getTableSize(data);
            
            space = H5S.create_simple(1, fliplr(size), []);
            group = H5G.create(file, h5Entity.query(obj.fname), 0);
            dset = H5D.create(group, h5Entity.identifier, memtype, space, 'H5P_DEFAULT');
            
            H5D.write(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
            
            H5D.close(dset);
            H5S.close(space);
            H5G.close(group);
            H5T.close(memtype);
            H5F.close(file);
        end
        
        function find(obj, h5Entity)
            
            file = H5F.open(obj.fname, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            dset = H5D.open(file, h5Entity.query(obj.fname));
            space = H5D.get_space(dset);
            memtype = h5Entity.createSchema();
            [~, dims, ~] = H5S.get_simple_extent_dims(space);
            dims = fliplr(dims);
            
            rdata = H5D.read(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
            h5Entity.setQueryResponse(rdata, dims);
            
            H5D.close(dset);
            H5S.close(space);
            H5T.close(memtype);
            H5F.close(file);
        end
        
        function addAttributes(obj, h5Entity)
            
            if ~ exist(obj.fname, 'file')
                obj.createFile(obj.fname)
            end
            
            file = H5F.open(obj.fname, 'H5F_ACC_RDWR','H5P_DEFAULT');
            
            memtype = h5Entity.createSchema();
            data = h5Entity.getPersistanceData();
            size = h5Entity.getTableSize(data);
            
            space = H5S.create ('H5S_SCALAR');
            group = H5G.create(file, h5Entity.query(obj.fname), 0);
            dset = H5D.create(group, h5Entity.identifier, 'H5T_STD_I32LE', space, 'H5P_DEFAULT');
            H5S.close (space);
            
            space = H5S.create_simple(1, fliplr(size), []);
            attr = H5A.create(dset, 'attributes', memtype, space, 'H5P_DEFAULT');
            H5A.write(attr, memtype, data);
            
            H5A.close(attr);
            H5D.close(dset);
            H5S.close(space);
            H5T.close(memtype);
            H5G.close(group);
            H5F.close(file);
        end
        
        function readAttributes(obj, h5Entity)
            
            file = H5F.open(obj.fname, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            dset = H5D.open(file, h5Entity.query(obj.fname));
            attr = H5A.open_name(dset, 'attributes');
            space = H5A.get_space(attr);
            
            memtype = h5Entity.createSchema();
            [~, dims, ~] = H5S.get_simple_extent_dims(space);
            dims = fliplr(dims);
            rdata=H5A.read(attr, memtype);
            h5Entity.setQueryResponse(rdata, dims);
            
            H5A.close (attr);
            H5D.close (dset);
            H5S.close (space);
            H5T.close (memtype);
            H5F.close (file);
        end
        
        function create(obj)
            file = H5F.create(obj.fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            
            desc = enumeration('EntityDescription');
            for i = 1:numel(desc)
                group = H5G.create(file, desc(i).toPath(), 0);
                H5G.close(group);
            end
            H5F.close(file);
        end
    end
    
end

