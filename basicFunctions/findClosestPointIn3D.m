function [closestIndx, closestPoint] = findClosestPointIn3D(testPoints, comparisonPoints, thresholdDistance)
% function compares two matrixes of m x 3 representing 3D locations for
% closest points. Runs through testPoints and compares to comparisonPoints.
% Outputs closestPoint for each entry of testPoints found in
% comparisonPoints. Does this for indexes as well. thresholdDistance is a
% maximum limit for distance between points. If the minimum found distance
% is over this, returns NaN for this value


% testPoints = rand(10,3);
% comparisonPoints = rand(15,3);
% thresholdDistance = 20;

%create blank arrays
closestIndx = zeros(length(testPoints),1);
closestPoint = zeros(length(testPoints),3);

%runs throug each entry of testPoints
for i = 1:length(testPoints)
    %finds the distances between the testPoint entry and comparison points
    %array
    distances = sqrt(sum(bsxfun(@minus, comparisonPoints, testPoints(i,:)).^2,2));
    
    %if less than the threshold distance computes the closest index and
    %value
    if min(distances) < thresholdDistance
        closestIndx(i) = find(distances==min(distances));
        closestPoint(i,:) = comparisonPoints(find(distances==min(distances)),:);
    else % if not returns NaN
        closestIndx(i) = NaN;
        closestPoint(i,:) = NaN;
    end
    
    % May need to add something to deal with multiple match with same entry
    % in comparison array....
    
end