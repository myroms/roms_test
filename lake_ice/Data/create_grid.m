% CREATE_GRID: Creates NetCDF grid for LAKE_ICE.

% git $Id$
%=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                                                  %
%=========================================================================%

% LAKE_ICE: ROMS Native Sea Ice Model Test

Gname = 'lake_ice_grd.nc';

% Set grid coordinates.

L = 200;
M = 100;

dx = 1000;     % 1 km
dy = 1000;     % 1 km

G = uniform_grid(dx, dy, L, M);

% Create ROMS NetCDF grid.

c_grid(L+1, M+1, Gname, true, false);

% Compute the bowl bathymetry.

a     = 3.5;
b     = 6.0;
hc    = 200;
hmin  = 20;
scale = 0.0014;
Xmid  = mean(G.x_rho(:));
Ymid  = mean(G.y_rho(:));

X = 0.002*(G.x_rho-Xmid);                % km
Y = 0.003*(G.y_rho-Ymid);                % km

h = hc - scale*(a*X.^2 + b*Y.^2);        % m

ind = find(h < hmin);
if (~isempty(ind))
  h(ind) = hmin;
end

% Compute land/sea mask.

rmask = ones(size(h));

ind = find(h < 20.5);
rmask(ind) = 0;

% Set other parameters in grid structure.

G.spherical = 0;
G.xl        = max(G.x_rho(:));
G.el        = max(G.y_rho(:));
G.angle     = zeros(size(G.x_rho));
G.h         = h;
G.mask_rho  = rmask;

[G.mask_u, G.mask_v, G.mask_psi] = uvp_masks(G.mask_rho);

% Compute Coriolis.

f0   = 1.0E-04;
beta = 0.0;

f = ones(size(G.x_rho)).*f0;
if (beta > 0)
  f = f + beta .* (G.y_rho - Ymid);
end
G.f = f;

% Write variables to ROMS Grid NetCDF file.  The land/sea masks was edited
% with "editmask.m" by hand.

GridVars = {'spherical', 'xl', 'el',                                    ...
            'angle', 'pm', 'pn', 'dndx', 'dmde', 'f', 'h',              ...
            'x_rho', 'y_rho', 'x_psi', 'y_psi',                         ...
            'x_u', 'y_u', 'x_v', 'y_v',                                 ...
            'mask_rho', 'mask_psi', 'mask_u', 'mask_v'};

for var = GridVars
  field = char(var);
  nc_write(Gname, field, G.(field));
end
nc_write(Gname, 'hraw', G.h, 1);

% Compute final grid structure.

G=get_roms_grid(Gname);

% Plot bathymetry.

figure;
contourf(G.x_rho/1000,G.y_rho/1000,nanland(G.h,G.mask_rho),20);
title(untexlabel('LAKE_ICE: Bathymetry (m)'));
xlabel('km');
ylabel('km');
colorbar;
colormap(flipud(cmap_odv('Pastel')));
axis equal

print('lake_ice_bathy.png', '-dpng', '-r300');