# Two_photon_imaging
This folder should contain everything you need for running code on are Buker Nanosurfaces (PrairieView) 2P system

This toolbox is designed to allow the user to present visual stimuli using pyschophysics toolbox and sync experimental
events with Burker Two Photon Systems.

There are a number of dependancies for this toolbox to work:
1. Install pyschophysics toolbox (http://psychtoolbox.org/)
2. Aquire interface box to communicate between stimulus computer and 2P system (USB-1208FS or USB-1408FS, USB-1408FS
 preferred)
 
In order to set up this toolbox to run properly follow these steps:
1. Download toolbox and add to matlab path
2. Follow USB box instructions to connect the first analogue out port to the first analogue in port of the Bruker box
3. Connect digital port A to the tigger input on the Bruker box
4. In order to test and calibrate the analogue signal levels run testDAQOutSignal and record the voltage output in
PraireView
5. Run readEventFileSetup.m on analysis computer to calculate voltage look up table
6. Run experiment code from the PTB_code folder


Analysis Prerequisites
1. Install an up to date version of FIJI (https://fiji.sc/)
2. Connect FIJI with matlab as explained here (http://bigwww.epfl.ch/sage/soft/mij/) NB, instead of using ij.jar, place the up to date version from your FIJI package (FIJI.app/jars), it will be named something like ij-1.52g.jar into the MATLAB folder
3. Install Cell Magic Wand into FIJI (https://www.maxplanckflorida.org/fitzpatricklab/software/cellMagicWand/)
4. You may need to increase your java heap size for FIJI and matlab to work with large images see (https://www.mathworks.com/matlabcentral/answers/92813-how-do-i-increase-the-heap-space-for-the-java-vm-in-matlab-6-0-r12-and-later-versions) NB use the java.opts method
5. In order to use the FISSA toolbox to do non-negative matrix factorization neuropil signal extraction, download and install the toolbox from the git page (https://github.com/rochefort-lab/fissa).
6. You will also need to add the anaconda version of Python to your envoiroment variable path to run the toolbox through matlab (should be something like "C:\Users\User_name\ProgramData\Anaconda2\python.exe")
7. You will need to modify the "Two_photon_imaging\mijiFunction\intializeMIJ.m" to your local FIJI path. 

Data Analysis
1. prepData and preDataMultiSingle will run motion correction and create average images from ROI selection
2. runMIJIROIBasedAnalysis runs semi automated analysis but needs input for Cell ROIs
3. create2PFigure will open an interactive data viewer for each video run
4. There are a number of scripts in analysis folder still under development, be aware when using

Any questions or issues please feel free to contact me (msavage@uabmc.edu)
