function extractIntensitiesWrapper()

intializeMIJ;
intensityDB = IntensityDB();

for i = 1:length(intensityDB)
    extractIntensities(intensityDB(i).dataDir, IJ);
end

MIJ.exit

end