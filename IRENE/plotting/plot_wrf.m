function plot_wrf (varargin)

%
% PLOT_WRF:  Plots coupling fields from WRF history NetCDF file.
%
% plot_WRF(rec, Dir, wrtPNG)
%
% On Input:
%
%    rec       Time record to plot (integer, OPTIONAL)
%                default: 1
%
%    Dir       Run sub-directory (string, OPTIONAL)
%                default: '' or [] for current directory
%
%    wrtPNG    Flag to save figures as a PNG file (logical, OPTIONAL)
%

% git $Id$
  %=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
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

% Plots the surface fluxes from WRF.

Hname='irene_wrf_his_d01_2011-08-27_06_00_00.nc';
Wname=strcat(Dir,'/',Hname);

epoch=datenum(2011,08,27,6,0,0);               % start time

time=nc_read(Wname,'XTIME');                   % hours since start time
lon=nc_read(Wname,'XLONG',1);
lat=nc_read(Wname,'XLAT',1);

Tstring=datestr(epoch+time./(60*24));

Imin=1;
Jmin=1;
[Imax,Jmax]=size(lon);

XboxW=[squeeze(lon(Imin:Imax,Jmin));                                    ...
       squeeze(lon(Imax,Jmin+1:Jmax))';                                 ...
       squeeze(flipud(lon(Imin:Imax-1,Jmax)));                          ...
       squeeze(fliplr(lon(Imin,Jmin:Jmax-1)))'];

YboxW=[squeeze(lat(Imin:Imax,Jmin));                                    ...
       squeeze(lat(Imax,Jmin+1:Jmax))';                                 ...
       squeeze(flipud(lat(Imin:Imax-1,Jmax)));                          ...
       squeeze(fliplr(lat(Imin,Jmin:Jmax-1)))'];

% Read in fluxes.

sst = nc_read(Wname, 'SST', rec);         % surface temperature (K)

alb = nc_read(Wname, 'ALBEDO', rec);      % Albedo (unitless, 0-1)
emi = nc_read(Wname, 'EMISS',  rec);      % emissivity

gsw = nc_read(Wname, 'GSW',    rec);      % net shortwave flux
sw  = nc_read(Wname, 'SWDOWN', rec);      % downward shortwave flux
swd = nc_read(Wname, 'SWDNB',  rec);      % downwelling shortwave flux
swu = nc_read(Wname, 'SWUPB',  rec);      % upwelling shortwave flux
glw = nc_read(Wname, 'GLW',    rec);      % downward longwave flux
lwu = nc_read(Wname, 'LWUPB',  rec);      % upwelling longwave flux
lwd = nc_read(Wname, 'LWDNB',  rec);      % downwelling longwave flux
hfx = nc_read(Wname, 'HFX',    rec);      % sensible heat flux
lhf = nc_read(Wname, 'LH',     rec);      % latent heat flux

swnet1 = swd - swu;                       % downwelling minus upwelling
swnet2 = (1.0 - alb) .* sw;               % compute net shortwave flux


ir = 5.67051E-8 .* emi .* sst.^4;         % outgoing IR correction flux

z1 = 3.0;
f1 = 1.0-0.27*exp(-2.80*z1)-0.45*exp(-0.07*z1);  % cool skin correction

heat = (swd-swu) + (glw - lwu) - hfx - lhf;      % net heat flux

% Plot fluxes

LONmin=-82.7;  LONmax=-57.5;
LATmin= 31.5;  LATmax= 47.0;

m_proj('mercator','longitudes',[LONmin,LONmax],                         ...
                  'latitudes',[LATmin,LATmax]);

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = sst-273.15;
m_pcolor(lon, lat, f);
shading interp; colorbar; caxis([0 35]);
cmocean('inferno',256);
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: Surface Land/Ocean Temperature (Celsius)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_tsur_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, gsw);
shading interp; colorbar; caxis([0 800]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: GSW - Net Shortwave Radiation Flux at the ground (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(gsw(:))),                                ...
         '  Max = ', num2str(max(gsw(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_gsw_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, sw);
shading interp; colorbar; caxis([0 800]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: SWDOWN - Downward Shortwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(sw(:))),                                 ...
         '  Max = ', num2str(max(sw(:)))]},                             ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_swdown_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, swd);
shading interp; colorbar; caxis([0 800]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: SWDNB - Downwelling Shortwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(swd(:))),                                ...
         '  Max = ', num2str(max(swd(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_swdn_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, swu);
shading interp; colorbar; caxis([0 200]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: SWUPB - Upwelling Shortwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(swu(:))),                                ...
         '  Max = ', num2str(max(swu(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_swup_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = (swd - swu) ./ swd;
m_pcolor(lon, lat, f);
shading interp; colorbar
colormap(cmap('R4'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: SWUPB decreased percentage from SWDNB');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_swperc_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end


figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, swnet1);
shading interp; colorbar; caxis([0 800]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: SWDNB - SWUPB, Net Shortwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(swnet1(:))),                             ...
         '  Max = ', num2str(max(swnet1(:)))]},                         ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_swflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, ir);
shading interp; colorbar; caxis([300 500]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: Outgoing IR flux, StefBo * emiss * sst^4 (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(glw(:))),                                ...
         '  Max = ', num2str(max(glw(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_irflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, glw);
shading interp; colorbar; caxis([300 500]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: GLW - Downward Longwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(glw(:))),                                ...
         '  Max = ', num2str(max(glw(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_glw_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, lwd);
shading interp; colorbar; caxis([300 500]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: LWDNB - Downwelling Longwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(lwd(:))),                                ...
         '  Max = ', num2str(max(lwd(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lwdn_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, lwu);
shading interp; colorbar; caxis([300 500]);
colormap(cmap('R2'));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: LWUPB - Upwelling Longwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(lwu(:))),                                ...
         '  Max = ', num2str(max(lwu(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lwup_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = lwu - ir;
m_pcolor(lon, lat, f);
shading interp; colorbar; caxis([-120 120]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: LWUPB -IR, Longwave Radiation Flux Difference (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lwup-irflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end


figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = glw - lwu;
m_pcolor(lon, lat, f);
shading interp; colorbar; caxis([-150 150]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: GLW - LWUPB, Net Longwave Radiation Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lwflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = lwd - lwu;
m_pcolor(lon, lat, f);
shading interp; colorbar; caxis([-150 150]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: LWDNB - LWUPB, Longwave Radiation Flux Difference (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lwdn-lwup_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end


figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
f = glw - lwd;
m_pcolor(lon, lat, f);
shading interp; colorbar; caxis([-150 150]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: GLW - LWDNB, Longwave Radiation Flux Difference (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(f(:))),                                  ...
         '  Max = ', num2str(max(f(:)))]},                              ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_glw-lwdn_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, hfx);
shading interp; colorbar; caxis([-300 300]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: HFX - Sensible Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(hfx(:))),                                ...
         '  Max = ', num2str(max(hfx(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_shflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, lhf);
shading interp; colorbar; caxis([-650 650]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: HFX - Latent Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(lhf(:))),                                ...
         '  Max = ', num2str(max(lhf(:)))]},                            ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_lhflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
m_grid('tickdir','out','yaxisloc','left');
hold on;
m_pcolor(lon, lat, heat);
shading interp; colorbar; caxis([-800 800]);
colormap(flipud(redblue(256)));
m_gshhs_i('color','k');
m_plot(XboxW,YboxW,'linewidth',2,'color','k');
title('WRF: Net Heat Flux (W/m^2)');
xlabel({Tstring(rec,:),                                                 ...
        ['Min = ', num2str(min(heat(:))),                               ...
         '  Max = ', num2str(max(heat(:)))]},                           ...
         'FontSize',12,'FontWeight','bold');
if (wrtPNG)
  png_file=strcat('wrf_irene_nhflx_',num2str(rec, '%3.3i'),'.png');
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2045x1605+131+104',      ...
        ' +repage ', png_file, blanks(1), png_file]);
end

return

