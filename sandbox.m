%% check if group present

tic
tf = true;
try
    fid = H5F.open('fixtures/test.h5', 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
    H5G.get_objinfo (fid, '/abc', 0);
catch Me
    tf = strfind(Me.message, ' ''abc'' doesn''t exist') < 1;
    H5F.close(fid);
end
toc

str = '/entity_Basic/id_10-Aug-2016_15_20_24';
cell = strsplit(str, '/');
id = char(cell(end));
idx = strfind(id, '_');

date = id(idx(1) + 1 : end);
DateString = datestr(datenum(date, 'dd-mmm-yyyy_HH_MM_SS'));

%% trying intensity to rstar
import ala_laurila_lab.*;

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))

path = which('test-symphony-persistence.xml');
calibration = service.CalibrationService('patch-rig-data', 'patch-rig-log', path);
i = calibration.getIntensityMeasurement('Blue', '02-May-2016');
s = calibration.getSpectralMeasurement('blue', '21-Apr-2016');
n = calibration.getNDFMeasurement('A4B', '20-Apr-2016');
l = calibration.getLinearityByStimulsDuration(20, 'BlueLed', '05-Dec-2015');
powerSpectrumPerArea = s.getNormalizedPowerSpectrum() * i.getPowerDensity(1, 'volt')/ i.getLedArea();

charge = l.getReferenceCharge(0.0221) / l.getReferenceCharge(1)
trans =  10^(n.opticalDensity)
rstarPerSecond = util.intensity2Rstar(powerSpectrumPerArea, s.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA)
rstarWithoutNDF = charge * rstarPerSecond * 0.02 
rstarWithNDF = charge * rstarPerSecond * trans* 0.02 
