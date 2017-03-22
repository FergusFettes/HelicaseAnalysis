function exdat(~,~)
global d; global h;
    assignin('base','PARAMSEXPORT',h.Params);     
    assignin('base','DATAEXPORT',h.filedat);
    assignin('base','Data_Collection',d.collect_data);
    %assignin('base','GG',g);
end %exports the manipulated data (in h structure) to base
