% 
%  ECOSIM_OPTICS: Plots EcoSim optical diagnostics for BIO_TOY
%

% git $Id$
%=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                            Hernan G. Arango      %
%=========================================================================%

Dname = 'roms_dia.nc';

PRINT   = true;     % save PNG files
CONVERT = true;     % use ImageMagic convert utility

% Set reading parameters

I = 3;
J = 3;
K = 30;             % surface level
T = 101;            % starting time record
dt = 100 ;          % time records stride

start4  = [I J 1 T];
count4  = [1 1 Inf Inf];
stride4 = [1 1 1 dt];

start5  = [I J K 1 T];
count5  = [1 1 1 Inf Inf];
stride5 = [1 1 1 1 dt];

time = ncread(Dname, 'ocean_time', T, Inf, dt)./86400;
wavelength = ncread(Dname, 'light');        

Nrec   = length(time);
Nbands = length(wavelength);

% Read in diagnotic data.

sur_irr = squeeze(ncread(Dname, 'surface_irradiance',                   ...
                  start4, count4, stride4));
dwn_irr = squeeze(ncread(Dname, 'downward_irradiance',                  ...
                  start5, count5, stride5));
sca_irr = squeeze(ncread(Dname, 'scalar_irradiance',                    ...
                  start5, count5, stride5));
lig_att = squeeze(ncread(Dname, 'light_attenuation',                    ...
                  start5, count5, stride5));
lig_cos = squeeze(ncread(Dname, 'light_cosine',                         ...
                  start5, count5, stride5));
phy_abs = squeeze(ncread(Dname, 'Phy_absorption',                       ...
                  start5, count5, stride5));
det_abs = squeeze(ncread(Dname, 'detrital_absorption',                  ...
                  start5, count5, stride5));
cdc_abs = squeeze(ncread(Dname, 'CDC_absorption',                       ...
                  start5, count5, stride5));
phy_bck = squeeze(ncread(Dname, 'Phy_backscattering',                   ...
                  start5, count5, stride5));
phy_sca = squeeze(ncread(Dname, 'Phy_scattering',                       ...
                  start5, count5, stride5));
tot_bck = squeeze(ncread(Dname, 'total_backscattering',                 ...
                  start5, count5, stride5));
tot_sca = squeeze(ncread(Dname, 'total_scattering',                     ...
                  start5, count5, stride5));

% Plot diagnotic fields.

X = repmat(wavelength, [1,Nrec]);
Y = repmat(time', [Nbands,1]);

label=strcat({'Day '},num2str(fix(time)));
units='$$\mu\hbox{M}\,\,\hbox{m}^{-2}\,\,\hbox{s}^{-1}\,\,\hbox{nm}^{-1}$$';

figure;
plot(X,sur_irr,'LineWidth',2);
grid on;
title('Surface Spectral Light Irradiance');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel(units, 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'SpecIrr.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,lig_cos,'LineWidth',2);
grid on;
title('Underwater Light Average Cosine');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('Spectral Average Cosine', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'LightCosine.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,sca_irr,'LineWidth',2);
grid on;
title('Scalar Spectral Light Irradiance');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel(units, 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'ScalarIrr.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,dwn_irr,'LineWidth',2);
grid on;
title('Spectral Downward Light Irradiance');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\mu\hbox{M}\,\,\hbox{m}^{-2}\,\,\hbox{s}^{-1}\,\,\hbox{nm}^{-1}$$', ...
       'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'DownIrr.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,lig_att,'LineWidth',2);
grid on;
title('Diffuse Light Attenuation');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'LightAtt.png';
  print(png_file, '-dpng', '-r300');
  unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',             ...
        ' +repage ', png_file, blanks(1), png_file]);
end

figure;
plot(X,phy_abs,'LineWidth',2);
grid on;
title('Phytoplankton Optical Absoption');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'PhyAbs.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,cdc_abs,'LineWidth',2);
grid on;
title('CDOM Optical Absoption');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'CDCabs.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,det_abs,'LineWidth',2);
grid on;
title('Detrital Optical Absoption');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'DetAbs.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,phy_sca,'LineWidth',2);
grid on;
title('Phytoplankton Optical Scattering');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'PhySca.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,phy_bck,'LineWidth',2);
grid on;
title('Phytoplankton Optical Backscattering');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'PhyBck.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,tot_sca,'LineWidth',2);
grid on;
title('Total Optical Scattering');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'TotalSca.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end

figure;
plot(X,tot_bck,'LineWidth',2);
grid on;
title('Total Optical Backscattering');
xlabel('Wavelength of Light (nm)', 'FontSize',12, 'FontWeight', 'bold');
ylabel('$$\hbox{m}^{-1}$$', 'Interpreter', 'latex', 'FontSize', 12)
legend(label, 'Location', 'best')
if (PRINT)
  png_file = 'TotalBck.png';
  print(png_file, '-dpng', '-r300');
  if (CONVERT)
    unix(['/opt/local/bin/convert -verbose -crop 2056x1653+128+55',     ...
          ' +repage ', png_file, blanks(1), png_file]);
  end
end
