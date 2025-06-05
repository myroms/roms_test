% This script plots the solution for vegetation_test case.

Gname = 'Data/roms_vegetation_test_grd.nc';
Dname = 'roms_dia.nc';
Hname = 'roms_his.nc';

% Get ROMS grid structure.

rec = 10;    % time record to plot

G = get_roms_grid(Gname, Hname, rec);

% Plot solution.

pt  = 2;           % plot type
map = 0;           % m_map switch
wrtPNG = true;     % write PNG files

%  Plot ROMS history fields.

v='ubar'; l=10; F=plot_field(G,Hname,v,rec,l,[-0.15 0.15],map,pt);
colormap(flipud(mpl_rainbow200));
title(['barotropic u-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_ubar.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='vbar'; l=10; F=plot_field(G,Hname,v,rec,l,[0 0.5],map,pt);
colormap(mpl_rainbow200);
title(['Barotropic v-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_vbar.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u'; l=10; F=plot_field(G,Hname,v,rec,l,[-0.15 0.15],map,pt);
colormap(flipud(mpl_rainbow200));
title(['Surface u-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_usur.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u'; l=1; F=plot_field(G,Hname,v,rec,l,[-0.15 0.15],map,pt);
colormap(flipud(mpl_rainbow200));
title(['Bottom u-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_ubot.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='v'; l=10; F=plot_field(G,Hname,v,rec,l,[0 0.5],map,pt);
colormap(mpl_rainbow200);
title(['Surface v-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_vsur.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='v'; l=1; F=plot_field(G,Hname,v,rec,l,[0 0.5],map,pt);
colormap(mpl_rainbow200);
title(['Bottom v-velocity (m/s)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_vbot.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

%  Plot ROMS diagnostics.

cax = [-2.5e-4 2.5e-4];

v='ubar_fveg'; l=10; F=plot_field(G,Dname,v,rec,l,cax,map,pt);
colormap((mpl_amwg256));
title(['u-barotropic: drag force term (m/s^2)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_ubar_fveg.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='u_fveg'; l=1; F=plot_field(G,Dname,v,rec,l,cax,map,pt);
colormap((mpl_amwg256));
title(['u-bottom: drag force term (m/s^2)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_ubot_fveg.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

cax = [-8e-4 0];

v='vbar_fveg'; l=10; F=plot_field(G,Dname,v,rec,l,cax,map,pt);
colormap(flipud(mpl_Paired(256)));
title(['v-barotropic: drag force term (m/s^2)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_vbar_fveg.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end

v='v_fveg'; l=1; F=plot_field(G,Dname,v,rec,l,cax,map,pt);
colormap(flipud(mpl_Paired(256)));
title(['v-bottom: drag force term (m/s^2)'])
ylabel('Y-axis (km)');
xlabel('X-axis (km)');
if (wrtPNG)
  png_file='veg_vbot_fveg.png';
  exportgraphics(gcf, png_file, 'resolution', 300);
end
