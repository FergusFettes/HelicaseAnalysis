function fext(tagval,~) 
global g; global h;
    % get bead and file selections
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).'; nbeadSel=length(beadSel);
    fileSel=g.fileLST.String(g.fileLST.Value); fileID=regexp(fileSel,'tmp_(\d\d\d)','tokens');

    % check that a single cycle file is selected
    if length(fileSel)~=1 || isempty(regexp(fileSel{:},'cycle', 'once'))
        errordlg('Please select a single cycle file for Force Calibration','Invalid file selection...')
        return
    end

    % prepare tag for figures and parameters
    if isfield(g.FIGS,'fext'); figslong=(1+length(g.FIGS.fext)); else figslong=1; end
    tag=strcat('fext',{' '},regexprep(fileSel,'cycle','cycle_fext_Beads'),num2str(beadSel,strcat(repmat('%d,',1,length(beadSel)-1),'%d')),{' '},'Figure',{' '},num2str(figslong));
    figname=strcat('Force Extension:',{' '},regexprep(tag,'^(\w+\s?)',''));
    
    % create figure with enough subplots
   	g.FIGS.fext(figslong)=figure('Position',(g.defPos+figslong*[5 -5 0 0]),'Name',figname{:},'NumberTitle','off','Tag',tag{:});
   	g.BTNS.Params(figslong).fext= uitoggletool('OnCallback',{@paramstoggle},'OffCallback',{@paramstoggle}, ...
       	'Tag',num2str(figslong),'Visible', 'off','TooltipString', 'Show Parameters', 'CData', zeros(16,16,3));

    % create figure with enough subplots
    rows=round(nbeadSel^.5); cols=ceil(nbeadSel^.5); 
    s = zeros(100); %preallocation per advice $$$ how to know if zeros(100), zeros(1,100) or zeros(100,1) is better? or ones(n) for that matter
    for i=1:(rows*cols); s(i)=subplot(rows,cols,i); end

    % fit and plot each bead
    goodness=g.GoodParams.fext;
    fitaxes=s;
    fitequation = g.FitSettings.fext.equation;
    fitbounds= g.FitSettings.fext.bounds;
    fitdatatypes=g.FitSettings.fext.data;
    fiton=str2double(tagval.Tag);
    
    paramsout=varyfit(goodness,fitaxes,fitdatatypes,fitequation,fitbounds,fiton);

    % figure title and labels 
    suplabel('Force [pN]','y'); suplabel('DNA Extension [\mum]','x');
    fileStr=strcat('\bf',regexprep(fileSel,'_','\\_')); %makes the fileSel titleable, and bold fonts it
    label=strcat('Force Extension',{' '},fileStr{:});
    suplabel(label{:},'t');

    % Get all parameters for all beads from function, and label with fileID.
    % Must match the number of coefficients from your fitequation.
    if fiton %for some reason this cant go before the figure title and labels
        if  isempty(paramsout)
            errordlg('Something went wrong', 'No data!');
        else
            Paramsout=cell2struct(paramsout,{'gdns' 'L' 'p'},1);
            h=setfield(h,'Params',{str2double(fileID{:}{:}{:})},'fext',Paramsout);
            fitParamsFext (tag);
            set(g.BTNS.Params(figslong).fext, 'Visible', 'on');
        end
    end
    

 end %worm-like-chain