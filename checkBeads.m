function checkBeads(~,~)
global g; global h;
    % get old bead selection
    beadSelOld=g.beadLST.Value;
    % nBeadsOld=length(g.beadLST.String);

    % get file selection
    fileSel=g.fileLST.Value; 
    nfileSel=length(fileSel);

    % get DNAbeads from logs of all selected files
    DNAbeads=zeros(1,nfileSel);
    for i=1:nfileSel;
        cFile=fileSel(i);
        filenum=regexp(h.filenames{cFile},'tmp_\d\d\d','match');
        cFilename=fullfile(h.path,strcat(filenum,'.log'));
        DNAbeads(i)=getNumFromLog(cFilename{:},'#beads'); %gtnumfromlog $$$ got improper assignment with rectangular matrix error while doing ttrc
    end

    % if files have unequal DNAbeads, error and revert number of files selected to 1
    if length(unique(DNAbeads))~=1
        errordlg('Number of beads in selected files not equal, resetting selection','Number of beads not equal');
        fileSel=fileSel(1);
        g.fileLST.Value=fileSel;
        DNAbeads=DNAbeads(1);
    end

    % check none of the beads have been cleaned
    beadsNew= 1:DNAbeads(1);
    beadcln=zeros(DNAbeads(1),1);

    fileNam=g.fileLST.String(g.fileLST.Value);
    if length(fileNam)==1 && ~isempty(regexp(fileNam{:},'cycle', 'once'))
        for i=1:DNAbeads(1)
            datfile=char(fullfile(h.path,strcat(filenum,'_cycle_Bead',num2str(beadsNew(i)),'.dat')));
            if  exist(datfile,'file');
                beadcln(i)=i;
            else beadcln(i)=0;
            end
        end

    %populate list
    beadcln=beadcln(beadcln~=0);
    nBeadsNew=length(beadcln);
    g.beadLST.String=beadcln;

    else

    % populate list
    beadsNew=1:DNAbeads(1);
    nBeadsNew=length(beadsNew);
    g.beadLST.String=beadsNew;

    end

    % if prev selection possible, retain, else revert to 1
    if max(beadSelOld) > nBeadsNew  
        g.beadLST.Value=1:length(g.beadLST.String); %!!!ALL THE BEADS
    else g.beadLST.Value=beadSelOld; 
    end

end %populate bead list from selected files