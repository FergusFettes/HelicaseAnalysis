function getparams (~,~)
global g; global h;
[index]=GCF_Data;
    
    % get filenames
    dir_content=dir(fullfile(h.path,'tmp_*.dat'));
    rawFilenames = {dir_content.name};

    % get cycle filenames
    cycleFilenames=regexp(rawFilenames(:),'(tmp_\d{3}_cycle)','tokens');
    cycleFilenames=[cycleFilenames{:}];
    cycleFilenames=unique([cycleFilenames{:}]');
    cycleNumbers=regexp(cycleFilenames,'(\d{3})','tokens'); cycleNumbers=[cycleNumbers{:}];
    
    % user selects appropriate cycle file from list
    selection=listdlg('PromptString','Please choose ID of force calibration file: ###',...
                    'SelectionMode','single',...
                     'ListString',[cycleNumbers{:}]);
    answer=cycleNumbers{selection};
    if isempty(answer); return; end
    
    fileID=str2num(answer{:});
    try
        if length(answer{:})~=3
            errordlg('Please enter a three digit number!','Invalid input!');
            return;
        elseif ~isfield(h.Params,'fcal')
            errordlg('Have you done the force calibration yet?','Parameters not found!');
            return;
        else
            assert(~isempty(h.Params(fileID).fcal.a));
            names=[]; for i=1:length(h.Params(fileID).fcal.a); names=[names(:)' {num2str(i)}]; end
            g.FIGS.Params.fitparams(index).RowName=names(:)';
            g.FIGS.Params.fitparams(index).Data=[h.Params(fileID).fcal.a;h.Params(fileID).fcal.b;h.Params(fileID).fcal.c;h.Params(fileID).fcal.gdns]';
        end
    catch
        errordlg('Check the number!','No params for that file!');
       	return;
    end
    g.FIGS.Params.fitparams(index).Visible='on';
end %imports fcal parameters for finishing the analysis
