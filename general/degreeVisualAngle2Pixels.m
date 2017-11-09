function sizeInPixels = degreeVisualAngle2Pixels(setup, sizeInVisualAngle)
%converts sizeInVisualAngle (size of object in visual angle) into pixel 
%sizes based on setup information (add to switch case for more setups)

switch setup
    case 1 % Shel 1170 monitor
        hM = 20; % hight of monitor in cm
        d = 25; % distance from monitor in cm
        res = 1024; % vertical resolution of monitor in cm
        
    case 2 % placeholder
        hM = 30; % hight of monitor in cm
        d = 25; % distance from monitor in cm
        res = 1024; % vertical resolution of monitor in cm
end

degreePerPix = rad2deg(atan2((0.5*hM),d)) / (0.5*res);

sizeInPixels = round(sizeInVisualAngle / degreePerPix);
end