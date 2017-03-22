function delbead(~,~)
global g; global h;
    [index,fileID]=GCF_Data;

    answer=inputdlg('Please enter the bead number whose data you would like to delete:','Deleting heights');
    if isempty(answer); return; end
    
    try 
     	beadnum=str2num(answer{:});
        delete(g.FIGS.Params.heights(index).PAN(beadnum));
    	h.Params(fileID).fig(index).heights(beadnum)=[];
    catch
        errordlg('That bead doesnt seem to be in the list!','Bead not found!');
    end
end %deletes bead data from table
