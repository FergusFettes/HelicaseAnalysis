function HelicaseAnalysisGUI
 clc;clear;close all;
%% Variables and initial values %%
% Positions for the popup windows
% small screen settings
%  g.defPos=[850          309         721         588];
%  g.defPosGUI=[450         450         350         500];
%  g.defPosPAR=[514         691         336         206];
%  g.dataHarvestPosition=[2150         150         850         900];

%big screen settings
g.defPos=[2350          309         721         588];
g.defPosGUI=[1950         450         350         500];
g.defPosPAR=[2014         691         336         206];
g.dataHarvestPosition=[2150         150         850         900];
g.ttrcPos = g.defPos+[0 -220 100 360];

% variables for minimized/maximized height
pheightmin = 20; %titlewidth
pheightmax = 235; %can be -1

% Standard goodnesses for fits & clean. If you change these you should change the
%'Value' of the popup boxes accordingly.
g.GoodParams.fcal=0.8;g.GoodParams.fext=0.8;g.GoodParams.clean=0.6;

%standard height value for trace cleaning
g.cleanhi=6;

% Preassigning zoomdata
g.zoomdat.xmin=[]; g.slideval=100; g.riseval=0.1;

% Fit equations & bounds & datatypes (datatype numbers found in getcolfromcycle)
g.FitTypes.Cali1.equation= @(a,b,c,x) exp(a.*x.^2 + b.*x + c);
g.FitTypes.Cali1.bounds={   {'-10' '-10' '0'}, ...                           lower bounds 
                            {'0' '-log(mean(xData))' 'log(max(yData))'}, ... start point 
                            {'0' '0' '5'} };
g.FitTypes.Cali1.data=[8, 2, 3];
g.FitTypes.Worm.equation=  @(a,b,x) ((1.38e-23.*298)./(b.*1e-9)).* ... k_B T over persistance length (p in nanometers) a=L b=p
                                ((4.*(1-(x./a)).^2).^(-1) - 4.^(-1) + ... first two bracketed compontents
                                  (x./a) - 0.5164228.*(x./a).^2 - 2.737418.*(x./a).^3 + 16.07497.*(x./a).^4 - 38.87607.*(x./a).^5 + 39.49944.*(x./a).^6 - 14.17718.*(x./a).^7) ... sum with coefficients
                                    .*1e12; %$$$
g.FitTypes.Worm.bounds={    {'max(xData)' '0' '[]'}, ...      lower bounds (must be three-component arrays) !!!ALL THIS EVAL STUFF CAN BE SORTED WITH OBJECT ORIENTED PROGRAMMING
                            {'1.1*max(xData)' '50' '[]'}, ... start point 
                            {'10' '100' '[]'} };            % upper bounds
g.FitTypes.Worm.data=[1, 2, 3];
                
% Standard equations (for quickbuttons)
g.FitSettings.clean= g.FitTypes.Worm;
g.FitSettings.fcal=  g.FitTypes.Cali1; 
g.FitSettings.fext=  g.FitTypes.Worm;
    
%initializing these fellows, not really sure why !!!
g.figsMSG.fcalexports='string';g.figsMSG.fextexports='string';

d.collect_data.force=[];d.collect_data.height_bp=[];d.collect_data.velocity_bp=[];
d.collect_data.rate=[];d.collect_data.height=[];d.collect_data.time=[];d.collect_data.velocity=[];

%initialize event structure and temp holder
e=[]; t=[]; analysis=struct(); analysis.LittleUpdate = 0;

%% LAYOUT %%
g.FIGS.main=figure('Name','parPlots GUI © DNAmotors','NumberTitle','off','Toolbar','none','Menubar','none','Position',g.defPosGUI);
    g.FIGS.Params=[];
    
h=guidata(g.FIGS.main);
h.path='D:\data\Fergus\2017-03-01'; %!!! change back for finish NB tmp 036 has some good examples of data that could afford to be truncated. maybe use for learning to truncate

g.vbox1=uix.VBox('Parent',g.FIGS.main);
% Path Selection %
    g.pathPN=uix.Panel('Parent',g.vbox1);
    g.pathBOX=uix.HBox('Parent',g.pathPN);
        g.pathTXT=    uicontrol('Parent',g.pathBOX,     'Style','text',     'String','Path:');
        g.pathEDT=    uicontrol('Parent',g.pathBOX,     'Style','edit',     'String',h.path,    'Callback',{@checkDir});
        g.pathBTN=    uicontrol('Parent',g.pathBOX,     'Style','push',     'String','Select',  'Callback',{@pathSEL});
        g.refrBTN=    uicontrol('Parent',g.pathBOX,     'Style','push',     'String','Refresh', 'Callback',{@checkDir});
    set(g.pathBOX,'Widths',[50 -1 50 50])
    
