function ExportCell(~,~)
global e;
    nam=fieldnames(e);
    
    exportcell=cell(length(nam),length(e));
    
    for i = 1:length(e)
        for j = 1:length(nam)
            exportcell(j,i) = {e(i).(nam{j})};
        end
    end
    
    exportcell=exportcell';
    
    for i = 1:length(exportcell)
        exportcell{i,10}=[];
        exportcell(i,11)={datestr(exportcell{i,11},'yyyy-mm-dd HH:MM:SS:FFF')};
        exportcell(i,12)={datestr(exportcell{i,12},'yyyy-mm-dd HH:MM:SS:FFF')};
    end

    assignin('base','EXPORT',exportcell);
end
