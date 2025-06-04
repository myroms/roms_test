% This script plots the solution for DuckNC Test case.

Gname = 'Data/roms_duck94_grd.nc';
Dname = 'roms_dia.nc';
Hname = 'roms_his.nc';

% Get ROMS grid structure.

rec = 10;    % time record to plot

G = get_roms_grid(Gname, Hname, rec);

% Plot domain grid.

kgrid=0;          % W-points section
column=0;         % row section
index=4;          % row section along j=4
plt=2;            % two panels with zoom
Zzoom=0.25;       % depth of the zoom in upper panel, 25 cm

wrtPNG=true;      % write PNG files

z=plot_scoord(G, kgrid, column, index, plt, Zzoom);
if (wrtPNG)
  png_file='ducknc_grd.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

%  Plot ROMS history solution.

v='u'; F=plot_section(G, Hname, v, rec, 'r', 4, 1);
colormap(mpl_rainbow200);
title(['u-velocity (m/s)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='omega'; F=plot_section(G, Hname, v, rec, 'r', 4, 1);
colormap(mpl_Accent(256));
title(['omega-velocity (m/s)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_omega.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u_stokes'; F=plot_section(G, Hname, v, rec, 'r', 4, 1);
colormap(flipud(mpl_rainbow200));
colormap(mpl_rainbow200);
title(['Stokes u-velocity (m/s)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u_stokes.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='omega_stokes'; F=plot_section(G, Hname, v, rec, 'r', 4, 1);
colormap(flipud(mpl_Accent(256)));
title(['Stokes omega-velocity (m/s)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_omega_stokes.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

%  Plot ROMS diagnostics.

v='u_hjvf'; F=plot_section(G, Dname, v, rec, 'r', 4, 1);
colormap(mpl_Paired(256));
title(['u-term: horizontal J-vortex force (m/s2)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u_hjvf.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u_vjvf'; F=plot_section(G, Dname, v, rec, 'r', 4, 1);
colormap(mpl_Set3(256));
title(['u-term: vertical J-vortex force (m/s2)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u_vjvf.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u_wbrk'; F=plot_section(G, Dname, v, rec, 'r', 4, 1);
colormap(cmap_odv('Odv'));
title(['u-term: wave breaking (m/s2)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u_wbrk.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u_prsgrd'; F=plot_section(G, Dname, v, rec, 'r', 4, 1);
colormap(mpl_Set3(256));
title(['u-term: pressure gradient (m/s2)'])
ylabel('depth (m)');
xlabel('X-axis (m)');
if (wrtPNG)
  png_file='ducknc_u_psrgd.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end
