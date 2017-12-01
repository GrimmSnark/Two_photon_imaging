function nums = stringEvent2Num(strings, codes)
% converts string events(cell of strings) into event number code

nums = zeros(1,length(strings));
for i=1:length(strings)
     nums(1,i) = find(strcmp(strings{i}, codes), 1);  
end

end