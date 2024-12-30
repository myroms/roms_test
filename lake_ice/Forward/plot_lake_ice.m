% PLOT_LAKE_ICE: Plots LAKE_ICE History or Station Data.

% git $Id$
%=====================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                             %
%    Licensed under a MIT/X style license                             %
%    See License_ROMS.md                                              %
%=====================================================================%

Dir   = './';
Sname = strcat(Dir, 'roms_lake_ice_sta.nc');
Qname = {dir(strcat(Dir,'roms_lake_ice_qck_*')).name};
Qname = strcat(Dir, Qname);

G = get_roms_grid(Qname{1}, Qname{1});

X = nc_read(Sname, 'x_rho')/1000;
Y = nc_read(Sname, 'y_rho')/1000;

for i=1:length(X)
  sta_loc{i}=['\bullet S',num2str(i)];
  sta_lab{i}=['S',num2str(i)];
end

time = nc_read(Sname, 'ocean_time')/86400;

epoch = datenum(2010, 1, 1);
Date  = epoch+time;

PLOT_MAPS      = true;             % if false, it plots station data
doPNG          = false;
doPNG_stations = false;

nf       = 3;                      % history filename number to process
Contours = false;                  % switch to use 'contourf' instead
Land     = [0.6 0.65 0.6];         % background color instead of white
Recs     = [60 76 104 121];        % time records to process

if (PLOT_MAPS)

%----------------------------------------------------------------------
% Plot bathymetry.
%----------------------------------------------------------------------

  figure;

  set(gca, 'color', Land);
  hold on;
  pcolor(G.x_rho/1000,G.y_rho/1000,nanland(G.h,G.mask_rho));
  text(X,Y,sta_loc);
  title(untexlabel('LAKE_ICE: Bathymetry (m)'));
  xlabel('km');
  ylabel('km');
  shading interp;
  colorbar;
  colormap(cmap_odv('Bathymetry'))
  axis equal;
  axis([0 200 0 100]);
  hold off;

  if (doPNG)
    png_file = strcat('ice_area_bathy', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

%----------------------------------------------------------------------
% Plot few ice properties maps.
%----------------------------------------------------------------------

  for ir = 1:length(Recs)

    ctime = (epoch+nc_read(Qname{nf},'ocean_time',Recs(ir))/86400);
    cdate = datestr(ctime, 0);

% Plot ice area and age.

    figure;

    subplot(2,1,1)
    set(gca, 'color', Land);
    hold on;
    F = nc_read(Qname{nf}, 'Aice', Recs(ir));
    if (Contours)
      contourf(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho),20);  
    else
      pcolor(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho));
    end
    title(untexlabel('Fraction of Cell Covered by Ice'));
    xlabel('km'); ylabel('km');
    colorbar; shading interp;
    colormap(flipud(vivid('mvbscflyor',[0.2 1])));
    caxis([0 1]);
    axis([0 200 0 100]);
    hold off;
  
    subplot(2,1,2)
    set(gca, 'color', Land);
    hold on;
    F = nc_read(Qname{nf}, 'ice_age', Recs(ir));
    if (Contours)
      contourf(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho),20);  
    else
      pcolor(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho));
    end
    title(untexlabel('Age of Water Ice'));
    xlabel(cdate); ylabel('km');
    colorbar; shading interp;
    colormap(flipud(vivid('mvbscflyor',[0.2 1])));
    caxis([0 Inf]);
    axis([0 200 0 100]);
    hold off

    if (doPNG)
      png_file = strcat('ice_area_', num2str(ir), '.png');
      exportgraphics(gcf, png_file, 'resolution', 300);
    end

