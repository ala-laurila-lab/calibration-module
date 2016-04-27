classdef H5Entity < handle
    
    properties(Abstract)
        identifier
    end
    
    properties
        entityManager;
    end
    
    methods
        
        function insertTable(obj, path)
            em  = obj.entityManager;
            
            if ~ exist(em.fname, 'file')
                em.createFile(fname)
            end
            
            file = H5F.open(em.fname, 'H5F_ACC_RDWR','H5P_DEFAULT');
            memtype = obj.createSchema();
            data = obj.getPersistanceData();
            size = obj.getTableSize(data);
            space = H5S.create_simple(1, fliplr(size), []);
            group = H5G.create(file, path, 0);
            dset = H5D.create(group, obj.identifier, memtype, space, 'H5P_DEFAULT');
            
            H5D.write(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
            H5G.close(group);
            H5F.close(file);
        end
        
        function date = lastEntry(obj, root)
            
            info = h5info(obj.entityManager.fname, root);
            n = numel(info.Groups);
            dateSet = cell(n, 1);
            for i = 1:n
                dateSet{i} = info.Groups(i).Name(length(root)+ 1 : end);
            end
            formattedDateSet = datetime(dateSet,'Format','dd-MMM-yyyy');
            sortedDateSet = sort(formattedDateSet, 'descend');
            date = datestr(sortedDateSet(1));
        end
        
        function selectTable(obj, path)
            
            file = H5F.open(obj.entityManager.fname, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            dset = H5D.open(file, path);
            space = H5D.get_space(dset);
            memtype = obj.createSchema();
            [~, dims, ~] = H5S.get_simple_extent_dims(space);
            dims = fliplr(dims);
            
            rdata = H5D.read(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
            obj.setQueryResponse(rdata, dims);
            
            H5D.close(dset);
            H5S.close(space);
            H5T.close(memtype);
            H5F.close(file);
        end
        
        function setEntityManager(obj, em)
            obj.entityManager = em;
        end
    end
    
    methods(Access = private)
        
        function n = getTableSize(~, data)
            names = fieldnames(data);
            n = numel(data.(names{1}));
        end
    end
    
    methods(Access = protected, Abstract)
        createSchema(obj)
        getPersistanceData(obj);
        setQueryResponse(obj, rdata, n)
    end
end
