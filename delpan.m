function delpan(hObject,~,~)
global g;
    [index]=GCF_Data;
    
    bead=str2double(get(hObject,'Tag'));
    
    g.deletions(bead)=g.FIGS.beadPAN(index).mainPAN(bead);
    
  	delete(g.FIGS.beadPAN(index).mainPAN(bead));
    
    if isempty(allchild(g.FIGS.pnlTAB(index))); delete(g.FIGS.ttrc(index)); end
end %deletes this panel
