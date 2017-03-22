function [paramsout] = varyfit(goodness,fitaxes,fitdatatypes,fitequation,fitbounds,fiton)
global g; global h;
% get bead and file selections
    beadstr=str2num(g.beadLST.String);
    beadSel=beadstr(g.beadLST.Value).';
    fileSel=g.fileLST.String(g.fileLST.Value);

    % prepare filename of selected file
    fileSelName=regexprep(fileSel,'cycle','cycle_Bead');

    Paramsout=[];
    count=0;
    for i=beadSel
        count=count+1;
        % get data
        cFile=fullfile(h.path,strcat(fileSelName,num2str(i),'.dat'));
        [data1,data2,data3]=getColFromCycle(cFile{:},fitdatatypes(1),fitdatatypes(2),fitdatatypes(3)); %$$$ did some preallocating in getcolfromcycle 
        warning('off','curvefit:prepareFittingData:removingNaNAndInf');
        [xData, yData, yErr] = prepareCurveData( data1, data2, data3 );

        axes(fitaxes(count)); %#ok<LAXES> %set current axis ?? in plot cant figure out

        % attempt fit 
        try
            if (length(xData)>2 || length(yData)>2) && fiton % (only for more than two points, with fiton = 1)
                % Gets boundary conditions and starting point from fcalbounds.
                LB=[eval(fitbounds{1,1}{1}) eval(fitbounds{1,1}{2}) eval(fitbounds{1,1}{3})]; %EVAL EVERYTHING
                SP=[eval(fitbounds{1,2}{1}) eval(fitbounds{1,2}{2}) eval(fitbounds{1,2}{3})]; %$$$ any way to get rid of eval? is it such a big deal anyway?
                UB=[eval(fitbounds{1,3}{1}) eval(fitbounds{1,3}{2}) eval(fitbounds{1,3}{3})];

                % Gets fittype from input string.
                ft = fittype( fitequation, 'independent', 'x', 'dependent', 'y' );
                fo = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',LB,'Upper',UB,'StartPoint',SP,'MaxI',50);                
                [fitresult,gdns,~] = fit ( xData, yData, ft, fo );
                
                %Add goodness to Params
                Paramsout.gdns(i)=gdns.rsquare;

                if gdns.rsquare>goodness %if fit good enough, continue
                    % store fit parameters (for later display etc.)
                    fitParams=coeffvalues (fitresult);    

                    for z=1:length(fitParams); letters='a':'m';
                        Paramsout=setfield(Paramsout,letters(z),{i},fitParams(z)); %sets field letters to #params, field index to #beads and that value to the appropriate parameter
                    end

                    % plot fit (variable parameters)
                    Paramscell=cell(length(fitParams),1);
                    for z=1:length(fitParams); Paramscell(z)={fitParams(z)}; end
                    xfit=min(xData):range(xData)/1000:max(xData);
                    yfit=fitequation(Paramscell{:}, xfit);
                    plot(xfit,yfit);  hold on;

                    % plot data
                    errorbar(xData,yData,yErr,'.');
                    ylim([0.9*min(yData) 1.1*max(yData)]);
                    xlim([0.9*min(xData) 1.1*max(xData)]);
                    title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                else %if fit no good, NaN
                    % empty plot with error msg (when fit does not converge)
                    text(0.5,0.5,{'Fit','did not','converge'},'HorizontalAlignment','Center')                          
                    title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                    %NaN params
                    letters='a':'m';
                    for z=1:length(letters); % As above.
                        Paramsout=setfield(Paramsout,letters(z),{i},NaN); %sets field letters to #params, field index to #beads and that value to NaN
                    end
                end
            elseif (length(xData)>2 || length(yData)>2) && ~fiton
                % only show plot of data if fit disabled
                errorbar(xData,yData,yErr,'.');
                ylim([0.9*min(yData) 1.1*max(yData)]);
                xlim([0.9*min(xData) 1.1*max(xData)]);
                title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
            else
                % empty plot with error msg (when <= 2 points)
                text(0.5,0.5,{'Not','enough','points'},'HorizontalAlignment','Center')                          
                title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
                %empty params
                letters='a':'m'; Paramsout.gdns(i)=0;
                for z=1:length(letters); % Cant use fcalParams here, have to delete extra fields later
                    Paramsout=setfield(Paramsout,letters(z),{i},0); %sets field letters to #params, field index to #beads and that value to zero
                end
            end % if
        catch
            % empty plot with error msg (when fit does not converge)
            text(0.5,0.5,{'Fit','did not','converge'},'HorizontalAlignment','Center')                          
            title(strcat('Bead',{' '},num2str(i)),'FontSize',8,'FontName','Arial','FontWeight','normal')
            %NaN params
            letters='a':'m'; Paramsout.gdns(i)=NaN;
            for z=1:length(letters); % As above.
                Paramsout=setfield(Paramsout,letters(z),{i},NaN); %sets field letters to #params, field index to #beads and that value to NaN
            end
        end %try/catch

        %delete all uneccesary fields
        if exist('fitParams','var') && (length(fields(Paramsout))>(length(fitParams)+1));
            for z=(length(fitParams)+1):length(letters);
                Paramsout=rmfield(Paramsout,letters(z));
            end
        elseif  ~exist('fitParams','var'); Paramsout=[]; %All the files were ignored, low data
        end

    if fiton && ~isempty(Paramsout); paramsout=struct2cell(Paramsout); else paramsout=[]; end %must convert to cell and back again during export
    end %for
end %varyfit takes parameters and plots graphs and returns fitparameters
