function ndfMap = addtoMap(ndfMap, data)
    d = data;

    if(~ isKey(ndfMap, d.id))    
        dateArray = cell(1, numel(d.ledInput));
        dateArray(:) = {d.calibrationDate};
        d.calibrationDateArray = dateArray;
        
        idArray = cell(1, numel(d.ledInput));
        idArray(:) = {d.id};
        d.ndf = idArray;
        ndfMap(d.id) = d;
    else

        dateArray = cell(1, numel(d.ledInput));
        idArray = cell(1, numel(d.ledInput));
        dateArray(:) = {d.calibrationDate};
        idArray(:) = {d.id};
        d.calibrationDateArray = dateArray;
        d.ndf = idArray;
        oldData = ndfMap(d.id);
        ndfMap(d.id) = [oldData(:), d];
    end
end

