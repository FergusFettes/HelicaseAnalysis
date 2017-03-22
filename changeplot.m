function changeplot(hObject,~,~)
global g;
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2num(fileID{:});
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});

    if strcmp(get(hObject,'String'),'<<-')
        g.zoomdat(index).xmin(beadnum)=g.zoomdat(index).xmin(beadnum)-g.slideval;
        g.zoomdat(index).xmax(beadnum)=g.zoomdat(index).xmax(beadnum)-g.slideval;
        set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)]);
        set(g.FIGS.setlim(index).xmin(beadnum),'String',num2str(g.zoomdat(index).xmin(beadnum)));
        set(g.FIGS.setlim(index).xmax(beadnum),'String',num2str(g.zoomdat(index).xmax(beadnum)));
    elseif strcmp(get(hObject,'String'),'->>')
        g.zoomdat(index).xmin(beadnum)=g.zoomdat(index).xmin(beadnum)+g.slideval;
        g.zoomdat(index).xmax(beadnum)=g.zoomdat(index).xmax(beadnum)+g.slideval;
        set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)]);
        set(g.FIGS.setlim(index).xmin(beadnum),'String',num2str(g.zoomdat(index).xmin(beadnum)));
        set(g.FIGS.setlim(index).xmax(beadnum),'String',num2str(g.zoomdat(index).xmax(beadnum)));
    elseif strcmp(get(hObject,'String'),'\/')
        g.zoomdat(index).ymin(beadnum)=g.zoomdat(index).ymin(beadnum)-g.riseval;
        g.zoomdat(index).ymax(beadnum)=g.zoomdat(index).ymax(beadnum)-g.riseval;
        set(g.FIGS.plot(fileID).axes(beadnum),'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        set(g.FIGS.setlim(index).ymin(beadnum),'String',num2str(g.zoomdat(index).ymin(beadnum)));
        set(g.FIGS.setlim(index).ymax(beadnum),'String',num2str(g.zoomdat(index).ymax(beadnum)));
    elseif strcmp(get(hObject,'String'),'/\')
        g.zoomdat(index).ymin(beadnum)=g.zoomdat(index).ymin(beadnum)+g.riseval;
        g.zoomdat(index).ymax(beadnum)=g.zoomdat(index).ymax(beadnum)+g.riseval;
        set(g.FIGS.plot(fileID).axes(beadnum),'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        set(g.FIGS.setlim(index).ymin(beadnum),'String',num2str(g.zoomdat(index).ymin(beadnum)));
        set(g.FIGS.setlim(index).ymax(beadnum),'String',num2str(g.zoomdat(index).ymax(beadnum)));
    else
        if strcmp(get(hObject,'String'),'Set Axes')
            set(g.FIGS.plot(fileID).axes(beadnum),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)],'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
        elseif strcmp(get(hObject,'String'),'Global Axes')
            for i=1:20
                try %!!! see elsewhere for complaints about this horrible loop. needs fixing
                    set(g.FIGS.plot(fileID).axes(i),'XLim',[g.zoomdat(index).xmin(beadnum) g.zoomdat(index).xmax(beadnum)],'YLim',[g.zoomdat(index).ymin(beadnum) g.zoomdat(index).ymax(beadnum)]);
                catch
                end
            end
        end
    end
end % updates plot with new limits
