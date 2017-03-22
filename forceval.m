function forceval(hObject,~,~)
global g; global h;
% get force box details
    in=regexp(get(gcf,'Tag'),'(\d+)$','match'); index=str2num(in{:});
    
    % get param file number from tag
  	in=regexp(get(hObject,'Tag'),'(\d+)$','match'); paramfileID=str2num(in{:});
    
    % get magpos from hObject
    val=get(hObject,'Value'); str=get(hObject,'String');
    magpos=str(val); magpos=str2num(magpos{:});
    
    % get beadSel from tag
    nums=regexp(get(gcf,'Tag'),'\d{1,3}','match'); nums=nums(2:end-1);
    for i=1:length(nums); beadNum(i)=str2num(nums{i}); end
    
    for i=beadNum;
        if h.Params(paramfileID).fcal.gdns(i)==0
            forces(i)=NaN;
        elseif isnan(h.Params(paramfileID).fcal.gdns(i))
            forces(i)=NaN;
        else
            a=h.Params(paramfileID).fcal.a(i); b=h.Params(paramfileID).fcal.b(i); c=h.Params(paramfileID).fcal.c(i);
            forces(i)=exp(a.*magpos.^2+b.*magpos+c);
        end
        g.FIGS.force(index).beadforce(i).String=num2str(forces(i));
    end
    
    forces=forces(forces~=0);
    
    av=mean(forces,'omitnan');
    dev=std(forces,'omitnan');
    
    g.FIGS.force(index).mean.String=strcat(num2str(av),'+/-',num2str(dev));
    
    rang=range(forces);
    common=mode(floor(forces(:)));
    
    g.FIGS.force(index).range.String=strcat('Range:',num2str(rang),'.           Most common:',num2str(common));
    
end %calculates the force and outputs it to force above
