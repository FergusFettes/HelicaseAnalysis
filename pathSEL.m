function pathSEL(~,~)
global g; global h;
    h.path=uigetdir();
    g.pathEDT.String=h.path;
    checkDir;
end %select file path
