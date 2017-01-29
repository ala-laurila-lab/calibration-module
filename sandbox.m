
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

charge = l.getChargeByVoltage(0.03) / l.getChargeByVoltage(1)
trans =  10^(-n.opticalDensity)
rstarPerSecond = util.intensity2Rstar(powerSpectrumPerArea, s.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA)
rstarWithoutNDF = charge * rstarPerSecond * 0.02 
rstarWithNDF = charge * rstarPerSecond * trans* 0.02 

%% Plots for visonarium poster

