function a = extractFromStruct(struct, isNumeric, listEntry, varargin)
% function that extracts information from structures and places it into
% cell array (a)
% struct is the input structure, isNumeric is a flag to convert data into
% numeric format, listEntry, is the level (in number) that contains the
% list of multiple entries, varargin is a list of strings for all the
% fields required to get down to the data wanted
% This function expects only one entry per list item...

structString ='struct';
structStringList = 'struct';

% builds the entry and list strings
for i=1:length(varargin)
    structString = [structString '.' varargin{i}];
    
    if i <= listEntry
        structStringList = [structStringList '.' varargin{i}];
    end
end

if ~isempty(listEntry) % if you want to get data from a list
    if length(listEntry)<2 % if data is in only one level of list
        suffixString = varargin{listEntry+1}; % initalises the specfic fields for the data entry
        
        for i = listEntry+2:length(varargin) % adds to the specfic fields for the data entry
            suffixString = [suffixString '.' varargin{i}];
        end
        
        for i=1:length(eval(structStringList)) % runs through the list
            a{i} = eval([structStringList '{1,i}.' suffixString]);
            
            if isNumeric % converts data to numbers
                a{i} =  str2num(a{i});
            end
        end
        
        if isNumeric
            a = cell2mat(a);
        end
        
    else % if data is in multiple levels of lists (ONLY SUPPORTS TWO LEVELS ATM
        for  b = 1:length(listEntry)
            chunkSuffix{b} = varargin{listEntry(b)+1}; % initalises the specfic fields for the data entry
            
            for i = listEntry(b)+2:listEntry((b+1)-1) % adds to the specfic fields for the data entry
                chunkSuffix{b} = [chunkSuffix{b} '.' varargin{i}];
            end
        end
        
        for i = listEntry(b)+2:length(varargin) % adds to the specfic fields for the data entry
            chunkSuffix{b} = [ chunkSuffix{b} '.' varargin{i}];
        end
        
            counter =0;
            for i=1:length(eval(structStringList)) % runs through the list
                
                for x =1:length(listEntry)
                    counter = counter +1;
                    a{counter} = eval([structStringList '{1,i}.' chunkSuffix{1} '{1,x}.' chunkSuffix{2}]);
                    
                    if isNumeric % converts data to numbers
                        a{counter} =  str2num(a{counter});
                    end
                end
            end
            
            if isNumeric
                a = cell2mat(a);
            end   
    end
    
else % if there is no list
    a= eval(structString);
    
    if isNumeric % converts data to numbers
        a =  str2num(a);
    end
end

end