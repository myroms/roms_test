function  fig = soliton_movie(Dir, Vname, type, varargin)

% SOLITON_MOVIE:  Animates solition nested solution
%
% soliton_movie(Dir, Vname, type, Caxis, mytile)
%
% This function animate soliton nested application by ploting coarse
% and fine grid solutions.
%
% On Input:
%
%    Dir           Directory of ROMS NetCDF history files (string)
%
%    Vname         ROMS NetCDF variable name to process (string)
%
%    type          Input file prefix (string)
%                    type = 'avg'    => average file
%                    type = 'his'    => history file
%  
%    Caxis         Color axis bounds (optional; vector)
%
%    mytitle       Plot title (optional, string)
%
%    GIFname       GIT animation filename (optional; string)
%
% Example:
%
%   soliton_movie('r01','zeta','his',[0 0.16]) 
%   soliton_movie('r01','zeta','his',[Inf Inf],'FB AB3-AM4','zeta_fb.gif') 
%   soliton_movie('r01','ubar','his') 
%   soliton_movie('r01','rvorticity_bar','avg') 

% svn $Id: soliton_movie.m 1154 2023-02-17 20:52:30Z arango $
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                           Hernan G. Arango      %
%=========================================================================%

% Read in requested variable.
  
Cncname = strcat(Dir,'/soliton_',type,'_coarse.nc');
Fncname = strcat(Dir,'/soliton_',type,'_fine.nc');

G = grids_structure({Cncname, Fncname});

C = nc_read(Cncname, Vname);
F = nc_read(Fncname, Vname);

Ctime = nc_read(Cncname, 'ocean_time');
Ftime = nc_read(Fncname, 'ocean_time');

long_name = nc_getatt(Cncname, 'long_name', Vname); 

switch Vname
  case {'ubar'}
    CX = G(1).x_u;
    CY = G(1).y_u;
    FX = G(2).x_u;
    FY = G(2).y_u;
  case {'vbar'}
    CX = G(1).x_v;
    CY = G(1).y_v;
    FX = G(2).x_v;
    FY = G(2).y_v;
  case {'zeta'}
    CX = G(1).x_rho;
    CY = G(1).y_rho;
    FX = G(2).x_rho;
    FY = G(2).y_rho;
  case {'rvorticity_bar'}
    CX = G(1).x_psi;
    CY = G(1).y_psi;
    FX = G(2).x_psi;
    FY = G(2).y_psi;
end

Cmin = min(C(:));   Cmax = max(C(:));
Fmin = min(F(:));   Fmax = max(F(:));

switch numel(varargin)
  case 0
    Caxis   = [Cmin Cmax];
    mytitle = long_name;
    GIFname=strcat(Vname, '.gif');
  case 1
    Caxis   = varargin{1};
    mytitle = long_name;
    GIFname=strcat(Vname, '.gif');
  case 2
    Caxis   = varargin{1};
    mytitle = [long_name, ':', blanks(4), varargin{2}];
    gif_name=strcat(Vname, '.gif');
  case 3
    Caxis   = varargin{1};
    mytitle = [long_name, ':', blanks(4), varargin{2}];
    GIFname = varargin{3};
end

if (isinf(Caxis(1)))
  Caxis(1)=Cmin;
end
if (isinf(Caxis(2)))
  Caxis(2)=Cmax;
end

%--------------------------------------------------------------------------
%  Create animation.
%--------------------------------------------------------------------------


fig=figure;

% Plot initial frame

subplot(211)
pcolorjw(CX, CY, squeeze(C(:,:,1)));
hold on;
plot(G(2).x_perimeter, G(2).y_perimeter, 'r-', 'LineWidth',2);
hold off
Ax=axis;
colorbar;
caxis(Caxis);
set(gca,'xlim',[-2 50])
if ~(isempty(mytitle))
  title(mytitle)
end
Cmin=min(min(squeeze(C(:,:,1))));
Cmax=max(max(squeeze(C(:,:,1))));
xlabel(['Min = ', num2str(Cmin), blanks(4), 'Max = ', num2str(Cmax)]);

subplot(212)
pcolorjw(FX, FY, squeeze(F(:,:,1)));
colorbar;
caxis(Caxis);
set(gca, 'Xlim', [-2 50]);
Fmin=min(min(squeeze(F(:,:,1))));
Fmax=max(max(squeeze(F(:,:,1))));
xlabel(['Min = ', num2str(Fmin), blanks(4), 'Max = ', num2str(Fmax)]);

frame = getframe(fig); 
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256); 

% Write to the GIF File. 

count = 1;
imwrite(imind, cm, GIFname, 'gif', 'Loopcount', inf); 

% Plot the rest of the time frames.

for rec=2:length(Ctime)

  count=count+1;

  subplot(211)
  pcolorjw(CX, CY, squeeze(C(:,:,rec)));
  hold on;
  plot(G(2).x_perimeter, G(2).y_perimeter, 'r-', 'LineWidth',2);
  hold off
  colorbar;
  caxis(Caxis)
  set(gca,'xlim',[-2 50])
  if ~(isempty(mytitle))
    title(mytitle)
  end
  Cmin=min(min(squeeze(C(:,:,rec))));
  Cmax=max(max(squeeze(C(:,:,rec))));
  xlabel(['Min = ', num2str(Cmin), blanks(4), 'Max = ', num2str(Cmax)]);

  subplot(212)
  pcolorjw(FX, FY, squeeze(F(:,:,rec)));
  colorbar;
  caxis(Caxis)
  set(gca,'xlim',[-2 50])
  Fmin=min(min(squeeze(F(:,:,rec))));
  Fmax=max(max(squeeze(F(:,:,rec))));
  xlabel(['Min = ', num2str(Fmin), blanks(4), 'Max = ', num2str(Fmax)]);

  drawnow
  pause(0.5)

  frame = getframe(fig); 
  im = frame2im(frame); 
  [imind,cm] = rgb2ind(im,256); 

  imwrite(imind, cm, GIFname, 'gif', 'WriteMode', 'append'); 
end

return
