function docalc (~,~)
global g; global h;
    [index,fileID,fileNum]=GCF_Data;

  	try
        assert(isempty(g.FIGS.Params.fitparams(index).Data))
        getparams();
    catch
    end
    
    try    %see if there is any data saved for this window/file
        for i=1:length(h.Params(fileID).fig(index).heights); if ~isempty(h.Params(fileID).fig(index).heights(i).part); beadNum(i)=i; end; end 
    catch
        errordlg('Have you selected any points?','Data not found.');
        return;
    end
    
%     beadNum=beadNum(beadNum~=0);

  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); Bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(Bead,'(\d+)(\w?)$','match'); beadNum=str2num(beadnum{:}{:});
    
%     for i=beadNum; 
%         partName(i)={g.FIGS.Params.heights(index).bead(i).RowName};
%     end %bead n<current has not been analysed in this case, that causes an error. cannot figure out the purpose of much of this though, its totally opaque. so i am going to leave it for now !!!

    filename=strcat('tmp_',fileNum{:},'.log');
    cFilename=fullfile(h.path,filename);
    magpos=getNumFromLog(cFilename,'position');
    
    answer=inputdlg('Please enter magnet position during measurement', 'Enter magpos',1,{num2str(magpos)});
    if isempty(answer); return; end
    magpos=str2double(answer{:});
    
	%force calculation: exp(ax^2+bx+c) where x is magpos
    x=magpos;
	try
        if x<0 || x>20
            errordlg('Magnet position should be between 0 and 20','Out of range!');
            return;
        elseif ~isfield(g.FIGS.Params, 'fitparams')
            errordlg('Have you imported the parameters?','No parameters here!');
            return;
        else
            assert(~isempty(g.FIGS.Params.fitparams(index).Data));
            beaddat=zeros(20,4);
            for i=beadNum;
                if g.FIGS.Params.fitparams(index).Data(i,4)==0
                    forces(i)=NaN;
                else
                    beaddat(i,:)=g.FIGS.Params.fitparams(index).Data(i,:);
                    a=beaddat(i,1); b=beaddat(i,2); c=beaddat(i,3);
                    forces(i)=exp(a.*x.^2+b.*x+c);
                end
            end
        end
	catch
        errordlg('Check your data!','Something is wrong!');
        return;
	end  
    
%     convert = inputdlg('Would you like to put in a dummy value for forces?');
%     if isempty(convert); return; end
%     for i = beadNum; forces(i) = str2num(convert{:}); end


    for j=beadNum 
    % height change
        for i=1:length(h.Params(fileID).fig(index).heights(j).part);
            min=h.Params(fileID).fig(index).heights(j).part(i).min; strt=h.Params(fileID).fig(index).heights(j).part(i).start;
            mx=h.Params(fileID).fig(index).heights(j).part(i).max; fin=h.Params(fileID).fig(index).heights(j).part(i).finish;
            bead(j).delX(i)=mx-min; bead(j).delT(i)=fin-strt;
            %need to have the same number of forces, though all are the same
            bead(j).force(i)= forces(j);
        end
        % slope (=speed)
        bead(j).slope=bead(j).delX./bead(j).delT;
        % conversion
        bead(j).bpconvert =  -(0.28439.*log(forces(j)+8.28212) - 0.57284.*log(forces(j)+0.56307) - 0.35476)./6.1;
        % slope/speed in bp/sec
        bead(j).slopebp=1000.*(bead(j).slope./bead(j).bpconvert);
        % height in bp
        bead(j).highbp=1000.*(bead(j).delX./bead(j).bpconvert);
        % rate
        bead(j).rate=bead(j).delT.^(-1);
        
        h.Params(fileID).fig(index).results(j)=struct('force',bead(j).force,'height_bp',bead(j).highbp,'velocity_bp',bead(j).slopebp,'rate',bead(j).rate,'height',bead(j).delX,'time',bead(j).delT,'velocity',bead(j).slope,'conversion',bead(j).bpconvert);

%         RowNames=partName{j}(:)';
%         
%         g.FIGS.Params.heights(index).bead(j).RowName=RowNames(:)';
        g.FIGS.Params.heights(index).bead(j).Data=[bead(j).force;bead(j).highbp;bead(j).slopebp;bead(j).rate;bead(j).delX;bead(j).delT; ...
            bead(j).slope;h.Params(fileID).fig(index).heights(j).part.min;h.Params(fileID).fig(index).heights(j).part.max;h.Params(fileID).fig(index).heights(j).part.start; ...
                h.Params(fileID).fig(index).heights(j).part.finish;]';
        g.FIGS.Params.heights(index).bead(j).ColumnName={'Force','Height Diff. bp','Velocity, bp/sec','Rate (Hz)','Height Diff. \mum', ...
            'Time','Velocity, \mum/s','z-Min','z-Max','Start','Finish'};
    end
    
    average;
    
   	g.FIGS.Params.results(index).Visible='on';
end %calcualtes speed height etc. from data selection and parameters file
