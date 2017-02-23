function CrisprAnalysisGUI
%clc;clear;close all;
%% Variables and initial values %%
% Positions for the popup windows
% g.defPos=[2350          309         721         588];
% g.defPosGUI=[1950         450         350         500];
% g.defPosPAR=[2014         691         336         206];

g.defPos=[1050          100         821         888];
g.defPosGUI=[950         500         450         250];
g.defPosPAR=[1014         691         336         206];

% Standard goodnesses for fits & clean. If you change these you should change the
%'Value' of the popup boxes accordingly.
g.GoodParams.ttrchigh=2;g.GoodParams.ttrcback=20;g.GoodParams.ttrcfore=20;
g.BreakTimerValue='nuthin';
g.rttnparams.minlong=150;
           
%% LAYOUT %%
g.FIGS.main=figure('Name','parPlots GUI © DNAmotors','NumberTitle','off','Toolbar','none','Menubar','none','Position',g.defPosGUI);
    g.FIGS.Params=[];

h=guidata(g.FIGS.main);
h.path='Z:\GroupMembers\Andrey\Magnetic tweezers data\20160720-28 Data Masha from Marius set up\2016-07-25';

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
                        g.quickRTTNBTN= uicontrol('Parent',g.quickCTRLGRD,'String','Multi-bead Analysis','Tag','mlty','Callback',{@rttn});
                        g.quickGRDBOX_2= uipanel('Parent',g.quickCTRLGRD);
                        g.quickEXPRTBTN= uicontrol('Parent',g.quickCTRLGRD,'String','Data2MATLAB','Callback',{@exdat});
                        g.quickSNGLBTN= uicontrol('Parent',g.quickCTRLGRD,'String','Single-bead Analysis','Tag','sngl','Callback',{@rttn});
                        g.quickGRDBOX_5= uipanel('Parent',g.quickCTRLGRD);
                        g.quickCLRBTN= uicontrol('Parent',g.quickCTRLGRD,'String','cleardata','Callback',{@klara});
                    set(g.quickCTRLGRD, 'Heights', [-1 -1 -1], 'Widths', [-1 -1]);
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

set(g.actnBOX, 'Heights', [15 120] );

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
    if  ~isempty(cycleFilenames)
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
    else g.beadLST.Value=1:length(g.beadLST.String);
    end

    end %populate bead list from selected files

