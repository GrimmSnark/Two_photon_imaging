gridSize = [15 28]; 
minAllowableDistance = 4;
maxNumPoints = 12;
idxPerFrame = [];

for i=1:4000
    idxPerFrame(:,i) = randDistributeSquares(gridSize, minAllowableDistance,maxNumPoints, idxPerFrame);
     
end





indexOfStim = unique(idxPerFrame);
totalStims = [indexOfStim,histc(idxPerFrame(:),indexOfStim)];
sortedStims = sortrows(totalStims, 2);