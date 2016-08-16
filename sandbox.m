% check if group present

tic
tf = true;
try 
fid = H5F.open('fixtures/test.h5', 'H5F_ACC_RDONLY', 'H5P_DEFAULT');    
H5G.get_objinfo (fid, '/abc', 0);
catch Me
    tf = strfind(Me.message, ' ''abc'' doesn''t exist') < 1
    H5F.close(fid);
end
toc

str = '/entity_Basic/id_10-Aug-2016_15_20_24';
cell = strsplit(str, '/');
id = char(cell(end));
idx = strfind(id, '_');

date = id(idx(1) + 1 : end);
DateString = datestr(datenum(date, 'dd-mmm-yyyy_HH_MM_SS'))
