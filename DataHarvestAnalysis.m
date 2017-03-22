function DataHarvestAnalysis(~,~,AssertMain,AssertAll)
  global t; global analysis; global e;  
    % gets the selection, or selects all from either of the two lists
    if AssertMain
        if AssertAll
            selection = 1:length(e);
        else %if assert all fails, we want to take the selection
            selection = analysis.MainBeadList.Value;
        end
    else %if assert main fails (ie if we want the potentials)
        if AssertAll
            selection = 1:length(t);
        else
            selection=analysis.NewBeadList.Value;
        end
    end
    
    
    %% Analysis %%
    if AssertMain

        if isempty(analysis.MainBeadList.String); return; end;
        
        analysis.Force = mean([e(selection).Force]);
        analysis.ForceDev = std([e(selection).Force]);
        analysis.HeightBp = mean([e(selection).HeightBp]);
        analysis.HeightBpDev = std([e(selection).HeightBp]);
        
        up=[]; down=[];
        countup=1;
        countdown=1;
        for i=selection
            if e(i).VelocityBp>0
                up(countup)=e(i).VelocityBp;
                countup=countup+1;
            else
                down(countdown)=e(i).VelocityBp;
                countdown=countdown+1;
            end
        end
        analysis.VelocityBpUp = mean(up);
        analysis.VelocityBpUpDev = std(up);
        
      	analysis.VelocityBpDown = mean(down);
        analysis.VelocityBpDownDev = std(down);
        
        analysis.Rate = mean([e(selection).Rate]);
        analysis.RateDev = std([e(selection).Rate]);
        analysis.Height = mean([e(selection).Height]);
        analysis.HeightDev = std([e(selection).Height]);
        analysis.DistanceFromSlide = mean([e(selection).DistanceFromSlide]);
        analysis.DistanceFromSlideDev = std([e(selection).DistanceFromSlide]);
        analysis.Duration = mean([e(selection).Duration]);
        analysis.DurationDev = std([e(selection).Duration]);
        
        up=[]; down=[];
        countup=1;
        countdown=1;
        for i=selection
            if e(i).Velocity>0
                up(countup)=e(i).Velocity;
                countup=countup+1;
            else
                down(countdown)=e(i).Velocity;
                countdown=countdown+1;
            end
        end

        analysis.VelocityUp = mean(up);
        analysis.VelocityUpDev = std(up);
        
      	analysis.VelocityDown = mean(down);
        analysis.VelocityDownDev = std(down);
        
        analysis.BpConversion = mean([e(selection).BpConversion]);
        analysis.BpConversionDev = std([e(selection).BpConversion]);


        if length(selection)~=1;
            analysis.FileTime = 'Various';
        else
            analysis.FileTime = datestr(e(selection).FileTime,'yyyy-mm-dd HH:MM:SS:FFF');
        end
        
      	if length(selection)~=1;
            analysis.ExactTime = 'Various';
        else
            analysis.ExactTime = datestr(e(selection).ExactTime,'yyyy-mm-dd HH:MM:SS:FFF');
        end
 
        clear collection;
        collection = sort(unique({e(selection).Protein0}));
        analysis.Protein0 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein0Conc}));
        analysis.Protein0Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).Protein1}));
        analysis.Protein1 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein1Conc}));
        analysis.Protein1Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).Protein2}));
        analysis.Protein2 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein2Conc}));
        analysis.Protein2Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).Protein3}));
        analysis.Protein3 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein3Conc}));
        analysis.Protein3Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).Protein4}));
        analysis.Protein4 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein4Conc}));
        analysis.Protein4Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).Protein5}));
        analysis.Protein5 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).Protein5Conc}));
        analysis.Protein5Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).BufferType}));
        analysis.BufferType = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({e(selection).ATP}));
        analysis.ATP = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).BeadNumber}));
        analysis.BeadNumber = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({e(selection).FileNumber}));
        analysis.FileNumber = sprintf('%s;',collection{:});

