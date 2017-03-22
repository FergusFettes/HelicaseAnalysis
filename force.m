function force(~,~)
global g; global h;
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
