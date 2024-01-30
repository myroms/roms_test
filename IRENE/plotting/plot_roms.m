function plot_roms (varargin)

%
% PLOT_ROMS:  Plots coupling fields from ROMS quick-save NetCDF file.
%
% plot_roms(rec, Dir, wrtPNG)
%
% On Input:
%
%    rec       Time record to plot (integer, OPTIONAL)
%                default: 1
%
%    Dir       Run sub-directory (string, OPTIONAL)
%                default: '' or [] for current directory
%
%    wrtPNG    Flag to save figure(s) as a PNG file (logical, OPTIONAL)  
%
  
% git $Id$
  %=========================================================================%
%  Copyright (c) 2002-2024 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                            Hernan G. Arango      %
%=========================================================================%

switch numel(varargin)
  case 0
    rec  = 1;
    Dir  = '.';
    wrtPNG = flase;
  case 1
    rec  = varargin{1};
    Dir  = '.';
    wrtPNG = false;
  case 2
    rec = varargin{1};
    if (isempty(varargin{2}))
      Dir = '.';
    else
      Dir = varargin{2};
    end
    wrtPNG = false;
  case 3
    rec  = varargin{1};
    if (isempty(varargin{2}))
      Dir = '.';
    else
      Dir = varargin{2};
    end
    wrtPNG = varargin{3};
end

% Plots the surface fluxes from ROMS.

Gname = '../Data/ROMS/irene_roms_grid.nc';
Rname = strcat(Dir,'/irene_qck.nc');

G = get_roms_grid(Gname, Rname);
S = grid_perimeter(G);

XboxR = S.grid.perimeter.X_psi;
YboxR = S.grid.perimeter.Y_psi;

Att   = nc_getatt(Rname, 'units', 'ocean_time');
ind   = strfind(lower(Att), 'since');
Adate = Att(ind+6:end);
epoch = datenum(Adate)*86400;

time  = nc_read(Rname,'ocean_time');
Tstring = datestr((epoch+time)./86400);

% Read in fluxes.

EminusP  = nc_read(Rname, 'EminusP',  rec, NaN);
Pair     = nc_read(Rname, 'Pair',     rec, NaN);
latent   = nc_read(Rname, 'latent',   rec, NaN);
lwrad    = nc_read(Rname, 'lwrad',    rec, NaN);
sensible = nc_read(Rname, 'sensible', rec, NaN);
shflux   = nc_read(Rname, 'shflux',   rec, NaN);
ssflux   = nc_read(Rname, 'ssflux',   rec, NaN);
sst      = nc_read(Rname, 'temp_sur', rec, NaN);
sss      = nc_read(Rname, 'salt_sur', rec, NaN);
sustr    = nc_read(Rname, 'sustr',    rec, NaN);
svstr    = nc_read(Rname, 'svstr',    rec, NaN);
swrad    = nc_read(Rname, 'swrad',    rec, NaN);

EminusP = EminusP .* 86400;      % m/day
ssflux  = ssflux  .* 86400;      % m/day

% Compute stress vectors at RHO-points.

iv = 3;                           % vector I-sampling
jv = 3;                           % vector J-sampling
vcolor = 'k';                     % vector overlay color
vscale = 2;                       % vector scale  

density = 1.5;                    % streamlines density
dx = 0.1;                         % streamlines monotonic longitude spacing
dy = 0.1;                         % streamlines monotonic latitude  spacing
scolor = 'r';                     % streamlines color

[L,M]=size(G.lon_rho);
Lm=L-1;     Mm=M-1;
Lm2=Lm-1;   Mm2=M-2;

alpha=G.angle(2:Lm,2:Mm);
mask = G.mask_rho(2:Lm,2:Mm);
Xr = G.lon_rho(2:Lm,2:Mm);
Yr = G.lat_rho(2:Lm,2:Mm);

Ur = 0.5.*(sustr(1:Lm2,2:Mm )+sustr(2:Lm,2:Mm));
Vr = 0.5.*(svstr(2:Lm ,1:Mm2)+svstr(2:Lm,2:Mm));
[Ur,Vr] = rotate_vec(Ur, Vr, alpha, 1);

