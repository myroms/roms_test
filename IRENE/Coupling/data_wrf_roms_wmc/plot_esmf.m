function plot_esmf(slon,slat,smask,dlon,dlat,dmask,suffix,varargin)

% PLOT_ESMF: Plots ESMF debugging field
%
% plot_esmf(slon, slat, dlon, dlat, file_date, clon, clat, doPNG);
% On Imput:
%
%    slon        Source coupled component longitude (2D array)
%    slat        Source coupled component latitude  (2D array)
%    smask       Source coupled component land mask (2D array)
%    dlon        Destination coupled component longitude (2D array)
%    dlat        Destination coupled component latitude  (2D array)
%    dmask       Destination coupled component land mask (2D array)
%    suffix      Filename suffix: YYYY-MM-DD_hh.mm.ss (string)
%    clon        Coastlines longitude (1D array, OPTIONAL)
%    clat        Coastlines latitude  (1D array, OPTIONAL)
%    doPNG       Switch to write PNG files (logical, OPTIONAL)
%

%  Optional arguments.

switch numel(varargin)
  case 0
    plot_coast = false;
    doPNG = false;
  case 1
    plot_coast = false;
    clon = [];
    clat = [];
    doPNG = false;
  case 2
    plot_coast = true;
    clon = varargin{1};
    clat = varargin{2};
    doPNG = false;
  case 3
    plot_coast = true;
    clon = varargin{1};
    clat = varargin{2};
    doPNG = varargin{3};
end

%----------------------------------------------------------------------
% Get perimeters.
%----------------------------------------------------------------------

Istr = 1;
Jstr = 1;
[Iend, Jend] = size(slon);

