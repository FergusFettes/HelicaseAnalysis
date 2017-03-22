function withdrawEvents(~,~) 
global analysis; global e; global t;
clear times;
    
    AssertAll = analysis.WithdrawAssertAll.Value;
    
    % get event selection (or just select all)
    if  AssertAll
        selection=1:length(e);
    else
       	selection=analysis.MainBeadList.Value; 
    end
    
    nam=fieldnames(e);
    %now refill structure
    for i=selection
        longnow=length(t);
        if ~longnow && ~isstruct(t); for j = 1:length(nam); t.(nam{j})=[]; end; end
        t(longnow + 1) = e(i);
    end
    
    e(selection)=[];
    analysis.MainBeadList.Value=1;
    
    DataHarvestUpdate;
end
