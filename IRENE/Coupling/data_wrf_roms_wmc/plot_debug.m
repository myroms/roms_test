% Driver to plot coupled fields between WRF and ROMS.
%
% The debugging NetCDF files used here are generated
% by the ESMF library when the "DebugLevel" in the
% script "coupling_esmf_atm_sbl_wmc.in" is greater
% than 2 (DebugLevel=3) and the debug_write token in
% "coupling_esmf_wrf.yaml" for a particular exchanged
% field is "true".
%
% WARNING: the debugging option should be run for a few
%          time step since it creates several NetCDF
%          files per model coupling step.


Dir   = './';
Rgrid = '../../Data/ROMS/irene_roms_grid.nc';
Wgrid = '../../Data/WRF/irene_wrf_inp_d01_20110827.nc';

% Get ROMS and WRF grid data.

G = get_roms_grid(Rgrid);

wlon  = nc_read(Wgrid, 'XLONG');
wlat  = nc_read(Wgrid, 'XLAT');
wland = nc_read(Wgrid, 'LANDMASK');
wlake = nc_read(Wgrid, 'LAKEMASK');

% Compute WRF ocean mask.
%
%  lakemask >   0: elsewhere (land, ocean)     1: lake
%  landmask >   0: elsewhere (ocean, lakes)    1: land

wmask = ones(size(wlon));
lake  = find(wlake == 1); wmask(lake) = 0;
land  = find(wland == 1); wmask(land) = 0;

% Plot debugging fields for selected filename suffix:

suffix = '2011-08-27_06.00.00';
doPNG  = true;

plot_esmf(G.lon_rho, G.lat_rho, G.mask_rho, wlon, wlat, wmask,      ...
          Dir, suffix, G.lon_coast, G.lat_coast, doPNG);