function rttn(hObject,skip,~)
    %% Initial values etc. %%    
    beadstr=str2num(g.beadLST.String); beadSel=beadstr(g.beadLST.Value).'; %#ok<ST2NM>
    fileSel=sort(g.fileLST.String(g.fileLST.Value));
    if length(fileSel)>1; errordlg('Only one file at a time please','Too many files!'); return; end
    fileID=regexp(fileSel,'tmp_(\d{3})','tokens'); fid=str2double(fileID{:}{:}{:});

  	if isfield(g.FIGS, 'rttn'); figslong=length(g.FIGS.rttn)+1; else figslong=1; end
    tag=strcat('rttn',{' '},'tmp_',fileID{:}{:},{' '},'Figure',{' '},num2str(figslong));
    figname=strcat('Rotation Analysis:',{' '},regexprep(tag,'^(\w+\s?)',''));
    
  	if  sum(cellfun(@exist,fullfile(h.path,strcat(fileSel,'.dat')))~=2) %checks that fileSel refers to existing files
        errordlg('Please select existing .dat files only','Invalid file selection...')
        return
    end

   	g.FIGS.rttn(figslong)=figure('Position',(g.defPos+figslong*[20 -20 0 0]),'Name',figname{:},'NumberTitle','off', ...
        'Toolbar','none','Menubar','none','Tag',tag{:});
    
    g.rttnparams.clnMLTY=0; g.rttnparams.clnHI=5; g.rttnparams.clnWID=10;
    
    rowname=cell(length(beadSel),1);
    rowname(1)={'Bead...'};
    %% Get Data %%
    cFile=fullfile(h.path,strcat(fileSel{:},'.dat'));                      	% assemble filename
    [DNAbeads]=getNumFromLog(strcat(cFile(1:end-4),'.log'),'#DNAbeads');  	% get number of beads
    if skip==1
        assert(2+2==4);
    else
        if  strcmp(get(hObject,'Tag'),'mlty')
            data=getTweezerDataMB(cFile);                                      	% load data
        else
            data=getTweezerDataSM(cFile);
        end
        h.rttndata(fid).t=data{1};                                              % assign t
        h.rttndata(fid).mp=data{2};                                             % assign mp
        h.rttndata(fid).mr=data{3};                                             % assign magrot
        if strcmp(get(hObject,'Tag'),'mlty')
            h.rttndata(fid).refZ=data{3*(DNAbeads+2)};                        	% assign refZ
            for i=beadSel;
                h.rttndata(fid).Bead(i).z=data{3*(i+1)};                        % assign Bead-zs
            end
        else
            h.rttndata(fid).refZ=data{12};                                      % assign refZ
            h.rttndata(fid).Bead.z=data{6};                                     % assign Bead-zs
        end
    end
    %% Layout %%
  	g.FIGS.pnlTAB(figslong) = uix.TabPanel('Parent',g.FIGS.rttn(figslong));
    for i=beadSel
    g.FIGS.beadPAN(figslong).mainPAN(i) = uix.Panel('Parent',g.FIGS.pnlTAB(figslong));
   	vbox1=uix.VBox('Parent',g.FIGS.beadPAN(figslong).mainPAN(i));
        refPAN=uix.Panel('Parent',vbox1);
            graphBOX=uix.HBox('Parent',refPAN);
                magPAN=uix.Panel('Parent',graphBOX);
                traceBOX=uix.HBox('Parent',graphBOX);
                    g.FIGS.beadPAN(figslong).tracePAN(i) = uix.Panel('Parent',traceBOX);
                    traceCTRL=uix.Grid('Parent',traceBOX, 'Padding', 3, 'Spacing', 1);
                        uicontrol('Parent',traceCTRL,'String','Truncate','Tag',num2str(i),'Callback',{@editdataZ});
                        g.FIGS.beadPAN(figslong).hiPARAM(i)=uicontrol('Parent',uipanel('Parent',traceCTRL, 'Title', 'Max Hi/Lo:'), ...
                            'Style','popup','String',{0:0.1:20},'Tag','clnHI','Value',21,'Callback',{@rttnparams});
                    	uicontrol('Parent',traceCTRL,'String','Undo Here','Tag',num2str(i),'Callback',{@traceplot});
                        g.FIGS.beadPAN(figslong).mltyPARAM(i)=uicontrol('Parent',uipanel('Parent',traceCTRL, 'Title', 'Do to all'),'Style','checkbox', ...
                            'Tag','clnMLTY','Callback',{@rttnparams});
                     	g.FIGS.beadPAN(figslong).widPARAM(i)=uicontrol('Parent',uipanel('Parent',traceCTRL, 'Title', 'Width'), ...
                            'Style','edit','String',10,'Callback',{@rttnparams},'Tag','clnWID');
                        uicontrol('Parent',traceCTRL,'String','Save','Tag',num2str(i),'Callback',{@savdat});
                    set(traceCTRL,'Heights',[-2 -2 -1],'Widths',[-1 -1]);
                set(traceBOX,'Widths',[-4 -1]);
            set(graphBOX,'Widths',[-1 -4]);
        beadBOX=uix.HBox('Parent',vbox1);
            littledataBOX=uix.VBox('Parent',beadBOX);
                g.FIGS.dataBOX(figslong).copy(i)=uix.VBox('Parent',littledataBOX);
                    g.FIGS.dataTBL(figslong).copy(i)=uitable('Parent',g.FIGS.dataBOX(figslong).copy(i),'Units', 'Normalized', ...
                        'RowName',rowname,'ColumnName',{'Rotation Events','Left Shift','Left Red Error','Left Blue Error','Right Shift','Right Red Error','Right Blue Error','Parabola X Shift','Parabola Y Shift','Red Parabola Error','Blue Parabola Error'});
            mainBOX = uix.VBox('Parent',beadBOX);
                g.FIGS.beadPAN(figslong).plotBOX(i)= uix.Panel('Parent',mainBOX);
                ctrlBOX= uix.HBox('Parent',mainBOX);
                    breakCTRL= uix.Panel('Parent',ctrlBOX,'Title','Break Data');
                        breakBOX= uix.VBox('Parent',breakCTRL);
                            uicontrol('Parent',uix.Panel('Parent',breakBOX),'String','Begin!','Tag',num2str(i),'Callback',{@rttnevents});
                            chooseBOX= uix.HBox('Parent',breakBOX);
                                uicontrol('Parent',uix.Panel('Parent',chooseBOX),'String','Left','Callback',{@breakbtn});
                                uicontrol('Parent',uix.Panel('Parent',chooseBOX),'String','Right','Callback',{@breakbtn});
                                uicontrol('Parent',uix.Panel('Parent',chooseBOX),'String','Same','Callback',{@breakbtn});
                                uicontrol('Parent',uix.Panel('Parent',chooseBOX),'String','Bad','Callback',{@breakbtn});
                            savBOX= uix.HBox('Parent',breakBOX);
                                uicontrol('Parent',uix.Panel('Parent',savBOX),'String','Quicksave','Tag',num2str(i),'Callback',{@rttnevents});
                                uicontrol('Parent',uix.Panel('Parent',savBOX),'String','Delete','Tag',num2str(i),'Callback',{@delpan});
                    cmprCTRL= uix.Panel('Parent',ctrlBOX);
                        cmprBOX= uix.VBox('Parent',cmprCTRL);
                            uicontrol('Parent',uix.Panel('Parent',cmprBOX),'String','Compare curves','Tag',num2str(i),'Callback',{@selCurve});
                            selBOX= uix.HBox('Parent', cmprBOX);
                                g.FIGS.beadPAN(figslong).fileSEL(i)=uicontrol('Parent',uipanel('Parent',selBOX, ...
                                    'Title', 'File Select'),'Style','popup','String',h.filenames,'Callback',{@fileselectionsynch});
                                g.FIGS.beadPAN(figslong).beadSEL(i)=uicontrol('Parent',uipanel('Parent',selBOX, ...
                                    'Title', 'Bead Select'),'Style','popup','String',{1:max(beadSel)},'Value',i);
                        set(cmprBOX,'Heights',[-2 -3]);
                    miscCTRL= uix.Panel('Parent',ctrlBOX);
                        boxbox=uix.VBox('Parent',miscCTRL);
                        if ~strcmp(get(hObject,'Tag'),'mlty')
                            g.comboBTN= uicontrol('Parent',boxbox,'String','C-C-C-COMBINATOR','Callback',{@combo});
                        end
            set(mainBOX,'Heights',[-5 -1]);
    set(beadBOX,'Widths',[-1 -2]);
    set(vbox1,'Heights',[-1 -4]);
    
    axsMag=axes('Parent', uicontainer('Parent', magPAN)); hold on; ylabel('MagPos [mm]','FontSize',8)
    plot(axsMag,h.rttndata(fid).t,h.rttndata(fid).mp,'r','LineWidth',2);
    
    axsTRC(i)=axes('Parent', uicontainer('Parent', g.FIGS.beadPAN(figslong).tracePAN(i))); hold on;  %#ok<*AGROW> ?? maybe try and figure this out at some point
    g.FIGS.plot(fid).axesTRC(i)=axsTRC(i);
    xlabel('Time [s]','FontSize',8);
    ylabel(strcat('Bead',{' '},num2str(i),' Z [\mum]'),'FontSize',8);
    
    axsRTN(i)=axes('Parent', uicontainer('Parent', g.FIGS.beadPAN(figslong).plotBOX(i))); hold on;  %#ok<*AGROW>
    g.FIGS.plot(fid).axes(i)=axsRTN(i);
    xlabel('Magnet Rotation','FontSize',8);
    ylabel(strcat('Bead',{' '},num2str(i),' Z [\mum]'),'FontSize',8);
    tabnames(i)=strcat('Bead',{' '},num2str(i));
    end
    tabnames=tabnames(~cellfun(@isempty,tabnames));
    set(g.FIGS.pnlTAB(figslong),'TabTitles',tabnames(:)');
    %% Trace Plot and Data Edit %%
    for i=beadSel
        traceplot([],i,[]);
    end
end %creates and analzsis panel with a time trace and box for doing rotation-extension calculations and table for results

function combo(~,~)
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});

    answer=inputdlg('We will attach the following file to the beginning of this file:','Combine files (please open analysis first)');
    if isempty(answer); return; end
    
    try
        dat(1)=h.rttndata(str2double(answer));
        dat(2)=h.rttndata(fid);
    catch
        errordlg('Check the number!','No params for that file!');
       	return;
    end
    
    dat(2).t=dat(2).t+dat(1).t(end);
    h.rttndata(fid).t=vertcat(dat(1).t,dat(2).t);
    h.rttndata(fid).mp=vertcat(dat(1).mp,dat(2).mp);
    h.rttndata(fid).mr=vertcat(dat(1).mr,dat(2).mr);
    h.rttndata(fid).refZ=vertcat(dat(1).refZ,dat(2).refZ);
    h.rttndata(fid).Bead.z=vertcat(dat(1).Bead.z,dat(2).Bead.z);
   
    hObject=[]; skip=1;
    rttn(hObject,skip);
