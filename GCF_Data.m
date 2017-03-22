function [index,fileID,fileNum,field]=GCF_Data(~,~)
%gets field
field=regexp(get(gcf,'Tag'),'^(\w+)','match');

%gets index (figslong)
index=regexp(get(gcf,'Tag'),'(\d+)$','match');
index=str2num(index{:});

%gets the ID of the tmp file currently being worked upon
fileNum=regexp(get(gcf,'Tag'),'\d{3}','match');
fileID=str2num(fileNum{:});

end% gets index, filenum and bead data for the current situation
