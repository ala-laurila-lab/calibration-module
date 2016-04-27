
info = h5info('src/test/resources/temp.h5', '/ndf');
n = numel(info.Groups);
dateSet = cell(n, 1);
for i = 1:n
    dateSet{i} = info.Groups(i).Name(6:end);
end
formattedDateSet = datetime(dateSet,'Format','dd-MMM-yyyy');
lastDate = sort(formattedDateSet, 'descend');

data = h5read('src/test/resources/temp.h5','/ndf/27-Apr-2016')
h5disp('src/test/resources/temp.h5','/ndf/27-Apr-2016')