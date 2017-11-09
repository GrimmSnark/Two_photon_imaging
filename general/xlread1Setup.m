function [Excel] = xlread1Setup(File)
% opens activeX server for fast reading, needs run before first usage of
% xlread1 ....see xlsread1 online page for more info 

Excel = actxserver ('Excel.Application'); 
% Excel.Workbooks.Open('C:\YourAddInFolder\AddInNameWithExtension'); 
% Excel.Workbooks.Item('AddInNameWithExtension').RunAutoMacros(1); 
% File='C:\YourFileFolder\FileName'; 
if ~exist(File,'file') 
ExcelWorkbook = Excel.Workbooks.Add; 
ExcelWorkbook.SaveAs(File,1); 
ExcelWorkbook.Close(false); 
end 
Excel.Workbooks.Open(File); 


% % close out Excel function...faster for reading needs added to the end of
% program

% Excel.ActiveWorkbook.Save; 
% Excel.Quit 
% Excel.delete 
% clear Excel


end