[Xs,Ys,Us,Vs] = vector4stream(sustr, svstr, G, dx, dy);

% Plot fluxes

LONmin=-80.6;  LONmax=-59.5;
LATmin= 31.9;  LATmax= 47.0;

Land = [0.6 0.65 0.6];           % gray-green
Lake = Land;

NC = 20;                         % number of contours

m_proj('mercator','longitudes',[LONmin,LONmax],                         ...
                  'latitudes',[LATmin,LATmax]);

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, sst);
shading interp; colorbar; caxis([0 35]);
cmocean('inferno',256);
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Temperature (Celsius)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(sst(:))),                                ...
         '  Max = ', num2str(max(sst(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_sst_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, sss);
shading interp; colorbar;  caxis([20 37]);
cmocean('delta',256);
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Salinity');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(sss(:))),                                ...
         '  Max = ', num2str(max(sss(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_sss_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_contourf(G.lon_rho, G.lat_rho, Pair, NC);
shading interp; colorbar; caxis([960 1020]);
cmocean('haline',256);
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Air Pressure (mb)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(Pair(:))),                               ...
         '  Max = ', num2str(max(Pair(:)))]},                           ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_pair_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, swrad);
shading interp; colorbar; caxis([0 800]);
colormap(cmap('R2'));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Net Shortwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(swrad(:))),                              ...
         '  Max = ', num2str(max(swrad(:)))]},                          ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_swrad_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, lwrad);
shading interp; colorbar; caxis([-150 150]);
colormap(flipud(redblue(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Net Longwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(lwrad(:))),                              ...
         '  Max = ', num2str(max(lwrad(:)))]},                          ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_lwrad_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, latent);
shading interp; colorbar; caxis([-650 650]);
colormap(flipud(redblue(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Latent Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(latent(:))),                             ...
         '  Max = ', num2str(max(latent(:)))]},                         ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_lhf_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
%m_contourf(G.lon_rho, G.lat_rho, sensible, 15);
m_pcolor(G.lon_rho, G.lat_rho, sensible);
shading interp; colorbar; caxis([-300 300]);
colormap(flipud(redblue(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Sensible Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(sensible(:))),                           ...
         '  Max = ', num2str(max(sensible(:)))]},                       ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_shf_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, shflux);
shading interp; colorbar; caxis([-800 800]);
colormap(flipud(redblue(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Net Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(shflux(:))),                             ...
         '  Max = ', num2str(max(shflux(:)))]},                         ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_shflux_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, ssflux);
shading interp; colorbar; caxis([-100 100]);
cmocean('delta',256);
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Kinematic Net Salt Flux, (E-P)*SSS, m/day');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(ssflux(:))),                             ...
         '  Max = ', num2str(max(ssflux(:)))]},                         ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_ssflux_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(G.lon_rho, G.lat_rho, EminusP);
shading interp; colorbar; caxis([-2 2]);
cmocean('delta',256);
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Evaporation minus Precipitation (m/day)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(EminusP(:))),                            ...
         '  Max = ', num2str(max(EminusP(:)))]},                        ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_EminusP_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = sqrt(Us .* Us + Vs .* Vs);
m_pcolor(Xs, Ys, f);
h = m_streamline(Xs, Ys, Us, Vs, density);
set(h,'color',scolor);
shading interp; colorbar; caxis([0.0 3.0]);
colormap(flipud(viridis(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Wind Stress Streamlines (N/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_wstress_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = sqrt(Ur .* Ur + Vr .* Vr);
m_pcolor(Xr, Yr, f);
m_quiver(Xr(1:iv:end,1:jv:end), Yr(1:iv:end,1:jv:end),                  ...
         Ur(1:iv:end,1:jv:end), Vr(1:iv:end,1:jv:end),                  ...
         vscale, 'color', vcolor);
shading interp; colorbar; caxis([0.0 3.0]);
colormap(flipud(viridis(256)));
m_gshhs_i('patch', Land, 'edgecolor', Lake);
m_plot(XboxR,YboxR,'linewidth',2,'color','k');
title('ROMS: Surface Wind Stress Vectors (N/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG) 
  png_file=strcat('roms_irene_wstrvec_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 1882x1700+218+50',       ...
        ' +repage ', png_file, blanks(1), png_file]);
end

return