end

%% Functionettes %%

function selCurve(hObject,~,~)
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2double(fileID{:});
    beadNum=str2double(get(hObject, 'Tag'));
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    
    fil=get(g.FIGS.beadPAN(index).fileSEL(beadNum),'String'); val= get(g.FIGS.beadPAN(index).fileSEL(beadNum),'Value'); 
    file2=fil(val); fileID2=regexp(file2,'\d{3}','match'); fileID2=str2double(fileID2{:}{:});
    fil=get(g.FIGS.beadPAN(index).beadSEL(beadNum),'String'); val= get(g.FIGS.beadPAN(index).beadSEL(beadNum),'Value');
    beadNum2=fil(val); beadNum2=str2double(beadNum2{:});

    %% Average and Plot %%
    binsize=0.2; a=binsize;
    rotTemplate=-14.1:a:12.1;
    C=zeros(length(rotTemplate),1);
    %~~~~~~~~~M-M-M-MULTIBALL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if h.breakdata(fileID).bead(beadNum).cmpr2
        in=h.breakdata(fileID).bead(beadNum).same;
        out=h.breakdata(fileID2).bead(beadNum2).same;
    else
        in=h.breakdata(fileID).bead(beadNum).in;
        out=h.breakdata(fileID).bead(beadNum).out;
    end
    for num=1:2
        b=1; v=1; 
        if num==1; datdat=in; elseif num==2; datdat=out; end
        for i=1:length(datdat)
            A = datdat{i};
            smoothdat=A(:,4); smoothdat(isnan(smoothdat))=0; %NaNs kill smooth (!!! could consider killing all NaNs as the data is processed at the start?)
            A(:,4)=smooth(smoothdat);          	% smooth z
            sizeA=size(A);
            long=sizeA(1);
            for k=1:length(rotTemplate)-1       % For values as long as the rotation
                for j=1:long                    % For the datapoints
                    if rotTemplate(k)>rotTemplate(k+1) %do nulia                   if template values are decreasing
                        if A(j,3)<=rotTemplate(k) && A(j,3)>rotTemplate(k+1)     % and magrot is between two consecutive values
                            C(k,b)=A(j,4);                                       % save magrot value in c
                            b=b+1;
                        end
                    end
                    if rotTemplate(k)<rotTemplate(k+1) %perevalili za nol          if template values are increasing
                        if A(j,3)>=rotTemplate(k) && A(j,3)<rotTemplate(k+1)     % and magrot is between two consecutive values
                            C(k,b)=A(j,4);                                       % save magrot value in c
                            b=b+1;
                        end
                    end
                end                             % Continue capturing magrots between consecutive templates through data
                b=v;
            end
            v=v+20;
            b=v;
        end %breaking into a sized bins
        sumC=zeros(length(rotTemplate),3);
        for j=1:length(rotTemplate)-1
            sumC(j,1)=sum(sum(C(j,:)));         % sum of all values in the a sized bins
            sumC(j,2)=length(find(C(j,:)));     % number of such values
            sumC(j,3)=sumC(j,1)/sumC(j,2);      % sum of values over number of values (ie. average)
        end %averaging
        sm=[transpose(rotTemplate) sumC(:,3)];
        clear C;
        if num==1; smIn=sm; elseif num==2; smOut=sm; end
    end
    
    plot(g.FIGS.plot(fileID).axes(beadNum),smIn(:,1),smIn(:,2),'r','LineWidth',1.5);
    hold on;
    plot(g.FIGS.plot(fileID).axes(beadNum),smOut(:,1),smOut(:,2),'b','LineWidth',1.5);
    
  	h.avdata(fileID).bead(beadNum).in=smIn;
    h.avdata(fileID).bead(beadNum).out=smOut;
    
    [in1,in2,out1,out2]=getpoints(fileID,beadNum,1);
    
    fitdat(fileID,beadNum,smIn,smOut,in1,in2,out1,out2,1)
    
    in1left=in1; in2left=in2; out1left=out1; out2left=out2; %#ok<NASGU>
    
  	[in1,in2,out1,out2]=getpoints(fileID,beadNum,2);
    
    fitdat(fileID,beadNum,smIn,smOut,in1,in2,out1,out2,2)
    
    in1right=in1; in2right=in2; out1right=out1; out2right=out2; %#ok<NASGU>
    
  	[in1,in2,out1,out2]=getpoints(fileID,beadNum,3);
    
    fitparab(fileID,beadNum,smIn,smOut,in1,in2,out1,out2)

