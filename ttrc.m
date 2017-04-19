function ttrc(~,~) 
global g; global h; global d;
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
        if min(d.tracedata(fid).Bead(beadSel(i)).z)<-2
            axis(axsBds(beadSel(i)),[0 max(d.tracedata(fid).t) 1 4]);
        else
            axis(axsBds(beadSel(i)),'tight');
        end
        xlabel(axsBds(beadSel(i)),'Time (s)');
        ylabel(axsBds(beadSel(i)),'Height (mu m)');
    end

    h.filedat=files;
end %ttrc