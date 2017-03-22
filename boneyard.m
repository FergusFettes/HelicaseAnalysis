%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% BONEYARD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

% function collect_data(hObject,~,~)
%     [index,fid]=GCF_Data;
%     
%     bead=str2double(get(hObject,'Tag'));
%     
%     d.collect_data.force=[d.collect_data.force(:)' h.Params(fid).fig(index).results(bead).force];
%     d.collect_data.height_bp=[d.collect_data.height_bp(:)' h.Params(fid).fig(index).results(bead).height_bp];
%     d.collect_data.velocity_bp=[d.collect_data.velocity_bp(:)' h.Params(fid).fig(index).results(bead).velocity_bp];  
%     d.collect_data.rate=[d.collect_data.rate(:)' h.Params(fid).fig(index).results(bead).rate];
%     d.collect_data.height=[d.collect_data.height(:)' h.Params(fid).fig(index).results(bead).height];
%     d.collect_data.time=[d.collect_data.time(:)' h.Params(fid).fig(index).results(bead).time];
%     d.collect_data.velocity=[d.collect_data.velocity(:)' h.Params(fid).fig(index).results(bead).velocity];
%     
% %     d.collect_data=h.Params(fid).fig(index).results(bead);
%     
% end %organises the data into a nice structure for exporting

% function eqtn(hObject,~,~)
%     sel = get(hObject,'Value');
%     if sel==1
%         g.FitSettings.(get(hObject,'Tag'))=g.FitTypes.Worm;
%     elseif sel==2
%         g.FitSettings.(get(hObject,'Tag'))=g.FitTypes.Cali1;
%     else %do nothing (space here for other fit types)
%     end
% 
% end %ready to make equations variable


% function restore(~,~)
%     cleancontent=dir(fullfile(h.path,'tmp_*.CLEAN*'));
%     % rename files
%     if ~isempty(cleancontent)
%         g.restoreMSG.msg='The following cleaned files were returned:';
%     for z=1:length(cleancontent)
%         cleanfile=char(fullfile(h.path,cleancontent(z).name));
%         datfile=char(fullfile(h.path,regexprep(cleancontent(z).name,'.CLEAN\w+','.dat')));
%         movefile(cleanfile,datfile);
%         g.restoreMSG.msg=strcat(g.restoreMSG.msg,{' '},datfile);
%     end
%     elseif isempty(cleancontent); g.restoreMSG.msg='No clean files. This place is filthy!';      
%     end
%     g.restoreMSG.box=msgbox(g.restoreMSG.msg,'Uncleaning files.');
%     checkDir;
% end %restores cleaned files

% function SubmitEvents(~,~)
%     [index,fileID,fileNum]=GCF_Data;
%     
%     try    
%         for i=1:length(h.Params(fileID).fig(index).heights); if ~isempty(h.Params(fileID).fig(index).heights(i).part); beadNum(i)=i; end; end 
%     catch
%         errordlg('Have you selected any points?','Data not found.');
%         return;
%     end
%     
%     beadNum=beadNum(beadNum~=0);
%     
%     filename=strcat('tmp_',fileNum{:},'.log');
%     cFilename=fullfile(h.path,filename);    
%     time = getNumFromLog(cFilename,'time'); time = time(2:end-1);
%     date = getNumFromLog(cFilename,'date'); date = date(2:end-1);
%     ActualTime = datetime({time,date});
%     
%     for i = 1: length(h.Params(fileID).fig(index).results)
%         longnow=length(e); %consider doing e(actualtime)???
%         e(longnow + 1).Force = h.Params(fileID).fig(index).results(i).force;
%         e(longnow + 1).HeightBp = h.Params(fileID).fig(index).results(i).height_bp;
%         e(longnow + 1).VelocityBp =  h.Params(fileID).fig(index).results(i).velocity_bp;
%         e(longnow + 1).Rate =  h.Params(fileID).fig(index).results(i).rate;
%         e(longnow + 1).Height =  h.Params(fileID).fig(index).results(i).height;
%         e(longnow + 1).Duration =  h.Params(fileID).fig(index).results(i).time;
%         e(longnow + 1).Velocity =  h.Params(fileID).fig(index).results(i).velocity;
%         e(longnow + 1).BpConversion =  h.Params(fileID).fig(index).results(i).conversion; %!!! (only one conversion?)
%         e(longnow + 1).FitParameters = g.FIGS.Params.fitparams(index);
%         e(longnow + 1).ActualTime = ActualTime;
%     end
%     
% end