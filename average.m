function average(~,~,~)
global g; global h;
in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fileID=str2num(fileID{:});

beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});

dat=h.Params(fileID).fig(index).results(beadnum);
% 'force'   'height_bp'     'velocity_bp'   'rate'  'height'    'time'  'velocity'  'conversion'

velo=dat.velocity_bp;
velowind=velo(velo<0); velounwind=velo(velo>0);

proc=dat.height_bp;
procwind=proc(velo<0); procunwind=proc(velo>0);

g.FIGS.averages(index).re(beadnum).String=strcat(num2str(mean(velowind)),'+/-', num2str(std(velowind)));
g.FIGS.averages(index).relong(beadnum).String=strcat(num2str(mean(procwind)),'+/-', num2str(std(procwind)));
g.FIGS.averages(index).recount(beadnum).String=length(velowind(~isnan(velowind)));

g.FIGS.averages(index).un(beadnum).String=strcat(num2str(mean(velounwind)),'+/-', num2str(std(velounwind)));
g.FIGS.averages(index).unlong(beadnum).String=strcat(num2str(mean(procunwind)),'+/-', num2str(std(procunwind)));
g.FIGS.averages(index).uncount(beadnum).String=length(velounwind(~isnan(velounwind)));

end % averages the speeds for this bead
