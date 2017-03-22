function TraceParams(tag,~)
global g;
if  isfield(g.FIGS.Params, 'ttrc'); figslong=(1+length(g.FIGS.Params.ttrc)); else figslong=1; end
   	g.FIGS.Params.ttrc(figslong) = figure('Name','Time Trace Parameters','NumberTitle','off','Toolbar','none', ...
         	'Position',(g.defPosPAR+figslong*[5 -5 0 0]), 'Visible','off','Tag',tag{:},'CloseRequestFcn',@closerequest2);
        g.FIGS.Params.vbox(figslong)= uix.VBox('Parent',g.FIGS.Params.ttrc(figslong));
            g.FIGS.Params.partsBOX(figslong) = uix.VBox('Parent',g.FIGS.Params.vbox(figslong));
            g.FIGS.Params.fitparams(figslong)= uitable('Visible','off','Units', 'Normalized','Parent',g.FIGS.Params.vbox(figslong), ...
                    'ColumnName',{'a','b','c','gdns'});
        set(g.FIGS.Params.vbox(figslong),'Heights',[-5 -1]);
end %parameters for the time trace
