classdef (Abstract)SpectralMeasurement < ala_laurila_lab.entity.Measurement
    
    properties
        ledType
        wavelength
    end
    
    properties(Constant)
        ERROR_MARGIN_PERCENT = 5
    end
    
    methods
        
        function obj = SpectralMeasurement(ledType)
            obj@ala_laurila_lab.entity.Measurement(ledType);
            obj.ledType = ledType;
        end
        
        function [power, graph] = getPowerSpectrum(obj, field)
            [power, graph] = obj.getPowerSpectrumByField(field);
        end
        
        function spectrum = getNormalizedPowerSpectrum(obj, field)
            
            powerSpectrum = obj.getPowerSpectrumByField(field);
            dLambda = diff(obj.wavelength);
            dLambda(end + 1) = dLambda(end);
            spectrum = powerSpectrum/ sum(powerSpectrum .* dLambda);
        end
        
        function error = getError(obj, old)
            % TODO caluclate error
            disp('TODO calculater error')
            error = 1;
        end
    end
    
    methods (Access = private)
        function [power, graph] = getPowerSpectrumByField(obj, field)
            import ala_laurila_lab.*;
            
            lambda = obj.wavelength;
            power = obj.(field);
            power = util.angle_correction(power, lambda);
            [power, graph] = util.extrapolate_edges(power, lambda);
        end
    end
    
    methods(Abstract)
        addPowerSpectrum(obj, field, power);
    end
    
    methods(Static)
        
        function CLASS = getClass(device)
            if strfind(lower(device), 'led')
                CLASS = 'ala_laurila_lab.entity.LEDSpectrum';
            elseif strfind(lower(device), 'projector')
                CLASS = 'ala_laurila_lab.entity.ProjectorSpectrum';
            end
        end
    end
end