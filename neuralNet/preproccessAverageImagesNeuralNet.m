function dataProcessed = preproccessAverageImagesNeuralNet(data2Process)

dataProcessed = cell([size(data2Process,1),1]);

for idx = 1:size(data2Process,1)
    
    temp = data2Process{idx};
    temp = round(mat2gray(temp) * 65536);
    
    dataProcessed(idx) = {uint16(temp)};
end

end