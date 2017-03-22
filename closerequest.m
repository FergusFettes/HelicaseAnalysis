function closerequest(~,~,~)
global g;
    % gets fieldname and index from current figure
    field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    % hides figure if close button is pressed while the plot is still open
    if  ishandle(g.BTNS.Params(index).(field{:}))
        set(g.BTNS.Params(index).(field{:}),'State','off');
    else delete(gcf);    
    end
end % stops errors when params figure is closed
