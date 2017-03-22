function DataHarvestUpdate(~,~)
global t; global analysis; global e;    
    NewStrings={};
    MainStrings={};
    
    for i=1:length(t)
        NewStrings = [NewStrings {datestr(t(i).ExactTime,'yyyy-mm-dd HH:MM:SS:FFF')}];
    end
    
    if analysis.LittleUpdate
        MainStrings = analysis.MainBeadList.String;
    else
        for i=1:length(e)
            MainStrings = [MainStrings {datestr(e(i).ExactTime,'yyyy-mm-dd HH:MM:SS:FFF')}];
        end
    end
    
    analysis.MainBeadList.String = MainStrings;
    analysis.NewBeadList.String =  NewStrings;
    
    analysis.total.String = num2str(length(e));
    try
        timeRange = strcat(num2str(days(diff([e(1).ExactTime e(end).ExactTime]))), {' '},'days');
        analysis.timeRange.String = timeRange{:};
    catch
        analysis.timeRange.String = 'none';
    end
    
    analysis.LittleUpdate = 0;
end % reworks all the data displayed in the Data Harvesting area
