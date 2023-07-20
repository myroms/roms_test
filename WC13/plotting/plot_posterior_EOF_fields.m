%
% PLOT_POSTERIOR_EOF_FIELDS:  Plot an EOF of the analysis error covariance
%                             matrix
%

% svn $Id: plot_posterior_EOF_fields.m 1154 2023-02-17 20:52:30Z arango $
%===========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                                                   %
%===========================================================================%

clear                                  % clear workspace
close all                              % close all figures

nEOF=1;                                % selected EOF number
frc_adjust=1;                          % surface forcing record to plot

PRINT=0;                               % switch to save figures as PNG
SHADING_INTERP=1;                      % switch for shading interp (1) or
                                       %            shading flat (0)

% Set input NetCDF files.

%Inp='../RBL4DVAR/wc13_hss.nc';            % RBL4D-Var EOF, stored in Hessian file
 Inp='../R4DVAR/wc13_hss.nc';          % R4D-Var EOF, stored in Hessian file

Grd='../Data/wc13_grd.nc';             % grid

% Load coastline coordinates.

coast=load('../Data/wc13_cst.mat','-mat');   % coastlines structure

% Read grid coordinates.

rlon=nc_read(Grd,'lon_rho');
rlat=nc_read(Grd,'lat_rho');

ulon=nc_read(Grd,'lon_u');
ulat=nc_read(Grd,'lat_u');

vlon=nc_read(Grd,'lon_v');
vlat=nc_read(Grd,'lat_v');

% Determine number of records (EOFs) and number of vertical levels in
% input NetCDF history files.

Nrec=length(nc_read(Inp,'ocean_time'));
N   =length(nc_read(Inp,'s_rho'));

klev=N;                   % processing surface level

% Read in selected EOF of analysis error covariance (nEOF) and
% replace land/sea mask values with NaNs.

FillValue=NaN;

zeta  =nc_read(Inp,'zeta'  ,nEOF,FillValue);   % free-surface
u     =nc_read(Inp,'u'     ,nEOF,FillValue);   % 3D u-momentum
v     =nc_read(Inp,'v'     ,nEOF,FillValue);   % 3D v-momentum
temp  =nc_read(Inp,'temp'  ,nEOF,FillValue);   % potential temperature
salt  =nc_read(Inp,'salt'  ,nEOF,FillValue);   % salinity
sustr =nc_read(Inp,'sustr' ,nEOF,FillValue);   % surface u-stress
svstr =nc_read(Inp,'svstr' ,nEOF,FillValue);   % surface v-stress
shflux=nc_read(Inp,'shflux',nEOF,FillValue);   % surface net heat flux

% Plot selected EOF of analysis error covariance for state variables.
% If 3D field, plot selected level (klev).

figure

subplot(3,2,1);
pcolor(rlon,rlat,zeta);
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['\zeta, EOF ',num2str(nEOF,1)]);

subplot(3,2,2)
pcolor(ulon,ulat,squeeze(u(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['u, EOF ',num2str(nEOF,1)]);

subplot(3,2,3);
pcolor(vlon,vlat,squeeze(v(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['v, EOF ',num2str(nEOF,1)]);

subplot(3,2,4);
pcolor(rlon,rlat,squeeze(temp(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['T, EOF ',num2str(nEOF,1)]);

subplot(3,2,5);
pcolor(rlon,rlat,squeeze(salt(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['S, EOF ',num2str(nEOF,1)]);

if (PRINT),
  print -dpng -r300 plot_posterior_EOF_fields_page1.png
end,

% Plot selected EOF of analysis error covariance for surface
% forcing variables.

figure

subplot(3,2,1);
pcolor(ulon,ulat,squeeze(sustr(:,:,frc_adjust)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['\tau_x, EOF ',num2str(nEOF,1)]);

subplot(3,2,2);
pcolor(vlon,vlat,squeeze(svstr(:,:,frc_adjust)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['\tau_y, EOF ',num2str(nEOF,1)]);

subplot(3,2,3);
pcolor(rlon,rlat,squeeze(shflux(:,:,frc_adjust)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title(['Q, EOF ',num2str(nEOF,1)]);

if (PRINT),
  print -dpng -r300 plot_posterior_EOF_fields_page2.png
end,
