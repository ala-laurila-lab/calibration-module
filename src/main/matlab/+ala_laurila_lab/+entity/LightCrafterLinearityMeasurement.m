classdef LightCrafterLinearityMeasurement <  ala_laurila_lab.entity.LinearityMeasurement

	properties (Dependent)
		flux
		ledCurrent
	end

	methods 

		function obj = set.flux(obj, flux)
			obj.addCharge(flux);
		end

		function obj = set.ledCurrent(obj, ledCurrent)
			obj.addVoltage(ledCurrent);
		end

		function flux = get.flux(obj)
			flux = obj.getCharges();
		end

		function ledCurrent = get.ledCurrent(obj)
			[~, ledCurrent] = obj.getCharges();
		end

		function flux = getFluxByLedCurrent(obj, current)
			flux = obj.getChargeByVoltage(current);
		end

	end
end