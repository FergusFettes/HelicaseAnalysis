function ClearData(~,~)
    global t; global analysis;
    AssertAll = analysis.DeleteAssertAll.Value;
    
    if isempty(t); return; end;
    
    % gets the selection, or selects all from either of the two lists
    if AssertAll
        t = [];
    else
        t(analysis.NewBeadList.Value)=[];
    end
    
    analysis.NewBeadList.Value=1;
    
    analysis.LittleUpdate = 1;
    DataHarvestUpdate;
end
