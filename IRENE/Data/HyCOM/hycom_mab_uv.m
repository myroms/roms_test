% This script process HyCOM surface currents for the Mid-Atlantic
% Bight (MAB) to facilitate manimpulation and ESMF regridding.

OutName = 'hycom_mab3hours_uv_25aug2011_31aug2011.nc';
CDLname = 'hycom_mab_uv.cdl';

epoch = datenum(2000, 1, 1);

% Set input files.

flist = dir('NRL/*.nc4');
InpName ={flist.name};

% Create output NetCDF file.

unix(['ncgen -b ',CDLname]);
unix(['mv -f ',replace(CDLname,'.cdl','.nc'), blanks(1), OutName]);

% Read and process longitude and latitude.

X = nc_read(InpName{1}, 'lon');
Y = nc_read(InpName{1}, 'lat');

lon = repmat(X,  [1 length(Y)]);
lat = repmat(Y', [length(X) 1]);

nc_write(OutName, 'lon', lon);
nc_write(OutName, 'lat', lat);

% Process land/sea mask.

F = nc_read(InpName{1}, 'water_u', 1, NaN);
ind = find(isnan(F));
mask = ones(size(lon));
mask(ind) = 0;
nc_write(OutName, 'mask', mask);

% Process HyCOM data.

Nrec = length(InpName);

for rec = 1:Nrec
  fname = InpName{rec};

  time  = nc_read(fname, 'time', 1) / 24;       % days since reference date
  dfrac = time - fix(time);
  dstr  = datestr(datenum(epoch+time), 31);
  Date  = str2num(datestr(datenum(epoch+time),'yyyymmdd'))+dfrac;

  disp(['Processing Date: ', dstr]);
  
  Usur  = nc_read(fname, 'water_u', 1, NaN);
  Vsur  = nc_read(fname, 'water_v', 1, NaN);

  Uind = find(isnan(Usur));
  if (~isempty(Uind))
    Uwind(Uind)=1.0E+30;
  end
  
  Vind = find(isnan(Vsur));
  if (~isempty(Vind))
    Vwind(Vind)=1.0E+30;
  end

  nc_write(OutName, 'time',    time, rec);
  nc_write(OutName, 'Date',    Date, rec);
  nc_write(OutName, 'water_u', Usur, rec);
  nc_write(OutName, 'water_v', Vsur, rec);
end