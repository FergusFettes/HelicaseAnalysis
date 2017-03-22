function getz (~,~)
global g; global h;
[index,fileID,~,field]=GCF_Data;
    
    oldname=get(g.FIGS.(field{:})(index), 'Name');
    set(g.FIGS.(field{:})(index), 'Name', 'Click figure, hold alt and click on data max + min. Press enter when done.');

    cursorobj=datacursormode(g.FIGS.(field{:})(index));
    cursorobj.SnapToDataVertex = 'on';
    
    while ~waitforbuttonpress
        cursorobj.Enable = 'on';
    end
    cursorobj.Enable = 'off';
    
   	info=getCursorInfo(cursorobj); position={info.Position}.';
    
  	beadnames=get(g.FIGS.pnlTAB(index),'TabTitles'); bead=beadnames(get(g.FIGS.pnlTAB(index),'Selection'));
    beadnum=regexp(bead,'(\d+)(\w?)$','match'); beadnum=str2num(beadnum{:}{:});

    try 
        RowNames=g.FIGS.Params.heights(index).bead(beadnum).RowName;
        partnum=length(RowNames);
    catch 
        g.FIGS.Params.heights(index).PAN(beadnum)=uipanel('Parent',g.FIGS.Params.partsBOX(index),'Title',bead);     %cannot set preperty of deleted object error, I guess because I had another one of the same sort open and deleted it???!!!
            nowbox= uix.VBox('Parent',g.FIGS.Params.heights(index).PAN(beadnum));
                g.FIGS.Params.heights(index).bead(beadnum)= uitable('Units', 'Normalized','Parent',nowbox, ...
                    'ColumnName',{'z-Min','z-Max','Start','Finish'});
        RowNames=[];
        partnum=0;
    end
    
    if mod(length(position),2) %if odd number of positions
        errordlg('Please select mins and maxs in pairs of two!','Bad data!');
        return;
    elseif ~mod(length(position),2) %if even number of positions
        num=length(position)/2;
        part=cell(num,1);
        %split the points into two-part parts
        for i=1:num                             %!!!could easily get rid of many of the {}s in part
            part(i)={position((2*i)-1:(2*i))};                      %gets the nth and n+1th datapoint
                                                                    %make sure they are all the right way round
            if part{i}{1}(2)>part{i}{2}(2)                          %if height of point 1 is greater than height of point 2
                max(i)=part{i}{1}(2); min(i)=part{i}{2}(2);         %max is height of point 1 and min is height of point 2
                finish(i)=part{i}{1}(1); start(i)=part{i}{2}(1);    %finish is time of point 1 and start is time of point 2
            else                                                    %otherwise
                max(i)=part{i}{2}(2); min(i)=part{i}{1}(2);         %max is height of point 2 and min is height of point 1
                finish(i)=part{i}{2}(1); start(i)=part{i}{1}(1);    %finish is time of point 2 and start is time of point 1
            end
            %create rownames (start time)
            row={strcat('T=',num2str(start(i)))};
            RowNames=[RowNames(:)' row];
        end 
      	%ensure parts from different intakes are added together nicely
        for j=partnum+1:partnum+num
           	%export data
           	h.Params(fileID).fig(index).heights(beadnum).part(j)=struct('min',min(j-partnum),'max',max(j-partnum),'start',start(j-partnum),'finish',finish(j-partnum));
        end 
    end
    
  	delete(findall(gcf,'Type','hggroup'));
    
  	set(g.FIGS.Params.heights(index).bead(beadnum),'RowName',RowNames(:)','Data',[h.Params(fileID).fig(index).heights(beadnum).part.min;h.Params(fileID).fig(index).heights(beadnum).part.max;h.Params(fileID).fig(index).heights(beadnum).part.start;h.Params(fileID).fig(index).heights(beadnum).part.finish]');
    set(g.FIGS.Params.ttrc(index),'Visible','on');
    for i=1:length(g.BTNS.Params(index).ttrc)
        if isfield(g.BTNS.Params(index).ttrc(i),'Number')
            set(g.BTNS.Params(index).ttrc(:),'Value',1);
        end
    end
   	set(g.FIGS.(field{:})(index), 'Name', oldname(:)');

    
end %gets points from time trace with help from user
