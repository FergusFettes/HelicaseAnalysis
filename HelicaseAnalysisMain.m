function HelicaseAnalysisMain
clc;clear;close all;
global g; global d; global e; global t; global analysis;

%% Variables and initial values %%
% Positions for the popup windows
% small screen settings
 g.defPos=[850          309         721         588];
 g.defPosGUI=[450         450         350         500];
 g.defPosPAR=[514         691         336         206];
 g.dataHarvestPosition=[450         150         850         900];
g.ttrcPos = g.defPos+[0 -220 100 360];
 
%big screen settings
% g.defPos=[2350          309         721         588];
% g.defPosGUI=[1950         450         350         500];
% g.defPosPAR=[2014         691         336         206];
% g.dataHarvestPosition=[2150         150         850         900];
% g.ttrcPos = g.defPos+[0 -220 100 360];

% variables for minimized/maximized height
g.pheightmin = 20; %titlewidth
g.pheightmax = 235; %can be -1

% Standard goodnesses for fits & clean. If you change these you should change the
%'Value' of the popup boxes accordingly.
g.GoodParams.fcal=0.8;g.GoodParams.fext=0.8;g.GoodParams.clean=0.6;

%standard height value for trace cleaning
g.cleanhi=6;

% Preassigning zoomdata
g.zoomdat.xmin=[]; g.slideval=100; g.riseval=0.1;

% Fit equations & bounds & datatypes (datatype numbers found in getcolfromcycle)
g.FitTypes.Cali1.equation= @(a,b,c,x) exp(a.*x.^2 + b.*x + c);
g.FitTypes.Cali1.bounds={   {'-10' '-10' '0'}, ...                           lower bounds 
                            {'0' '-log(mean(xData))' 'log(max(yData))'}, ... start point 
                            {'0' '0' '5'} };
g.FitTypes.Cali1.data=[8, 2, 3];
g.FitTypes.Worm.equation=  @(a,b,x) ((1.38e-23.*298)./(b.*1e-9)).* ... k_B T over persistance length (p in nanometers) a=L b=p
                                ((4.*(1-(x./a)).^2).^(-1) - 4.^(-1) + ... first two bracketed compontents
                                  (x./a) - 0.5164228.*(x./a).^2 - 2.737418.*(x./a).^3 + 16.07497.*(x./a).^4 - 38.87607.*(x./a).^5 + 39.49944.*(x./a).^6 - 14.17718.*(x./a).^7) ... sum with coefficients
                                    .*1e12; %$$$
g.FitTypes.Worm.bounds={    {'max(xData)' '0' '[]'}, ...      lower bounds (must be three-component arrays) !!!ALL THIS EVAL STUFF CAN BE SORTED WITH OBJECT ORIENTED PROGRAMMING
                            {'1.1*max(xData)' '50' '[]'}, ... start point 
                            {'10' '100' '[]'} };            % upper bounds
g.FitTypes.Worm.data=[1, 2, 3];
                
% Standard equations (for quickbuttons)
g.FitSettings.clean= g.FitTypes.Worm;
g.FitSettings.fcal=  g.FitTypes.Cali1; 
g.FitSettings.fext=  g.FitTypes.Worm;
    
%initializing these fellows, not really sure why !!!
g.figsMSG.fcalexports='string';g.figsMSG.fextexports='string';

d.collect_data.force=[];d.collect_data.height_bp=[];d.collect_data.velocity_bp=[];
d.collect_data.rate=[];d.collect_data.height=[];d.collect_data.time=[];d.collect_data.velocity=[];

%initialize event structure and temp holder
e=[]; t=[]; analysis=struct(); analysis.LittleUpdate = 0;

%% Initialize %%
HelicaseAnalysisGUI;
checkDir;

end