function offset(~,~)
global g; global h;
% get bead and file selections
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).'; nbeadSel=length(beadSel); 
  	fileSel=g.fileLST.String(g.fileLST.Value); fileID=regexp(fileSel,'tmp_(\d\d\d)','tokens');


    % prepare filename of selected file
    if isfield(g.FIGS,'offs'); figslong=(1+length(g.FIGS.offs)); else figslong=1; end
    
    % create figure with enough subplots    
   	g.FIGS.offs(figslong)=figure('Position',(g.defPos+figslong*[5 -5 0 0]),'Name','Offset 3D Plots','NumberTitle','off');

    rows=round(nbeadSel^.5); cols=ceil(nbeadSel^.5); 
    s = zeros(1,25); %preallocating
    for i=1:(rows*cols); s(i)=subplot(rows,cols,i); end   
    
    cFile=fullfile(h.path,strcat(fileSel{:},'.dat'));
    [DNAbeads]=getNumFromLog(strcat(cFile(1:end-4),'.log'),'#DNAbeads');   	 % get number of beads
    data=getTweezerDataMB(cFile);                                          	 % load data ?? gettweezerdatamb$$$
    t=data{1};                                                    % assign t
    
    for beadID=1:DNAbeads
        Bead(beadID).z=data{3 * (beadID + 1)};
        Bead(beadID).y=data{3 * (beadID + 1) - 1};
        Bead(beadID).x=data{3 * (beadID + 1) - 2};
    end;   % assign z all DNAbeads
    
    c = linspace(1,10,length(Bead(1).z));
    
    count=1;
    for num=beadSel
        scatter3(s(count),Bead(num).x,Bead(num).y,Bead(num).z,[],c);
        view(s(count),[25 80]);
        title(s(count),strcat('Bead',{' '},num2str(num)),'FontSize',8);
        count=count+1;
    end
    
    suplabel('Projections','t');

end %fits beads to exp(ax^2+bx+c) and makes a parameters file
