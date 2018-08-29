daq = DaqDeviceIndex;

err = DaqDConfigPort(daq,1,1);   % Configures the digital port accoridng to the above setting
err = DaqDConfigPort(daq,0,1);   % Configures the digital port accoridng to the above setting
%  DaqDOut(daq,1,0);



while 0<1
    data = DaqDIn(daq);
    disp(num2str(data));
    
    if KbCheck
        break;
    end
    
end
