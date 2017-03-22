function HelicaseAnalysisGUI
global g;
g.FIGS.main=figure('Name','parPlots GUI © DNAmotors','NumberTitle','off','Toolbar','none','Menubar','none','Position',g.defPosGUI);
    g.FIGS.Params=[];
    
global h;
h=guidata(g.FIGS.main);
h.path='Z:\GroupMembers\Fergus\MATLAB\parPlots\2016-02-17'; %!!! change back for finish NB tmp 036 has some good examples of data that could afford to be truncated. maybe use for learning to truncate

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
                        g.quickEXPRTBTN=    uicontrol('Parent',g.quickCTRLGRD,'String','Projections',   'Callback',{@offset});
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
            g.asdBOX=uix.HBox('Parent',g.actnBOX);
                g.exfsBTN=uicontrol('Parent',g.asdBOX,   'Style','push',     'String','Export Figures','Callback',{@exfs});
                g.exdatBTN=uicontrol('Parent',g.asdBOX,   'Style','push',     'String','Export Data','Callback',{@exdat});
            
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

set(g.actnBOX, 'Heights', [15 120 g.pheightmin*ones(1,(n1-3)) 25] );

% Minimization %minimizing function. uses pheight values assigned at the start
function nMinimize( eventSource, eventData, whichpanel )%#ok<INUSL>
        s = get( g.actnBOX, 'Heights' );
        panel{whichpanel}.Minimized = ~panel{whichpanel}.Minimized;
        
        if panel{whichpanel}.Minimized
            s(whichpanel) = g.pheightmin;
        else
            s(whichpanel) = g.pheightmax;
        end
        set( g.actnBOX, 'Heights', s );
end

end %MainGUI