SX = [squeeze(slon(Istr:Iend,Jstr));                                ...
      squeeze(slon(Iend,Jstr+1:Jend))';                             ...
      squeeze(flipud(slon(Istr:Iend-1,Jend)));                      ...
      squeeze(fliplr(slon(Istr,Jstr:Jend-1)))'];

SY = [squeeze(slat(Istr:Iend,Jstr));                                ...
      squeeze(slat(Iend,Jstr+1:Jend))';                             ...
      squeeze(flipud(slat(Istr:Iend-1,Jend)));                      ...
      squeeze(fliplr(slat(Istr,Jstr:Jend-1)))'];


Istr = 1;
Jstr = 1;
[Iend, Jend] = size(dlon);

DX = [squeeze(dlon(Istr:Iend,Jstr));                                ...
      squeeze(dlon(Iend,Jstr+1:Jend))';                             ...
      squeeze(flipud(dlon(Istr:Iend-1,Jend)));                      ...
      squeeze(fliplr(dlon(Istr,Jstr:Jend-1)))'];

DY = [squeeze(dlat(Istr:Iend,Jstr));                                ...
      squeeze(dlat(Iend,Jstr+1:Jend))';                             ...
      squeeze(flipud(dlat(Istr:Iend-1,Jend)));                      ...
      squeeze(fliplr(dlat(Istr,Jstr:Jend-1)))'];


LineTypeS = 'k-';
LineTypeD = 'r-';

%----------------------------------------------------------------------
% Set plot options.
%----------------------------------------------------------------------

% Get plot date string.

date_str = strrep(strrep(suffix, '_', ' '), '.', ':');
plot_str = datestr(datenum(date_str), 31);

% Set color palette.

 Cmap = cmap_odv('Odv_437');
%Cmap = cmap('R2');
%Cmap = vivid('mvbscflyor',[0.7 0.2]);
%Cmap = flipud(vivid('mvbscflyor',[0.2 1]));

%----------------------------------------------------------------------
% Plot coupled components fields.
%----------------------------------------------------------------------

% ROMS export fields.

figure;
roms_exp{1} = ['roms_01_export_Usur_', suffix, '.nc'];
roms_var{1} = 'Usur';

F = nc_read(roms_exp{1}, roms_var{1});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, smask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(slon, slat, f); colorbar; shading interp;
colormap(Cmap);
title(['ROMS Export: ', roms_var{1}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('roms_export_', roms_var{1}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
roms_exp{2} = ['roms_01_export_Vsur_', suffix, '.nc'];
roms_var{2} = 'Vsur';

F = nc_read(roms_exp{2}, roms_var{2});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, smask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(slon, slat, f); colorbar; shading interp;
colormap(Cmap);
title(['ROMS Export: ', roms_var{2}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('roms_export_', roms_var{2}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
roms_exp{3} = ['src_Usur_ESM_01_roms-to-wrf_', suffix, '.nc'];
roms_var{3} = 'Usur';

F = nc_read(roms_exp{3}, roms_var{3});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, smask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(slon, slat, f); colorbar; shading interp;
colormap(Cmap);
title(['Source ROMS-to-WRF Export: ', roms_var{3}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('roms_src_', roms_var{3}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
roms_exp{4} = ['src_Vsur_ESM_01_roms-to-wrf_', suffix, '.nc'];
roms_var{4} = 'Vsur';

F = nc_read(roms_exp{4}, roms_var{4});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, smask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(slon, slat, f); colorbar; shading interp;
colormap(Cmap);
title(['Source ROMS-to-WRF Export: ', roms_var{4}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('roms_src_', roms_var{4}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end

% WRF import fields.

figure;
wrf_imp{1}  = ['wrf_01_import_Usur_', suffix, '.nc'];
wrf_var{1}  = 'Usur';

F = nc_read(wrf_imp{1}, wrf_var{1});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import from ROMS: ', wrf_var{1}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_import_', wrf_var{1}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{2}  = ['wrf_01_import_Vsur_', suffix, '.nc'];
wrf_var{2}  = 'Vsur';

F = nc_read(wrf_imp{2}, wrf_var{2});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import from ROMS: ', wrf_var{2}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_import_', wrf_var{2}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{3}  = ['wrf_01_import_dUsur_', suffix, '.nc'];
wrf_var{3}  = 'dUsur';

F = nc_read(wrf_imp{3}, wrf_var{3});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import from DATA: ', wrf_var{3}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_import_', wrf_var{3}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end

figure;
wrf_imp{4}  = ['wrf_01_import_dVsur_', suffix, '.nc'];
wrf_var{4}  = 'dVsur';

F = nc_read(wrf_imp{4}, wrf_var{4});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import from DATA: ', wrf_var{4}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_import_', wrf_var{4}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{5}  = ['wrf_01_merged_Usur-dUsur_', suffix, '.nc'];
wrf_var{5}  = 'Usur-dUsur';

F = nc_read(wrf_imp{5}, wrf_var{5});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import Merged DATA-ROMS: ', wrf_var{5}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_merged_', wrf_var{5}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{6}  = ['wrf_01_merged_Vsur-dVsur_', suffix, '.nc'];
wrf_var{6}  = 'Vsur-dVsur';

F = nc_read(wrf_imp{6}, wrf_var{6});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['WRF Import Merged DATA-ROMS: ', wrf_var{6}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_merged_', wrf_var{6}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{7}  = ['dst_Usur_ESM_01_roms-to-wrf_', suffix, '.nc'];
wrf_var{7}  = 'Usur';

F = nc_read(wrf_imp{7}, wrf_var{7});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['Destination ROMS-to-WRF Import: ', wrf_var{7}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_dst_', wrf_var{7}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{8}  = ['dst_Vsur_ESM_01_roms-to-wrf_', suffix, '.nc'];
wrf_var{8}  = 'Vsur';

F = nc_read(wrf_imp{8}, wrf_var{8});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['Destination ROMS-to-WRF Import: ', wrf_var{8}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_dst_', wrf_var{8}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{9}  = ['dst_dUsur_ESM_01_data-to-wrf_', suffix, '.nc'];
wrf_var{9}  = 'dUsur';

F = nc_read(wrf_imp{9}, wrf_var{9});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['Destination DATA-to-WRF Import: ', wrf_var{9}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_dst_', wrf_var{9}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end


figure;
wrf_imp{10} = ['dst_dVsur_ESM_01_data-to-wrf_', suffix, '.nc'];
wrf_var{10} = 'dVsur';

F = nc_read(wrf_imp{10}, wrf_var{10});
ind = F > 1.0E+15;
if (~isempty(ind))
  F(ind) = NaN;
end
f = nanland(F, dmask);
fmin = min(f(:));
fmax = max(f(:));

pcolor(dlon, dlat, f); colorbar; shading interp;
colormap(Cmap);
title(['Destination DATA-to-WRF Import: ', wrf_var{10}]);
xlabel({['Min = ', num2str(fmin), blanks(4),'Max = ', num2str(fmax)], ...
        plot_str});
hold on;
if (plot_coast)
  plot(clon, clat, 'k-');
end
plot(SX, SY, LineTypeS, 'LineWidth', 2);
plot(DX, DY, LineTypeD, 'LineWidth', 2);
hold off;
if (doPNG)
  png_file = strcat('wrf_dst_', wrf_var{10}, '.png');
  exportgraphics(gcf, png_file, 'resolution', 300);
end

return
