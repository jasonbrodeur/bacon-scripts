%***********************************************************************
%The trees are 25 m tall.
%I would suggest for daytime sensible heat flux (H) of 300 W m-2,
%wind speed (u) of 2.5 m s-1 (ustar = 0.4 m s-1), air temperature (Ta) 23 C and relative humidity (RH) of 50%.
%For nighttime, H = -30 W m-2, u = 0.5 m s-1 (ustar = 0.1 m s-1), Ta = 13 C and RH = 60%.
%My quick rough calculation of L is for daytime -20 and for nighttime 3.
%measurement heights (zm) of 2, 4, 6  and 8 m above the tops of the trees?
%putting the tower on the east side of the southern 'operator select' area.
%assumig preveiling wind direction is 315 degree
%This leaves only about 250 m of fetch

%By Baozhang Chen
%
%May 27, 2009
%***********************************************************************

function footprint_SiteC

%  cd 'D:\Andy_FP';
%  path_out = 'D:\Andy_FP\outputs\';

%universal parameters:
% Definition of the grid over which the footprint phi is going to be  calculated
y_max = 1000;  %caution: make sure the x_max, y_max is same as that defined in footprint_kormann_and_meixner
x_max = 1000;
pix = 5;  %pix= d in footprint_kormann_and_meixner


% Definition of the grid over which the footprint phi is going to be
% calculated
x = [-x_max:pix:x_max];
y = [0:pix:y_max]; y = y(end:-1:1)';

M = length(x);  % pixels in x direction
N = length(y);  % pixels in y direction
x_x = x(ones(1,N),:);
y_y = y(:,ones(1,M));

% Rotate input matrix within a 1.5 times larger matrix. To call this
% function this time is for getting the size of retated matrix in order to
[B,TransferF] = footprint_rotate(x_x,y_y,x_x,0);%   this is the reference point for rotation B(6,6)=99

%%%%%%%%% Site C parameters %%%%%%%%%%%%%%%%%%%%%

h_c = 3; %canopy height in meter
z_m = 6; %EC sensor height in meter
z_0 = .1*h_c; %10% of h_c
d = 0.67*h_c;
p_bar = 98;

%daytime
u = 3; %in m/s_a
wd = 270; %in degree
T_a = 23; %air temperature at z_m in oC
RH = 50;  %air relative humidity at z_m in %
H = 100;  % sensible heat flux in w/m^2
LE = 400; %latent heat flux in w/m^2
sig_v = 0.2*u;
% % nighttime
% u = 1.5; %in m/s_a
% wd = 70; %in degree
% T_a = 13; %air temperature at z_m in oC
% RH = 80;  %air relative humidity at z_m in %
% H = -3;  % sensible heat flux in w/m^2
% LE = 0; %latent heat flux in w/m^2
% sig_v = 0.1*u; %first assumption
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ust,L] = calc_ustar_L(h_c, z_m, u, T_a, RH, p_bar, H, LE);
%ust = 80/500*u
%L = calc_monin_obhukov_L(ust,T_a,RH,p_bar,H,LE)
ust
L
[phi,f,D_y,xs,ys,param] = footprint_kormann_and_meixner_bob(z_0,z_m,u,ust,sig_v,L,y_max,x_max,pix);

% cal relative footprint function per pixe
sumphi = sum(abs(phi(:)));  %the following loop is for uniform the whole footprint area equals to 1
if sumphi ~= 0
    phi = phi/sumphi;   %relative footprint function; %unit:total=1
end
phi = flipud(phi);

% %% Jay's inserted stuff
% cumu_phi_nr = footcumsort(phi)*100;
% find(cumu_phi_nr > 90);
% 
% 

%%

% Rotate the matix of phi using new retating fuction
% with wind direction of alpha_rot_dgr = wd_cur:
alpha_rot_dgr = wd;
% Rotate input matrix within a 1.5 times larger matrix
[phi_rot,TransferF] = footprint_rotate(x_x,y_y,phi,alpha_rot_dgr); % call rotating function: this is the reference point for rotation B(6,6)=99

cumu_phi = footcumsort(phi_rot)*100;
%    save (fullfile (path_out,['Zm=',int2str(z_m), '=', int2str(H)]),'cumu_phi', '-v6');


Ax = TransferF.Ax;
Bx = TransferF.Bx;
x_off = TransferF.x_offset;
[n2,m2] = size(cumu_phi);
x_l = linspace(-pix*(TransferF.Bx+TransferF.x_offset),pix*(TransferF.Bx+TransferF.x_offset),m2);
x_l = x_l(ones(1,n2),:);
y_l = linspace(pix*(TransferF.By+TransferF.y_offset),-pix*(TransferF.By+TransferF.y_offset),n2)';
y_l = y_l(:,ones(1,m2));

%bob_fig_ini(['u=',int2str(u), 'H=', int2str(H)],100/70);
fig=0;
fig=fig+1;
figure(fig)
[Cd,hd] = contour(x_l, y_l, cumu_phi, [50,80,90]);

%    [Cd,hd] = contour(x_l,y_l,filtfilt(fir1(20,1e-2,'low'),1,cumu_phi),[10,20,40,60,70,80,90,95,99]);
%colorbar;
%clabel(Cd,hd,'manual')
xlim([-400 400]);ylim([-200 200])
clabel(cd,hd,'fontsize',8,'color','r','rotation',0)
hold on
h=line(0,0,...
    'marker','+','markeredgecolor','r','markerfacecolor','r');
set(1,'name','pcolor','numbertitle','off')
ylabel('Distance from tower S-N (m)','fontsize',12,'color','k' );
xlabel('Distance from tower W-E (m)','fontsize',12,'color','k');
set(gca,'FontSize',10)
set(gca,'DefaultTextFontName','Arial')
reg_line_str = sprintf('H = %3.3g \nLE = %3.3g',H,LE);
text(-270,8,reg_line_str);
%view(-90,90);
%set(gca,'ydir','rev')
%    pathfig = [path_out ['Zm=',int2str(z_m), 'H=', int2str(H)]];
%    print('-depsc',parthfig);
%    save (path_out,['u=',int2str(u), 'H=', int2str(H)]);
hold off

%        figure(2);
%        pcolor(x_l,y_l,log10(abs(phi_rot)));
%        caxis([-5 0]);
%        colormap jet;
%        shading flat;
%        colorbar;
%       h=line(0,0,...
%            'marker','+','markeredgecolor','w','markerfacecolor','w');
%        ylabel('Distance from tower S-N (m)');
%        xlabel('Distance from tower W-E (m)');
%        text(3100, -3100,'log(\phi)','FontSize',18);
%        hold off;
%        %hgsave (fullfile (path_out,[SiteId, yrId '_purefp']), '-v6');
%       %figtitle_yrd = [SiteId, yrId '_purefp'];
%       %pathfig_out_yrd = [path_out figtitle_yrd];
%      % hgsave (pathfig_out_yrd);
%      % print('-djpeg', pathfig_out_yrd);
