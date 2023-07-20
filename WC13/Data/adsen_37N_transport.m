%
%  This script sets-up the adjoint sensitivity forcing file for the
%  time averaged 37N transport during the 4D-Var analysis cycle.
%

% Define the prior circulation history file.

Inp='../I4DVAR/wc13_fwd_000.nc';

% Define the 37N section, over upper "depth" meters.

depth=-500.0;
jlat=21;
section=22:36;

gname='wc13_grd.nc';

[h]=nc_read(gname,'h');

Eradius=6371315.0;

lonr=nc_read(gname,'lon_rho'); lonr=lonr';
latr=nc_read(gname,'lat_rho'); latr=latr'; 
lonv=nc_read(gname,'lon_v');   lonv=lonv';
latv=nc_read(gname,'lat_v');   latv=latv';
lonu=nc_read(gname,'lon_u');   lonu=lonu';
latu=nc_read(gname,'lat_u');   latu=latu';

[Jm Im]=size(latr);
coslatv=zeros(Jm-1,Im);
for ib=1:Im,
  for jb=1:Jm-1,
    coslatv(jb,ib)=cos( latv(jb,ib)*pi/180 );
  end,
end,
dlonu=zeros(Jm-1,Im);
dlonupre=lonu(:,2:end)-lonu(:,1:end-1);
dlonu(:,2:end-1)=(dlonupre(2:end,:)+dlonupre(1:end-1,:))/2;
faclon=Eradius*coslatv.*(dlonu*pi/180);
facsverd=1./1e6; % nbr exact ?

nHIS=nc_read(Inp,'nHIS');
ntimes=nc_read(Inp,'ntimes');
facdt1=nHIS/ntimes;
  
clear f;
v='v';         
f=nc_read(Inp,v);
  
clear varr;
varr=zeros(size(f));
  
 
for it=1:size(f,4),

  if it==1 | it==size(f,4),
    facdt=0.5*facdt1;
  else,
    facdt=facdt1;
  end,
  
  clear z_w;
  [z_w]=depths(Inp,gname,5,0);
    
  nlevt=size(f,3);
    
  clear Hz;
  for k=1:nlevt
    Hz(:,:,k)=z_w(:,:,k+1)-z_w(:,:,k);
  end
    
  clear z_v;
  [z_v]=depths(Inp,gname,4,0);
    
  clear df;
    
  for k=1:nlevt,
    for i=section,
      if z_v(i,jlat,k) > depth
        fac=faclon(jlat,i)*facsverd;
        df=0.5*(Hz(i,jlat,k)+Hz(i,jlat-1,k));
        varr(i,jlat,k,it)=facdt*df*fac;
      end,
    end,
  end,
    
end,

% Create adjoint sensitivy NetCDF file.

Out='wc13_ads.nc';
unix('ncgen -b adsen.cdl');
  
% Write out information variables.

v='spherical';    f=nc_read(Inp,v);  s=nc_write(Out,v,f);
  
v='Vtransform';   f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='Vstretching';  f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='theta_s';      f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='theta_b';      f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='Tcline';       f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='hc';           f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='s_rho';        f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='s_w';          f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='Cs_r';         f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='Cs_w';         f=nc_read(Inp,v);  s=nc_write(Out,v,f);

v='h';            f=nc_read(Inp,v);  s=nc_write(Out,v,f);
  
v='lon_rho';      f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='lat_rho';      f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='lon_u';        f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='lat_u';        f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='lon_v';        f=nc_read(Inp,v);  s=nc_write(Out,v,f);
v='lat_v';        f=nc_read(Inp,v);  s=nc_write(Out,v,f);

% Write out adjoint sensitive scope arrays. Set same values as
% land/sea masking.

v='mask_rho';     f=nc_read(Inp,v);  s=nc_write(Out,'scope_rho',f);
v='mask_u';       f=nc_read(Inp,v);  s=nc_write(Out,'scope_u',f);
v='mask_v';       f=nc_read(Inp,v);  s=nc_write(Out,'scope_v',f);
  
% Write out zero state variables.

v='ocean_time';   f=nc_read(Inp,v);  s=nc_write(Out,v,f);
  
v='zeta';         f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='ubar';         f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='vbar';         f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='u';            f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='v';            f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='temp';         f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
v='salt';         f=nc_read(Inp,v);  s=nc_write(Out,v,zeros(size(f)));
  
% Over-write v-momentum sensitivity functional for the California
% Current System: sensitivity of meridional transport along 37N
% for the upper 500 m.

s=nc_write(Out,'v',varr);
  