end %with user, creates fits for left right and parabola and saves data

function [in1,in2,out1,out2]=getpoints(fileID,beadNum,datpart)
    if datpart==1
        title(g.FIGS.plot(fileID).axes(beadNum),'LEFT: Red Bottom, Red Top, Blue Bottom, Blue Top');
    elseif datpart==2
        title(g.FIGS.plot(fileID).axes(beadNum),'RIGHT: Red Bottom, Red Top, Blue Bottom, Blue Top');
    elseif datpart==3
        title(g.FIGS.plot(fileID).axes(beadNum),'Red curve start, Red curve end, Blue curve start, Blue curve end');
    end
    p=impoint(g.FIGS.plot(fileID).axes(beadNum));
    wait(p);
    in1=getPosition(p);
    p=impoint(g.FIGS.plot(fileID).axes(beadNum));
    wait(p);
    in2=getPosition(p);
    p=impoint(g.FIGS.plot(fileID).axes(beadNum));
    wait(p);
    out1=getPosition(p);
    p=impoint(g.FIGS.plot(fileID).axes(beadNum));
    wait(p);
    out2=getPosition(p);
end %gets button presses for fitting !!! split in three

function fitdat(fileID,beadNum,smIn,smOut,in1,in2,out1,out2,itN)

    for num=1:2
        if num==1; datin=smIn; num1=in1; num2=in2; elseif num==2; datin=smOut; num1=out1; num2=out2; end
        j=1;
        long=length(datin);
        if itN==1                   %on first iteration
            k=1;
            incr=1;
            workdat=datin;
        else                        %on later iterations
            k=long;                 %take the length of the data
            incr=-1;                
            workdat=-datin;         %invert the data
            num1=-num1;
            num2=-num2;
        end
        while workdat(k,1)<num1(1)  %while the data value is less than the x-coord of the first point
            k=k+incr;               %move along one data point
            if k>long
                break
            end
        end
        while workdat(k,1)<num2(1) && workdat(k,1)>=num1(1) %while the data value is between the two x coords
            lineout(j,:)=datin(k,:);%save the data
            k=k+incr; j=j+1;        %and increment data and dataout positions
            if k>long
                break
            end
        end
