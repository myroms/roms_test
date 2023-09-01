%
% PLOT_OBS:  Plot 4D-Var observations
%

% git $Id$
%===========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.md                                                    %
%===========================================================================%

clear                                  % clear workspace
close all                              % close all figures

PRINT=1;                               % switch to save figures as PNG

LonMin=-134;                           % map left   longitude
LonMax=-116;                           % map right  longitude
LatMin=30;                             % map botton latitude
LatMax=48;                             % map top    latidude

xlab=LonMin:4:LonMax;                  % longitude labels
ylab=LatMin:4:LatMax;                  % latidude  labels

% Set input NetCDF file.

Obs='../Data/wc13_obs.nc';             % observations
Grd='../Data/wc13_grd.nc';             % grid file

% Read grid coordinates.

rlon=nc_read(Grd,'lon_rho');
rlat=nc_read(Grd,'lat_rho');

% Read in observations.

obs  =nc_read(Obs,'obs_value');         % observation values
label=nc_read(Obs,'obs_provenance');    % observation origin

Xobs =nc_read(Obs,'obs_Xgrid');         % fractional I-grid
Yobs =nc_read(Obs,'obs_Ygrid');         % fractional J-grid
Zobs =nc_read(Obs,'obs_depth');         % fractional K-grid

% Since we do not have the (lon,lat) for the observations in
% Obs file, interpolate from fractional grid locations.

[Lp,Mp]=size(rlon);
[Igrid,Jgrid]=meshgrid(0:Mp-1,0:Lp-1);

olon=interp2(Igrid,Jgrid,rlon,Yobs,Xobs);   % Notice (Yobs,Xobs)
olat=interp2(Igrid,Jgrid,rlat,Yobs,Xobs);   % because rotated
                                            % coordinates (origin)

% Sort by observation platform using label.

ind1=find(label==1);                        % SSH
ind2=find(label==2);                        % SST
ind3=find((label==3 | label==4 | label==6) ...
          & Zobs > 26);                     % in situ T
ind4=find((label==5 | label==7) ...
	  & Zobs > 26);                     % in situ S

% Set topography GEBCO palette.

Cpal = [-6000.0  -3500.0  -3000.0  -2500.0 -2000.0 ...
        -1500.0  -1000.0   -500.0   -200.0  -100.0 ...
          -50.0    -25.0    -10.0      0.0    50.0 ...
          100.0    200.0    300.0    400.0   500.0 ...
         1000.0   1500.0   2000.0   3000.0];

R = [0.07059 0.09020 0.07843 0.10588 0.11765 ...
     0.11373 0.10588 0.10980 0.10588 0.10588 ...
     0.14902 0.19216 0.41176 0.63137 0.76471 ...
     0.88627 0.87451 0.82745 0.74118 0.63922 ...
     0.60000 0.56078 0.52941 0.45882];

G = [0.03922 0.19216 0.35294 0.40784 0.44706 ...
     0.54510 0.64706 0.72157 0.80000 0.84706 ...
     0.87451 0.90196 0.94902 1.00000 0.81961 ...
     0.88235 0.76863 0.69804 0.58824 0.49804 ...
     0.46275 0.43137 0.40784 0.34510];

B = [0.23137 0.43529 0.54902 0.64314 0.70196 ...
     0.76863 0.82353 0.87843 0.92549 0.94510 ...
     0.94510 0.92549 0.91373 0.90196 0.31373 ...
     0.40000 0.36078 0.31765 0.18431 0.18431 ...
     0.16863 0.15294 0.14118 0.11373];

Cpal(1:13)=[];          % Remove water colors
R(1:13)=[];                               
G(1:13)=[];
B(1:13)=[];

% Set map projection.

m_proj('Mercator','long',[LonMin,LonMax],'lat',[LatMin,LatMax]);

% Set coastline database to intermidiate, and save it.

m_gshhs_i('save','wcoast');

% Convert observation locations to map coordinates.

[X,Y]=m_ll2xy(olon,olat);

% Plob observations. Draw a Mercator map using the m_map
% tools.

figure;

x=X(ind1); y=Y(ind1); f=obs(ind1);    % SSH observations

set(gca,'color',[.9 .99 1]);

m_usercoast('wcoast','patch',[0.25 0.25 0.25]);
m_grid('box','on','xtick',xlab,'xticklabels',xlab, ...
       'ytick',ylab,'yticklabels',ylab, ...
       'color','k','fontsize',10,'fontweight','bold');
hold on;

scatter(x,y,50,f,'d','filled');

colorbar('fontsize',10,'fontweight','bold');
title('Aviso SSH','fontsize',10,'fontweight','bold');

if (PRINT)
  print -dpng -r100 ssh_obs
end,

figure;

x=X(ind2); y=Y(ind2); f=obs(ind2);    % SST observations

set(gca,'color',[.9 .99 1]);

m_usercoast('wcoast','patch',[0.25 0.25 0.25]);
m_grid('box','on','xtick',xlab,'xticklabels',xlab, ...
       'ytick',ylab,'yticklabels',ylab, ...
       'color','k','fontsize',10,'fontweight','bold');
hold on;

scatter(x,y,50,f,'d','filled');

colorbar('fontsize',10,'fontweight','bold');
title('Blended SST','fontsize',10,'fontweight','bold');

if (PRINT)
  print -dpng -r100 sst_obs
end,


figure;

x=X(ind3); y=Y(ind3); f=obs(ind3);    % in situ T

set(gca,'color',[.9 .99 1]);

m_usercoast('wcoast','patch',[0.25 0.25 0.25]);
m_grid('box','on','xtick',xlab,'xticklabels',xlab, ...
       'ytick',ylab,'yticklabels',ylab, ...
       'color','k','fontsize',10,'fontweight','bold');
hold on;

scatter(x,y,80,f,'d','filled');

colorbar('fontsize',10,'fontweight','bold');
title('In Situ T','fontsize',10,'fontweight','bold');

if (PRINT)
  print -dpng -r100 t_obs
end,

figure;

x=X(ind4); y=Y(ind4); f=obs(ind4);    % in situ S

set(gca,'color',[.9 .99 1]);

m_usercoast('wcoast','patch',[0.25 0.25 0.25]);
m_grid('box','on','xtick',xlab,'xticklabels',xlab, ...
       'ytick',ylab,'yticklabels',ylab, ...
       'color','k','fontsize',10,'fontweight','bold');
hold on;

scatter(x,y,80,f,'d','filled');

colorbar('fontsize',10,'fontweight','bold');
title('In Situ S','fontsize',10,'fontweight','bold');

if (PRINT)
  print -dpng -r100 s_obs
end,

    
    
