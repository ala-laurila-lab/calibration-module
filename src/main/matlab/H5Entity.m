classdef H5Entity < handle
    
    properties(Abstract)
        identifier
    end
    
    methods
        
        function insertTable(obj, fname, path)
            if ~ exist(fname, 'file')
                obj.create(fname)
            end
            
            file = H5F.open(fname, 'H5F_ACC_RDWR','H5P_DEFAULT');
            memtype = obj.createSchema();
            data = obj.getTableData();
            size = obj.getTableSize(data);
            space = H5S.create_simple(1, fliplr(size), []);
            group = H5G.create (file, path, 0);
            dset = H5D.create(group, obj.identifier, memtype, space, 'H5P_DEFAULT');
            
            H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
            H5G.close (group);
            H5F.close(file);
        end
        
        function date = lastEntry(~, fname, root)
            
            info = h5info(fname, root);
            n = numel(info.Groups);
            dateSet = cell(n, 1);
            for i = 1:n
                dateSet{i} = info.Groups(i).Name(length(root)+ 1 : end);
            end
            formattedDateSet = datetime(dateSet,'Format','dd-MMM-yyyy');
            sortedDateSet = sort(formattedDateSet, 'descend');
            date = sortedDateSet(1);
        end
        
        function selectTable(obj, fname, path)
            
            file = H5F.open (fname, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            dset = H5D.open (file, path);
            space = H5D.get_space (dset);
            memtype = obj.createSchema();
            [~, dims, ~] = H5S.get_simple_extent_dims (space);
            dims = fliplr(dims);
            
            rdata = H5D.read(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
            obj.setQueryResponse(rdata, dims);
            
            H5D.close (dset);
            H5S.close (space);
            H5T.close (memtype);
            H5F.close (file);
        end
    end
    
    methods(Access = private)
        
        function create(~, name)
            file = H5F.create(name, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            
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

