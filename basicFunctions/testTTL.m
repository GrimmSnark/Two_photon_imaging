daq = DaqDeviceIndex([],0);


while ~KbCheck
   
    detectTTLPulse(daq,1, 128, 1)
    
end                       