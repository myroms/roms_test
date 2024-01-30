%
% PLOT_PRIOR_POSTERIOR_ERRORS:  Plot the difference between the prior and
%                               posterior error variances deviations
%

% git $Id$
%===========================================================================%
%  Copyright (c) 2002-2024 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.md                                                    %
%===========================================================================%

clear                                  % clear workspace
close all                              % close all figures

PRINT=0;                               % switch to save figures as PNG
SHADING_INTERP=1;                      % switch for shading interp (1) or
                                       %            shading flat (0)

% Set input NetCDF files.

 Inpb='../Data/wc13_std_i.nc';         % prior standard deviations

%Inpa='../RBL4DVAR/wc13_err.nc';           % RBL4D-Var posterior error variance
 Inpa='../R4DVAR/wc13_err.nc';         % R4D-Var posterior error variance

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

Nrec=length(nc_read(Inpa,'ocean_time'));
N   =length(nc_read(Inpa,'s_rho'));

klev=N;                   % processing surface level

% Read in the prior error standard deviations.

Rec=1;
FillValue=NaN;

zetab=nc_read(Inpb,'zeta',Rec,FillValue);
ub   =nc_read(Inpb,'u'   ,Rec,FillValue);
vb   =nc_read(Inpb,'v'   ,Rec,FillValue);
tempb=nc_read(Inpb,'temp',Rec,FillValue);
saltb=nc_read(Inpb,'salt',Rec,FillValue);

% Convert prior error standard deviations to variances.

zetab=zetab.*zetab;
ub=ub.*ub;
vb=vb.*vb;
tempb=tempb.*tempb;
saltb=saltb.*saltb;

% Read in the expected posterior error variances.

Rec=1;

zetaa=nc_read(Inpa,'zeta',Rec,FillValue);
ua   =nc_read(Inpa,'u'   ,Rec,FillValue);
va   =nc_read(Inpa,'v'   ,Rec,FillValue);
tempa=nc_read(Inpa,'temp',Rec,FillValue);
salta=nc_read(Inpa,'salt',Rec,FillValue);

diffz=zetaa-zetab;
diffu=ua-ub;
diffv=va-vb;
difft=tempa-tempb;
diffs=salta-saltb;

% Plot the difference between the prior and posterior error
% variances for state variables. If 3D field, plot selected
% level (klev).

figure

subplot(3,2,1);
pcolor(rlon,rlat,diffz);
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title('\zeta increment');

subplot(3,2,2);
pcolor(ulon,ulat,squeeze(diffu(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title('u increment');

subplot(3,2,3);
pcolor(vlon,vlat,squeeze(diffv(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title('v increment');

subplot(3,2,4);
pcolor(rlon,rlat,squeeze(difft(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title('T increment')

subplot(3,2,5);
pcolor(rlon,rlat,squeeze(diffs(:,:,klev)));
if (SHADING_INTERP), shading interp; else shading flat; end
colorbar; hold on;
plot(coast.lon,coast.lat,'k');
title('S increment');

if (PRINT),
  print -dpng -r300 plot_prior_posterior_errors.png
end,
