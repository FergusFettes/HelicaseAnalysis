function exfs(~,~)
global g; global h;
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