%         [coefout,fitparams]=polyfit(lineout(:,1),lineout(:,2),1);
%         [yout,delta]=polyval(coefout,lineout(:,1),fitparams);
%         if num==1; line1=lineout; L1coef=coefout; y1=yout; delta1=delta; elseif num==2; line2=lineout; L2coef=coefout; y2=yout; delta2=delta; end
        [fitobject,gof]=fit(lineout(:,1),lineout(:,2),'poly1'); %#ok<ASGLU>
        fitval=fitobject(lineout(:,1));
        ci=confint(fitobject, 0.67);
        delta=abs((fitobject.p2-ci(1,2))/fitobject.p1);
        
        if num==1; line1=lineout; y1=fitval; fit1=fitobject; delta1=delta;
        elseif num==2; line2=lineout; y2=fitval; fit2=fitobject; delta2=delta; 
        end
        %%things for later(possibly) L1gof=gof;  L2gof=gof;
        
    end
    
 	cla(g.FIGS.plot(fileID).axes(beadNum));
    delete(findall(gcf,'Type','hggroup'));
    
    
    plot(g.FIGS.plot(fileID).axes(beadNum),smIn(:,1),smIn(:,2),'r','LineWidth',1.5);
    hold on;
    plot(g.FIGS.plot(fileID).axes(beadNum),smOut(:,1),smOut(:,2),'b','LineWidth',1.5);
    plot(g.FIGS.plot(fileID).axes(beadNum),line1(:,1),y1,'r','LineWidth',2)
    plot(g.FIGS.plot(fileID).axes(beadNum),line2(:,1),y2,'b','LineWidth',2)
    
    y01=mean(y1);
    % y02=mean(y2); use if you wanna know the x and y change of the fits, but be careful with that
    x1=(y01-fit1.p2)/fit1.p1;
    x2=(y01-fit2.p2)/fit2.p1;
    d=x2-x1;
    
    plot(g.FIGS.plot(fileID).axes(beadNum),[x1 x2],[y01 y01],'g','LineWidth',2)
    
    if itN==1
    h.fitdata(fileID).bead(beadNum).left=d;
    h.fitdata(fileID).bead(beadNum).leftreddelta=delta1;
    h.fitdata(fileID).bead(beadNum).leftbluedelta=delta2;
    elseif itN==2
    h.fitdata(fileID).bead(beadNum).right=d;
    h.fitdata(fileID).bead(beadNum).rightreddelta=delta1;
    h.fitdata(fileID).bead(beadNum).rightbluedelta=delta2;
    end
    
    if itN==1
        rttndata(beadNum,2,d,delta1,delta2);
    elseif itN==2
        rttndata(beadNum,5,d,delta1,delta2);
    end

end %fits and plots first order polynomial, and exports data

function fitparab(fileID,beadNum,smIn,smOut,in1,in2,out1,out2)
    
    for num=1:2
        if num==1; datdat=smIn; num1=in1; num2=in2; elseif num==2; datdat=smOut; num1=out1; num2=out2; end
        j=1;
        long=length(datdat);
        k=1;
        while datdat(k,1)<num1(1)   %keep iterating along the data until you reach the first x-coord
            k=k+1;
            if k>long
                break
            end
        end
        while datdat(k,1)<num2(1) && datdat(k,1)>=num1(1)
            datout(j,:)=datdat(k,:);%then save data until you reach the secong x-coord
            k=k+1; j=j+1;
            if k>long
                break
            end
        end
        [coefout,fitparams]=polyfit(datout(:,1),datout(:,2),2);     %fit a polynomial to the data, get first three coefficients coefficients
        [yout,delta]=polyval(coefout,datout(:,1),fitparams);       	%evaluate the polynomial at the data positions
        
        if num==1; line1=datout; L1coef=coefout; y1=yout; delta1=delta; elseif num==2; line2=datout; L2coef=coefout; y2=yout; delta2=delta; end
    end
    
 	cla(g.FIGS.plot(fileID).axes(beadNum));
    delete(findall(gcf,'Type','hggroup'));
    
    plot(g.FIGS.plot(fileID).axes(beadNum),smIn(:,1),smIn(:,2),'r','LineWidth',1.5);    %plot the averaged curves
    hold on
    plot(g.FIGS.plot(fileID).axes(beadNum),smOut(:,1),smOut(:,2),'b','LineWidth',1.5);  %ditto
    plot(g.FIGS.plot(fileID).axes(beadNum),line1(:,1),y1,'r','LineWidth',2)             %plot the polynomial values (fit)
    plot(g.FIGS.plot(fileID).axes(beadNum),line2(:,1),y2,'b','LineWidth',2)             %ditto
    x01=-L1coef(2)/(2*L1coef(1));                                                       %find maximum for x
    x02=-L2coef(2)/(2*L2coef(1));
    y01=-(L1coef(2)^2)/(4*L1coef(1))+L1coef(3);                                         %and for y
    y02=-(L2coef(2)^2)/(4*L2coef(1))+L2coef(3);
    dy=y02-y01;                                                                         %and find the difference
    dx=x02-x01;
    dytxt=num2str(dy);
    dxtxt=num2str(dx);
    plot(g.FIGS.plot(fileID).axes(beadNum),[x01 x02],[y01 y02],'g','LineWidth',2)
    nadpis=strcat('dx=',dxtxt,' dy=',dytxt);
    title(nadpis)
    
    h.fitdata(fileID).bead(beadNum).parabx=dx;
    h.fitdata(fileID).bead(beadNum).paraby=dy;
    h.fitdata(fileID).bead(beadNum).parabdelta=delta;
    
    rttndata(beadNum,8,dx,0); rttndata(beadNum,9,dy,delta1,delta2);
    
    delete(findall(gcf,'Type','hggroup')); hold off
