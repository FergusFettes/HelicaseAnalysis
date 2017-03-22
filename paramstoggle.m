function paramstoggle(~,~,~) 
global g;
    % get name and number from tag
  	field=regexp(get(gcf,'Tag'),'^(\w+)','match'); in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    % set the visibility of the window to the value of the togglebutton (ie on or off)
    g.FIGS.Params.(field{:})(index).Visible = get(g.BTNS.Params(index).(field{:}),'State');
end % shows parameters figure
