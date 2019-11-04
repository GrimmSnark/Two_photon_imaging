function OSI = calculateOSI_V3(dataMean, angles, directionStimFlag)

% dataMean = [1 0.1 0.1 0.1 1 0.1 0.1 0.1];
%  dataMean = [1 0 0 0 1 0 0 0];
%  dataMean = [1 0.3 0 0.1 0.3 0.1 0 0.3];
%  dataMean = [0.2 ones(1,7) * 0.1];
% 
% angles = linspace(0, 360, 9);
% angles = angles(1:end-1);

x=interp1(dataMean,linspace(1,length(angles),36));
gausStruct = dualGaussianFitMS(x);

response = gausStruct.modelTrace;
responseAngles = 1:length(response);

sinResponse = (response * sin(deg2rad(responseAngles*2))') ^2;
cosResponse = (response * cos(deg2rad(responseAngles*2))') ^2;
OSI = (sqrt((sinResponse + cosResponse)))/ sum(response);

    
end