function SubmitEvents(hObject,~,~)
global g; global h; global t;
[index,fileID,fileNum]=GCF_Data;
    
    bead=str2double(get(hObject,'Tag'));
    
    filename=strcat('tmp_',fileNum{:},'.log');
    cFilename=fullfile(h.path,filename);    
    time = getStrFromLog(cFilename,'time'); time = time(2:end-1);
    date = getStrFromLog(cFilename,'date'); date = date(2:end-1);
    try
        ActualTime = datetime([date ' ' time],'InputFormat', 'dd/MM/uuuu HH:mm:ss');
    catch
        ActualTime = datetime([date ' ' time],'InputFormat', 'dd.MM.uuuu HH:mm:ss');
    end
    
    for i = 1: length(h.Params(fileID).fig(index).results(bead).force)
        times(i)= h.Params(fileID).fig(index).heights(bead).part(i).start;
    end
        
    [~,order]=sort(times);
    
    for i = order                   %combined with the above, this orders the data before saving it in t
        longnow=length(t);
        t(longnow + 1).Force = h.Params(fileID).fig(index).results(bead).force(i);
        t(longnow + 1).HeightBp = h.Params(fileID).fig(index).results(bead).height_bp(i);
        t(longnow + 1).VelocityBp =  h.Params(fileID).fig(index).results(bead).velocity_bp(i);
        t(longnow + 1).Rate =  abs(h.Params(fileID).fig(index).results(bead).rate(i));
        t(longnow + 1).Height =  h.Params(fileID).fig(index).results(bead).height(i);
        t(longnow + 1).DistanceFromSlide = h.Params(fileID).fig(index).heights(bead).part(i).min;
        t(longnow + 1).Duration =  h.Params(fileID).fig(index).results(bead).time(i);
        t(longnow + 1).Velocity =  h.Params(fileID).fig(index).results(bead).velocity(i);
        t(longnow + 1).BpConversion =  h.Params(fileID).fig(index).results(bead).conversion;
        t(longnow + 1).FitParameters = g.FIGS.Params.fitparams(index);
        t(longnow + 1).FileTime = ActualTime;
   
        timenow = h.Params(fileID).fig(index).heights(bead).part(i).start;
        t(longnow + 1).ExactTime = ActualTime + seconds(abs(timenow));
        
        t(longnow + 1).Protein0 = 'no data';
        t(longnow + 1).Protein0Conc = 'no data';
        t(longnow + 1).Protein1 = 'no data';
        t(longnow + 1).Protein1Conc = 'no data';
        t(longnow + 1).Protein2 = 'no data';
        t(longnow + 1).Protein2Conc = 'no data';
        t(longnow + 1).Protein3 = 'no data';
        t(longnow + 1).Protein3Conc = 'no data';
        t(longnow + 1).Protein4 = 'no data';
        t(longnow + 1).Protein4Conc = 'no data';
        t(longnow + 1).Protein5 = 'no data';
        t(longnow + 1).Protein5Conc = 'no data';
        t(longnow + 1).BufferType = 'no data';
        t(longnow + 1).ATP = 'no data';
        t(longnow + 1).BeadNumber = num2str(bead);
        t(longnow + 1).FileNumber = num2str(fileID);
    end
    
%     assignin('base','t',t);
    try
        if analysis.Main.isvalid
            DataHarvestUpdate;
        end
    catch
    end
end % orders and outputs the data in the t structure for DataTowneTM
