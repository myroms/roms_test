%
% PLOT_EOF_EIGENVALUES:  Plot the eigenvalues for each EOF of
%                        the analysis error covariance matrix,
%                        and the randomized trace estimates
%

% git $Id$
%===========================================================================%
%  Copyright (c) 2002-2023 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.md                                                    %
%===========================================================================%

clear                                  % clear workspace
close all                              % close all figures

PRINT=0;                               % switch to save figure as PNG

% Set input NetCDF files

%Inp='../RBL4DVAR/wc13_hss.nc';            % RBL4D-Var EOF stored in Hessian file
 Inp='../R4DVAR/wc13_hss.nc';          % R4D-Var EOF stored in Hessian file

% Read in error covariance EOF analysis variables.

Ritz      =nc_read(Inp,'Ritz');            % Ritz eigenvalues
Ritz_error=nc_read(Inp,'Ritz_error');      % Accuracy of Ritz eigenvalues
ae_trace  =nc_read(Inp,'ae_trace');        % error covariance matrix trace

% Plot EOF analysis variables.

figure

subplot(3,1,1)
plot(Ritz,'r','LineWidth',2)
xlabel('EOF number (i)')
ylabel('\lambda_i')
title('Eigenvalues')

subplot(3,1,2)
plot(log10(Ritz_error),'b','LineWidth',2)
xlabel('EOF number (i)')
ylabel('log_{10}(\epsilon_i)')
title('Eigenvalue Error')

subplot(3,1,3)
plot(ae_trace(2:end),'k','LineWidth',2)
xlabel('Randomized Sample Number')
ylabel('Tr(E^a)')
title('Randomized Trace Estimates')

if (PRINT),
  print -r300 -dpng plot_eof_eigenvalues.png
end,
