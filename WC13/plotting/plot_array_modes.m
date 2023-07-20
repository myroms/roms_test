%
% PLOT_ARRAY_MODES:  Plot chosen stabilized representer matrix array modes
%

% svn $Id: plot_array_modes.m 1154 2023-02-17 20:52:30Z arango $
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                                                 %
%=========================================================================%

clear                                  % clear workspace

PRINT=0;                               % switch to save figures as PNG
SHADING_INTERP=1;                      % switch for shading interp (1) or
                                       %            shading flat (0)

% Set input NetCDF files.

Inp='../ARRAY_MODES/EX7/wc13_tlm_003.nc';  % Array modes file (saved in TLM)

Grd='../Data/wc13_grd.nc';

% Load coastline coordinates.

coast=load('../Data/wc13_cst.mat','-mat');   % coastlines structure

% Read grid coordinates.

rlon=nc_read(Grd,'lon_rho');
rlat=nc_read(Grd,'lat_rho');

ulon=nc_read(Grd,'lon_u');
ulat=nc_read(Grd,'lat_u');

vlon=nc_read(Grd,'lon_v');
vlat=nc_read(Grd,'lat_v');

% Determine number of records and number of vertical levels in
% input NetCDF history file.

Nrec=length(nc_read(Inp,'ocean_time'));
N   =length(nc_read(Inp,'s_rho'));

klev=N;                   % process surface level

% Plot selected array mode for each state variable. If 3D field,
% plot selected level (klev).

FillValue=NaN;

figure

for rec=1:Nrec
  f=nc_read(Inp,'zeta',rec,FillValue);
  subplot(3,2,rec);
  pcolor(rlon,rlat,f);
  if (SHADING_INTERP), shading interp; else shading flat; end
  colorbar; hold on;
  plot(coast.lon,coast.lat,'k');
  title(['\zeta time=',num2str(rec-1,1),' days']);
end,

if (PRINT)
  print -dpng -r300 plot_array_modes_zeta.png
end

figure

for rec=1:Nrec
  f=nc_read(Inp,'u',rec,FillValue);
  subplot(3,2,rec);
  pcolor(ulon,ulat,squeeze(f(:,:,klev)));
  if (SHADING_INTERP), shading interp; else shading flat; end
  colorbar; hold on;
  plot(coast.lon,coast.lat,'k');
  title(['u time=',num2str(rec-1,1),' days']);
end,

if (PRINT)
  print -dpng -r300 plot_array_modes_u.png
end

figure

for rec=1:Nrec
  f=nc_read(Inp,'v',rec,FillValue);
  subplot(3,2,rec);
  pcolor(vlon,vlat,squeeze(f(:,:,klev)));
  if (SHADING_INTERP), shading interp; else shading flat; end
  colorbar; hold on;
  plot(coast.lon,coast.lat,'k');
  title(['v time=',num2str(rec-1,1),' days']);
end

if (PRINT)
  print -dpng -r300 plot_array_modes_v.png
end

figure

for rec=1:Nrec
  f=nc_read(Inp,'temp',rec,FillValue);
  subplot(3,2,rec);
  pcolor(rlon,rlat,squeeze(f(:,:,klev)));
  if (SHADING_INTERP), shading interp; else shading flat; end
  colorbar; hold on;
  plot(coast.lon,coast.lat,'k');
  title(['T time=',num2str(rec-1,1),' days']);
end

if (PRINT)
  print -dpng -r300 plot_array_modes_temp.png
end

figure

for rec=1:Nrec
  f=nc_read(Inp,'salt',rec,FillValue);
  subplot(3,2,rec);
  pcolor(rlon,rlat,squeeze(f(:,:,klev)));
  if (SHADING_INTERP), shading interp; else shading flat; end
  colorbar; hold on;
  plot(coast.lon,coast.lat,'k');
  title(['S time=',num2str(rec-1,1),' days']);
end

if (PRINT),
  print -dpng -r300 plot_array_modes_salt.png
end