% Plot ice thiknesses.

    figure;

    subplot(2,1,1)
    set(gca, 'color', Land);
    hold on;
    F = nc_read(Qname{nf}, 'ice_thickness', Recs(ir));
    if (Contours)
      contourf(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho),20);  
    else
      pcolor(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho));
    end
    title(untexlabel('Average Ice Thickness in Cell, m'));
    xlabel('km'); ylabel('km');
    colorbar; shading interp;
    colormap(flipud(vivid('mvbscflyor',[0.2 1])));
    caxis([0 Inf]);
    axis([0 200 0 100]);
    hold off;

    subplot(2,1,2)
    set(gca, 'color', Land);
    hold on;
    F = nc_read(Qname{nf}, 'meltpond_thickness', Recs(ir));
    if (Contours)
      contourf(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho),20);  
    else
      pcolor(G.x_rho/1000,G.y_rho/1000,nanland(F,G.mask_rho));
    end
    title(untexlabel('Surface Melt Water Thickness on Ice, m'));
    xlabel(cdate); ylabel('km');
    colorbar; shading interp;
    colormap(flipud(vivid('mvbscflyor',[0.2 1])));
    caxis([0 0.1]);
    axis([0 200 0 100]);
    hold off;  

    if (doPNG)
      png_file = strcat('ice_tickness_', num2str(ir), '.png');
      exportgraphics(gcf, png_file, 'resolution', 300);
    end

  end

else

%----------------------------------------------------------------------
% Plot ice model variables from stations file.
%----------------------------------------------------------------------

% Set distinguished line colors and replace default sequence.
% Use  plot(X,Y,'linewidth',1) or other value to increase width.

  C     = linspecer(length(X));     % pick colors
  width = 1;                        % default 0.5

  axes('NextPlot','replacechildren', 'ColorOrder', C);

  x = Date;     % use date label on x-axis

  figure;

  shflux   = nc_read(Sname, 'shflux');
  swrad    = nc_read(Sname, 'swrad');
  lwrad    = nc_read(Sname, 'lwrad');
  latent   = nc_read(Sname, 'latent');
  sensible = nc_read(Sname, 'sensible');

  station  = 1;                     % all stations have same heat flux

  plot(x, shflux(station,:),                                        ...
       x, swrad(station,:),                                         ...
       x, lwrad(station,:),                                         ...
       x, latent(station,:),                                        ...
       x, sensible(station,:),                                      ...
       'linewidth', width);
  title('Heat Flux components, W/m^2');
  datetick('x', 'mmmyy', 'keepticks');
  xlabel(sta_lab{1});
  legend('shflux', 'swrad', 'lwrad', 'latent', 'sensible',          ...
         'Location','northeast');
  grid on;

  if (doPNG_stations)
    png_file = strcat('ice_heat_flux', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'sustr');
  subplot(2,1,1)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Surface U-stress, N/m^2');
  grid on;

  F = nc_read(Sname, 'svstr');
  subplot(2,1,2)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  title('Surface V-stress, N/m^2');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_windstress', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'zeta');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Free Surface, m');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_zeta', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'Aice');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Fraction of Cell Covered by Ice');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_cover', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'ice_thickness');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Average Ice Thickness, m');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_thickness', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'meltpond_thickness');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Suface Melt Water Thickness on Ice, m');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_meltpond', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'ice_age');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Ice Age');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_age', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'Uice');
  subplot(2,1,1)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('U-component Ice Velocity, m/s');
  grid on;

  F = nc_read(Sname, 'Vice');
  subplot(2,1,2)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  title('V-component Ice Velocity, m/s');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_vel', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'Tice');
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Interior Ice Temperature, C');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_temp', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'ice_sst');
  subplot(2,1,1)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Temperature of Ice/Snow Surface, C');
  grid on;

  F = nc_read(Sname, 'under_ice_temp');

  subplot(2,1,2)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  title('Temperature of Molecular sub-layer under Ice, C');
  grid on;
  if (doPNG_stations)
    png_file = strcat('ice_sst', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

  figure;

  F = nc_read(Sname, 'ai_melt_freeze');
  subplot(3,1,1)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  legend(sta_lab, 'Location','best');
  title('Rate of Melt/Freeze at ATM-ICE Interface, m/s');
  grid on;

  F = nc_read(Sname, 'ao_melt_freeze');
  subplot(3,1,2)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  title('Rate of Melt/Freeze at ATM-OCN Interface, m/s');
  grid on;

  F = nc_read(Sname, 'io_melt_freeze');
  subplot(3,1,3)
  plot(x, F, 'linewidth', width);
  datetick('x', 'mmmyy', 'keepticks');
  title('Rate of Melt/Freeze at ICE-OCN Interface, m/s');
  grid on;

  if (doPNG_stations)
    png_file = strcat('ice_melt', '.png');
    exportgraphics(gcf, png_file, 'resolution', 300);
  end

end
