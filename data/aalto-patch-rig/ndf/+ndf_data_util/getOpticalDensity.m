function odTable = getOpticalDensity(location)
    wheel1 = dir(fullfile(location, 'ndf', 'wheel1'));
    data = {};
    ndfMap = containers.Map();

    for i = 3 : length(wheel1)
        data{end + 1} = loadjson(fullfile(location, 'ndf', 'wheel1', wheel1(i).name));
        ndfMap = ndf_data_util.addtoMap(ndfMap, data{end});
    end

    wheel2 = dir(fullfile(location, 'ndf', 'wheel2'));

    for i = 3 : length(wheel2)
        data{end + 1} = loadjson(fullfile(location, 'ndf', 'wheel2', wheel2(i).name));
        ndfMap = ndf_data_util.addtoMap(ndfMap, data{end});
    end

    ndfnames = cellfun(@(d) d.ndfName, data , 'UniformOutput', false)';
    od = cellfun(@(d) d.opticalDensity, data , 'UniformOutput', false)';
    calibrationDate = cellfun(@(d) d.calibrationDate, data , 'UniformOutput', false)';

    odTable = sortrows(table(ndfnames, od, calibrationDate), 'calibrationDate'); 
end