%         analysis.xxx = mean([e(selection).xxx]);
%         analysis.xxxDev = std([e(selection).xxx]);
    else
        if isempty(analysis.NewBeadList.String); return; end;
        
      	analysis.Force = mean([t(selection).Force]);
        analysis.ForceDev = std([t(selection).Force]);
        analysis.HeightBp = mean([t(selection).HeightBp]);
        analysis.HeightBpDev = std([t(selection).HeightBp]);
        
        up=[]; down=[];
        countup=1;
        countdown=1;
        for i=selection
            if t(i).VelocityBp>0
                up(countup)=t(i).VelocityBp;
                countup=countup+1;
            else
                down(countdown)=t(i).VelocityBp;
                countdown=countdown+1;
            end
        end
        analysis.VelocityBpUp = mean(up);
        analysis.VelocityBpUpDev = std(up);
        
      	analysis.VelocityBpDown = mean(down);
        analysis.VelocityBpDownDev = std(down);
        
        analysis.Rate = mean([t(selection).Rate]);
        analysis.RateDev = std([t(selection).Rate]);
        analysis.Height = mean([t(selection).Height]);
        analysis.HeightDev = std([t(selection).Height]);
        analysis.DistanceFromSlide = mean([t(selection).DistanceFromSlide]);
        analysis.DistanceFromSlideDev = std([t(selection).DistanceFromSlide]);
      	analysis.Duration = mean([t(selection).Duration]);
        analysis.DurationDev = std([t(selection).Duration]);
        
        up=[]; down=[];
        countup=1;
        countdown=1;
        for i=selection
            if t(i).Velocity>0
                up(countup)=t(i).Velocity;
                countup=countup+1;
            else
                down(countdown)=t(i).Velocity;
                countdown=countdown+1;
            end
        end
        analysis.VelocityUp = mean(up);
        analysis.VelocityUpDev = std(up);
        
      	analysis.VelocityDown = mean(down);
        analysis.VelocityDownDev = std(down);
        
        analysis.BpConversion = mean([t(selection).BpConversion]);
        analysis.BpConversionDev = std([t(selection).BpConversion]);
        if length(selection)~=1;
            analysis.FileTime = 'Various';
        else
            analysis.FileTime = datestr(t(selection).FileTime,'yyyy-mm-dd HH:MM:SS:FFF');
        end
      	if length(selection)~=1;
            analysis.ExactTime = 'Various';
        else
            analysis.ExactTime = datestr(t(selection).ExactTime,'yyyy-mm-dd HH:MM:SS:FFF');
        end
        
       	clear collection;
        collection = sort(unique({t(selection).Protein0}));
        analysis.Protein0 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein0Conc}));
        analysis.Protein0Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).Protein1}));
        analysis.Protein1 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein1Conc}));
        analysis.Protein1Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).Protein2}));
        analysis.Protein2 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein2Conc}));
        analysis.Protein2Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).Protein3}));
        analysis.Protein3 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein3Conc}));
        analysis.Protein3Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).Protein4}));
        analysis.Protein4 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein4Conc}));
        analysis.Protein4Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).Protein5}));
        analysis.Protein5 = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).Protein5Conc}));
        analysis.Protein5Conc = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).BufferType}));
        analysis.BufferType = sprintf('%s;',collection{:});
        
     	clear collection;
        collection = sort(unique({t(selection).ATP}));
        analysis.ATP = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).BeadNumber}));
        analysis.BeadNumber = sprintf('%s;',collection{:});
        
        clear collection;
        collection = sort(unique({t(selection).FileNumber}));
        analysis.FileNumber = sprintf('%s;',collection{:});
        
    end

    %% Display %%
    
    strings={strcat(num2str(analysis.Force),{' '}, '+/-',{' '}, num2str(analysis.ForceDev)),...
                strcat(num2str(analysis.HeightBp),{' '}, '+/-',{' '}, num2str(analysis.HeightBpDev)),...
                strcat(num2str(analysis.VelocityBpUp),{' '}, '+/-',{' '}, num2str(analysis.VelocityBpUpDev)),...
                strcat(num2str(analysis.VelocityBpDown),{' '}, '+/-',{' '}, num2str(analysis.VelocityBpDownDev)),...
                strcat(num2str(analysis.Rate),{' '}, '+/-',{' '}, num2str(analysis.RateDev)),...
                strcat(num2str(analysis.Height),{' '}, '+/-',{' '}, num2str(analysis.HeightDev)),...
                strcat(num2str(analysis.DistanceFromSlide),{' '}, '+/-',{' '}, num2str(analysis.DistanceFromSlideDev)),...
                strcat(num2str(analysis.Duration),{' '}, '+/-',{' '}, num2str(analysis.DurationDev)),...
                strcat(num2str(analysis.VelocityUp),{' '}, '+/-',{' '}, num2str(analysis.VelocityUpDev)),...
                strcat(num2str(analysis.VelocityDown),{' '}, '+/-',{' '}, num2str(analysis.VelocityDownDev)),...
                strcat(num2str(analysis.BpConversion),{' '}, '+/-',{' '}, num2str(analysis.BpConversionDev)),...
                'nuthin to see here',...
                analysis.FileTime,...
                analysis.ExactTime,...
                analysis.Protein0,...
                analysis.Protein0Conc,...
                analysis.Protein1,...
                analysis.Protein1Conc,...
                analysis.Protein2,...
                analysis.Protein2Conc,...
                analysis.Protein3,...
                analysis.Protein3Conc,...
                analysis.Protein4,...
                analysis.Protein4Conc,...
                analysis.Protein5,...
                analysis.Protein5Conc,...
                analysis.BufferType,...
                analysis.ATP,...
                analysis.BeadNumber,...
                analysis.FileNumber,...
                };

    analysis.DataDisplay.Data = [strings{:}]';
    
%     analysis.MateData.Data = [meta{:}]';
end
