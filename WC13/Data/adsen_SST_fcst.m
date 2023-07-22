%
%  This script sets-up the adjoint sensitivity forcing files 'wc13_oifA.nc'
%  and 'wc13_oifA.nc' in observation space for the mean-squared SST using
%  observations to verify the forecasts.
%
%  The observed SST is used as a surrogate for the truth.

%  git $Id$
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                                                 %
%=========================================================================%

clear all

% Forecast averaging interval (records).

dstart=13018;
dend=13019;

% Lat-lon range.

flats=34.5;
flate=40.5;
flon=-125.5;

% Define the forecast mod and obs files.

InpA='../RBL4DVAR_forecast_impact/FCSTA/wc13_mod.nc';
InpB='../RBL4DVAR_forecast_impact/FCSTB/wc13_mod.nc';
InpO='forecast_obs.nc';

% Define the central CA target region for the SST forecast error metric.

Gname='wc13_grd.nc';

lonr =nc_read(Gname,'lon_rho');
latr =nc_read(Gname,'lat_rho');
maskr=nc_read(Gname,'mask_rho');

% Identify the target area: central CA coast.

maskC=zeros(size(maskr));
maskC(latr>=flats&latr<=flate&lonr>=flon)=1;
maskC=maskr.*maskC;
[xC,yC,indC]=find(maskC==1);

% Read forecast obs data.

obs_time=nc_read(InpO,'obs_time');
obs_prov=nc_read(InpO,'obs_provenance');
obs_Xgrid=nc_read(InpO,'obs_Xgrid');
obs_Ygrid=nc_read(InpO,'obs_Ygrid');
obs_value=nc_read(InpO,'obs_value');

% Find SST obs during the selected forecast day in the target area.

clear ind
ind=find(obs_prov==2 &                                                  ...
         obs_time>=dstart & obs_time<=dend &                            ...
         obs_Xgrid>=min(xC) & obs_Xgrid<=max(xC) &                      ...
         obs_Ygrid>=min(yC) & obs_Ygrid<=max(yC));    % SST

% Read the forecast values at the obs points.

fA=nc_read(InpA,'NLmodel_value');
fB=nc_read(InpB,'NLmodel_value');

tfA=fA-obs_value;
tfB=fB-obs_value;

dfA=zeros(size(tfA));
dfB=zeros(size(tfB));

dfA(ind)=tfA(ind);
dfB(ind)=tfB(ind);

% Compute dJA and dJB.

dJA=nansum(dfA.*dfA)./size(ind,1);
dJB=nansum(dfB.*dfB)./size(ind,1);

% Multiply by the weights.

dfA(ind)=tfA(ind)./size(ind,1);
dfB(ind)=tfB(ind)./size(ind,1);

%--------------------------------------------------------------------------
% Create adjoint sensitivy NetCDF file.
%--------------------------------------------------------------------------

disp(' ');

OutA = 'wc13_oifA.nc';
OutB = 'wc13_oifB.nc';

disp(['Creating and processing: ', OutA]);
unix(['cp ',InpO, blanks(1), OutA]);
s=nc_write(OutA,'obs_value',dfA);


disp(['Creating and processing: ', OutB]);
unix(['cp ',InpO, blanks(1), OutB]);
s=nc_write(OutB,'obs_value',dfB);
