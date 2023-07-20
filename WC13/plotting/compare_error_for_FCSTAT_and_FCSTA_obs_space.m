%
%  This script sets-up the adjoint sensitivity forcing in observation
%  space for the mean-squared SST using observations to verify the forecasts.
%  The observed SST is used as a surrogate for the truth.

clear all

% Forecast averaging interval (records).

dstart=13018;
dend=13019;

% Lat-lon range.

flats=34.5;
flate=40.5;
flon=-125.5;

% Define the forecast mod and obs files.

InpAT='../RBL4DVAR_forecast_impact/FCSTAT/wc13_mod.nc';
InpA ='../RBL4DVAR_forecast_impact/FCSTA/wc13_mod.nc';
InpB ='../RBL4DVAR_forecast_impact/FCSTB/wc13_mod.nc';
InpO ='../Data/forecast_obs.nc';

% Define the central CA target region for the SST forecast error metric.

Gname='../Data/wc13_grd.nc';

lonr=ncread(Gname,'lon_rho');
latr=ncread(Gname,'lat_rho');
maskr=ncread(Gname,'mask_rho');

% Identify the target area: central CA coast.

maskC=zeros(size(maskr));
maskC(latr>=flats&latr<=flate&lonr>=flon)=1;
maskC=maskr.*maskC;
[xC,yC,indC]=find(maskC==1);

% Read forecast obs data.

obs_time=ncread(InpO,'obs_time');
obs_prov=ncread(InpO,'obs_provenance');
obs_Xgrid=ncread(InpO,'obs_Xgrid');
obs_Ygrid=ncread(InpO,'obs_Ygrid');
obs_value=ncread(InpO,'obs_value');

% Find SST obs during the selected forecast day in the target area.

clear ind
ind=find(obs_prov==2 &                                                  ...
         obs_time>=dstart & obs_time<=dend &                            ...
         obs_Xgrid>=min(xC) & obs_Xgrid<=max(xC) &                      ...
         obs_Ygrid>=min(yC) & obs_Ygrid<=max(yC)); % SST

% Read the forecast values at the obs points.

fAT=ncread(InpAT,'NLmodel_value');
fA =ncread(InpA, 'NLmodel_value');
fB =ncread(InpB, 'NLmodel_value');

tfAT=fAT-obs_value;
tfA =fA -obs_value;
tfB =fB -obs_value;

dfAT=zeros(size(tfAT));
dfA =zeros(size(tfA));
dfB =zeros(size(tfB));

dfAT(ind)=tfAT(ind);
dfA(ind) =tfA(ind);
dfB(ind) =tfB(ind);

% Compute dJA and dJB.

dJAT=nansum(dfAT.*dfAT)./size(ind,1);
dJA =nansum(dfA.*dfA)./size(ind,1);
dJB =nansum(dfB.*dfB)./size(ind,1);

% Compute the error differences

deAT=dJAT-dJB
deA =dJA-dJB

