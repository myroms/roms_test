function plt_floats(Hname, Fname);

%
% PLT_FLOATS:  Reads and plots Lagrangian trajectories
%
% plt_floats(Hname, Fname)
%
% This routine read floats NetCDF file and plots Lagrangian
% trajectories.
%
% On Input:
%
%    Hname       NetCDF history file name (character string)
%    Fname       NetCDF floats  file name (character string)
%
% On Output:
%
%    floats.flc  Animation file for Lagrangian trajectory
%

% svn $Id: plt_floats.m 1154 2023-02-17 20:52:30Z arango $
%===========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                           Hernan G. Arango        %
%===========================================================================%

if (nargin < 1),
  Hname='roms_his.nc';
  Fname='roms_flt.nc';
end,

PPM_MOVIE = 0; 

%---------------------------------------------------------------------
%  Read in domain data. 
%---------------------------------------------------------------------

spherical=nc_read(Hname,'spherical');

if (spherical),
  Xr=nc_read(Hname,'lon_rho');
  Yr=nc_read(Hname,'lat_rho');
else,  
  Xr=nc_read(Hname,'x_rho').*0.001;
  Yr=nc_read(Hname,'y_rho').*0.001;
end,  
  
rmask=ones(size(Xr));
[vname,nvars]=nc_vname(Hname);
for n=1:nvars,
  name=deblank(vname(n,:));
  switch (name)
    case 'mask_rho'
      rmask=nc_read(Hname,name);
  end,
end,

%---------------------------------------------------------------------
%  Read in floats data. 
%---------------------------------------------------------------------

spval=0.9e+35;

time=nc_read(Fname,'ocean_time');
time=time./86400;

if (spherical),
  xfloat=nc_read(Fname,'lon');
  yfloat=nc_read(Fname,'lat');
else,  
  xfloat=nc_read(Fname,'x').*0.001;
  yfloat=nc_read(Fname,'y').*0.001;
end,  
[nf,nt]=size(xfloat);

ind=find(xfloat > spval);
if (~isempty(ind)),
  xfloat(ind)=NaN;
  yfloat(ind)=NaN;
end,

%---------------------------------------------------------------------
%  Draw trajectories.
%---------------------------------------------------------------------

if (PPM_MOVIE),

  fig=figure;

  axis manual
  set(gca,'nextplot','replacechildren');
 
  for n=1:nt,

    pcolorjw(Xr,Yr,rmask);
    colormap([0 0 0; 1 1 1]);
    title(['Time = ',num2str(time(n),'%10.5f'), '  days']);
    hold on;
  
    h=plot(xfloat(:,n),yfloat(:,n),'ro');
%   set(h(1),'markersize',5)
    hold off;
  
    F(n)=getframe(fig);

    outfile=sprintf('floats%3.3d.ppm',n);
  
    print('-dppmraw', outfile);
  
  end,

  nx=560;           % Size of default Matlab window
  ny=480;

  movie_file='floats.flc';
  eval('!ls floats???.ppm > allppm.list');
  eval(['!/bin/rm -v ' movie_file]);
  cmd=['!ppm2fli -g ' int2str(nx) 'x' int2str(ny)];
  cmd=[cmd  ' -N allppm.list ' movie_file];
  eval(cmd);
  unix('/bin/rm -v allppm.list');
  unix('/bin/rm -v *.ppm');
  
else,

  fig=figure;
  aviobj=avifile('floats.avi');
  
  for n=1:nt,

    pcolorjw(Xr,Yr,rmask);
    colormap([0 0 0; 1 1 1]);
    title(['Time = ',num2str(time(n),'%10.5f'), '  days']);
    hold on;
  
    h=plot(xfloat(:,n),yfloat(:,n),'ro');
%   set(h(1),'markersize',5)
    hold off;

    F=getframe(fig);

    aviobj=addframe(aviobj,F);
  
  end,
  close(fig);
  aviobj=close(aviobj);

end,

