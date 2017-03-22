function plot_beads(~,~,fid,figslong,beadnum)
global g; global d;
%plot the beaddata in the right axes
%   g.FIGS.plot(fid).bead(beadnum)=plot(axsBds(beadnum), d.tracedata(fid).t+globalT,d.tracedata(fid).Bead(beadnum).z,'b'); hold on;   % plot bdsZ removed globalT from the line below, see here for usage. dont know what it was for.
    g.FIGS.plot(fid).bead(beadnum).norm(figslong)=plot(g.FIGS.plot(fid).axes(beadnum),...
                                         d.tracedata(fid).t,...
                                          d.tracedata(fid).Bead(beadnum).zNORM, 'k');
  	hold(g.FIGS.plot(fid).axes(beadnum),'on');
    g.FIGS.plot(fid).bead(beadnum).smooth(figslong)=plot(g.FIGS.plot(fid).axes(beadnum),...
                                                d.tracedata(fid).t,...
                                                 d.tracedata(fid).Bead(beadnum).z, 'g');    % plot bdsZ

    %get the x-limits and export them to the axis-changers (local and global) and zoom controls
    xlimits=get(g.FIGS.plot(fid).axes(beadnum),'XLim');
    g.FIGS.setlim(figslong).xmin(beadnum).String=xlimits(1); g.FIGS.setlim(figslong).xmax(beadnum).String=xlimits(2);
    g.FIGS.globlim(figslong).xmin(beadnum).String=xlimits(1); g.FIGS.globlim(figslong).xmax(beadnum).String=xlimits(2);
    g.zoomdat(figslong).xmin(beadnum)=xlimits(1); g.zoomdat(figslong).xmax(beadnum)=xlimits(2);
    
    %get the y-limits and export them to the axis-changers (local and global) and zoom controls
    ylimits=get(g.FIGS.plot(fid).axes(beadnum),'YLim');
    g.FIGS.setlim(figslong).ymin(beadnum).String=ylimits(1); g.FIGS.setlim(figslong).ymax(beadnum).String=ylimits(2);
    g.FIGS.globlim(figslong).ymin(beadnum).String=ylimits(1); g.FIGS.globlim(figslong).ymax(beadnum).String=ylimits(2);
    g.zoomdat(figslong).ymin(beadnum)=ylimits(1); g.zoomdat(figslong).ymax(beadnum)=ylimits(2);
end
