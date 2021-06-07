function ndfMap = addtoMap(ndfMap, data)
    d = data;

    if(~ isKey(ndfMap, d.id))    
        dateArray = cell(1, numel(d.ledInput));
        dateArray(:) = {d.calibrationDate};
        d.calibrationDateArray = dateArray;

        ndfMap(d.id) = d;
    else

        dateArray = cell(1, numel(d.ledInput));
        dateArray(:) = {d.calibrationDate};
        d.calibrationDateArray = dateArray;
        oldData = ndfMap(d.id);
        ndfMap(d.id) = [oldData(:), d];
    end
end

