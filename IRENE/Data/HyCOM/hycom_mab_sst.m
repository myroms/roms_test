% This script extracts a subset of the HyCOM SST for the Mid-Atlantic
% Bight (MAB) to facilitate manimpulation and ESMF regridding.

InpName = 'hycom_sst_25aug2011_31aug2011.nc';
OutName = 'hycom_mab_sst_25aug2011_31aug2011.nc';
CDLname = 'hycom_mab_sst.cdl';

% Set extract indices from global grid.

i1 = 2500;
i2 = 2900;
j1 = 1900;
j2 = 2190;    % tripolar transition is at j=2172

% Create output NetCDF file.

unix(['ncgen -b ',CDLname]);
unix(['mv -f ',replace(CDLname,'.cdl','.nc'), blanks(1), OutName]);

% Read and write HyCOM data.

Nrec = length(nc_read(InpName, 'MT'));

lon = nc_read(InpName, 'Longitude');
lon = lon(i1:i2, j1:j2) - 360;
nc_write(OutName, 'Longitude', lon);

lat = nc_read(InpName, 'Latitude');
lat = lat(i1:i2, j1:j2);
nc_write(OutName, 'Latitude', lat);

F = nc_read(InpName, 'temperature', 1, NaN);
F = F(i1:i2, j1:j2);
ind = find(isnan(F));
mask = ones(size(lon));
mask(ind) = 0;
nc_write(OutName, 'mask', mask);

for rec=1:Nrec
  F = nc_read(InpName, 'MT', rec);
  nc_write(OutName, 'MT', F, rec);

  F = nc_read(InpName, 'Date', rec);
  nc_write(OutName, 'Date', F, rec);

  F = nc_read(InpName, 'temperature', rec, NaN);
  F = F(i1:i2, j1:j2);
  ind = find(isnan(F));
  if (~isempty(ind))
    F(ind)=1.0E30;
  end
  nc_write(OutName, 'temperature', F, rec);
end

