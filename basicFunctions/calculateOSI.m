function OSI = calculateOSI(maxResponse, minResponse)
% Calculates OSI modulation index 0-1

OSI = (maxResponse - minResponse)/(maxResponse + minResponse);

end