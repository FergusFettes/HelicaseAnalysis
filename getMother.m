function getMother(~,~)
global analysis; global e;
analysis.MainBeadList.Value=1;
    load('MotherFile.mat');
    DataHarvestUpdate;
end
