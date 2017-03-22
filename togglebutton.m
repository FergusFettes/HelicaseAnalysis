function togglebutton(hObject,~,~)
global g;
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
