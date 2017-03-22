function fitParamsFext(tag,~)
global g; global h;
if  isfield(g.FIGS.Params, 'fext'); figslong=length(g.FIGS.Params.fext)+1; else figslong=1; end
  	g.FIGS.Params.fext(figslong) = figure('Visible','off','Name','Force Extension Parameters', ...
       	'NumberTitle','off','Toolbar','none','Position',(g.defPosPAR+figslong*[5 -5 0 0]),'Tag',tag{:}, ...
            'CloseRequestFcn',@closerequest);
    fitParamsTBL=uitable('Units', 'Normalized','Position',[0 0 1 1],'ColumnName',{'L','p','gdns'});
    beadSel=g.beadLST.Value;
    beadsString=g.beadLST.String;
    fileSel=g.fileLST.String(g.fileLST.Value);
    fileNamesSel=regexprep(fileSel,'cycle','cycle_Bead');
    fileID=regexp(fileNamesSel,'tmp_(\d\d\d)','tokens');
    fileID=str2double(fileID{:}{:}{:});
    fitParamsTBL.RowName=beadsString(beadSel',:);
    fitParamsTBL.Data=[h.Params(fileID).fext.L;h.Params(fileID).fext.p;h.Params(fileID).fext.gdns]';
end %fitParamsFext !!! consider combining these two?
