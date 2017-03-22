function commitEvents(~,~)  
global t; global analysis; global e;
    clear times;
    
    AssertAll = analysis.CommitAssertAll.Value;
    
    % get event selection (or just select all)
    if  AssertAll
        selection=1:length(t);
    else
       	selection=analysis.NewBeadList.Value; 
    end
    
    % create a vector that knows the times of every event in e, and save e to temp
    times(1) = datetime('today');
    elong=length(e);
  	for i = 1: elong
        times(i)= e(i).ExactTime;
        tempstruct(i)=e(i);
    end
    e=[];
    
    %add the times of t
    count=1;
    for i = selection
        times(elong + count) = t(i).ExactTime;
        count = count + 1;
    end
    
    %now create a vector which knows the order that these times go in
    [~,order]=sort(times);
    
    if isempty(order); order=selection; end;

    %now prepare and then refill structure
    nam=fieldnames(t);
    for i=1:length(nam); e.(nam{i})=[]; end
    count=1;
    for i=order
        if i>elong
            e(count) = t( selection( i - elong ) );
        else
            e(count) = tempstruct(i);
        end
        count=count+1;
    end
    
    t(selection)=[];
    analysis.NewBeadList.Value  = 1;
    analysis.MainBeadList.Value = 1;
    
    DataHarvestUpdate;
end
