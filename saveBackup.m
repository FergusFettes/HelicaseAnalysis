function saveBackup(~,~)
global analysis;
BackupName=inputdlg('Please enter a filename for the backup', 'FILENAME.mat');
    if isempty(BackupName); return; end;
    save(BackupName{:},'e');
end