end %fits and plots second order polynomial, and exports data

function rttnevents(hObject,~,~)
   	fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2double(fileID{:});
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    beadNum=str2double(get(hObject, 'Tag'));
    
    % need time, magnet position, magnetic rotation and z pos
    A=[h.rttndata(fileID).t h.rttndata(fileID).mp h.rttndata(fileID).mr h.rttndata(fileID).Bead(beadNum).z];
    
    %% Split data into rotation events %%
    long=length(A);                             % A is an ~80k by 4 double containing time, magpos, magrot and z
    temp.out={}; temp.in={};
    nOut=0; nIn=0;
    minlong=g.rttnparams.minlong;
    k=1;i=1;                                    % initialize
    while i<long
        i=i+1;
        while A(i,3)<-14                    % while magnetic rotation is < -14
            if i+1>long;                   	% so long as we havent reached the end of the data
                break
            end
            i=i+1;                          % step i and check again
        end                                 % will move on at end of data, or when magrot >= -14
        if A(i,3)>A(i-1,3) && A(i,3)>-14    % if magrot is increasing and > -14
            while A(i,3)>A(i-1,3)           % so long as magrot is increasing
                Bout(k,:)=A(i,:);           % prepare to export all four data columns
                    if i+1>long;            % (data-length security, as above)
                        break
                    end
                k=k+1; i=i+1;
            end
            if k<minlong; k=1; clear Bout; continue; end;
            nOut=nOut+1;k=1;
            temp.out(nOut)={Bout};          % export all data columns to temp
            clear Bout
        end
        if A(i,3)<A(i-1,3) && A(i,3)>-14    % if magrot is decreasing and greater than -14
            while A(i,3)<A(i-1,3)           % while decreasing
                BIn(k,:)=A(i,:);         	% prepare to export all data columns
                if i+1>long;                % (data-length save)
                    break
                end
                k=k+1;i=i+1;
            end
            if k<minlong; k=1; clear Bout; continue; end;
            nIn=nIn+1;k=1;
            temp.in(nIn)={BIn};            	% export all data columns to temp
            clear BIn
        end
    end 
    %% User check beads %%
    h.breakdata(fileID).bead(beadNum).in={};
    h.breakdata(fileID).bead(beadNum).out={};
    h.breakdata(fileID).bead(beadNum).same={};
    InNum=0; OutNum=0; SamNum=0; DelNum=0;
    cla(g.FIGS.plot(fileID).axes(beadNum));
    
    %user splits the data into three categories, labelled 'left' 'right' and 'same', and deletes others
    for num=1:2
        if num==1; dat=temp.in; numnum=nIn; elseif num==2; dat=temp.out; numnum=nOut; end
        for i=1:numnum
            B=dat{i};
            
          	%quicksave
            if strcmp(get(hObject,'String'),'Quicksave'); SamNum=SamNum+1; h.breakdata(fileID).bead(beadNum).same(SamNum)={B}; continue; end
            
            smoothdat=A(:,4); smoothdat(isnan(smoothdat))=0;                                                            % NaNs kill smooth
            g.FIGS.plot(fileID).bead(beadNum)=plot(g.FIGS.plot(fileID).axes(beadNum),A(:,3),smooth(smoothdat,60),'y');
            hold on
            smoothdat=B(:,4); smoothdat(isnan(smoothdat))=0;                                                            % NaNs kill smooth
            g.FIGS.plot(fileID).bead(beadNum)=plot(g.FIGS.plot(fileID).axes(beadNum),B(:,3),smooth(smoothdat,60),'LineWidth',2);
