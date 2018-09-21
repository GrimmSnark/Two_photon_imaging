function newArray = typecastArray(theArray, newType)
  curshape = num2cell(size(theArray));
  lineArray = typecast(theArray(:), newType);
  lineArray = lineArray(1:2:end);
  newArray = reshape(lineArray, curshape{:});
end