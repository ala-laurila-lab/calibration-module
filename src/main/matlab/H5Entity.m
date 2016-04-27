classdef H5Entity < handle
    
    properties(Abstract)
        identifier
        group
    end
    
    properties(SetAccess = private)
        query
    end
    
    methods
        
        function date = lastEntry(~, fname, root)
            
            info = h5info(fname, root);
            n = numel(info.Groups);
            dateSet = cell(n, 1);
            for i = 1:n
                dateSet{i} = info.Groups(i).Name(length(root)+ 1 : end);
            end
            formattedDateSet = datetime(dateSet,'Format','dd-MMM-yyyy');
            sortedDateSet = sort(formattedDateSet, 'descend');
            date = datestr(sortedDateSet(1));
        end
        
        function prepareInsertStatement(obj, recordedDate)
            if nargin < 2
                recordedDate = date;
            end
            obj.query = @(fname)strcat(obj.group.toPath(), datestr(recordedDate));
        end
        
        function prepareSelectStatement(obj, recordedDate)
            if nargin < 2
                lastDate = @(fname) obj.lastEntry(fname, obj.group.toPath());
                obj.query = @(fname)strcat(obj.group.toPath(), datestr(lastDate(fname)), '/', obj.identifier);
            else
                obj.query = @(fname)strcat(obj.group.toPath(), datestr(recordedDate()), '/', obj.identifier);
            end
        end
        
        function n = getTableSize(~, data)
            names = fieldnames(data);
            n = numel(data.(names{1}));
        end
    end
    
    methods(Abstract)
        createSchema(obj)
        getPersistanceData(obj);
        setQueryResponse(obj, rdata, n)
    end
end
