function fcal(tagval,~)
    % get bead and file selections
    global g; global h;
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).'; nbeadSel=length(beadSel);
    fileSel=g.fileLST.String(g.fileLST.Value); fileID=regexp(fileSel,'tmp_(\d\d\d)','tokens');

    % check that a single cycle file is selected
    if length(fileSel)~=1 || isempty(regexp(fileSel{:},'cycle', 'once'))
        errordlg('Please select a single cycle file for Force Calibration','Invalid file selection...')
        return
    end   

    % prepare filename of selected file
    if isfield(g.FIGS,'fcal'); figslong=(1+length(g.FIGS.fcal)); else figslong=1; end
    tag=strcat('fcal',{' '},regexprep(fileSel,'cycle','cycle_Beads'),num2str(beadSel,strcat(repmat('%d,',1,length(beadSel)-1),'%d')),{' '},'Figure',{' '},num2str(figslong));
	figname=strcat('Force Calibration:',{' '},regexprep(tag,'^(\w+\s?)',''));
    
    % create figure with enough subplots    
   	g.FIGS.fcal(figslong)=figure('Position',(g.defPos+figslong*[5 -5 0 0]),'Name',figname{:},'NumberTitle','off','Tag',tag{:});
   	g.BTNS.Params(figslong).fcal= uitoggletool('OnCallback',{@paramstoggle},'OffCallback',{@paramstoggle}, ...
       	'Tag',num2str(figslong),'Visible', 'off','TooltipString', 'Show Parameters', 'CData', zeros(16,16,3));

    rows=round(nbeadSel^.5); cols=ceil(nbeadSel^.5); 
    s = zeros(1,25); %preallocating
    for i=1:(rows*cols); s(i)=subplot(rows,cols,i); end

    % fit and plot each bead
    goodness=g.GoodParams.fcal;
    fitaxes=s;
    fitequation=g.FitSettings.fcal.equation;   % varyfunc will automatically detect, plot and output the right number of coefficients (hopeflly!)
    fitbounds=g.FitSettings.fcal.bounds;                  
    fitdatatypes=g.FitSettings.fcal.data;                                    % get datatype numbers from getColFromCycle. This is equivalent to magnetposition, FxCorr, Fxerr.
    fiton=str2double(tagval.Tag);
    paramsout=varyfit(goodness,fitaxes,fitdatatypes,fitequation,fitbounds,fiton);

    % figure title and labels 
    ttl(1)=suplabel('Force [pN]','y'); ttl(2)=suplabel('Magnet Position [mm]','x',[0.0800 0.100 0.8400 0.8400]);
    set(ttl,'FontSize',8)

    fileStr=strcat('\bf',regexprep(fileSel,'_','\\_'));
    label=strcat('Force Calibration',{' '},fileStr{:});
    suplabel(label{:},'t');
    
    % Get all parameters for all beads from function, and label with fileID.
    % Must match the number of coefficients from your fitequation.
    if fiton %for some reason this cant go before the figure title and labels
        if  isempty(paramsout)
            errordlg('Something went wrong', 'No data!');
        else
            Paramsout=cell2struct(paramsout,{'gdns' 'a' 'b' 'c'},1);
            h=setfield(h,'Params',{str2double(fileID{:}{:}{:})},'fcal',Paramsout);
            fitParamsFcal (tag);
            set(g.BTNS.Params(figslong).fcal, 'Visible', 'on');
        end
    end

end %fits beads to exp(ax^2+bx+c) and makes a parameters file