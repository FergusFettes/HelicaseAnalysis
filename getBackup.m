function getBackup(~,~)
global analysis;
analysis.MainBeadList.Value=1;
    BackupName=inputdlg('Please enter the name of the file to retrieve', 'FILENAME.mat');
    if isempty(BackupName); return; end;
    load(BackupName{:});
    DataHarvestUpdate;
end
