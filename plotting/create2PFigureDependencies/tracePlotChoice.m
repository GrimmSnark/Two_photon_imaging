function tracePlotChoice(src, evnt)
% Gets the trace plot choice and passes it back into the UserData

% gets global variables
global H
global hLine

figData = get(H.ax, 'UserData');
figData.plotChoice = src.Text;
set(H.ax, 'UserData', figData);

% If a cell has already been selected, it will update the plot with the new
% type of trace
if isfield(figData, 'cellNum')
    % tries to delete old trace
    if ~isempty(hLine)
        try
            delete(hLine)
            hLine = [];
        catch me
            hLine = [];
        end
    end
    % plots new one
    plotCaTraces(figData.cellNum, figData.experimentStructure, figData, figData.cmap);
end

% toggle butttons ON or OFF
for i = 1:length(H.traceButtonHandles)
    if strcmp(figData.plotChoice, eval(['H.traceButtonHandles(' num2str(i) ').Text']))
        set(eval(['H.traceButtonHandles(' num2str(i) ')']), 'Checked', 'on');
    else
        set(eval(['H.traceButtonHandles(' num2str(i) ')']), 'Checked', 'off');
    end
end

end