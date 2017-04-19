function DataHarvest(~,~,~)
global analysis; global e; global g;
    e=[];
    
    dataHarvestPosition=g.dataHarvestPosition;

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
