%
%  This script sets-up the adjoint sensitivity forcing file for the
%  time averaged 37N transport during the 4D-Var analysis cycle.
%  A veryifying analysis is used as a surrogate for the truth.
%

clear all

% Forecast averaging interval (number of history file record per day).

nAVG=1;

% Define the forecast and verifying analysis history files.

InpAT='../RBL4DVAR_forecast_impact/FCSTAT/wc13_fwd.nc';
InpA ='../RBL4DVAR_forecast_impact/FCSTA/wc13_fwd.nc';
InpB ='../RBL4DVAR_forecast_impact/FCSTB/wc13_fwd.nc';
InpVA='../Data/RBL4DVAR_VERIFYING_ANALYSIS/wc13_fwd_001.nc';

% Define the 37N section, over upper "depth" meters.

depth=-500.0;
jlat=21;
section=22:36;

Gname='../Data/wc13_grd.nc';

[h]=ncread(Gname,'h');

Eradius=6371315.0;

lonr=ncread(Gname,'lon_rho'); lonr=lonr';
latr=ncread(Gname,'lat_rho'); latr=latr'; 
lonv=ncread(Gname,'lon_v');   lonv=lonv';
latv=ncread(Gname,'lat_v');   latv=latv';
lonu=ncread(Gname,'lon_u');   lonu=lonu';
latu=ncread(Gname,'lat_u');   latu=latu';

[Jm Im]=size(latr);
coslatv=zeros(Jm-1,Im);
for ib=1:Im
  for jb=1:Jm-1
    coslatv(jb,ib)=cos( latv(jb,ib)*pi/180 );
  end
end
dlonu=zeros(Jm-1,Im);
dlonupre=lonu(:,2:end)-lonu(:,1:end-1);
dlonu(:,2:end-1)=(dlonupre(2:end,:)+dlonupre(1:end-1,:))/2;
faclon=Eradius*coslatv.*(dlonu*pi/180);
facsverd=1./1e6; % nbr exact ?

nHIS=ncread(InpA,'nHIS');
ntimes=ncread(InpA,'ntimes');
%facdt1=nHIS/ntimes;
facdt1=1/nAVG;
  
clear f;
v='v';         
fAT=nc_read(InpAT,v);
fA=nc_read(InpA,v);
fB=nc_read(InpB,v);
fVA=nc_read(InpVA,v);
  
clear varr;
varr=zeros(size(fA));
  
 
for it=(size(fA,4)-nAVG):size(fA,4)

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

dJAT=nansum(nansum(nansum(nansum(varr.*(fAT-fVA),1),2),3),4);
dJA=nansum(nansum(nansum(nansum(varr.*(fA-fVA),1),2),3),4);
dJB=nansum(nansum(nansum(nansum(varr.*(fB-fVA),1),2),3),4);

deAT=dJAT*dJAT-dJB*dJB
deA=dJA*dJA-dJB*dJB

