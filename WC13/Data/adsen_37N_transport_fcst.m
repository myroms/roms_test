%
%  This script sets-up the adjoint sensitivity forcing files
%  'wc13_foi_A.nc' and 'wc13_foi_B.nc' for the time averaged 37N
%  transport during the 4D-Var analysis cycle.
%
%  A veryifying analysis is used as a surrogate for the truth.
%

% svn $Id$
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                                                 %
%=========================================================================%

clear all

% Forecast averaging interval (number of history file record per day).

nAVG=1;

% Define the forecast and verifying analysis history files.

InpA ='../RBL4DVAR_forecast_impact/FCSTA/wc13_fwd.nc';
InpB ='../RBL4DVAR_forecast_impact/FCSTB/wc13_fwd.nc';
InpVA='RBL4DVAR_VERIFYING_ANALYSIS/wc13_fwd_001.nc';

% Set variables to process.

Vinfo = {'spherical', 'Vtransform', 'Vstretching', 'theta_s',           ...
         'theta_b', 'Tcline', 'hc', 's_rho', 's_w', 'Cs_r', 'Cs_w',     ...
         'h', 'lon_rho', 'lat_rho', 'lon_u', 'lat_u', 'lon_v', 'lat_v', ...
         'ocean_time'};

Vmasks = {'scope_rho', 'scope_u', 'scope_v'};

Vstate = {'zeta', 'ubar', 'vbar', 'u', 'v', 'temp', 'salt'};

% Set adjoint sensitivity scope mask with the same values as the regular
% masks.

F.scope_rho = nc_read(InpA, 'mask_rho');
F.scope_u   = nc_read(InpA, 'mask_u');
F.scope_v   = nc_read(InpA, 'mask_v');

% Define the 37N section, over upper "depth" meters.

depth=-500.0;
jlat=21;
section=22:36;

Gname='wc13_grd.nc';

[h]=nc_read(Gname,'h');

Eradius=6371315.0;

lonr=nc_read(Gname,'lon_rho'); lonr=lonr';
latr=nc_read(Gname,'lat_rho'); latr=latr'; 
lonv=nc_read(Gname,'lon_v');   lonv=lonv';
latv=nc_read(Gname,'lat_v');   latv=latv';
lonu=nc_read(Gname,'lon_u');   lonu=lonu';
latu=nc_read(Gname,'lat_u');   latu=latu';

[Jm Im]=size(latr);
coslatv=zeros(Jm-1,Im);
for ib=1:Im,
  for jb=1:Jm-1,
    coslatv(jb,ib)=cos( latv(jb,ib)*pi/180 );
  end
end
dlonu=zeros(Jm-1,Im);
dlonupre=lonu(:,2:end)-lonu(:,1:end-1);
dlonu(:,2:end-1)=(dlonupre(2:end,:)+dlonupre(1:end-1,:))/2;
faclon=Eradius*coslatv.*(dlonu*pi/180);
facsverd=1./1e6; % nbr exact ?

nHIS=nc_read(InpA,'nHIS');
ntimes=nc_read(InpA,'ntimes');
%facdt1=nHIS/ntimes;
facdt1=1/nAVG;
  
clear f;
v='v';         
fA =nc_read(InpA,v);
fB =nc_read(InpB,v);
fVA=nc_read(InpVA,v);
  
clear varr;
varr=zeros(size(fA));
  
 
for it=(size(fA,4)-nAVG):size(fA,4),

  facdt=facdt1;
  
  clear z_w;
  [z_w]=depths(InpA,Gname,5,0);
    
  nlevt=size(fA,3);
    
  clear Hz;
  for k=1:nlevt
    Hz(:,:,k)=z_w(:,:,k+1)-z_w(:,:,k);
  end
    
  clear z_v;
  [z_v]=depths(InpA,Gname,4,0);
    
  clear df;
    
  for k=1:nlevt,
    for i=section,
      if z_v(i,jlat,k) > depth
        fac=faclon(jlat,i)*facsverd;
        df=0.5*(Hz(i,jlat,k)+Hz(i,jlat-1,k));
        varr(i,jlat,k,it)=facdt*df*fac;
      end
    end
  end
    
end

% Compute dJA and dJB.

dJA=nansum(nansum(nansum(nansum(varr.*(fA-fVA),1),2),3),4);
dJB=nansum(nansum(nansum(nansum(varr.*(fB-fVA),1),2),3),4);

varrA=dJA.*varr;
varrB=dJB.*varr;

%--------------------------------------------------------------------------
% Create adjoint sensitivy NetCDF file: wc13_foi_A.nc
%--------------------------------------------------------------------------

% Create output NetCDf from CDL file.

Out='wc13_foi_A.nc';
unix('ncgen -b adsen.cdl');
unix(['mv adsen.nc ' Out]);

disp(' ');
disp(['Creating and processing: ', Out]);
disp(' ');

% Write out information variables.

for var = Vinfo
  v = char(var);
  f = nc_read (InpA, v);
  s = nc_write(Out,  v, f);
end

% Write out adjoint sensitive scope arrays: same values as land/sea
% masking.

for var = Vmasks
  field = char(var);
  s = nc_write(Out, field, F.(field));
end

% Write out zero state variables.
	
for var = Vstate
  v = char(var);
  f = nc_read (InpA, v);
  s = nc_write(Out, v, zeros(size(f)));
end

% Over-write v-momentum sensitivity functional for the California
% Current System: sensitivity of meridional transport along 37N
% for the upper 500 m.

s=nc_write(Out,'v',varrA);

%--------------------------------------------------------------------------
% Create adjoint sensitivy NetCDF file: wc13_foi_B.nc
%--------------------------------------------------------------------------

% Create output NetCDf from CDL file.

Out='wc13_foi_B.nc';
unix('ncgen -b adsen.cdl');
unix(['mv adsen.nc ' Out]);

disp(' ');
disp(['Creating and processing: ', Out]);
disp(' ');

% Write out information variables.

for var = Vinfo
  v = char(var);
  f = nc_read (InpB, v);
  s = nc_write(Out,  v, f);
end

% Write out adjoint sensitive scope arrays: same values as land/sea
% masking.

for var = Vmasks
  field = char(var);
  s = nc_write(Out, field, F.(field));
end

% Write out zero state variables.

for var = Vstate
  v = char(var);
  f = nc_read (InpB, v);
  s = nc_write(Out, v, zeros(size(f)));
end

% Over-write v-momentum sensitivity functional for the California
% Current System: sensitivity of meridional transport along 37N
% for the upper 500 m.

s=nc_write(Out,'v',varrB);
  
