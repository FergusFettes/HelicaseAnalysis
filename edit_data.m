function edit_data(hObject,~,~)
global d;
in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2double(in{:});
   	fileID=regexp(get(gcf,'Tag'),'\d{3}','match'); fid=str2double(fileID{:});
    
    tabnam=get(g.FIGS.pnlTAB(index),'TabTitles'); beads=regexprep(tabnam,'Bead ','');
    for i=1:length(beads); beadSel(i)=str2double(beads{i}); end
    
    d.dataedit.t=d.tracedata(fid).t;                                                % assign t
   	d.dataedit.mp=d.tracedata(fid).mp;                                          	% assign mp
   	d.dataedit.refZ=d.tracedata(fid).refZ;                                       % assign refZ
	for i=beadSel; 
      	d.dataedit.Bead(i).z=d.tracedata(fid).Bead(i).z;                          % assign Bead-zs
	end
    
   	%% Clean absurd values
    value=g.cleanhi;
    reverse=10;
    fore=10;
    if strcmp(get(hObject,'String'),'Clean One');  multy=0; elseif strcmp(get(hObject,'String'),'Clean All'); multy=1; end
    if multy==1
        for i=1:length(beadSel)
            ded=[];
            for j=1:length(d.dataedit.Bead(beadSel(i)).z)
                if abs(d.dataedit.Bead(beadSel(i)).z(j))>value
                    ded(j)=j;
                end
            end
            ded(ded==0)=[];
            for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
                maxmax=k+fore;
                minmin=k-reverse;
                while maxmax>length(d.dataedit.t)
                    maxmax=maxmax-1;
                end
                while minmin<1
                    minmin=minmin+1;
                end
                d.dataedit.Bead(beadSel(i)).z(minmin:maxmax)=0;
            end
            cla(g.FIGS.plot(fid).axes(beadSel(i))); g.FIGS.plot(fid).beadTRC(beadSel(i))=plot(g.FIGS.plot(fid).axes(beadSel(i)),d.dataedit.t,d.dataedit.Bead(beadSel(i)).z,'k');
        end
    elseif multy==0
        ded=[];
        thisbead=str2double(get(hObject,'Tag'));
        for j=1:length(d.dataedit.Bead(thisbead).z)
            if abs(d.dataedit.Bead(thisbead).z(j))>value
                ded(j)=j;
            end
        end
        ded(ded==0)=[];
        for k=ded %this is really inelegant, as it wipes the same positions multiple times :/
            maxmax=k+fore;
            minmin=k-reverse;
            while maxmax>length(d.dataedit.t)
                maxmax=maxmax-1;
            end
            while minmin<1
                minmin=minmin+1;
            end
            d.dataedit.Bead(thisbead).z(minmin:maxmax)=0;
        end
      	cla(g.FIGS.plot(fid).axes(thisbead)); g.FIGS.plot(fid).beadTRC(thisbead)=plot(g.FIGS.plot(fid).axes(thisbead),d.dataedit.t,d.dataedit.Bead(thisbead).z,'k');
    end
end %trucates time trace as instructed by user, and creates temporary data
