function setlim(hObject,~,~)
global g;
  	in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});
    
    beads=regexprep(beadnames,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    if strcmp(get(hObject,'Tag'),'xmin')
        g.zoomdat(index).xmin(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'xmax')
        g.zoomdat(index).xmax(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'ymin')
        g.zoomdat(index).ymin(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'ymax')
        g.zoomdat(index).ymax(beadnum)=str2num(get(hObject,'String'));
    elseif strcmp(get(hObject,'Tag'),'slideval')
        g.slideval=str2num(get(hObject,'String'));
        for i=beadSel
            set(g.FIGS.setlim(index).slideval(i),'String',get(hObject,'String'));
        end
    elseif strcmp(get(hObject,'Tag'),'riseval')
        g.riseval=str2num(get(hObject,'String'));
        for i=beadSel
            set(g.FIGS.setlim(index).riseval(i),'String',get(hObject,'String'));
        end
    end
    
    %!!! The name 'String' is not an accessible property for an instance of
    %class 'matlab.graphics.GraphicsPlaceholder'. error when I try to use :
    %instead of this horrible loop. I have this same problem elsewhere.
    
    for i=beadSel
        if strcmp(get(hObject,'Tag'),'glob xmin')
            g.zoomdat(index).xmin(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).xmin(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).xmin(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob xmax')
            g.zoomdat(index).xmax(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).xmax(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).xmax(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob ymin')
            g.zoomdat(index).ymin(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).ymin(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).ymin(i),'String',get(hObject,'String'));
        elseif strcmp(get(hObject,'Tag'),'glob ymax')
            g.zoomdat(index).ymax(i)=str2num(get(hObject,'String'));
            set(g.FIGS.setlim(index).ymax(i),'String',get(hObject,'String'));
            set(g.FIGS.globlim(index).ymax(i),'String',get(hObject,'String'));
        end
    end
end %sets the limits for time trace