%             ylim(g.FIGS.plot(fileID).axes(beadNum),[0 0.7]); xlim(g.FIGS.plot(fileID).axes(beadNum),[-14 12]); dont know if this is strictly necessary. if it is, will have to autozero the curves first
            hold off;
            g.BreakTimerValue='nuthin';
            t=timer('TimerFcn',{@timerfunc});
            start(t);
            if strcmp(g.BreakTimerValue,'Left')
               	InNum=InNum+1;
                h.breakdata(fileID).bead(beadNum).in(InNum)={B};
            elseif strcmp(g.BreakTimerValue,'Right')
                OutNum=OutNum+1;
                h.breakdata(fileID).bead(beadNum).out(OutNum)={B};
            elseif strcmp(g.BreakTimerValue,'Same')
                SamNum=SamNum+1;
                h.breakdata(fileID).bead(beadNum).same(SamNum)={B};
            elseif strcmp(g.BreakTimerValue,'Bad')
                assert(1+1==2);
                DelNum=DelNum+1;
            end
            g.BreakTimerValue='nuthin';
            delete(t);
        end
    end
    cla(g.FIGS.plot(fileID).axes(beadNum));
   	delete(findall(gcf,'Type','hggroup'));
    
    rttndata(beadNum,1,(SamNum+InNum+OutNum),0,0);
    
    if SamNum
        h.breakdata(fileID).bead(beadNum).cmpr2=1;
    else
        h.breakdata(fileID).bead(beadNum).cmpr2=0;
    end
    
    selnum=get(g.FIGS.pnlTAB(index),'Selection');
    if length(allchild(g.FIGS.pnlTAB(index)))>selnum
        set(g.FIGS.pnlTAB(index),'Selection',(selnum+1));
    end
end %splits the data into rotation events, and then asks the user to further divide them into categroies

function rttndata (thisbead,columnnum,datdat,error1,error2)
    %get name of file and creates a rowname
   	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    tit=strcat('Bead',{' '},num2str(thisbead));

    %gets old row names and data from table
    rownames=get(g.FIGS.dataTBL(index).copy(thisbead),'RowName');
    rownames(thisbead)=tit;
  	data=get(g.FIGS.dataTBL(index).copy(thisbead),'Data');
    
    %adds new data to table, and adds error data if error data exists
    data(thisbead,columnnum)=datdat;
    if error1~=0; data(thisbead,(columnnum+1))=mean(error1); data(thisbead,(columnnum+2))=mean(error2); end

    %gets surviving bead tabs from figure and feeds data to their positions in the table
   	tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    for i=1:length(beads); set(g.FIGS.dataTBL(index).copy(str2double(beads{i})),'RowName',rownames,'Data',data); end
    
end %saves data to table

function traceplot(hObject,bead,~)
  	fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});
    
    %if undo button was pressed, just replot this graph
    if strcmp(get(hObject,'String'),'Undo Here'); bead=str2double(get(hObject,'Tag')); cla(g.FIGS.plot(fid).axesTRC(bead)); end
    
    %else, replot the graphs given by 'bead'
    g.FIGS.plot(fid).beadTRC(bead)=plot(g.FIGS.plot(fid).axesTRC(bead),h.rttndata(fid).t,h.rttndata(fid).Bead(bead).z,'b');
end %plots (or replots) time trace graphs

function editdataZ(hObject,~,~)
   	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
   	fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});
    
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    h.rttnedit.t=h.rttndata(fid).t;                                          	% assign t
   	h.rttnedit.mp=h.rttndata(fid).mp;                                          	% assign mp
    h.rttnedit.mr=h.rttndata(fid).mr;                                         	% assign magrot
   	h.rttnedit.refZ=h.rttndata(fid).refZ;                                       % assign refZ
	for i=beadSel; 
      	h.rttnedit.Bead(i).z=h.rttndata(fid).Bead(i).z;                         % assign Bead-zs
	end
    
   	%% Clean absurd values
    value=g.rttnparams.clnHI;
    reverse=g.rttnparams.clnWID;
    fore=g.rttnparams.clnWID;
    multy=g.rttnparams.clnMLTY;
    if multy==1
        for i=1:length(beadSel)
            ded=[];
            for j=1:length(h.rttnedit.Bead(beadSel(i)).z)
                if abs(h.rttnedit.Bead(beadSel(i)).z(j))>value
                    ded(j)=j;
                end
            end
            ded(ded==0)=[];
            for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
                maxmax=k+fore;
                minmin=k-reverse;
                while maxmax>length(h.rttnedit.t)
                    maxmax=maxmax-1;
                end
                while minmin<1
                    minmin=minmin+1;
                end
                h.rttnedit.Bead(beadSel(i)).z(minmin:maxmax)=0;
            end
            cla(g.FIGS.plot(fid).axesTRC(beadSel(i))); g.FIGS.plot(fid).beadTRC(beadSel(i))=plot(g.FIGS.plot(fid).axesTRC(beadSel(i)),h.rttnedit.t,h.rttnedit.Bead(beadSel(i)).z,'b');
        end
    elseif multy==0
        ded=[];
        thisbead=str2double(get(hObject,'Tag'));
        for j=1:length(h.rttnedit.Bead(thisbead).z)
            if abs(h.rttnedit.Bead(thisbead).z(j))>value
                ded(j)=j;
            end
        end
        ded(ded==0)=[];
        for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
            maxmax=k+fore;
            minmin=k-reverse;
            while maxmax>length(h.rttnedit.t)
                maxmax=maxmax-1;
            end
            while minmin<1
                minmin=minmin+1;
            end
            h.rttnedit.Bead(beadSel(i)).z(minmin:maxmax)=0;
        end
        cla(g.FIGS.plot(fid).axesTRC(thisbead)); g.FIGS.plot(fid).beadTRC(thisbead)=plot(g.FIGS.plot(fid).axesTRC(thisbead),h.rttnedit.t,h.rttnedit.Bead(thisbead).z,'b');
    end
