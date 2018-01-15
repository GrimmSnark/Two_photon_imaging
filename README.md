# Two_photon_imaging
This folder should contain everything you need for running code on the 2P system

This toolbox is designed to allow the user to present visual stimuli using pyschophysics toolbox and sync experimental
events with Burker Two Photon Systems.

THIS DOES NOT DO FLUORESCENCE ANALYSIS, FOR THAT TRY SOMETHING LIKE SUITE2P

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
6. Run/Create analysis code based on whatever you want [under construction, will being adding to this as I create my own scripts]

In future this toolbox will interact with results of Suite2P imaging analysis...
