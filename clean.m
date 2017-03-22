function clean(~,~)
global g; global h;
    goodness=g.GoodParams.clean; fitdatatypes=g.FitSettings.clean.data;
    fitequation=g.FitSettings.clean.equation; fitbounds=g.FitSettings.clean.bounds;

    % get bead and file selections
    beadstr=str2num(g.beadLST.String); %#ok<*ST2NM>
    beadSel=beadstr(g.beadLST.Value).'; nbeadSel=length(beadSel); % g.beadLST.Value became these two lines. can probably do it better :/ here and a few other places to make it work with different numbers$$$
    fileSel=g.fileLST.String(g.fileLST.Value);

    % prepare filename of selected file
    fileSelName=regexprep(fileSel,'cycle','cycle_Bead');
    
    % check that a single cycle file is selected
    if length(fileSel)~=1 || isempty(regexp(fileSel{:},'cycle', 'once'))
        errordlg('Please select a single cycle file for cleaning. (Trace cleaning coming in version 6.5)','Invalid file selection...')
        return
    end  
    
    g.cleanMSG.msg='The following beads were cleaned:';

    for i=1:nbeadSel
        % get data
        cFile=fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.dat'));
        [data1,data2,data3]=getColFromCycle(cFile{:},fitdatatypes(1),fitdatatypes(2),fitdatatypes(3)); %$$$ did some preallocating in getcolfromcycle 
        warning('off','curvefit:prepareFittingData:removingNaNAndInf');
        [xData, yData, ~] = prepareCurveData( data1, data2, data3 );

        % attempt fit 
        try
            if length(xData)>2 || length(yData)>2
                % Gets boundary conditions and starting point from fcalbounds.
                LB=[eval(fitbounds{1,1}{1}) eval(fitbounds{1,1}{2}) eval(fitbounds{1,1}{3})]; %EVAL EVERYTHING
                SP=[eval(fitbounds{1,2}{1}) eval(fitbounds{1,2}{2}) eval(fitbounds{1,2}{3})]; %$$$ any way to get rid of eval? is it such a big deal anyway?
                UB=[eval(fitbounds{1,3}{1}) eval(fitbounds{1,3}{2}) eval(fitbounds{1,3}{3})];
                
                % Gets fittype from input string.
                ft = fittype( fitequation, 'independent', 'x', 'dependent', 'y' );
                fo = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',LB,'Upper',UB,'StartPoint',SP,'MaxI',50);                
                [~,gdns,~] = fit ( xData, yData, ft, fo );

                if gdns.rsquare>goodness %if fit good enough, do nothing
                else %if fit no good, remove beadfiles
                    olddatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.dat'))); % no idea why all of these need to be charred $$$
                    newdatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.CLEANEDnoFIT')));
                    movefile(olddatafile,newdatafile);
                    g.cleanMSG.msg=strcat(g.cleanMSG.msg,{' '},newdatafile);
                end
            else %if no data, remove beadfiles
              	olddatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.dat')));
              	newdatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.CLEANEDnoDATA')));
            	movefile(olddatafile,newdatafile);
             	g.cleanMSG.msg=strcat(g.cleanMSG.msg,{' '},newdatafile);
            end % if
        catch %if fit fails, remove beadfiles
          	olddatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.dat')));
          	newdatafile=char(fullfile(h.path,strcat(fileSelName,num2str(beadSel(i)),'.CLEANEDnoFIT')));
         	movefile(olddatafile,newdatafile);
         	g.cleanMSG.msg=strcat(g.cleanMSG.msg,{' '},newdatafile);
        end %try/catch
    end %for
    
    if strcmp(g.cleanMSG.msg,'The following beads were cleaned:');
        g.cleanMSG.box = msgbox('Nothing to clean here! You can up the goodness to catch more bad fits.','Cleaning complete.');
    else
        g.cleanMSG.box = msgbox( g.cleanMSG.msg, 'Files Cleaned!');
    end
	checkDir;

end %removes bead files (from cycle files only) with two or less data points ?? look into removing data from all files also