% Plot Action Panels %
    g.mainBOX=uix.HBox('Parent',g.vbox1 );
        g.actnBOX=uix.VBox('Parent',g.mainBOX);
            g.actnTXT= uicontrol('Parent',g.actnBOX,   'Style','text',     'String','Actions...');
            
            %Quick Action Access
            g.quickPAN= uix.BoxPanel('Padding',5,'Title', 'Quick Controls', 'Parent', g.actnBOX);
                g.quickBOX= uix.VBox('Parent',g.quickPAN);
                    g.quickCTRLGRD= uix.Grid('Parent',g.quickBOX, 'Spacing', 5);
                        g.quickFCALBTN=     uicontrol('Parent',g.quickCTRLGRD,'String','F.Cal',         'Callback',{@fcal},'Tag','1');
                        g.quickFEXTBTN=     uicontrol('Parent',g.quickCTRLGRD,'String','F.Ext (WLC)',   'Callback',{@fext},'Tag','1');
                        g.quickTTRCBTN=     uicontrol('Parent',g.quickCTRLGRD,'String','Time Trace',    'Callback',{@ttrc});
                        g.quickCLEANBTN=    uicontrol('Parent',g.quickCTRLGRD,'String','Collect Data',  'Callback',{@DataHarvest});
                        g.quickFRCBTN=      uicontrol('Parent',g.quickCTRLGRD,'String','Fast Force',    'Callback',{@force});
                        g.quickEXPRTBTN=    uicontrol('Parent',g.quickCTRLGRD,'String','Data2MATLAB',   'Callback',{@exdat});
                    set(g.quickCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                    
            %Panel containing options for force calibration
            g.fcalPAN= uix.BoxPanel('Padding',5,'Title', 'Force Calibration Options', 'Parent', g.actnBOX);
                g.fcalBOX= uix.VBox ('Parent',g.fcalPAN);
                    g.fcalCTRLGRD= uix.Grid('Parent',g.fcalBOX, 'Spacing', 5);
                        g.fcalCHKBOX= uipanel('Parent',g.fcalCTRLGRD, 'Title', 'Fit');
                            g.fcalCHK= uicontrol('Value',1,'Tag', 'fcalBTN', 'Parent', g.fcalCHKBOX, 'Style','checkbox', 'Callback', {@checkboxvalue});
                        g.fcalGOODBOX= uipanel('Parent',g.fcalCTRLGRD, 'Title', 'Fit Goodness:');
                            g.fcalGOODLST= uicontrol('Parent',g.fcalGOODBOX,'Style','popup','String',{0:0.01:1},...
                                'Callback',{@good},'Tag','fcal','Value',81);
                        g.fcalGRDBOX_3= uipanel('Parent',g.fcalCTRLGRD);
                        g.fcalGRDBOX_4= uipanel('Parent',g.fcalCTRLGRD);
                        g.fcalGRDBOX_5= uipanel('Parent',g.fcalCTRLGRD);
                        g.fcalGRDBOX_6= uipanel('Parent',g.fcalCTRLGRD);
                    set(g.fcalCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                    g.fcalBTN= uicontrol('Parent',g.fcalBOX,   'String','Plot',   'Callback',{@fcal},'Tag','1');
                set(g.fcalBOX, 'Heights',[-1 25]);
                
            %Panel containing options for force extension.
            g.fextPAN= uix.BoxPanel('Padding',5,'Title', 'Force Extension Options', 'Parent', g.actnBOX);
                g.fextBOX= uix.VBox ('Parent',g.fextPAN);
                    g.fextCTRLGRD= uix.Grid('Parent',g.fextBOX, 'Spacing', 5);
                        g.fextWLCBOX= uipanel('Parent',g.fextCTRLGRD, 'Title', 'WLC:');
                           g.fextWLCCHK= uicontrol('Value',1,'Tag', 'fextWLCBTN', 'Parent', g.fextWLCBOX, 'Style','checkbox', 'Callback', {@checkboxvalue});
                        g.fextGOODBOX= uipanel('Parent',g.fextCTRLGRD, 'Title', 'Fit Goodness:');
                            g.fextGOODLST= uicontrol('Parent',g.fextGOODBOX,'Style','popup','String',{0:0.01:1},...
                                'Callback',{@good},'Tag','fext','Value',81);
                        g.fextGRDBOX_3= uipanel('Parent',g.fextCTRLGRD);
                        g.fextGRDBOX_4= uipanel('Parent',g.fextCTRLGRD);
                        g.fextGRDBOX_5= uipanel('Parent',g.fextCTRLGRD);
                        g.fextGRDBOX_6= uipanel('Parent',g.fextCTRLGRD);
                    set(g.fextCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                    g.fextWLCBTN= uicontrol('Parent',g.fextBOX, 'Style','push',   'String','Plot',...
                        'Callback',{@fext},'Tag','1'); %tag '0' for no wlc tag '1' for wlc
                set(g.fextBOX, 'Heights',[-1 25]);
                
            %Panel containing options for time trace    
            g.ttrcPAN= uix.BoxPanel('Padding',5,'Title', 'Time Trace/Conversion Options', 'Parent', g.actnBOX);
                g.ttrcBOX= uix.VBox ('Parent',g.ttrcPAN);
                    g.ttrcCTRLGRD= uix.Grid('Parent',g.ttrcBOX, 'Spacing', 5);
                        g.ttrcGRDBOX_1= uipanel('Parent',g.ttrcCTRLGRD);
                        g.ttrcGRDBOX_2= uipanel('Parent',g.ttrcCTRLGRD);
                        g.ttrcGRDBOX_3= uipanel('Parent',g.ttrcCTRLGRD);
                        g.ttrcGRDBOX_4= uipanel('Parent',g.ttrcCTRLGRD);
                        g.ttrcGRDBOX_5= uipanel('Parent',g.ttrcCTRLGRD);
                        g.ttrcGRDBOX_6= uipanel('Parent',g.ttrcCTRLGRD);
                    set(g.ttrcCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                    g.ttrcBTN= uicontrol('Parent',g.ttrcBOX, 'Style','push',   'String','Go!',   'Callback',{@ttrc});
                set(g.ttrcBOX, 'Heights',[-1 25]);
                
            %Panel containing cleaning options
            g.cleanPAN= uix.BoxPanel('Padding',5,'Title', 'Cleaning Options', 'Parent', g.actnBOX);
                g.cleanBOX= uix.VBox ('Parent',g.cleanPAN);
                    g.cleanCTRLGRD= uix.Grid('Parent',g.cleanBOX, 'Spacing', 5);
                        g.cleanGRDBOX_1= uipanel('Parent',g.cleanCTRLGRD);
                        g.cleanGOODBOX= uipanel('Parent',g.cleanCTRLGRD, 'Title', 'Clean Goodness:');
                            g.cleanGOODLST= uicontrol('Parent',g.cleanGOODBOX,'Style','popup','String',{0:0.01:1},...
                                'Callback',{@good},'Tag','clean','Value',61);
                        g.cleanGRDBOX_3= uipanel('Parent',g.cleanCTRLGRD);
                        g.cleanGRDBOX_4= uipanel('Parent',g.cleanCTRLGRD);
                        g.cleanEQTNBOX= uipanel('Parent',g.cleanCTRLGRD,'Title','Clean Equation:');
                            g.cleanEQTNLST= uicontrol('Parent',g.cleanEQTNBOX,'Style','popup','String', ...
                                {'Worm-Like-Chain' 'Calibration'}, 'Callback',{@eqtn},'Tag','clean','Value',1);
                        g.cleanRSTRBOX= uipanel('Parent',g.cleanCTRLGRD,'Title','Restore Files:');
                            g.cleanRSTRBTN= uicontrol('Parent',g.cleanRSTRBOX,'String','Unclean','Callback',{@restore});
                    set(g.cleanCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                    g.cleanBTN= uicontrol('Parent',g.cleanBOX,'String','Clean Files','Callback',{@clean});
                set(g.cleanBOX, 'Heights',[-1 25]);
                
%             g.svfsBTN=uicontrol('Parent',g.actnBOX,   'Style','push',     'String','Save Open Figures');
            g.exfsBTN=uicontrol('Parent',g.actnBOX,   'Style','push',     'String','Export Figures','Callback',{@exfs});
            
            %adds correctly numbered minimizefunction to panels
            %gets childs and assigns panels, can be done for any actionbox just by changing the line below. 
            childs=flip(allchild(g.actnBOX));
            n1=length(childs); panel{10}='smth'; % initializes panel array (up to ten panels)
            for q=3:(n1-1) %avoiding title, quickbox and bottom button
                panel{q}=childs(q);
                set(panel{q}, 'MinimizeFcn', {@nMinimize, q}, 'Minimized', true);
            end
            
% Files %
        g.fileBOX=uix.VBox('Parent',g.mainBOX);
            g.fileTXT=uicontrol('Parent',g.fileBOX,   'Style','text',     'String','Files...');
            g.fileLST=uicontrol('Parent',g.fileBOX,   'Style','list',     'Callback',{@checkBeads}, 'Max',100);
        set(g.fileBOX,'Heights',[15 -1])
% Beads %
        g.beadBOX = uix.VBox('Parent',g.mainBOX);
            g.beadTXT=uicontrol('Parent',g.beadBOX,   'Style','text',     'String','Beads...');
            g.beadLST=uicontrol('Parent',g.beadBOX,   'Style','listbox',  'Max',100);
        set(g.beadBOX,'Heights',[15 -1])
    set(g.mainBOX,'Widths',[200 -1 70])

set(g.vbox1,'Heights',[30 -1])

set(g.actnBOX, 'Heights', [15 120 pheightmin*ones(1,(n1-3)) 25] );

% Minimization %minimizing function. uses pheight values assigned at the start
function nMinimize( eventSource, eventData, whichpanel )%#ok<INUSL>
        s = get( g.actnBOX, 'Heights' );
        panel{whichpanel}.Minimized = ~panel{whichpanel}.Minimized;
        
        if panel{whichpanel}.Minimized
            s(whichpanel) = pheightmin;
        else
            s(whichpanel) = pheightmax;
        end
        set( g.actnBOX, 'Heights', s );
end

%% Initialize %%
checkDir;
        
%% CALLBACKS %%  
function checkDir(~,~)
    % set path to String in Text-Edit field
    h.path=g.pathEDT.String;

    % check for folder at path location
    if exist(h.path,'dir') ~=7
        errordlg('Please select an existing Folder','Folder not found...');
        return;
    end

    % get old file selection
    fileSelOld=g.fileLST.Value;
    nFilesOld=length(g.fileLST.String);

    % check that folder contains tweezer dat files
    dir_content=dir(fullfile(h.path,'tmp_*.dat'));
    if isempty(dir_content)
        errordlg('Please select a Folder containing tweezers files!','Folder empty...');
        return;
    end

    % get dat filenames
    rawFilenames = {dir_content.name};
    datFilenames=regexp(rawFilenames(:),'(tmp_\d{3})(?:.dat)','tokens');
    datFilenames=[datFilenames{:}];
    % get cycle filenames
    cycleFilenames=regexp(rawFilenames(:),'(tmp_\d{3}_cycle)','tokens');
    cycleFilenames=[cycleFilenames{:}];
    cycleFilenames=unique([cycleFilenames{:}]');
    % merge lists 
    if iscell(cycleFilenames)
        allFilenames=flip(sort([datFilenames{:},cycleFilenames{:}]));
    else
        allFilenames=flip(sort([datFilenames{:}]));
    end
    % populate listbox
    g.fileLST.String=allFilenames;
    nFilesNew=length(g.fileLST.String);
    h.filenames=allFilenames;

    % retain old file selection: oldfile selection + nFilesNew
    if nFilesNew>=nFilesOld && nFilesOld>0
        filesNew=fileSelOld + (nFilesNew-nFilesOld);
        g.fileLST.Value=filesNew;
    else
        g.fileLST.Value =1; % if nFilesNew < nFilesOld %!!!changed for trialling
    end

    % get n beads
    checkBeads;

    guidata(g.FIGS.main,h)
end %check directory, also refresh files

function checkBeads(~,~)
    % get old bead selection
    beadSelOld=g.beadLST.Value;
    % nBeadsOld=length(g.beadLST.String);

    % get file selection
    fileSel=g.fileLST.Value; 
    nfileSel=length(fileSel);

    % get DNAbeads from logs of all selected files
    DNAbeads=zeros(1,nfileSel);
    for i=1:nfileSel;
        cFile=fileSel(i);
        filenum=regexp(h.filenames{cFile},'tmp_\d\d\d','match');
        cFilename=fullfile(h.path,strcat(filenum,'.log'));
        DNAbeads(i)=getNumFromLog(cFilename{:},'#beads'); %gtnumfromlog $$$ got improper assignment with rectangular matrix error while doing ttrc
    end

    % if files have unequal DNAbeads, error and revert number of files selected to 1
    if length(unique(DNAbeads))~=1
        errordlg('Number of beads in selected files not equal, resetting selection','Number of beads not equal');
        fileSel=fileSel(1);
        g.fileLST.Value=fileSel;
        DNAbeads=DNAbeads(1);
    end

    % check none of the beads have been cleaned
    beadsNew= 1:DNAbeads(1);
    beadcln=zeros(DNAbeads(1),1);

    fileNam=g.fileLST.String(g.fileLST.Value);
    if length(fileNam)==1 && ~isempty(regexp(fileNam{:},'cycle', 'once'))
        for i=1:DNAbeads(1)
            datfile=char(fullfile(h.path,strcat(filenum,'_cycle_Bead',num2str(beadsNew(i)),'.dat')));
            if  exist(datfile,'file');
                beadcln(i)=i;
            else beadcln(i)=0;
            end
        end

    %populate list
    beadcln=beadcln(beadcln~=0);
    nBeadsNew=length(beadcln);
    g.beadLST.String=beadcln;

    else

    % populate list
    beadsNew=1:DNAbeads(1);
    nBeadsNew=length(beadsNew);
    g.beadLST.String=beadsNew;

    end

    % if prev selection possible, retain, else revert to 1
    if max(beadSelOld) > nBeadsNew  
        g.beadLST.Value=1:length(g.beadLST.String); %!!!ALL THE BEADS
    else g.beadLST.Value=beadSelOld; 
    end

    end %populate bead list from selected files

function clean(~,~)

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

function fcal(tagval,~)
    % get bead and file selections
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

function fext(tagval,~) 
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

function ttrc(~,~) 
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).'; % nbeadSel=length(beadSel);
    fileSel=sort(g.fileLST.String(g.fileLST.Value));
    fileID=regexp(fileSel,'tmp_(\d{3})','tokens'); fileID=[fileID{:}]; 
    
    if isfield(g.FIGS, 'ttrc'); figslong=length(g.FIGS.ttrc)+1; else figslong=1; end
    tag=strcat('ttrc',{' '},'tmp_',strjoin(unique([fileID{:}]),'_'),{' '},'Figure',{' '},num2str(figslong)); % tag is different if you select a cycle and its files, but plot is the same $$$
    figname=strcat('Time Trace:',{' '},regexprep(tag,'^(\w+\s?)',''));
 
    cycles=regexp(fileSel,'tmp_\d\d\d_cycle','match'); cycles=[cycles{:}];
    if sum(~cellfun(@isempty,cycles))>0 %if cycle files exist
        cycleFileIDs=[];
        for i=1:length(cycles)
            fn=fullfile(h.path,strcat(cycles(i),'_Bead',num2str(beadSel(1))','.dat'));  % use cycle of first selected bead
            cycleFileIDs=[cycleFileIDs;getColFromCycle(fn{:},6)];                       % assemble list of .dat files
        end
        fileSel=fileSel(cellfun(@isempty,regexp(fileSel,'cycle')));                     % remove _cycle files
        fileSel=[fileSel;strsplit(strtrim(sprintf('tmp_%03d\n',cycleFileIDs)))'];       %add .dats from cycle $$$ %03d\n gets the numbers of the dat files, adding zeros until they are three digits?
    end
    fileSel=unique(fileSel); % perhaps the cycle file thing is to allow you to select a few of the files from the cycle
    fileID=regexp(fileSel,'tmp_(\d\d\d)','tokens'); fileID=[fileID{:}]; 

    if  sum(cellfun(@exist,fullfile(h.path,strcat(fileSel,'.dat')))~=2) %checks that fileSel refers to existing files
        errordlg('Please select existing .dat files only','Invalid file selection...')
        return
    end

    % create figure with enough subplots
    g.FIGS.ttrc(figslong)=figure('Position',(g.ttrcPos),'Name',figname{:},'NumberTitle','off', ...
        'Toolbar','none','Menubar','none','Tag',tag{:});
%         g.FIGS.ttrc(figslong)=figure('Position',(g.defPos+[0 -200 50 200]),'Name',figname{:},'NumberTitle','off', ...
%         'Toolbar','none','Menubar','none','Tag',tag{:});
    
    TraceParams (tag);

    %% get Data 
    try framerate=getNumFromLog(char(fullfile(h.path,strcat(fileSel,'.log'))),'framerate'); catch; framerate=300; end %this is totally cheating, but i have no idea whats going on here !!!
    files(1:500)=struct('t',zeros(100000,1),'mp',zeros(100000,1),'refZ',zeros(100000,1),'refZ_sm',zeros(100000,1),'Bead',[]); %initialize structure $$$ possibly could have initialized Bead.z further
    for f=1:length(fileSel)
        cFile=fullfile(h.path,strcat(fileSel{f},'.dat'));                      	 % assemble filename
        fid=str2num(fileID{f}{:});                                            	 % string fileID $$$evidence!
        [DNAbeads]=getNumFromLog(strcat(cFile(1:end-4),'.log'),'#DNAbeads');   	 % get number of beads
        data=getTweezerDataMB(cFile);                                          	 % load data ?? gettweezerdatamb$$$
        d.tracedata(fid).t=data{1};                                                    % assign t
        d.tracedata(fid).mp=data{2};                                                   % assign mp
%         files(fid).refZ=data{3*(DNAbeads+2)};                                    % assign refZ
        smoothdat=data{3*(DNAbeads+2)}; smoothdat(isnan(smoothdat))=0;           % NaNs kill smooth
        d.tracedata(fid).refZ=smooth(smoothdat,framerate./10);                    	 % assign refZ (smooth)

        for beadID=beadSel; 
            d.tracedata(fid).Bead(beadID).zNORM=data{3*(beadID+1)};
        	smoothdat=data{3*(beadID+1)}; smoothdat(isnan(smoothdat))=0;         %NaNs kill smooth
            d.tracedata(fid).Bead(beadID).z=smooth(smoothdat,framerate./10);
        end;   % assign z all DNAbeads
    end
    %% Layout
    vbox1=uix.VBox('Parent',g.FIGS.ttrc(figslong));                    % first create all pnls
        hbox1=uix.HBox('Parent',vbox1);
            refPAN=uix.Panel('Parent',hbox1); 
            magPAN=uix.Panel('Parent',hbox1); 
        g.FIGS.pnlTAB(figslong) = uix.TabPanel('Parent',vbox1);
    set(vbox1,'Heights',[-1 -5]);
    for b=1:length(beadSel)
        g.FIGS.beadPAN(figslong).mainPAN(beadSel(b)) = uix.Panel('Parent',g.FIGS.pnlTAB(figslong));
        ubermainBOX=uix.VBox('Parent',g.FIGS.beadPAN(figslong).mainPAN(beadSel(b)));
            mainBOX = uix.HBox('Parent',ubermainBOX);
            
            %general buttons
                ctrlBOX = uix.VBox('Parent',mainBOX);
                    ctrlPAN_1 = uix.Panel('Parent',ctrlBOX);
                        uicontrol('Parent',ctrlPAN_1,'String','Max/Min Height', ... 
                            'Callback',{@getz},'Tag','1');
                    ctrlPAN_2 = uix.Panel('Parent',ctrlBOX);
                        btnBOX= uix.Grid('Parent',ctrlPAN_2);
                            uicontrol('Parent',btnBOX,'String','Delete','Callback',{@delbead});
                            uicontrol('Parent',btnBOX,'String','Average','Callback',{@average});
                            g.BTNS.Params(figslong).ttrc(beadSel(b))= uicontrol('Parent',btnBOX,'Style','togglebutton','String','Params', ...
                                'Callback',{@togglebutton},'Tag',tag{:});
                            uicontrol('Parent',btnBOX,'String','Kill','Tag',num2str(beadSel(b)),'Callback',{@delpan});
                        set(btnBOX,'Heights',[-1 -1],'Widths',[-1 -1]);
                    ctrlPAN_4 = uix.Panel('Parent',ctrlBOX);
                        uicontrol('Parent',ctrlPAN_4,'String','Calculate results!','Callback',{@docalc});
                  	ctrlPAN_3 = uix.Panel('Parent',ctrlBOX);
                        cleanBOX= uix.Grid('Parent',ctrlPAN_3);
                            uicontrol('Parent',cleanBOX,'String','Clean One','Tag',num2str(beadSel(b)),'Callback',{@edit_data});
                            uicontrol('Parent',cleanBOX,'String','Clean All','Tag',num2str(beadSel(b)),'Callback',{@edit_data});
                            uicontrol('Parent',cleanBOX,'String','Save','Tag',num2str(beadSel(b)),'Callback',{@SubmitEvents});
                            uicontrol('Parent',cleanBOX,'String','Undo','Callback',{@plot_beads,fid,figslong,beadSel(b)});
                        set(cleanBOX,'Heights',[-1 -1],'Widths',[-1 -1]);
                        
            %results panels
                rsltBOX= uix.HBox('Parent',mainBOX);
                    meanPAN= uix.Panel('Parent',rsltBOX,'Title','Running Averages');
                        gridnow= uix.Grid('Parent',meanPAN,'Spacing',5);
                            g.FIGS.averages(figslong).un(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Unwinding Speed'),'Style','text');
                            g.FIGS.averages(figslong).unlong(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Unwinding Event Height'),'Style','text');
                        	g.FIGS.averages(figslong).uncount(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Number of Events'),'Style','text');
                            g.FIGS.averages(figslong).re(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Rewinding Speed'),'Style','text');
                            g.FIGS.averages(figslong).relong(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Rewinding Event Height'),'Style','text');
                            g.FIGS.averages(figslong).recount(beadSel(b))= uicontrol('Position',[0 0 150 40],'Parent',uipanel('Parent',gridnow,'Title','Number of Events'),'Style','text');
                        set(gridnow,'Heights',[-1 -1 -1],'Widths',[-1 -1]);
                    uix.Panel('Parent', rsltBOX, 'Title', 'Additional Data Here');
           	set(mainBOX,'Widths',[120,-1]);
            
            %bead trace panel
            graphBOX= uix.HBox('Parent',ubermainBOX);
                beadsBOX= uix.VBox('Parent',graphBOX);
                    g.FIGS.beadsPAN(beadSel(b)) = uix.Panel('Parent',beadsBOX);
                %and controls
                zoomBOX = uix.VBox('Parent',graphBOX);
                    lineBOX= uix.HBox('Parent',zoomBOX);
                        g.FIGS.traceview(figslong).norm(beadSel(b)) = uicontrol('Parent',uipanel('Parent',lineBOX,'Title','normal trace'), 'Style','Checkbox', 'Callback',{@tracetogglebutton,fid,figslong,beadSel(b),1}, 'Value',1);
                        g.FIGS.traceview(figslong).smooth(beadSel(b)) = uicontrol('Parent',uipanel('Parent',lineBOX,'Title','smooth trace'), 'Style','Checkbox', 'Callback',{@tracetogglebutton,fid,figslong,beadSel(b),0}, 'Value',1);
                    hereBOX= uix.HBox('Parent',uipanel('Parent',zoomBOX,'Title','Settings Here'));
                        zoomGRID = uix.Grid('Parent',hereBOX);
                            xstrtPAN=uipanel('Parent',zoomGRID,'Title','x min');
                                g.FIGS.setlim(figslong).xmin(beadSel(b))=uicontrol('Parent',xstrtPAN,'Style','edit','Callback',{@setlim},'Tag','xmin');
                            xfinPAN=uipanel('Parent',zoomGRID,'Title','x max');
                                g.FIGS.setlim(figslong).xmax(beadSel(b))=uicontrol('Parent',xfinPAN,'Style','edit','Callback',{@setlim},'Tag','xmax');
                            ystrtPAN=uipanel('Parent',zoomGRID,'Title','y min');
                                g.FIGS.setlim(figslong).ymin(beadSel(b))=uicontrol('Parent',ystrtPAN,'Style','edit','Callback',{@setlim},'Tag','ymin');
                            yfinPAN=uipanel('Parent',zoomGRID,'Title','y max');
                                g.FIGS.setlim(figslong).ymax(beadSel(b))=uicontrol('Parent',yfinPAN,'Style','edit','Callback',{@setlim},'Tag','ymax');
                        set(zoomGRID,'Heights',[-1 -1],'Widths',[-1 -1]);
                    uicontrol('Parent',zoomBOX,'String','Set Axes','Callback',{@changeplot});
                    %sliding
                    slideBOX= uix.HBox('Parent',uipanel('Parent',zoomBOX,'Title','Slide Window'));
                        uicontrol('Parent',slideBOX,'String','<<-','Callback',{@changeplot});
                        uicontrol('Parent',slideBOX,'String','->>','Callback',{@changeplot});
                        g.FIGS.setlim(figslong).slideval(beadSel(b))=uicontrol('Parent',slideBOX,'Style','edit','String',num2str(g.slideval),'Tag','slideval','Callback',{@setlim});
                  	%raising
                    riseBOX= uix.HBox('Parent',uipanel('Parent',zoomBOX,'Title','Raise/Lower Window'));
                        uicontrol('Parent',riseBOX,'String','/\','Callback',{@changeplot});
                        uicontrol('Parent',riseBOX,'String','\/','Callback',{@changeplot});
                        g.FIGS.setlim(figslong).riseval(beadSel(b))=uicontrol('Parent',riseBOX,'Style','edit','String',num2str(g.riseval),'Tag','riseval','Callback',{@setlim});
                    %global controls
                    globalBOX= uix.HBox('Parent',uipanel('Parent',zoomBOX,'Title','All Beads'));
                        zoomGRID = uix.Grid('Parent',globalBOX);
                            xstrtPAN=uipanel('Parent',zoomGRID,'Title','x min');
                                g.FIGS.globlim(figslong).xmin(beadSel(b))=uicontrol('Parent',xstrtPAN,'Style','edit','Callback',{@setlim},'Tag','glob xmin');
                            xfinPAN=uipanel('Parent',zoomGRID,'Title','x max');
                                g.FIGS.globlim(figslong).xmax(beadSel(b))=uicontrol('Parent',xfinPAN,'Style','edit','Callback',{@setlim},'Tag','glob xmax');
                            ystrtPAN=uipanel('Parent',zoomGRID,'Title','y min');
                                g.FIGS.globlim(figslong).ymin(beadSel(b))=uicontrol('Parent',ystrtPAN,'Style','edit','Callback',{@setlim},'Tag','glob ymin');
                            yfinPAN=uipanel('Parent',zoomGRID,'Title','y max');
                                g.FIGS.globlim(figslong).ymax(beadSel(b))=uicontrol('Parent',yfinPAN,'Style','edit','Callback',{@setlim},'Tag','glob ymax');
                        set(zoomGRID,'Heights',[-1 -1],'Widths',[-1 -1]);
                    uicontrol('Parent',zoomBOX,'String','Global Axes','Callback',{@changeplot});
                set(zoomBOX,'Heights',[55 125 35 55 55 125 35]);
            set(graphBOX,'Widths',[-1 180]);
        set(ubermainBOX,'Heights',[-1 -2]);
    end     

    axsRef=axes('Parent', uicontainer('Parent', refPAN)); hold on; ylabel('RefZ [\mum]','FontSize',8)  % then create axes, to avoid rescaling
    axsMag=axes('Parent', uicontainer('Parent', magPAN)); hold on; ylabel('MagPos [mm]','FontSize',8)
    tabnames={}; %axsBds(100)='tab'; %?? initialize axes
    for b=1:length(beadSel);
        axsBds(beadSel(b))=axes('Parent', uicontainer('Parent', g.FIGS.beadsPAN(beadSel(b)))); hold on;  %#ok<*AGROW> ?? maybe try and figure this out at some point
        g.FIGS.plot(fid).axes(beadSel(b))=axsBds(beadSel(b));
        xlabel('Time [s]','FontSize',8);
        ylabel(strcat('Bead',{' '},num2str(beadSel(b)),' Z [\mum]'),'FontSize',8);
        tabnames(b)=strcat('Bead',{' '},num2str(beadSel(b)));
    end
    set(g.FIGS.pnlTAB(figslong),'TabTitles',tabnames(:)');

    %% Plots
    globalT=0; %$$$
    tmax=zeros(1,100); %?? need to triple check i actually understand preassassination
    for f=1:length(fileSel);
        fid=str2double(fileID{f}{:});                                                   % string fileID

        %tmax(f)=d.tracedata(fid).t(end);                                                      % track cumul. t
%         plot(axsRef, d.tracedata(fid).t+globalT,d.tracedata(fid).refZ,'b'); hold on;                      	% plot ref
        plot(axsRef, d.tracedata(fid).t+globalT,d.tracedata(fid).refZ,'k','Linewidth',.3);    	% plot ref

        plot(axsMag,d.tracedata(fid).t+globalT,d.tracedata(fid).mp,'r','LineWidth',2);              % plot mag

        for b=1:length(beadSel);
            empty=[];   %dumb that i have to do this. there must be a better way...
            variable=[];
            plot_beads(empty,variable,fid,figslong,beadSel(b));
        end
        %globalT=globalT+tmax(f);                                                      	% track  cumul. t
    end

    %no idea what this is !!!
    ctmax=cumsum(tmax); ct12=(ctmax-diff([0,ctmax])/2);                                	% file annotation pos
    axBds=strsplit(strtrim(sprintf('axsBds(%d) ',beadSel)));                         	% list of axBds
    for f=1:length(fileSel)
        fid=str2double(fileID{f}{:});                                                   % string fileID
        for axs=[{'axsRef','axsMag'} axBds(:)'];                                        % list of all axs
            axes(eval(axs{:})); yl=get(eval(axs{:}),'YLim');                            %#ok<LAXES> % file annotation pos
            line([ctmax(f) ctmax(f)],yl,'LineStyle',':','Color',[.7 .7 .7]); ylim(yl);
            text(ct12(f),yl(2),sprintf('%03d',fid),'FontSize',8,'Color',[.7 .7 .7],'FontAngle','italic')
        end
    end
%     linkaxes([axsRef,axsBds,axsMag],'x'); %!!!???lunacy!

%    set(axsRef,'XTickLabel',[])
%    set(axsMag,'XTickLabel',[])

    pause(.01)
    axis(axsMag,'tight');
    ylabel(axsMag,'Height (mu m)');
    xlabel(axsMag,'Time (s)');
   	axis(axsRef,'tight');
    xlabel(axsRef,'Time (s)');
    ylabel(axsRef,'Height (mu m)');
    for i=1:length(beadSel)
        if max(abs(d.tracedata(fid).Bead(beadSel(i)).z))>10
            axis(axsBds(beadSel(i)),[0 max(d.tracedata(fid).t) 1 4]);
        else
            axis(axsBds(beadSel(i)),'tight');
        end
        xlabel(axsBds(beadSel(i)),'Time (s)');
        ylabel(axsBds(beadSel(i)),'Height (mu m)');
    end

    h.filedat=files;
end %ttrc

function force(~,~)
  	% get bead and file selections
    beadstr=str2num(g.beadLST.String); beadSel=beadstr(g.beadLST.Value).';
    fileSel=g.fileLST.String(g.fileLST.Value); fileSelID=regexp(fileSel,'tmp_(\d\d\d)','tokens'); fileSelID=str2num(fileSelID{:}{:}{:});
    
    answer=inputdlg('Please enter ID of force calibration file: ###','FileID');
    if isempty(answer); return; end
    fileID=str2num(answer{:});
    try
        if length(answer{:})~=3
            errordlg('Please enter a three digit number!','Invalid input!');
            return;
        elseif ~isfield(h.Params,'fcal')
            errordlg('Have you done the force calibration yet?','Parameters not found!');
            return;
        else
            assert(~isempty(h.Params(fileID).fcal.a));
            paramsID=fileID;
        end
    catch
        errordlg('Check the number!','No params for that file!');
       	return;
    end

 	% prepare filename of selected file
    if isfield(g.FIGS,'fcal'); figslong=(1+length(g.FIGS.fcal)); else figslong=1; end
    tag=strcat('force',{' '},fileSel,{' '},'Beads',num2str(beadSel,strcat(repmat('%d,',1,length(beadSel)-1),'%d')),{' '},'Figure',{' '},num2str(figslong));
   	
    % create figure
   	g.FIGS.force(figslong).main=figure('Position',(g.defPosPAR),'Name',strcat('Forces for File:',num2str(fileSelID)),'Toolbar','none','NumberTitle','off','Tag',tag{:});
    boxnow= uix.HBox('Parent',g.FIGS.force(figslong).main);
        gridnow= uix.Grid('Parent',boxnow, 'Spacing', 5);
        panelnow=uix.VBox('Parent',boxnow);
            ctrlGRID= uix.Grid('Parent',panelnow,'Spacing',5);
                uicontrol('Parent',uipanel('Parent',ctrlGRID,'Title','Magnet Position'),'Style','popup','String',{0:0.1:10},'Callback',{@forceval}, ...
                    'Value',11,'Tag',num2str(paramsID));
                g.FIGS.force(figslong).mean=uicontrol('Parent',uipanel('Parent',ctrlGRID,'Title','Mean and Deviation'),'Style','text','Position',[0 0 120 40]);
                g.FIGS.force(figslong).range=uicontrol('Parent',uipanel('Parent',ctrlGRID,'Title','Range and Mode'),'Style','text','Position',[0 0 120 40]);
                uipanel('Parent',ctrlGRID)
            set(ctrlGRID,'Heights',[-1 -1 -1 -5]);
    num=[];
    for i=beadSel
        g.FIGS.force(figslong).beadforce(i)= uicontrol('Parent',uipanel('Parent',gridnow,'Title',strcat('Bead',num2str(i))),'Style','text');
        num=[num(:)' -1];
    end
    set(gridnow,'Widths',-1,'Heights',num);
    pos=get(g.FIGS.force(figslong).main,'Position'); set(g.FIGS.force(figslong).main, 'Position', pos+[0 (-35)*length(num) 0 35*length(num)]);
end %quick overview of the forces on the beads at different magnet positons

function forceval(hObject,~,~)
    % get force box details
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    
    % get param file number from tag
  	in=regexp(get(hObject,'Tag'),'(\d+)$','match'); paramfileID=str2num(in{:});
    
    % get magpos from hObject
    val=get(hObject,'Value'); str=get(hObject,'String');
    magpos=str(val); magpos=str2num(magpos{:});
    
    % get beadSel from tag
    nums=regexp(get(gcf,'Tag'),'\d{1,3}','match'); nums=nums(2:end-1);
    for i=1:length(nums); beadNum(i)=str2num(nums{i}); end
    
    for i=beadNum;
        if h.Params(paramfileID).fcal.gdns(i)==0
            forces(i)=NaN;
        elseif isnan(h.Params(paramfileID).fcal.gdns(i))
            forces(i)=NaN;
        else
            a=h.Params(paramfileID).fcal.a(i); b=h.Params(paramfileID).fcal.b(i); c=h.Params(paramfileID).fcal.c(i);
            forces(i)=exp(a.*magpos.^2+b.*magpos+c);
        end
        g.FIGS.force(index).beadforce(i).String=num2str(forces(i));
    end
    
    forces=forces(forces~=0);
    
    av=mean(forces,'omitnan');
    dev=std(forces,'omitnan');
    
    g.FIGS.force(index).mean.String=strcat(num2str(av),'+/-',num2str(dev));
    
    rang=range(forces);
    common=mode(floor(forces(:)));
    
    g.FIGS.force(index).range.String=strcat('Range:',num2str(rang),'.           Most common:',num2str(common));
    
end %calculates the force and outputs it to force above

function exfs(~,~)
    % Save all open fcal figures
    if isfield(g.FIGS,'fcal')                                           % check that fcals have been created
        g.figsMSG.fcalexports='The following Force Calibration figures were created:';
    for a=find(ishandle(g.FIGS.fcal))                                   % iterate only over valid (undeleted) handles
        tag=regexprep(g.FIGS.fcal(a).Tag,'^(\w+\s?)','');
        fn=fullfile(h.path,tag); 
        export_fig (fn, '-jpg', '-eps', g.FIGS.fcal(a));    % export the figures
        g.figsMSG.fcalexports=strcat(g.figsMSG.fcalexports,{'           '},tag,'.eps');
        g.figsMSG.fcalexports=strcat(g.figsMSG.fcalexports,{'           '},tag,'.jpg');
    end
    g.figsMSG.fcalexports=strcat(g.figsMSG.fcalexports,'.',{'                               '});
    else g.figsMSG.fcalexports=strcat('No Force Calibration figures available! Oh my!',{'                            '});
    end

     % Save all open fext figures
    if isfield(g.FIGS,'fext')                                           % check that fext have been created
        g.figsMSG.fextexports='The following Force Extension figures were created:';
    for a=find(ishandle(g.FIGS.fext))                                   % iterate only over valid (undeleted) handles
        tag=regexprep(g.FIGS.fext(a).Tag,'^(\w+\s?)',''); 
        fn=fullfile(h.path,tag); 
        export_fig (fn, '-jpg', '-eps', g.FIGS.fext(a));    % export the figures
        g.figsMSG.fextexports=strcat(g.figsMSG.fextexports,{'           '},tag,'.eps');
        g.figsMSG.fextexports=strcat(g.figsMSG.fextexports,{'           '},tag,'.jpg');
    end
    g.figsMSG.fextexports=strcat(g.figsMSG.fextexports,'.',{'                               '});
    else g.figsMSG.fextexports=strcat('No Force Extension figures available! Oh dear!',{'                            '});
    end 

%     Save all open ttrc figures
%     if isfield(g.FIGS,'ttrc')                                           % check that ttrc have been created
%         g.figsMSG.ttrcexports='The following Time Trace figures were saved:';
%     for a=find(ishandle(g.FIGS.ttrc))                                   % iterate only over valid (undeleted) handles
%         fn=fullfile(h.path,strcat(g.FIGS.ttrc(a).Tag,'_',g.FIGS.pnlTab(1).TabTitles(g.FIGS.pnlTab(1).Selection),'.eps'));
%         export_fig(fn{:},g.FIGS.ttrc(a)) ;   % export the figure
%         g.figsMSG.ttrcexports=strcat(g.figsMSG.ttrcexports,{' '},g.FIGS.ttrc(a).Tag,'.eps');
%     end
%     g.figs.MSG.ttrcexports=strcat(g.figsMSG.ttrcexports,'.');
%     else g.figsMSG.ttrcexports='No Time Trace figures available! Oh no!';
%     end

    g.figsMSG.message = strcat(g.figsMSG.fcalexports,g.figsMSG.fextexports);
    g.figsMSG.MSGBOX = msgbox( g.figsMSG.message, 'Figures Saved!');

end %exports figures !!! make it so it doesnt save over identical files, easiest probably just to close the figures after saving though that might be annoying

function fitParamsFext(tag,~)
    if  isfield(g.FIGS.Params, 'fext'); figslong=length(g.FIGS.Params.fext)+1; else figslong=1; end
  	g.FIGS.Params.fext(figslong) = figure('Visible','off','Name','Force Extension Parameters', ...
       	'NumberTitle','off','Toolbar','none','Position',(g.defPosPAR+figslong*[5 -5 0 0]),'Tag',tag{:}, ...
            'CloseRequestFcn',@closerequest);
    fitParamsTBL=uitable('Units', 'Normalized','Position',[0 0 1 1],'ColumnName',{'L','p','gdns'});
    beadSel=g.beadLST.Value;
    beadsString=g.beadLST.String;
    fileSel=g.fileLST.String(g.fileLST.Value);
    fileNamesSel=regexprep(fileSel,'cycle','cycle_Bead');
    fileID=regexp(fileNamesSel,'tmp_(\d\d\d)','tokens');
    fileID=str2double(fileID{:}{:}{:});
    fitParamsTBL.RowName=beadsString(beadSel',:);
    fitParamsTBL.Data=[h.Params(fileID).fext.L;h.Params(fileID).fext.p;h.Params(fileID).fext.gdns]';
end %fitParamsFext !!! consider combining these two?

function fitParamsFcal(tag,~)
    if isfield(g.FIGS.Params, 'fcal'); figslong=length(g.FIGS.Params.fcal)+1; else figslong=1; end
   	g.FIGS.Params.fcal(figslong) = figure('Visible', 'off', 'Name','Force Calibration Parameters', ...
    	'NumberTitle','off','Toolbar','none','Position',(g.defPosPAR+figslong*[5 -5 0 0]),'Tag',tag{:}, ...
        	'CloseRequestFcn',@closerequest);
    fitParamsTBL=uitable('Units', 'Normalized','Position',[0 0 1 1],'ColumnName',{'a','b','c','gdns'});
    beadSel=g.beadLST.Value;
    beadsString=g.beadLST.String;
    fileSel=g.fileLST.String(g.fileLST.Value);
    fileNamesSel=regexprep(fileSel,'cycle','cycle_Bead');
    fileID=regexp(fileNamesSel,'tmp_(\d\d\d)','tokens'); fileID=str2double(fileID{:}{:}{:});
    fitParamsTBL.RowName=beadsString(beadSel',:);
    fitParamsTBL.Data=[h.Params(fileID).fcal.a;h.Params(fileID).fcal.b;h.Params(fileID).fcal.c;h.Params(fileID).fcal.gdns]';
end % creates figure displaying fit parameters

%% Functionettes %%

function plot_beads(~,~,fid,figslong,beadnum)
    %plot the beaddata in the right axes
%   g.FIGS.plot(fid).bead(beadnum)=plot(axsBds(beadnum), d.tracedata(fid).t+globalT,d.tracedata(fid).Bead(beadnum).z,'b'); hold on;   % plot bdsZ removed globalT from the line below, see here for usage. dont know what it was for.
    g.FIGS.plot(fid).bead(beadnum).norm(figslong)=plot(g.FIGS.plot(fid).axes(beadnum),...
                                         d.tracedata(fid).t,...
                                          d.tracedata(fid).Bead(beadnum).zNORM, 'k');
  	hold(g.FIGS.plot(fid).axes(beadnum),'on');
    g.FIGS.plot(fid).bead(beadnum).smooth(figslong)=plot(g.FIGS.plot(fid).axes(beadnum),...
                                                d.tracedata(fid).t,...
                                                 d.tracedata(fid).Bead(beadnum).z, 'g');    % plot bdsZ

    %get the x-limits and export them to the axis-changers (local and global) and zoom controls
    xlimits=get(g.FIGS.plot(fid).axes(beadnum),'XLim');
    g.FIGS.setlim(figslong).xmin(beadnum).String=xlimits(1); g.FIGS.setlim(figslong).xmax(beadnum).String=xlimits(2);
    g.FIGS.globlim(figslong).xmin(beadnum).String=xlimits(1); g.FIGS.globlim(figslong).xmax(beadnum).String=xlimits(2);
    g.zoomdat(figslong).xmin(beadnum)=xlimits(1); g.zoomdat(figslong).xmax(beadnum)=xlimits(2);
    
    %get the y-limits and export them to the axis-changers (local and global) and zoom controls
    ylimits=get(g.FIGS.plot(fid).axes(beadnum),'YLim');
    g.FIGS.setlim(figslong).ymin(beadnum).String=ylimits(1); g.FIGS.setlim(figslong).ymax(beadnum).String=ylimits(2);
    g.FIGS.globlim(figslong).ymin(beadnum).String=ylimits(1); g.FIGS.globlim(figslong).ymax(beadnum).String=ylimits(2);
    g.zoomdat(figslong).ymin(beadnum)=ylimits(1); g.zoomdat(figslong).ymax(beadnum)=ylimits(2);
end

function edit_data(hObject,~,~)
   	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
   	fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});
    
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    d.dataedit.t=d.tracedata(fid).t;                                                % assign t
   	d.dataedit.mp=d.tracedata(fid).mp;                                          	% assign mp
   	d.dataedit.refZ=d.tracedata(fid).refZ;                                       % assign refZ
	for i=beadSel; 
      	d.dataedit.Bead(i).z=d.tracedata(fid).Bead(i).z;                          % assign Bead-zs
	end
    
   	%% Clean absurd values
    value=g.cleanhi;
    reverse=10;
    fore=10;
    if strcmp(get(hObject,'String'),'Clean One');  multy=0; elseif strcmp(get(hObject,'String'),'Clean All'); multy=1; end
    if multy==1
        for i=1:length(beadSel)
            ded=[];
            for j=1:length(d.dataedit.Bead(beadSel(i)).z)
                if abs(d.dataedit.Bead(beadSel(i)).z(j))>value
                    ded(j)=j;
                end
            end
            ded(ded==0)=[];
            for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
                maxmax=k+fore;
                minmin=k-reverse;
                while maxmax>length(d.dataedit.t)
                    maxmax=maxmax-1;
                end
                while minmin<1
                    minmin=minmin+1;
                end
                d.dataedit.Bead(beadSel(i)).z(minmin:maxmax)=0;
            end
            cla(g.FIGS.plot(fid).axes(beadSel(i))); g.FIGS.plot(fid).beadTRC(beadSel(i))=plot(g.FIGS.plot(fid).axes(beadSel(i)),d.dataedit.t,d.dataedit.Bead(beadSel(i)).z,'k');
        end
    elseif multy==0
        ded=[];
        thisbead=str2double(get(hObject,'Tag'));
        for j=1:length(d.dataedit.Bead(thisbead).z)
            if abs(d.dataedit.Bead(thisbead).z(j))>value
                ded(j)=j;
            end
        end
        ded(ded==0)=[];
        for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
            maxmax=k+fore;
            minmin=k-reverse;
            while maxmax>length(d.dataedit.t)
                maxmax=maxmax-1;
            end
            while minmin<1
                minmin=minmin+1;
            end
            d.dataedit.Bead(thisbead).z(minmin:maxmax)=0;
        end
      	cla(g.FIGS.plot(fid).axes(thisbead)); g.FIGS.plot(fid).beadTRC(thisbead)=plot(g.FIGS.plot(fid).axes(thisbead),d.dataedit.t,d.dataedit.Bead(thisbead).z,'k');
    end
end %trucates time trace as instructed by user, and creates temporary data

function [paramsout] = varyfit(goodness,fitaxes,fitdatatypes,fitequation,fitbounds,fiton)
    % get bead and file selections
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).';
    fileSel=g.fileLST.String(g.fileLST.Value);

    % prepare filename of selected file
    fileSelName=regexprep(fileSel,'cycle','cycle_Bead');

    Paramsout=[];
    count=0;
    for i=beadSel
        count=count+1;
        % get data
        cFile=fullfile(h.path,strcat(fileSelName,num2str(i),'.dat'));
        [data1,data2,data3]=getColFromCycle(cFile{:},fitdatatypes(1),fitdatatypes(2),fitdatatypes(3)); %$$$ did some preallocating in getcolfromcycle 
        warning('off','curvefit:prepareFittingData:removingNaNAndInf');
        [xData, yData, yErr] = prepareCurveData( data1, data2, data3 );

        axes(fitaxes(count)); %#ok<LAXES> %set current axis ?? in plot cant figure out

        % attempt fit 
        try
            if (length(xData)>2 || length(yData)>2) && fiton % (only for more than two points, with fiton = 1)
                % Gets boundary conditions and starting point from fcalbounds.
                LB=[eval(fitbounds{1,1}{1}) eval(fitbounds{1,1}{2}) eval(fitbounds{1,1}{3})]; %EVAL EVERYTHING
                SP=[eval(fitbounds{1,2}{1}) eval(fitbounds{1,2}{2}) eval(fitbounds{1,2}{3})]; %$$$ any way to get rid of eval? is it such a big deal anyway?
                UB=[eval(fitbounds{1,3}{1}) eval(fitbounds{1,3}{2}) eval(fitbounds{1,3}{3})];

                % Gets fittype from input string.
                ft = fittype( fitequation, 'independent', 'x', 'dependent', 'y' );
                fo = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',LB,'Upper',UB,'StartPoint',SP,'MaxI',50);                
                [fitresult,gdns,~] = fit ( xData, yData, ft, fo );
                
                %Add goodness to Params
                Paramsout.gdns(i)=gdns.rsquare;

                if gdns.rsquare>goodness %if fit good enough, continue
                    % store fit parameters (for later display etc.)
                    fitParams=coeffvalues (fitresult);    

                    for z=1:length(fitParams); letters='a':'m';
                        Paramsout=setfield(Paramsout,letters(z),{i},fitParams(z)); %sets field letters to #params, field index to #beads and that value to the appropriate parameter
                    end

                    % plot fit (variable parameters)
                    Paramscell=cell(length(fitParams),1);
                    for z=1:length(fitParams); Paramscell(z)={fitParams(z)}; end
                    xfit=min(xData):range(xData)/1000:max(xData);
                    yfit=fitequation(Paramscell{:}, xfit);
                    plot(xfit,yfit);  hold on;

                    % plot data
                    errorbar(xData,yData,yErr,'.');
                    ylim([0.9*min(yData) 1.1*max(yData)]);
                    xlim([0.9*min(xData) 1.1*max(xData)]);
                    title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                else %if fit no good, NaN
                    % empty plot with error msg (when fit does not converge)
                    text(0.5,0.5,{'Fit','did not','converge'},'HorizontalAlignment','Center')                          
                    title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                    %NaN params
                    letters='a':'m';
                    for z=1:length(letters); % As above.
                        Paramsout=setfield(Paramsout,letters(z),{i},NaN); %sets field letters to #params, field index to #beads and that value to NaN
                    end
                end
            elseif (length(xData)>2 || length(yData)>2) && ~fiton
                % only show plot of data if fit disabled
                errorbar(xData,yData,yErr,'.');
                ylim([0.9*min(yData) 1.1*max(yData)]);
                xlim([0.9*min(xData) 1.1*max(xData)]);
                title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
            else
                % empty plot with error msg (when <= 2 points)
                text(0.5,0.5,{'Not','enough','points'},'HorizontalAlignment','Center')                          
                title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                %empty params
                letters='a':'m'; Paramsout.gdns(i)=0;
                for z=1:length(letters); % Cant use fcalParams here, have to delete extra fields later
                    Paramsout=setfield(Paramsout,letters(z),{i},0); %sets field letters to #params, field index to #beads and that value to zero
                end
            end % if
        catch
            % empty plot with error msg (when fit does not converge)
            text(0.5,0.5,{'Fit','did not','converge'},'HorizontalAlignment','Center')                          
            title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
            %NaN params
            letters='a':'m'; Paramsout.gdns(i)=NaN;
            for z=1:length(letters); % As above.
                Paramsout=setfield(Paramsout,letters(z),{i},NaN); %sets field letters to #params, field index to #beads and that value to NaN
            end
        end %try/catch

        %delete all uneccesary fields
        if exist('fitParams','var') && (length(fields(Paramsout))>(length(fitParams)+1));
            for z=(length(fitParams)+1):length(letters);
                Paramsout=rmfield(Paramsout,letters(z));
            end
        elseif  ~exist('fitParams','var'); Paramsout=[]; %All the files were ignored, low data
        end

    if fiton && ~isempty(Paramsout); paramsout=struct2cell(Paramsout); else paramsout=[]; end %must convert to cell and back again during export
    end %for
end %varyfit takes parameters and plots graphs and returns fitparameters

function TraceParams(tag,~)
    if  isfield(g.FIGS.Params, 'ttrc'); figslong=(1+length(g.FIGS.Params.ttrc)); else figslong=1; end
   	g.FIGS.Params.ttrc(figslong) = figure('Name','Time Trace Parameters','NumberTitle','off','Toolbar','none', ...
         	'Position',(g.defPosPAR+figslong*[5 -5 0 0]), 'Visible','off','Tag',tag{:},'CloseRequestFcn',@closerequest2);
        g.FIGS.Params.vbox(figslong)= uix.VBox('Parent',g.FIGS.Params.ttrc(figslong));
            g.FIGS.Params.partsBOX(figslong) = uix.VBox('Parent',g.FIGS.Params.vbox(figslong));
            g.FIGS.Params.fitparams(figslong)= uitable('Visible','off','Units', 'Normalized','Parent',g.FIGS.Params.vbox(figslong), ...
                    'ColumnName',{'a','b','c','gdns'});
        set(g.FIGS.Params.vbox(figslong),'Heights',[-5 -1]);
end %parameters for the time trace

function getz (~,~)
    [index,fileID,~,field]=GCF_Data;
    
    oldname=get(g.FIGS.(field{:})(index), 'Name');
    set(g.FIGS.(field{:})(index), 'Name', 'Click figure, hold alt and click on data max + min. Press enter when done.');

    cursorobj=datacursormode(g.FIGS.(field{:})(index));
    cursorobj.SnapToDataVertex = 'on';
    
    while ~waitforbuttonpress
        cursorobj.Enable = 'on';
    end
    cursorobj.Enable = 'off';
    
   	info=getCursorInfo(cursorobj); position={info.Position}.';
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});

    try 
        RowNames=g.FIGS.Params.heights(index).bead(beadnum).RowName;
        partnum=length(RowNames);
    catch 
        g.FIGS.Params.heights(index).PAN(beadnum)=uipanel('Parent',g.FIGS.Params.partsBOX(index),'Title',bead);     %cannot set preperty of deleted object error, I guess because I had another one of the same sort open and deleted it???!!!
            nowbox= uix.VBox('Parent',g.FIGS.Params.heights(index).PAN(beadnum));
                g.FIGS.Params.heights(index).bead(beadnum)= uitable('Units', 'Normalized','Parent',nowbox, ...
                    'ColumnName',{'z-Min','z-Max','Start','Finish'});
        RowNames=[];
        partnum=0;
    end
    
    if mod(length(position),2) %if odd number of positions
        errordlg('Please select mins and maxs in pairs of two!','Bad data!');
        return;
    elseif ~mod(length(position),2) %if even number of positions
        num=length(position)/2;
        part=cell(num,1);
        %split the points into two-part parts
        for i=1:num                             %!!!could easily get rid of many of the {}s in part
            part(i)={position((2*i)-1:(2*i))};                      %gets the nth and n+1th datapoint
                                                                    %make sure they are all the right way round
            if part{i}{1}(2)>part{i}{2}(2)                          %if height of point 1 is greater than height of point 2
                max(i)=part{i}{1}(2); min(i)=part{i}{2}(2);         %max is height of point 1 and min is height of point 2
                finish(i)=part{i}{1}(1); start(i)=part{i}{2}(1);    %finish is time of point 1 and start is time of point 2
            else                                                    %otherwise
                max(i)=part{i}{2}(2); min(i)=part{i}{1}(2);         %max is height of point 2 and min is height of point 1
                finish(i)=part{i}{2}(1); start(i)=part{i}{1}(1);    %finish is time of point 2 and start is time of point 1
            end
            %create rownames (start time)
            row={strcat('T=',num2str(start(i)))};
            RowNames=[RowNames(:)' row];
        end 
      	%ensure parts from different intakes are added together nicely
        for j=partnum+1:partnum+num
           	%export data
           	h.Params(fileID).fig(index).heights(beadnum).part(j)=struct('min',min(j-partnum),'max',max(j-partnum),'start',start(j-partnum),'finish',finish(j-partnum));
        end 
    end
    
  	delete(findall(gcf,'Type','hggroup'));
    
  	set(g.FIGS.Params.heights(index).bead(beadnum),'RowName',RowNames(:)','Data',[h.Params(fileID).fig(index).heights(beadnum).part.min;h.Params(fileID).fig(index).heights(beadnum).part.max;h.Params(fileID).fig(index).heights(beadnum).part.start;h.Params(fileID).fig(index).heights(beadnum).part.finish]');
    set(g.FIGS.Params.ttrc(index),'Visible','on');
    for i=1:length(g.BTNS.Params(index).ttrc)
        if isfield(g.BTNS.Params(index).ttrc(i),'Number')
            set(g.BTNS.Params(index).ttrc(:),'Value',1);
        end
    end
   	set(g.FIGS.(field{:})(index), 'Name', oldname(:)');

    
end %gets points from time trace with help from user

function getparams (~,~)
    [index]=GCF_Data;
    
    % get filenames
    dir_content=dir(fullfile(h.path,'tmp_*.dat'));
    rawFilenames = {dir_content.name};

    % get cycle filenames
    cycleFilenames=regexp(rawFilenames(:),'(tmp_\d{3}_cycle)','tokens');
    cycleFilenames=[cycleFilenames{:}];
    cycleFilenames=unique([cycleFilenames{:}]');
    cycleNumbers=regexp(cycleFilenames,'(\d{3})','tokens'); cycleNumbers=[cycleNumbers{:}];
    
    % user selects appropriate cycle file from list
    selection=listdlg('PromptString','Please choose ID of force calibration file: ###',...
                    'SelectionMode','single',...
                     'ListString',[cycleNumbers{:}]);
    answer=cycleNumbers{selection};
    if isempty(answer); return; end
    
    fileID=str2num(answer{:});
    try
        if length(answer{:})~=3
            errordlg('Please enter a three digit number!','Invalid input!');
            return;
        elseif ~isfield(h.Params,'fcal')
            errordlg('Have you done the force calibration yet?','Parameters not found!');
            return;
        else
            assert(~isempty(h.Params(fileID).fcal.a));
            names=[]; for i=1:length(h.Params(fileID).fcal.a); names=[names(:)' {num2str(i)}]; end
            g.FIGS.Params.fitparams(index).RowName=names(:)';
            g.FIGS.Params.fitparams(index).Data=[h.Params(fileID).fcal.a;h.Params(fileID).fcal.b;h.Params(fileID).fcal.c;h.Params(fileID).fcal.gdns]';
        end
    catch
        errordlg('Check the number!','No params for that file!');
       	return;
    end
    g.FIGS.Params.fitparams(index).Visible='on';
end %imports fcal parameters for finishing the analysis

function docalc (~,~)
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

function setlim(hObject,~,~)
  	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});
    
    beads=regexprep(beadnames,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    if strcmp(get(hObject,'Tag'),'xmin')
        g.zoomdat(index).xmin(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'xmax')
        g.zoomdat(index).xmax(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'ymin')
        g.zoomdat(index).ymin(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'ymax')
        g.zoomdat(index).ymax(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'slideval')
        g.slideval=str2num(get(hObject,'String'));
        for i=beadSel
            set(g.FIGS.setlim(index).slideval(i),'String',get(hObject,'String'));
        end
    elseif strcmp(get(hObject,'Tag'),'riseval')
        g.riseval=str2num(get(hObject,'String'));
        for i=beadSel
            set(g.FIGS.setlim(index).riseval(i),'String',get(hObject,'String'));
        end
    end
    
    %!!! The name 'String' is not an accessible property for an instance of
    %class 'matlab.graphics.GraphicsPlaceholder'. error when I try to use :
    %instead of this horrible loop. I have this same problem elsewhere.
    
    for i=beadSel
        if strcmp(get(hObject,'Tag'),'glob xmin')
            g.zoomdat(index).xmin(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).xmin(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).xmin(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob xmax')
            g.zoomdat(index).xmax(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).xmax(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).xmax(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob ymin')
            g.zoomdat(index).ymin(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).ymin(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).ymin(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob ymax')
            g.zoomdat(index).ymax(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).ymax(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).ymax(i),'String',get(hObject,'String'));
        end
    end
end %sets the limits for time trace

function changeplot(hObject,~,~)
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2num(fileID{:});
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});

    if strcmp(get(hObject,'String'),'<<-')
        g.zoomdat(index).xmin(beadnum)=g.zoomdat(index).xmin(beadnum)-g.slideval;
        g.zoomdat(index).xmax(beadnum)=g.zoomdat(index).xmax(beadnum)-g.slideval;
        set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)]);
        set(g.FIGS.setlim(index).xmin(beadnum),'String',num2str(g.zoomdat(index).xmin(beadnum)));
        set(g.FIGS.setlim(index).xmax(beadnum),'String',num2str(g.zoomdat(index).xmax(beadnum)));
    elseif strcmp(get(hObject,'String'),'->>')
        g.zoomdat(index).xmin(beadnum)=g.zoomdat(index).xmin(beadnum)+g.slideval;
        g.zoomdat(index).xmax(beadnum)=g.zoomdat(index).xmax(beadnum)+g.slideval;
        set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)]);
        set(g.FIGS.setlim(index).xmin(beadnum),'String',num2str(g.zoomdat(index).xmin(beadnum)));
        set(g.FIGS.setlim(index).xmax(beadnum),'String',num2str(g.zoomdat(index).xmax(beadnum)));
    elseif strcmp(get(hObject,'String'),'\/')
        g.zoomdat(index).ymin(beadnum)=g.zoomdat(index).ymin(beadnum)-g.riseval;
        g.zoomdat(index).ymax(beadnum)=g.zoomdat(index).ymax(beadnum)-g.riseval;
        set(g.FIGS.plot(fileID).axes(beadnum),'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        set(g.FIGS.setlim(index).ymin(beadnum),'String',num2str(g.zoomdat(index).ymin(beadnum)));
        set(g.FIGS.setlim(index).ymax(beadnum),'String',num2str(g.zoomdat(index).ymax(beadnum)));
    elseif strcmp(get(hObject,'String'),'/\')
        g.zoomdat(index).ymin(beadnum)=g.zoomdat(index).ymin(beadnum)+g.riseval;
        g.zoomdat(index).ymax(beadnum)=g.zoomdat(index).ymax(beadnum)+g.riseval;
        set(g.FIGS.plot(fileID).axes(beadnum),'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        set(g.FIGS.setlim(index).ymin(beadnum),'String',num2str(g.zoomdat(index).ymin(beadnum)));
        set(g.FIGS.setlim(index).ymax(beadnum),'String',num2str(g.zoomdat(index).ymax(beadnum)));
    else
        if strcmp(get(hObject,'String'),'Set Axes')
            set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)],'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        elseif strcmp(get(hObject,'String'),'Global Axes')
            for i=1:20
                try %!!! see elsewhere for complaints about this horrible loop. needs fixing
                    set(g.FIGS.plot(fileID).axes(i),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)],'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
                catch
                end
            end
        end
    end
end % updates plot with new limits

function average(~,~,~)
  	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2num(fileID{:});
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});
    
    dat=h.Params(fileID).fig(index).results(beadnum);
    % 'force'   'height_bp'     'velocity_bp'   'rate'  'height'    'time'  'velocity'  'conversion'
    
    velo=dat.velocity_bp;
    velowind=velo(velo<0); velounwind=velo(velo>0);
    
    proc=dat.height_bp;
    procwind=proc(velo<0); procunwind=proc(velo>0);
    
    g.FIGS.averages(index).re(beadnum).String=strcat(num2str(mean(velowind)),'+/-', num2str(std(velowind)));
    g.FIGS.averages(index).relong(beadnum).String=strcat(num2str(mean(procwind)),'+/-', num2str(std(procwind)));
    g.FIGS.averages(index).recount(beadnum).String=length(velowind(~isnan(velowind)));
    
    g.FIGS.averages(index).un(beadnum).String=strcat(num2str(mean(velounwind)),'+/-', num2str(std(velounwind)));
    g.FIGS.averages(index).unlong(beadnum).String=strcat(num2str(mean(procunwind)),'+/-', num2str(std(procunwind)));
    g.FIGS.averages(index).uncount(beadnum).String=length(velounwind(~isnan(velounwind)));
    
end % averages the speeds for this bead

function SubmitEvents(hObject,~,~)
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

function DataHarvest(~,~,~)
    e=[];
    
    dataHarvestPosition=[2150         150         850         900];

    eventPropertiesStrings = {  'Force' 
                                'Height(bp)' 
                               	'Velocity(bp,Unwinding)' 
                               	'Velocity(bp,Rewinding)' 
                              	'Rate' 
                              	'Height'
                                'Distance From Slide'
                               	'Duration' 
                              	'Velocity(Unwinding)'
                                'Velocity(Rewinding)'
                               	'Conversion Factor' 
                                'Fit Parameters'
                               	'File Time'
                                'Exact Time'
                               	'Main Protein'
                              	'Concentration'
                             	'Co-Protein 1'
                              	'Concentration'
                            	'Co-Protein 2'
                               	'Concentration'
                               	'Co-Protein 3'
                              	'Concentraion'
                              	'Co-Protein 4'
                              	'Concentration'
                             	'Co-Protein 5'
                              	'Concentration'
                                'Buffer Type'
                                'ATP'
                                'Bead Number'
                                'File Number'};

    metadataStrings         = { 'some'
                                'data'
                                'like'};
                            
    analysis.Main = figure('Name','Welcome to DataTowne TM','NumberTitle','off','Toolbar','none','Menubar','none','Position',dataHarvestPosition);
        mainBox = uix.VBox('Parent',analysis.Main);
        
            box1 = uix.HBox('Parent',mainBox);                                  %general controls
                box1box1 = uix.HBox('Parent',box1);
                    uicontrol('Parent',box1box1,    'Style','push',     'String','Get MotherFile',      'Callback',{@getMother});
                    uicontrol('Parent',box1box1,    'Style','push',     'String','Save MotherFile',     'Callback',{@saveMother});
                    uicontrol('Parent',box1box1,    'Style','push',     'String','Restore from Backup',	'Callback',{@getBackup});
                    uicontrol('Parent',box1box1,    'Style','push',     'String','Backup',              'Callback',{@saveBackup});
                box1box2 = uix.Grid('Parent',box1);
                    analysis.total = uicontrol('Parent',uipanel('Parent',box1box2,'Title','Total Events'),   'Style','text');
                    analysis.timeRange = uicontrol('Parent',uipanel('Parent',box1box2,'Title','Time Range'),     'Style','text');
                
            box2 = uix.HBox('Parent',mainBox);                                  %display and analysis
                box2Panel1 = uix.Panel('Parent',box2,           'Title','Main data Collection.');
                    analysis.MainBeadList = uicontrol('Parent',box2Panel1,     'Style','list', 'Max',100,   'Callback',{@DataHarvestAnalysis,1,0});

                box2Panel2 = uix.Panel('Parent',box2,'Title','Current potentials.');
                    analysis.NewBeadList  = uicontrol('Parent',box2Panel2,     'Style','list', 'Max',100,   'Callback',{@DataHarvestAnalysis,0,0});
                
                box2Panel3 = uix.Panel('Parent',box2,'Title','Data types.');
                    uitable('Parent',box2Panel3,       'RowName',eventPropertiesStrings);
                
                box2Panel4 = uix.Panel('Parent',box2,'Title','Values.');
                    analysis.DataDisplay =  uitable('Parent',box2Panel4, 'RowName',[],'ColumnName',[], 'ColumnWidth',{120});
                
                box2Panel5 = uix.Panel('Parent',box2,'Title','Meta-data.');
                    uitable('Parent',box2Panel5,       'RowName',metadataStrings);
                    
             	box2Panel6 = uix.Panel('Parent',box2,'Title','Values.');
                    analysis.MetaData =  uitable('Parent',box2Panel6, 'RowName',[],'ColumnName',[], 'ColumnWidth',{120});
            set(box2,'Widths',[-2 -2 120 -2 120 -2]);
            
            box3 = uix.HBox('Parent',mainBox);                                  %data gathering/control
                box3Panel1 = uix.Panel('Parent',box3,'Title','Edit Selected Entries Manually', 'BorderWidth',3);
                    box3Grid = uix.Grid('Parent',box3Panel1,'Spacing',5);
                        analysis.EditSelection = uicontrol('Parent',uix.Panel('Parent',box3Grid),'Style','popupmenu','String',eventPropertiesStrings);
                        uicontrol('Parent',uix.Panel('Parent',box3Grid), 'Style','text', 'String','well hallo');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid, 'Title','Export cell'), 'String','Export',      'Callback',{@ExportCell});
                        analysis.EditContent = uicontrol('Parent',uix.Panel('Parent',box3Grid,'Title','Double or String'),'Style','edit');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid,'Title','Change new batch'),'Style','push','String','Commit','Callback', {@DataHarvestEdit,0,0});
                        uicontrol('Parent',uix.Panel('Parent',box3Grid), 'Style','text');
                    set(box3Grid,'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
                box3Panel2 = uix.Panel('Parent',box3,'Title','Submit and Change Values', 'BorderWidth',3);
                   	box3Grid2 = uix.Grid('Parent',box3Panel2,'Spacing',5);
                        uicontrol('Parent',uix.Panel('Parent',box3Grid2,'Title','Commit to main'),      'String','Commit',  'Callback',{@commitEvents});
                        uicontrol('Parent',uix.Panel('Parent',box3Grid2,'Title','Withdraw from main'), 	'String','Withdraw','Callback',{@withdrawEvents});
                        uicontrol('Parent',uix.Panel('Parent',box3Grid2,'Title','Delete'),              'String','Delete',  'Callback',{@ClearData});
                        analysis.CommitAssertAll =      uicontrol('Parent',uix.Panel('Parent',box3Grid2), 'Style','checkbox', 'String','all');
                        analysis.WithdrawAssertAll =    uicontrol('Parent',uix.Panel('Parent',box3Grid2), 'Style','checkbox', 'String','all');
                        analysis.DeleteAssertAll =      uicontrol('Parent',uix.Panel('Parent',box3Grid2), 'Style','checkbox', 'String','all');
                    set(box3Grid2, 'Heights', [-1 -1 -1], 'Widths', [-4 -1]);
                box3Panel3 = uix.Panel('Parent',box3,'Title','little panels', 'BorderWidth',3);
                  	box3Grid3 = uix.Grid('Parent',box3Panel3);
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','im');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','panel');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','going');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','you');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','a');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','and');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','to');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','a');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','little');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','im');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','tell');
                        uicontrol('Parent',uix.Panel('Parent',box3Grid3), 'Style','text', 'String','stori');
                    set(box3Grid3, 'Heights', [-1 -2 -1 -2], 'Widths', [-1 -3 -2]);
        set(mainBox,'Heights',[-1 -5 -3]);
        
        DataHarvestUpdate;
end % where the data is gathered and it's basic info can be viewed and edited

function DataHarvestUpdate(~,~)
    
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

function DataHarvestAnalysis(~,~,AssertMain,AssertAll)
    
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

function commitEvents(~,~)    
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

function DataHarvestEdit(~,~,AssertMain,AssertAll)
    structureFields={'Force',...
        'HeightBp',...
        'VelocityBpUp',...
        'VelocityBpDown',...
        'Rate',...
        'Height',...
        'DistanceFromSlide',...
        'Duration',...
        'VelocityUp',...
        'VelocityDown',...
        'BpConversion',...
        'FitParameters',...
        'FileTime',...
        'ExactTime',...
        'Protein0',...
        'Protein0Conc',...
        'Protein1',...
        'Protein1Conc',...
        'Protein2',...
        'Protein2Conc',...
        'Protein3',...
        'Protein3Conc',...
        'Protein4',...
        'Protein4Conc',...
        'Protein5',...
        'Protein5Conc',...
        'BufferType',...
        'ATP'};
    
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
    field=structureFields{analysis.EditSelection.Value};
    content = analysis.EditContent.String;
    
    if ~isempty(str2num(content)); content = str2num(content); end
    
    if AssertMain
        for i = selection   
        e(i).(field) = content;
        end
    else
        for i = selection   
        t(i).(field) = content;
        end;
    end
    
end % add entries to selected data

function [index,fileID,fileNum,field]=GCF_Data(~,~)
    %gets field
    field=regexp(get(gcf,'Tag'),'^(\w+)','match');
    
    %gets index (figslong)
   	index=regexp(get(gcf,'Tag'),'(\d+)$','match');
    index=str2num(index{:});
    
    %gets the ID of the tmp file currently being worked upon
    fileNum=regexp(get(gcf,'Tag'),'\d{3}','match');
    fileID=str2num(fileNum{:});
    
end% gets index, filenum and bead data for the current situation  

%% Microfunctions %%

function withdrawEvents(~,~)    
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

function ClearData(~,~)
    
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

function getMother(~,~)
    analysis.MainBeadList.Value=1;
    load('MotherFile.mat');
    DataHarvestUpdate;
end

function getBackup(~,~)
    analysis.MainBeadList.Value=1;
    BackupName=inputdlg('Please enter the name of the file to retrieve', 'FILENAME.mat');
    if isempty(BackupName); return; end;
    load(BackupName{:});
    DataHarvestUpdate;
end

function saveMother(~,~)
    save('MotherFile.mat','e');
end

function saveBackup(~,~)
    BackupName=inputdlg('Please enter a filename for the backup', 'FILENAME.mat');
    if isempty(BackupName); return; end;
    save(BackupName{:},'e');
end

function ExportCell(~,~)
    nam=fieldnames(e);
    
    exportcell=cell(length(nam),length(e));
    
    for i = 1:length(e)
        for j = 1:length(nam)
            exportcell(j,i) = {e(i).(nam{j})};
        end
    end
    
    exportcell=exportcell';
    
    for i = 1:length(exportcell)
        exportcell{i,10}=[];
        exportcell(i,11)={datestr(exportcell{i,11},'yyyy-mm-dd HH:MM:SS:FFF')};
        exportcell(i,12)={datestr(exportcell{i,12},'yyyy-mm-dd HH:MM:SS:FFF')};
    end

    assignin('base','EXPORT',exportcell);
end

function closerequest(~,~,~)
    % gets fieldname and index from current figure
    field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    % hides figure if close button is pressed while the plot is still open
    if  ishandle(g.BTNS.Params(index).(field{:}))
        set(g.BTNS.Params(index).(field{:}),'State','off');
    else delete(gcf);    
    end
end % stops errors when params figure is closed

function closerequest2(~,~,~)
    % gets fieldname and index from current figure
    field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    % hides figure if close button is pressed while the plot is still open
    if  ishandle(g.BTNS.Params(index).(field{:}))
        set(g.BTNS.Params(index).(field{:})(:),'Value',0);
        set(g.FIGS.Params.(field{:})(index),'Visible','Off');
    else delete(gcf);    
    end
end % stops errors when params figure is closed

function exdat(~,~)
    assignin('base','PARAMSEXPORT',h.Params);     
    assignin('base','DATAEXPORT',h.filedat);
    assignin('base','Data_Collection',d.collect_data);
    %assignin('base','GG',g);
end %exports the manipulated data (in h structure) to base

function good(hObject,~,~)
    itm = get(hObject,'String');
    sel = get(hObject,'Value');
    g.GoodParams.(get(hObject,'Tag'))=str2double(itm{sel});
end %place the goodness to change in the popup tag, and this function will set it to the popup value.

function pathSEL(~,~)
    h.path=uigetdir();
    g.pathEDT.String=h.path;
    checkDir;
end %select file path

function delbead(~,~)
    [index,fileID]=GCF_Data;

    answer=inputdlg('Please enter the bead number whose data you would like to delete:','Deleting heights');
    if isempty(answer); return; end
    
    try 
     	beadnum=str2num(answer{:});
        delete(g.FIGS.Params.heights(index).PAN(beadnum));
    	h.Params(fileID).fig(index).heights(beadnum)=[];
    catch
        errordlg('That bead doesnt seem to be in the list!','Bead not found!');
    end
end %deletes bead data from table

function delpan(hObject,~,~)
    [index]=GCF_Data;
    
    bead=str2double(get(hObject,'Tag'));
    
    g.deletions(bead)=g.FIGS.beadPAN(index).mainPAN(bead);
    
  	delete(g.FIGS.beadPAN(index).mainPAN(bead));
    
    if isempty(allchild(g.FIGS.pnlTAB(index))); delete(g.FIGS.ttrc(index)); end
end %deletes this panel

function checkboxvalue(hObject, ~, ~) %as with paramstoggle, place the handle of the uibutton whose tag you want to control with checkbox in the checkbox's tag
    g.(get(hObject,'Tag')).Tag=num2str(get(hObject,'Value'));
end

function paramstoggle(~,~,~) 
    % get name and number from tag
  	field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    % set the visibility of the window to the value of the togglebutton (ie on or off)
    g.FIGS.Params.(field{:})(index).Visible = get(g.BTNS.Params(index).(field{:}),'State');
end % shows parameters figure

function togglebutton(hObject,~,~)
    % get name and number from tag
  	field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
   	% set the visibility of the window to the value of the togglebutton (ie on or off)
    if get(hObject,'Value')
        g.FIGS.Params.(field{:})(index).Visible = 'On';
    else
        g.FIGS.Params.(field{:})(index).Visible = 'Off';
    end
    
    %synchs all buttons in time trace
    if strcmp(field{:},'ttrc')
        for i=1:length(g.BTNS.Params(index).ttrc)
            if isfield(g.BTNS.Params(index).ttrc(i),'Number')
                set(g.BTNS.Params(index).ttrc(:),'Value',get(hObject,'Value'));
            end
        end
    end
end %toggles visibility of paramters

function tracetogglebutton(hObject,~,fid,index,beadnum,AssertNorm)
   	% set the visibility of the window to the value of the togglebutton (ie on or off)
    if AssertNorm
        if get(hObject,'Value')
            g.FIGS.plot(fid).bead(beadnum).norm(index).Visible = 'On';
        else
            g.FIGS.plot(fid).bead(beadnum).norm(index).Visible = 'Off';
        end
    else
        if get(hObject,'Value')
            g.FIGS.plot(fid).bead(beadnum).smooth(index).Visible = 'On';
        else
            g.FIGS.plot(fid).bead(beadnum).smooth(index).Visible = 'Off';
        end
    end
end %toggles visibility of paramters

end %MainGUI


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% BONEYARD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

% function collect_data(hObject,~,~)
%     [index,fid]=GCF_Data;
%     
%     bead=str2double(get(hObject,'Tag'));
%     
%     d.collect_data.force=[d.collect_data.force(:)' h.Params(fid).fig(index).results(bead).force];
%     d.collect_data.height_bp=[d.collect_data.height_bp(:)' h.Params(fid).fig(index).results(bead).height_bp];
%     d.collect_data.velocity_bp=[d.collect_data.velocity_bp(:)' h.Params(fid).fig(index).results(bead).velocity_bp];  
%     d.collect_data.rate=[d.collect_data.rate(:)' h.Params(fid).fig(index).results(bead).rate];
%     d.collect_data.height=[d.collect_data.height(:)' h.Params(fid).fig(index).results(bead).height];
%     d.collect_data.time=[d.collect_data.time(:)' h.Params(fid).fig(index).results(bead).time];
%     d.collect_data.velocity=[d.collect_data.velocity(:)' h.Params(fid).fig(index).results(bead).velocity];
%     
% %     d.collect_data=h.Params(fid).fig(index).results(bead);
%     
% end %organises the data into a nice structure for exporting

% function eqtn(hObject,~,~)
%     sel = get(hObject,'Value');
%     if sel==1
%         g.FitSettings.(get(hObject,'Tag'))=g.FitTypes.Worm;
%     elseif sel==2
%         g.FitSettings.(get(hObject,'Tag'))=g.FitTypes.Cali1;
%     else %do nothing (space here for other fit types)
%     end
% 
% end %ready to make equations variable


% function restore(~,~)
%     cleancontent=dir(fullfile(h.path,'tmp_*.CLEAN*'));
%     % rename files
%     if ~isempty(cleancontent)
%         g.restoreMSG.msg='The following cleaned files were returned:';
%     for z=1:length(cleancontent)
%         cleanfile=char(fullfile(h.path,cleancontent(z).name));
%         datfile=char(fullfile(h.path,regexprep(cleancontent(z).name,'.CLEAN\w+','.dat')));
%         movefile(cleanfile,datfile);
%         g.restoreMSG.msg=strcat(g.restoreMSG.msg,{' '},datfile);
%     end
%     elseif isempty(cleancontent); g.restoreMSG.msg='No clean files. This place is filthy!';      
%     end
%     g.restoreMSG.box=msgbox(g.restoreMSG.msg,'Uncleaning files.');
%     checkDir;
% end %restores cleaned files

% function SubmitEvents(~,~)
%     [index,fileID,fileNum]=GCF_Data;
%     
%     try    
%         for i=1:length(h.Params(fileID).fig(index).heights); if ~isempty(h.Params(fileID).fig(index).heights(i).part); beadNum(i)=i; end; end 
%     catch
%         errordlg('Have you selected any points?','Data not found.');
%         return;
%     end
%     
%     beadNum=beadNum(beadNum~=0);
%     
%     filename=strcat('tmp_',fileNum{:},'.log');
%     cFilename=fullfile(h.path,filename);    
%     time = getNumFromLog(cFilename,'time'); time = time(2:end-1);
%     date = getNumFromLog(cFilename,'date'); date = date(2:end-1);
%     ActualTime = datetime({time,date});
%     
%     for i = 1: length(h.Params(fileID).fig(index).results)
%         longnow=length(e); %consider doing e(actualtime)???
%         e(longnow + 1).Force = h.Params(fileID).fig(index).results(i).force;
%         e(longnow + 1).HeightBp = h.Params(fileID).fig(index).results(i).height_bp;
%         e(longnow + 1).VelocityBp =  h.Params(fileID).fig(index).results(i).velocity_bp;
%         e(longnow + 1).Rate =  h.Params(fileID).fig(index).results(i).rate;
%         e(longnow + 1).Height =  h.Params(fileID).fig(index).results(i).height;
%         e(longnow + 1).Duration =  h.Params(fileID).fig(index).results(i).time;
%         e(longnow + 1).Velocity =  h.Params(fileID).fig(index).results(i).velocity;
%         e(longnow + 1).BpConversion =  h.Params(fileID).fig(index).results(i).conversion; %!!! (only one conversion?)
%         e(longnow + 1).FitParameters = g.FIGS.Params.fitparams(index);
%         e(longnow + 1).ActualTime = ActualTime;
%     end
%     
% end