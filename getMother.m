function getMother(~,~)
global analysis;
analysis.MainBeadList.Value=1;
    load('MotherFile.mat');
    DataHarvestUpdate;
end
