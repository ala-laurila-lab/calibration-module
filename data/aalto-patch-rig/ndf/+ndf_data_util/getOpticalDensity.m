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
    
    d = [data{:}];
    
    wheelId = [d.wheelId]';
    ndfId = [d.ndfId]';
    od = [d.opticalDensity]';
    calibrationDate = arrayfun(@(d) datetime(d.calibrationDate, 'InputFormat', 'dd-MMM-yyyy'), d , 'UniformOutput', false);
    calibrationDate = [calibrationDate{:}]';

    odTable = sortrows(table(wheelId, ndfId, od, calibrationDate), 'calibrationDate'); 
end