end %trucates time trace as instructed by user, and creates temporary data

function savdat(hObject,~,~)
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});
   	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    if g.rttnparams.clnMLTY==1
        for i=1:length(beadSel)
            h.rttndata(fid).Bead(i).z=h.rttnedit.Bead(i).z;
        end
    elseif g.rttnparams.clnMLTY==0
        thisbead=str2double(get(hObject,'Tag'));
        h.rttndata(fid).Bead(thisbead).z=h.rttnedit.Bead(thisbead).z;
    end
    h.rttndata(fid).t=h.rttnedit.t;
    h.rttndata(fid).mp=h.rttnedit.mp;
    h.rttndata(fid).mr=h.rttnedit.mr;
    h.rttndata(fid).refZ=h.rttnedit.refZ;
end %makes changes to the time trace data permanent

function rttnparams (hObject,~,~)
    try
        if strcmp(get(hObject,'Style'),'popupmenu')
            str=get(hObject,'String');
            val=get(hObject,'Value');
            out=str2double(str{val});
            pass=val;
        elseif strcmp(get(hObject,'Style'),'edit')
            out=str2double(get(hObject,'String'));
            assert(~isempty(out));
            pass=out;
        elseif strcmp(get(hObject,'Style'),'checkbox')
            out=get(hObject,'Value');
            pass=out;
        end
    catch
        errordlg('Maybe try entering numbers?','Something went wrong!');
        return;
    end
    g.rttnparams=setfield(g.rttnparams,get(hObject,'Tag'),out); %#ok<SFLD>
    
    val=get(hObject,'Style');
    
    synchrttnparams(pass,val);
end %changes the values used to make bad data usable

function synchrttnparams(pass,val)
  	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beadSel=regexprep(tabnam,'Bead ','');
    
	for i=1:length(beadSel)
        if strcmp(val,'edit')
            set(g.FIGS.beadPAN(index).widPARAM(str2double(beadSel{i})),'String',pass);
        elseif strcmp(val,'popupmenu')
            set(g.FIGS.beadPAN(index).hiPARAM(str2double(beadSel{i})),'Value',pass);
        else
            set(g.FIGS.beadPAN(index).mltyPARAM(str2double(beadSel{i})),'Value',pass);
        end
	end
end %makes sure all these values are synched across the gui

function breakbtn(hObject,~,~)
    g.BreakTimerValue=get(hObject,'String');
end %buttons for selecting curves assign values throguh here

function timerfunc(~,~)
    thumbtwiddler=1;
    while thumbtwiddler<10000
        if ~strcmp(g.BreakTimerValue,'nuthin')
            return
        end
        thumbtwiddler=thumbtwiddler+1;
        pause(0.3);
    end 
end %first attempt at a timer function. kinda rediculous method, but it works

function delpan(hObject,~,~)
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    
    bead=str2double(get(hObject,'Tag'));
    
    rttndata(bead,1,0,0,0); rttndata(bead,2,0,0,0); rttndata(bead,3,0,0,0); rttndata(bead,4,0,0,0);
    
    g.deletions(bead)=g.FIGS.beadPAN(index).mainPAN(bead);
    
  	delete(g.FIGS.beadPAN(index).mainPAN(bead));
end %deletes a panel, and deletes its data. not recoverable

function fileselectionsynch(hObject,~,~)
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    
    for i=1:length(beads); set(g.FIGS.beadPAN(index).fileSEL(str2double(beads{i})),'Value',get(hObject,'Value')); end
end %makes sure the file selection menus all have the same value

function pathSEL(~,~)
    h.path=uigetdir();
    g.pathEDT.String=h.path;
    checkDir;
end %select file path

function exdat(~,~)
    assignin('base','DATOUT',h);        
end %exports data to matlab

function klara(~,~)
    h.rttndata=[];
    h.rttnedit=[];
    h.breakdata=[];
    h.avdata=[];
    h.fitdata=[];
end %clears smth

end %MainGUIdelete