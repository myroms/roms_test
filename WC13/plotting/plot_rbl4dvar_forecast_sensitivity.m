%
% PLOT_RBL4DVAR_FCST_SENSITIVITY:  Plots forecast observation sensitivity
%

% git $Id$
%=========================================================================%
%  Copyright (c) 2002-2024 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                                                  %
%=========================================================================%

clear                                  % clear workspace

% Forecast averaging interval (number of history file record per day).
% Must be the same value used in Data/adsen_37N_transport_fcst.m.

nAVG=1;

PRINT=true;                            % switch to save figure as PNG

% Set input NetCDF files.
%
%   InpA:    Forecast from anlysis
%   InpB:    Forecast from background
%   InpVA:   Veryfying analysis
%   Obs:     Observation file
%   Mod:     RBL4D-Var impact file
%   NLmod:   RBL4D-Var file
%
%   Gname:   Application GRID NetCDF file

InpA='../RBL4DVAR_forecast_sensitivity/FCSTA/wc13_fwd.nc';
InpB='../RBL4DVAR_forecast_sensitivity/FCSTB/wc13_fwd.nc';
InpVA='../Data/RBL4DVAR_VERIFYING_ANALYSIS/wc13_fwd_001.nc';
Obs  ='../Data/wc13_obs.nc';
Mod  ='../RBL4DVAR_forecast_sensitivity/Case1/wc13_mod.nc';
NLmod='../RBL4DVAR/EX3_RPCG/wc13_mod.nc';

Gname='../Data/wc13_grd.nc';

% First compute the transport weights for the forecast metric.
% (Define the 37N section, over upper "depth" meters)

depth=-500.0;
jlat=21;
section=22:36;

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

nHIS=nc_read(InpA,'nHIS');
ntimes=nc_read(InpA,'ntimes');
%facdt1=nHIS/ntimes;
facdt1=1/nAVG;
  
clear f;
v='v';         
fA=nc_read(InpA,v);
fB=nc_read(InpB,v);
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

% Compute the forecast error metrics

dJA=nansum(nansum(nansum(nansum(varr.*(fA-fVA),1),2),3),4);
dJB=nansum(nansum(nansum(nansum(varr.*(fB-fVA),1),2),3),4);

eA=dJA*dJA;
eB=dJB*dJB;

% Now compute the change in the error metric

de=eA-eB;                  % actual change in error metric

% Read observations variables.

obs  =ncread(Obs,'obs_value');            % observation values
type =ncread(Obs,'obs_type');             % state variable flag
label=ncread(Obs,'obs_provenance');       % observation origin

% Read observation sensitivity.

sen  =ncread(Mod,'ObsSens_total');        % total

% Read observation scale (bounded observations, scale=1).

scale=ncread(NLmod,'obs_scale');

% Read NL model values in observation space.

NLM=ncread(NLmod,'NLmodel_initial');

% Compute the innovation vector.

innov=(obs-NLM).*scale;

% Sort by observation platform using label.

ind1=find(label==1);      % SSH
ind2=find(label==2);      % SST
ind3=find(label==3);      % T XBT
ind4=find(label==4);      % T CTD
ind5=find(label==5);      % S CTD
ind6=find(label==6);      % T Argo
ind7=find(label==7);      % S Argo

% Compute total sensitivity.

totimp=sum(sen  .*innov,1);

timp1=sum(sen(ind1).*innov(ind1),1);
timp2=sum(sen(ind2).*innov(ind2),1);
timp3=sum(sen(ind3).*innov(ind3),1);
timp4=sum(sen(ind4).*innov(ind4),1);
timp5=sum(sen(ind5).*innov(ind5),1);
timp6=sum(sen(ind6).*innov(ind6),1);
timp7=sum(sen(ind7).*innov(ind7),1);

% Check.

timp=timp1+timp2+timp3+timp4+timp5+timp6+timp7;

% Plot observation sensitivity.

figure;

fonts=10;

subplot(3,1,1);
dn=[length(obs) length(ind1) length(ind2) length(ind3) length(ind4) ...
                length(ind5) length(ind6) length(ind7)];
b1=bar(dn,'r');
Y=b1.YData;
text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center');
grid on;
MyLabel={'Nobs','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('N_{obs}');
title('RBL4D-Var Observation Sensitivity');

subplot(3,1,2);
d2=[de totimp timp1 timp2 timp3 timp4 timp5 timp6 timp7];
b2=bar(d2,'b');
grid on;
MyLabel={'NL de','TL de','SSH','SST','T XBT','T CTD','S CTD','T Argo','S Argo'};
set(gca,'XTickLabel',MyLabel,'FontSize',fonts);
ylabel('\Delta e');

if (PRINT)
  png_file='plot_rbl4dvar_forecast_sensitivity.png';
  print(png_file, '-dpng', '-r300');
  if (exist('/opt/local/bin/convert','file'))
    unix(['/opt/local/bin/convert -verbose -crop 2100x1132+100+45',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end 
end
