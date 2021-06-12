# Calibration Module Ala-Laurila Lab

The light calibration module provides a user interface to quantify the properties of the visual stimulation. This is crucial to ensure that all experiments are performed with a defined light intensity, measured in photoisomerizations which occur in the photoreceptors when they receive light. 

The light calibration module provides a semi-automated tool to acquire and structure the calibration measurements. It stores the calibration measurements from both spatially uniform and from structured stimulus sources such as LEDs or DLP projectors. The measurements include the stimulus intensity, light source nonlinearity, the spectrum of the light source and the attenuation factor of the neutral density filters. The calibration data file format is plain text json, and easily readable by any programming language.

## How to calibrate Aalto patch rig?

The user interface for calibrations are programmed using [symphony modules](https://github.com/ala-laurila-lab/data-acquisition/tree/master/src/main/matlab/%2Bala_laurila_lab/%2Bmodules). 

### Intensity calibration

 Due to age-related changes in the light source, the absolute intensity it provides can fluctuate. The fluctuation is quantified by measuring the power output of the light source associated with a standard input to the light source (voltage or LED current) at regular intervals. If the difference to the previous measurement is not marginal (more than 3%), then the visual stimulation component of the setup is examined to ensure it still functions correctly before starting a new experiment. The newly developed Symphony Module; semi-automates the intensity calibration process. It saves the power output of a photometer UDT S470 flexOptometer (Gamma Scientific, "San Diego, CA", USA) and stores the information along with the calibration date and additional user information.

1. Setup the optometer. 
2. Open Symphony > Modules > Intensity calibration. 
3. Select and run the calibration spot (500 um) symphony protocol with no neutral density filter present in optical path.
4. Enter the power measured in optometer to Intensity calibration GUI, and save. Data is stored in dir `lib/calibration-module/data/aalto-patch-rig/intensity`. 

### Synchronize data to github

Open git shell 

```
cd <matlab-path>/projects/data-acquisition/lib/calibration-module/
git add data
git commit -m 'Add calibration data'
git push origin master
```

### Compute R*/rod/second table

As a best practice, follow [github pull request flow](https://guides.github.com/introduction/flow/) when generating R* table. It helps to do a quick manul review/check on changed R* values.

 ![image](https://user-images.githubusercontent.com/7013764/121772630-2eb79380-cb7f-11eb-828e-19fef61d5c6f.png)

Script to generate rstar table is present in [projector_calibration.m](https://github.com/ala-laurila-lab/calibration-module/blob/master/projector_calibration.m). 
[Manually verify and update calibration data](https://github.com/ala-laurila-lab/calibration-module/blob/master/projector_calibration.m#L6)
1. Replace the right folder / file name for spectrum and linearity measurement.
```
SPECTRUM_DATA_FOLDER = '2019-05-06';
LED_NON_LINEARITY_FILE_NAME = 'x08_Jun_202115_45_56-non-linearity.json';
```
2. Execute the data section, It will display the calibration history for ndf, and intensity
3. If there is no change in the light path, then the calibration data will be approximately the same.
4. Input the right intensity, ndf value and run the script.
5. Script will generate [rstar-table.csv](https://github.com/ala-laurila-lab/calibration-module/blob/master/data/aalto-patch-rig/rstar-table.csv). 

> <b> Calculated rstar table will be used in common-control module of symphony to select the right ndf, and led current value for given R*/rod/second.  </b>


## Requirements

- Matlab 2015a+
- [ToolboxToolbox](https://github.com/ToolboxHub/ToolboxToolbox)

## For Development

The project directory structure generally follows the [Maven Standard Directory Layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html).

1. Download and install [ToolboxToolbox](https://github.com/ToolboxHub/ToolboxToolbox)
2. Restart Matlab
3. `git clone https://github.com/ala-laurila-lab/calibration-module.git` into `<userpath>\projects\calibration-module` folder 
4. open the matlab command window and run `tbUseProject('calibration-module)`

### Matlab dependencies
    
     calibration-module
        |
        |____ app-toolboxes
                |____ mdepin (Matlab dependency injection framework) 
                |____ matlab-persistence (ORM layer for persistence)      

## License

Licensed under the [MIT License](https://opensource.org/licenses/MIT), which is an [open source license](https://opensource.org/docs/osd).
