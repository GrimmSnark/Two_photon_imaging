function OSI = calculateOSI_V2(preferredOrientationNo, dataMean, angles, directionStimFlag)

prefAngle = angles(preferredOrientationNo);
[orthoPos, orthoNeg] = orthoAngle(prefAngle);

[~, prefAngleIndex] = find(angles == prefAngle);
[~, orthoPosIndex] = find(angles == orthoPos);
[~, orthoNegIndex] = find(angles == orthoNeg);

if directionStimFlag ==1
   oppositeDir = prefAngle- 180;
   
   if oppositeDir<0
       oppositeDir = oppositeDir+360;
   end
   
   [~, oppositeDirIndex] = find(angles == oppositeDir);

   
   OSI = (dataMean(prefAngleIndex) + dataMean(oppositeDirIndex) -  ( dataMean(orthoPosIndex) + dataMean(orthoNegIndex))) / (dataMean(prefAngleIndex) + dataMean(oppositeDirIndex));
   
elseif directionStimFlag == 0
    if ~isempty(orthoPosIndex)
        OSI = (dataMean(prefAngleIndex) - dataMean(orthoPosIndex)) / dataMean(prefAngleIndex);
    else
        OSI = (dataMean(prefAngleIndex) - dataMean(orthoNegIndex)) / dataMean(prefAngleIndex);
    end
end
end