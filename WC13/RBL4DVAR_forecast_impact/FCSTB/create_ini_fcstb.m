% This script creates the initial condition file for a forecast initialized
% from the previous RBL4D-Var background solution (EXE_RPCG) forward file
% "wc13_fwd_000.nc".

%  git $Id$
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                                                  %
%=========================================================================%

clear all

Inp='../../RBL4DVAR/EX3_RPCG/wc13_fwd_000.nc';
Out='wc13_ini.nc';

% First copy ../../Data/wc13_ini_template.nc into wc13_ini.nc.

unix(['cp ../../Data/wc13_ini_template.nc ' Out]);

disp(' ');
disp(['Creating and processing: ', Out]);
disp(' ');

% Now determine the last record from the 4D-Var background forward file.

ocean_time=nc_read(Inp,'ocean_time');
nrec=size(ocean_time,1);

s=nc_write(Out,'ocean_time',ocean_time(nrec));

% Read and write state fields from last recored "nrec" of the forward
% file.

Vstate = {'zeta', 'ubar', 'vbar', 'u', 'v', 'temp', 'salt'};

for var = Vstate
  v = char(var);
  f = nc_read (Inp, v, nrec);
  s = nc_write(Out, v, f);
end
