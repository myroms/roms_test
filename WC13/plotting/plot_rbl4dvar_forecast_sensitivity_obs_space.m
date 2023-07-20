%
% PLOT_RBL4DVAR_FCST_SENSITIVITY_OBS_SPACE:  Plots forecast observation
%                                            sensitivity
%

% svn $Id: plot_rbl4dvar_forecast_sensitivity_obs_space.m 1154 2023-02-17 20:52:30Z arango $
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                                                 %
%=========================================================================%

clear                                  % clear workspace

PRINT=true;                            % switch to save figure as PNG

% Set input NetCDF files.
%
%   InpA:    Forecast from analysis
%   InpB:    Forecast from background
%   InpO:    Observation file

InpA='../RBL4DVAR_forecast_sensitivity/FCSTA/wc13_mod.nc';
InpB='../RBL4DVAR_forecast_sensitivity/FCSTB/wc13_mod.nc';
InpO='../Data/forecast_obs.nc';

% Set adjoint forcing arrays in obs space

InpoiA='../RBL4DVAR_forecast_sensitivity/Case2/wc13_oifa.nc';
InpoiB='../RBL4DVAR_forecast_sensitivity/Case2/wc13_oifb.nc';

Obs  ='../Data/wc13_obs.nc';                                  % observation file
Mod  ='../RBL4DVAR_forecast_sensitivity/Case2/wc13_mod.nc';   % RBL4D-Var sensitivity file.
NLmod='../RBL4DVAR/EX3_RPCG/wc13_mod.nc';                     % RBL4D-Var file

% Read the forecast values at the obs points.

fA=ncread(InpA,'NLmodel_value');
fB=ncread(InpB,'NLmodel_value');
fO=ncread(InpO,'obs_value');

% Read in the forcing functions.

oA=ncread(InpoiA,'obs_value');
oB=ncread(InpoiB,'obs_value');

% Compute actual change in MSE SST error.

de=nansum(oA.*(fA-fO))-nansum(oB.*(fB-fO));

% Now compute the sensitivities
% Read observations variables.

obs  =ncread(Obs,'obs_value');            % observation values
type =ncread(Obs,'obs_type');             % state variable flag
label=ncread(Obs,'obs_provenance');       % observation origin

% Read observation sensitivities.

sen  =ncread(Mod,'ObsSens_total');        % total

% Read observation scale (bounded observations, scale=1).

scale=ncread(NLmod,'obs_scale');

% Read NL model values in observation space.

NLM=ncread(NLmod,'NLmodel_initial');

% Compute the innovation vector.

innov=(obs-NLM).*scale;

% Sort by observation platform using label.

ind1=find(label==1);      % SSH
ind2=find(label==2);      % SST
ind3=find(label==3);      % T XBT
ind4=find(label==4);      % T CTD
ind5=find(label==5);      % S CTD
ind6=find(label==6);      % T Argo
ind7=find(label==7);      % S Argo

% Compute total sensitivitys.

totimp=sum(sen  .*innov,1);

timp1=sum(sen(ind1).*innov(ind1),1);
timp2=sum(sen(ind2).*innov(ind2),1);
timp3=sum(sen(ind3).*innov(ind3),1);
timp4=sum(sen(ind4).*innov(ind4),1);
timp5=sum(sen(ind5).*innov(ind5),1);
timp6=sum(sen(ind6).*innov(ind6),1);
timp7=sum(sen(ind7).*innov(ind7),1);

% Check.

timp=timp1+timp2+timp3+timp4+timp5+timp6+timp7;

% Plot observation sensitivitys.

figure;

fonts=10;

subplot(3,1,1);
dn=[length(obs) length(ind1) length(ind2) length(ind3) length(ind4) ...
                length(ind5) length(ind6) length(ind7)];
b1=bar(dn,'r');
Y=b1.YData;
text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center');
grid on;
MyLabel={'Nobs','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('N_{obs}');
title('RBL4D-Var Observation Sensitivity');

subplot(3,1,2);
d2=[de totimp timp1 timp2 timp3 timp4 timp5 timp6 timp7];
b2=bar(d2,'m');
grid on;
MyLabel={'NL de','TL de','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('\Delta e');

if (PRINT)
  png_file='plot_rbl4dvar_forecast_sensitivity_obs_sensitivity.png';
  print(png_file, '-dpng', '-r300');
  if (exist('/opt/local/bin/convert','file'))
    unix(['/opt/local/bin/convert -verbose -crop 2100x1132+100+45',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end 
end
