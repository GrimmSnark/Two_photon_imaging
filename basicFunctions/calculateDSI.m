function DSI = calculateDSI(preferredOrientationNo, dataMean, angles)

prefAngle = angles(preferredOrientationNo);
[~, prefAngleIndex] = find(angles == prefAngle);

oppositeDir = prefAngle- 180;

if oppositeDir<0
    oppositeDir = oppositeDir+360;
end

[~, oppositeDirIndex] = find(angles == oppositeDir);


DSI = (dataMean(prefAngleIndex)  - dataMean(oppositeDirIndex))/ dataMean(prefAngleIndex);
end