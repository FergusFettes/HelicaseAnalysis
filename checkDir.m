function checkDir
    % set path to String in Text-Edit field
    global h; global g;
    h.path=g.pathEDT.String;

    % check for folder at path location
    if exist(h.path,'dir') ~=7
        errordlg('Please select an existing Folder','Folder not found...');
        return;
    end

    % get old file selection
    fileSelOld=g.fileLST.Value;
    nFilesOld=length(g.fileLST.String);

    % check that folder contains tweezer dat files
    dir_content=dir(fullfile(h.path,'tmp_*.dat'));
    if isempty(dir_content)
        errordlg('Please select a Folder containing tweezers files!','Folder empty...');
        return;
    end

    % get dat filenames
    rawFilenames = {dir_content.name};
    datFilenames=regexp(rawFilenames(:),'(tmp_\d{3})(?:.dat)','tokens');
    datFilenames=[datFilenames{:}];
    % get cycle filenames
    cycleFilenames=regexp(rawFilenames(:),'(tmp_\d{3}_cycle)','tokens');
    cycleFilenames=[cycleFilenames{:}];
    cycleFilenames=unique([cycleFilenames{:}]');
    % merge lists 
    if iscell(cycleFilenames)
        allFilenames=flip(sort([datFilenames{:},cycleFilenames{:}]));
    else
        allFilenames=flip(sort([datFilenames{:}]));
    end
    % populate listbox
    g.fileLST.String=allFilenames;
    nFilesNew=length(g.fileLST.String);
    h.filenames=allFilenames;

    % retain old file selection: oldfile selection + nFilesNew
    if nFilesNew>=nFilesOld && nFilesOld>0
        filesNew=fileSelOld + (nFilesNew-nFilesOld);
        g.fileLST.Value=filesNew;
    else
        g.fileLST.Value =1; % if nFilesNew < nFilesOld %!!!changed for trialling
    end

    % get n beads
    checkBeads;

    guidata(g.FIGS.main,h)
end %check directory, also refresh files
