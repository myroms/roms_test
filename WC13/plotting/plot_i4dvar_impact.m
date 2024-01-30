%
% PLOT_I4DVAR_IMPACT:  Plots observation impact for I4D-Var
%

% git $Id$
%===========================================================================%
%  Copyright (c) 2002-2024 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.md                                                    %
%===========================================================================%

clear                                  % clear workspace
close all                              % close all figures

PRINT=0;                               % switch to save figure as PNG

% Set input NetCDF files.

Inp0 ='../I4DVAR/wc13_fwd_000.nc';     % prior circulation file
Inp1 ='../I4DVAR/wc13_fwd_001.nc';     % posterior circulation file
Inpa ='../I4DVAR_impact/wc13_ads.nc';  % adjoint forcing file (dI/dx)
Obs  ='../Data/wc13_obs.nc';           % observation file
Mod  ='../I4DVAR_impact/wc13_mod.nc';  % I4D-Var impact file.
NLmod='../I4DVAR/wc13_mod.nc';         % I4D-Var file

% Read in impact variables.

varr=nc_read(Inpa,'v');                % transport weights
vb  =nc_read(Inp0,'v');                % prior velocity
va  =nc_read(Inp1,'v');                % posterior velocity

% Compute transports (Sv).

transb=nansum(nansum(nansum(nansum(varr.*vb,1),2),3),4);  % prior
transa=nansum(nansum(nansum(nansum(varr.*va,1),2),3),4);  % posterior

dtrans=transa-transb;                  % actual transport increment

% Read observations variables.

obs  =nc_read(Obs,'obs_value');            % observation values
type =nc_read(Obs,'obs_type');             % state variable flag
label=nc_read(Obs,'obs_provenance');       % observation origin

% Read observation impacts.

sen  =nc_read(Mod,'ObsImpact_total');      % total
icsen=nc_read(Mod,'ObsImpact_IC');         % initial conditions
fcsen=nc_read(Mod,'ObsImpact_FC');         % surface forcing
bcsen=nc_read(Mod,'ObsImpact_BC');         % open boundary conditions

% Read observation scale (bounded observations, scale=1).

scale=nc_read(Mod,'obs_scale');

% Read NL model values in observation space.

NLM=nc_read(NLmod,'NLmodel_initial');

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

% Compute total impacts.

totimp=sum(sen  .*innov,1);
icimp =sum(icsen.*innov,1);
fcimp =sum(fcsen.*innov,1);
bcimp =sum(bcsen.*innov,1);

timp1=sum(sen(ind1).*innov(ind1),1);
timp2=sum(sen(ind2).*innov(ind2),1);
timp3=sum(sen(ind3).*innov(ind3),1);
timp4=sum(sen(ind4).*innov(ind4),1);
timp5=sum(sen(ind5).*innov(ind5),1);
timp6=sum(sen(ind6).*innov(ind6),1);
timp7=sum(sen(ind7).*innov(ind7),1);

% Check.

timp=timp1+timp2+timp3+timp4+timp5+timp6+timp7;

% Plot observation impacts.

figure;

fonts=10;

subplot(3,1,1);
dn=[length(obs) length(ind1) length(ind2) length(ind3) length(ind4) ...
                length(ind5) length(ind6) length(ind7)];
bar(dn);
MyLabel={'Nobs','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('N_{obs}');
title('I4D-Var Observation Impact');

subplot(3,1,2);
d1=[dtrans totimp icimp fcimp bcimp];
bar(d1);
colormap([1 0 0]);
MyLabel={'NL dI','TL dI','IC','FC','BC'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('\Delta I')

subplot(3,1,3);
d2=[totimp timp1 timp2 timp3 timp4 timp5 timp6 timp7];
bar(d2);
colormap([1 0 0]);
MyLabel={'TL dI','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('\Delta I');

if (PRINT),
  print -dpng -r300 plot_i4dvar_impact.png
end,
