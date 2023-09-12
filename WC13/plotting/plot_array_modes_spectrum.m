%
% PLOT_ARRAY_MODES_SPECTRUM:  Plot the eigenvalues spetrum of the
%                             preconditioned stabilized representer
%                             matrix
%

% git $Id$
%=========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                                                  %
%=========================================================================%

clear                                  % clear workspace

PRINT=true;                            % switch to save figure as PNG

% Set input NetCDF files
%
%   Inp:  RBL4D-Var file, Exercise 03

Inp='../RBL4DVAR/EX3_RPCG/wc13_mod.nc';

% Array modes inner loop eigenvector processed (Nvct in s4dvar.in)

Nvct = 10;

% Read in the eignevalue.

Ritz      =ncread(Inp,'cg_Ritz');             % Ritz eigenvalues
Ritz_error=ncread(Inp,'cg_RitzErr');          % Ritz eigenvalue error

nr=size(Ritz,1)-1;
x=[1:nr];

tsh=0.01*Ritz(nr);
xt=[1 nr];
yt=[tsh tsh];

% Plot EOF analysis variables.

figure

subplot(2,1,1)
plot(x,log10(Ritz(nr:-1:1)),'r','LineWidth',2)
hold on
plot(x,log10(Ritz(nr:-1:1)),'rs','LineWidth',1, ...
     'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
plot(x(Nvct),log10(Ritz(nr-Nvct)),'ks','LineWidth',1, ...
     'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',8);
plot(xt,log10(yt),'k--');
xlabel('inner-loop (i)')
ylabel('log_{10}(\lambda_i)')
xlim([1 nr])
title('Eigenvalues')

if (PRINT)
  png_file='plot_array_modes_eigenvalues.png';
  print(png_file, '-dpng', '-r300');
  if (exist('/opt/local/bin/convert'))
    unix(['/opt/local/bin/convert -verbose -crop 2015x845+159+33',      ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end
