% It plots the free-surface solution for the SHOREFACE Test
% for a north-south periodic channel that includes a linear
% sloping shore on its eastern boundary, and it is forced
% with waves from a Wave Model.

Hname = 'roms_his.nc';

zeta = nc_read(Hname, 'zeta');
h    = nc_read(Hname, 'h');
x    = nc_read(Hname, 'x_rho');

% Extract solution at j=5 and record=8.

j   = 5;
rec = 8;

ssh = squeeze(zeta(:,j,rec));
hs  = -squeeze(h(:,j));
xs  = squeeze(x(:,j));

zmin = min(hs);
yhs  = [zmin hs' zmin];
xhs  = [xs(1) xs' xs(end)];

figure;

fill(xhs, yhs, [0.6 0.7 0.6]);
axis tight;
hold on;
plot (xs, ssh, 'r-');
hold off;

title('Shoreface Test: WEC Vortex Force');
xlabel('x (m)');
ylabel('depth (m)');
legend('bathymetry', 'SSH', 'location', 'NorthWest');

