% Plots U.S. East Coast (USEC) 4D-Var Increments and control Vectors.

Dusec  = dir('../').folder;

Gusec3 = strcat(Dusec, '/Data/GRD/usec3km_roms_grd.nc');
Gusec6 = strcat(Dusec, '/Data/GRD/usec6km_roms_grd.nc');

Tusec  = {'2019.08.27', '2019.08.30'};

Husec3 = '2019.08.27/usec3km_roms_fwd_20190827_outer0.nc';
Husec6 = '2019.08.27/usec6km_roms_fwd_20190827_outer0.nc';

Iusec3 = {'2019.08.27/usec3km_roms_itl_20190827.nc',                  ...
          '2019.08.30/usec3km_roms_itl_20190830.nc'};

Iusec6 = {'2019.08.27/usec6km_roms_itl_20190827.nc',                  ...
          '2019.08.30/usec6km_roms_itl_20190830.nc',};

Musec3 = {'2019.08.27/usec3km_roms_mod_20190827.nc',                  ...
          '2019.08.30/usec3km_roms_mod_20190830.nc'};

usec_str = datenum(2019,8,27);
usec_end = datenum(2019,9,02);

if ~exist('G3','var')
  G3 = get_roms_grid(Gusec3, Husec3);
end

if ~exist('G6','var')
  G6 = get_roms_grid(Gusec6, Husec6);
end

R.zeta = [-0.2 0.2];
R.temp = [-3.5 3.5];
R.salt = [-0.4 0.4];
R.u    = [-0.3 0.3];
R.v    = [-0.25 0.25];

r     = 2;
ptype = 1;
map   = 1;
o     = 'h';
ind   = 100;
wrt   = -500;

for n=1:length(Iusec3);
  if exist(Iusec3{n},'file')
    l=50;  F=plot_state(G3,Iusec3{n},r,l,ptype,map,o,ind,wrt,'3km_sur',R);
    l=-20; F=plot_state(G3,Iusec3{n},r,l,ptype,map,o,ind,wrt,'3km_20m',R);
    l=-50; F=plot_state(G3,Iusec3{n},r,l,ptype,map,o,ind,wrt,'3km_50m',R);
    unix(['mv *_3km*.png ', Tusec{n}]);
  end
end

for n=1:length(Iusec6); 
  if exist(Iusec3{n},'file')
    l=50;  F=plot_state(G6,Iusec6{n},r,l,ptype,map,o,ind,wrt,'6km_sur',R);
    l=-20; F=plot_state(G6,Iusec6{n},r,l,ptype,map,o,ind,wrt,'6km_20m',R);
    l=-50; F=plot_state(G6,Iusec6{n},r,l,ptype,map,o,ind,wrt,'6km_50m',R);
    unix(['mv *_6km*.png ', Tusec{n}]);
  end
end

% Plot DesrozierS diagnostics.

D=plot_desroziers(Musec3, usec_str, usec_end, 12, true, true);

% PLot 4D-Var state conctol vector.

for n=1:length(Musec3);
  if exist(Musec3{n},'file')
    V=plot_4dvar_vectors(Musec3{n},true,true);
    unix(['mv inc_*.png inn_*.png res_*.png err_*.png ', Tusec{n}]);
  end
end