function fitParamsFcal(tag,~)
global g; global h;
if isfield(g.FIGS.Params, 'fcal'); figslong=length(g.FIGS.Params.fcal)+1; else figslong=1; end
   	g.FIGS.Params.fcal(figslong) = figure('Visible', 'off', 'Name','Force Calibration Parameters', ...
    	'NumberTitle','off','Toolbar','none','Position',(g.defPosPAR+figslong*[5 -5 0 0]),'Tag',tag{:}, ...
        	'CloseRequestFcn',@closerequest);
    fitParamsTBL=uitable('Units', 'Normalized','Position',[0 0 1 1],'ColumnName',{'a','b','c','gdns'});
    beadSel=g.beadLST.Value;
    beadsString=g.beadLST.String;
    fileSel=g.fileLST.String(g.fileLST.Value);
    fileNamesSel=regexprep(fileSel,'cycle','cycle_Bead');
    fileID=regexp(fileNamesSel,'tmp_(\d\d\d)','tokens'); fileID=str2double(fileID{:}{:}{:});
    fitParamsTBL.RowName=beadsString(beadSel',:);
    fitParamsTBL.Data=[h.Params(fileID).fcal.a;h.Params(fileID).fcal.b;h.Params(fileID).fcal.c;h.Params(fileID).fcal.gdns]';
end % creates figure displaying fit parameters
