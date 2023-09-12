%
% PLOT_OP:  Plots specified Optimal Perturbations eigenvector
%

% git $Id$
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                                                  %
%=========================================================================%

 TLMname='channel_tlm.nc';    % single OP file

 MULTIPLE=false;              % process a single OP file
%MULTIPLE=true;               % process multiple files

 NEV=4;                       % eingenvector to process

 NC=8;                        % number of contours
 
% Read in Optimal Perturbations data.

Xr=nc_read(TLMname,'x_rho');
Yr=nc_read(TLMname,'y_rho');

Xr=Xr./1000;
Yr=Yr./1000;

D.zeta=nc_read(TLMname, 'zeta');
D.temp=nc_read(TLMname, 'temp');

Nsur=size(D.temp,3);

% Extract initial and final values.

if (MULTIPLE),
  Rini=1;
  Rend=2;
else
  Rend=2*NEV;
  Rini=Rend-1;
end

D.Zini=squeeze(D.zeta(:,:,Rini));
D.Zend=squeeze(D.zeta(:,:,Rend));

D.Tini=squeeze(D.temp(:,:,Nsur,Rini));
D.Tend=squeeze(D.temp(:,:,Nsur,Rend));

% Set color axis for all figures.

CiniZ=[realmax realmin];
CendZ=[realmax realmin];
CiniT=[realmax realmin];
CendT=[realmax realmin];

CiniZ(1)=min(CiniZ(1), min(D.Zini(:)));
CiniZ(2)=max(CiniZ(2), max(D.Zini(:)));
CendZ(1)=min(CiniZ(1), min(D.Zend(:)));
CendZ(2)=max(CiniZ(2), max(D.Zend(:)));

CiniT(1)=min(CiniT(1), min(D.Tini(:)));
CiniT(2)=max(CiniT(2), max(D.Tini(:)));
CendT(1)=min(CiniT(1), min(D.Tend(:)));
CendT(2)=max(CiniT(2), max(D.Tend(:)));

% Plot initial and final perturbations.

figure;
  
h1=subplot(2,2,1);
contourf(Xr,Yr,D.Zini,NC);
colorbar; caxis(CiniZ);
grid on;
title('zeta initial');
xlabel('Km'); ylabel('Km');

h2=subplot(2,2,2);
contourf(Xr,Yr,D.Zend,NC);
colorbar; caxis(CendZ);
grid on;
title('zeta final');
xlabel('Km'); ylabel('Km');

h3=subplot(2,2,3);
contourf(Xr,Yr,D.Tini,NC);
colorbar; caxis(CiniT);
grid on;
title('temp initial');
xlabel('Km'); ylabel('Km');

h4=subplot(2,2,4);
contourf(Xr,Yr,D.Tend,NC);
colorbar; caxis(CendT);
grid on;
title('temp final');
xlabel('Km'); ylabel('Km');

eval(['print -dpng -r300 ' strcat('channel_eigen',num2str(NEV),'.png')])
