function saveBackup(~,~)
global e;
BackupName=inputdlg('Please enter a filename for the backup', 'FILENAME.mat');
    if isempty(BackupName); return; end;
    save(BackupName{:},'e');
end
