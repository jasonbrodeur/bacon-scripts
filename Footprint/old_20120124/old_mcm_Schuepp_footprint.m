% function [] = mcm_Schuepp_footprint(data, year_start, year_end, Ustar_th, xf_use)

%% mcm_Schuepp_footprint.m 
%%% Footprint data filtering program:
%%% This program uses the Scheupp analytical footprint model to estimate
%%% the radial distance from which a specified percentage of the measured
%%% flux is coming from (e.g. ground distance (m) in which 70% of the
%%% measured flux comes from).  
% Inputs:
% data - input data structure
% year_start - start year for calculation
% year_end - end year for calculation
% Ustar_th - u* threshold
% xf_use - fraction of flux within footprint considered acceptable


%%%%%%%%%%%%%%%%%% Details of Obukhov Length Calculation %%%%%%%%%%%%%%%%%%
% Atmospheric Stability by The Obukhov Length. 
% AMS reference:
% http://amsglossary.allenpress.com/glossary/search?id=obukhov-length1
% The Obukhov length, L = -(Tv*ustar^3)/(K*g*Qv)
% where k is von K�rm�n's constant, u* is the friction velocity (a measure
% of turbulent surface stress), g is gravitational acceleration (m/s2), 
% Tv is virtual temperature in deg K 
% Qv is a kinematic virtual temperature flux at the surface in K.m/s.
% Qv = H/(roh*Cp) where H is sensible heat flux in W/m2 or J/s.m2
% Tv = (1 + 0.61 rv)*Ta in deg K
% rv = (0.622*e)/(P-e) is mixing ratio
%%% Following Garrett, 1992 (Page 38) 
% L = - (roh*Cp*Ta*ustar^3)/(K*g*H)
% where H is in J/s.m2 (W/m2)
% Ta is degree K
%%% At a given height z above a surface, 
% (z-d)/L = 0 for statically neutral stability, 
% (z-d)/L is positive for stable atmosphere in a typical range of 1 to 5 
% (z-d)/L is negative for unstable atmosphere in a typical range of -5 to 
% -1 stratification.
% (z-d)/L is typically -1 to -2 over tall forests 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isfield(data,'site');
%  site = data.site;   
% else  
%     site = input('Please input site name (e.g. ''TP39''): ','s');
% end


%%% Test of wind roses -- remove
% ctr = 1;
% for yr_ctr = year_start:1:year_end
% figure(ctr);clf;
% % subplot(3,3,ctr);
% ind(ctr).out = find(data.Year == yr_ctr & ~isnan(data.W_Dir.*data.WS));
% % h1 = figure('Name', 'Wind Rose'); clf
% jjb_wind_rose(data.W_Dir(ind(ctr).out), data.WS(ind(ctr).out));
% title(num2str(yr_ctr));
%     
% ctr = ctr + 1;
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for yr_ctr = year_start:1:year_end
function [xcorrm, xcorrhs, xf_m, xf_h, L2, zL] = mcm_Schuepp_footprint(u, ustar, H, Ta, RH, APR, z, h, zanm)
%%% Get height information from parameter file:
% [Heights] = params(yr_ctr, site, 'Heights');
%%%% Vegetation heights
% hcan = Heights(1,2);    % vegetation height (m)
d    = h*2/3;        % displacemeny height (m)
z0   = h*0.1;        % roughness heigh (m)
% zm = z - d;
%%% Measurement heights:
if nargin == 8
    disp('Assuming that anemometer (zanm) and EC equipment (z) at same height');
 zanm = z;    % anemometer and EC equipment at the same height (m)
 u_extrap_flag = 0;
else
u_extrap_flag = 1;    
end
% z    = Heights(1,1);    % flux instrument height at proposed 20m tower (m)
%%% Constants:
roh = 1.293;  % Kg/m3 at a temperature of 273 K and a pressure of 101.325 kPa.
k    = 0.41;      % von Karmn constant
Cp   = 1012;      % Cp in Jkg/degK
g    = 9.81;      % m/s2
%%% Get Sector Information:
% [fetch] = params(yr_ctr, site, 'Fetch');
%%% Get meteorological information:
% ta       = data.Ta(data.Year == yr_ctr);   % air temperature (oC)
% hs       = data.H(data.Year == yr_ctr);   % sensibel heat flux (W/m2)
% uavg     = data.WS(data.Year == yr_ctr);   % windspeed (m/s)
% windd    = data.W_Dir(data.Year == yr_ctr);   % Wind direction (deg)
% ustar = data.Ustar(data.Year == yr_ctr);   % friction velocity, u* (m/s)
% RH  = data.RH(data.Year == yr_ctr);   % relative humidity
% APR   = data.APR(data.Year == yr_ctr);   % atmospheric pressure (kPa)
% par = data.PAR(data.Year == yr_ctr);    % incoming solar radiation (umolm-2s-1)
%%% Calculate any information if necessary:
% [windd_math_rad] = CSWind2Polar(windd,'rad'); % Converts wind dir into mathematical notation + radians
% [windd_math_deg] = CSWind2Polar(windd,'deg'); % Converts wind dir into mathematical notation + degrees
% ustr     = ustr_obs;                        % Use observed ustar values if available
ustar_cal = (k*u)/(log((zanm-d)/z0));     % Compute friction velocity, to fill missing
ustar(isnan(ustar)) = ustar_cal(isnan(ustar));  % Fill in gaps in measured with modeled
[e,ea] = vappress(Ta, RH);                  % Convert HMP RH to vap. pressures 
                                            % [e - vapour pressure (kPa); ea - saturation vapour pressure (kPa)]
rv     = (0.622.*e)./(APR-e);                 % water vapour mixing ratio
tv     = (1+0.61.*rv).*(Ta+273.15);         % converts Ta to virtual temperature (in deg K)
L  = -1.*(roh*Cp.*tv.*ustar.^3)./(k*g.*H);     % Obukhov Length (in meters) 
zL = (z-d)./L;                              % (z/L stability parameter)

% Velocity at proposed flux instrumentation height 
% u_extrap = abs(ustar/k)*log((z-d)/z0);
% Calculate average wind velocity used in the model
uavg_mod = ustar*(log((z-d)/z0)-1+(z0/(z-d)))/(k*(1-(z0/(z-d))));

if u_extrap_flag == 1
uavg = uavg_mod;
else
uavg = u;
uavg(isnan(uavg)) = uavg_mod((isnan(uavg)));   
end
 

% Correction factors
gama = 0.0646 + Ta.*(6.1).^5;
kt   = Ta + 237.3;
slop = ((2503*2.718).^((17.269.*Ta)./kt))./(kt).^2;
br   = gama./slop;
roh  = 1.292 - 0.00428.*Ta;
%%% A second calculation of the Obukhov length:
L2 = -(((ustar).^3).*roh.*Cp.*(Ta+273.15))./(k.*g.*H.*(1 + (0.07./br)));
fim  = abs((1-(16*(z-d)./L2)).^-0.25);
fihs = abs((1-(16*(z-d)./L2)).^-0.5);

% Calculate Xmax, distance where maximum flux originates
xmax    = (uavg./ustar).*((z-d)/(2*k));
xcorrm  = fim .* xmax;
xcorrhs = fihs .* xmax;
%%% Convert values to real numbers:
% xcorrhs_real = real(xcorrhs);
% xcorrm_real = real(xcorrm);

% Calculate the upwind distance from which 40-90% of the measured flux
% comes from
ctr_xf = 1;
for xf_pct = 0.5:0.05:0.95
% Distance at which the cumulative flux density is equal to a fraction (80%) of total
xfrac(:,ctr_xf)   = (-1/log(xf_pct)).*(uavg./ustar).*((z-d)/k);
xf_m(:,ctr_xf)  = fim  .* xfrac(:,ctr_xf);   % flux footprint
xf_h(:,ctr_xf) = fihs .* xfrac(:,ctr_xf);   % flux footprint with heat correction
ctr_xf = ctr_xf+1;
end

%%% Convert values to real numbers:
% xf_m = real(xf_m);
% xf_h = real(xf_h);
% %% Part 2:  Filtering:
% 
% % Assign max fetch distances for each measurement:
% %%% Calculates the distance to the edge of site at small increments of
% %%% angles:
% [angles_out dist_out] = fetchdist(fetch);
% [angles_sorted index] = sort(angles_out);
% dist_sorted = dist_out(index);
% clear index;
% max_fetches = NaN.*ones(length(windd_math_rad),1);
% 
% for k = 1:1:length(angles_out)-1
%     ind2 = find(windd_math_rad >= angles_sorted(k) & windd_math_rad < angles_sorted(k+1));
%     
%     max_fetches(ind2) = dist_sorted(k);
% end
% 
% figure('Name','Preview of % footprint distances');clf;
% plot(xfrachm_real(:,2),'b.');hold on;
% plot(xfrachm_real(:,4),'g.');hold on;
% plot(xfrachm_real(:,6),'m.');hold on;
% plot(max_fetches,'r-','LineWidth',2);
% legend('50% dist','70% dist','90% dist','fetch dist');
% axis([1 length(max_fetches) 0 1000])
% 
% 
% % Make a variable to track stability conditions:
% 
% stab_flag = NaN.*ones(length(max_fetches),1);
% stab_flag(zL < -0.2) = -1;
% stab_flag(zL >= -0.2 & zL <= 0.2) = 0;
% stab_flag(zL > 0.2) = 1;
% 
% % Make a variable to track ustar threshold acceptance or rejection
% ustar_flag = ones(length(max_fetches),1);
% ustar_flag(par < 30 & ustar < Ustar_th) = 0;
% 
% 
% %% Plotting Some Information:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % 1. Wind Rose - Visual Inspection of the wind field.
% ind = find(~isnan(windd_math_deg.*u));
% figure('Name', 'Wind Rose'); clf
% jjb_wind_rose(windd_math_deg(ind), u(ind));
% 
% % 2. Draw a quick outline of the tower and site?
% figure('Name', 'Annual Footprint');clf;
% %%% Plot Xmax, as well as 70% and 80% distances
% polar(windd_math_rad, real(xfrachs_real(:,5)),'g.');hold on;
% polar(windd_math_rad, real(xfrachs_real(:,4)),'r.');
% polar(windd_math_rad, xcorr_real,'bx'); 
% %%% Plot the site:
%   h1 =  polar(angles_sorted,dist_sorted);
%   set(h1,'LineStyle','-','LineWidth',2,'Color',[1 0.5 0.8]);
% %%% Set the size of the plot
% rlim = 1000;axis([-1 1 -1 1]*rlim); % Sets the limits for the graph:
% %%% Plot Contour Distancs Rings
% plot_ang = (0:pi/180:2*pi)';
% for pl_dist = 100:100:900
%     h2 = polar(plot_ang,[pl_dist.*ones(length(plot_ang),1)]);
%   set(h2,'LineStyle','--','LineWidth',2,'Color',[0.5 0.5 0.5]);
%   t1 = text(0,pl_dist+10,num2str(pl_dist));
%   set(t1, 'FontSize',12,'Color','k');
% end
% %%% legend
% legend('X_{max}','X_{70}','X_{80}','boundary')
% 
% % 3. Stratify for different conditions:
% %%% a) unstable/neutral:
% ind_u_n = find(stab_flag < 1);
% figure('Name', 'Footprints for Unstable/Neutral');clf;
% %%% Plot Xmax, as well as 70% and 80% distances
% polar(windd_math_rad(ind_u_n), real(xfrachs_real((ind_u_n),5)),'g.');hold on;
% polar(windd_math_rad(ind_u_n), real(xfrachs_real((ind_u_n),4)),'r.');
% polar(windd_math_rad(ind_u_n), xcorr_real(ind_u_n),'bx'); 
% %%% Plot the site:
%   h1 =  polar(angles_sorted,dist_sorted);
%   set(h1,'LineStyle','-','LineWidth',2,'Color',[1 0.5 0.8]);
% %%% Set the size of the plot
% rlim = 1000;axis([-1 1 -1 1]*rlim); % Sets the limits for the graph:
% %%% Plot Contour Distancs Rings
% plot_ang = (0:pi/180:2*pi)';
% for pl_dist = 100:100:900
%     h2 = polar(plot_ang,[pl_dist.*ones(length(plot_ang),1)]);
%   set(h2,'LineStyle','--','LineWidth',2,'Color',[0.5 0.5 0.5]);
%   t1 = text(0,pl_dist+10,num2str(pl_dist));
%   set(t1, 'FontSize',12,'Color','k');
% end
% %%% legend
% legend('X_{max}','X_{70}','X_{80}','boundary')
% 
% %%% b) stable:
% ind_s = find(stab_flag == 1);
% figure('Name', 'Footprints for Stable');clf;
% %%% Plot Xmax, as well as 70% and 80% distances
% polar(windd_math_rad(ind_s), real(xfrachs_real((ind_s),5)),'g.');hold on;
% polar(windd_math_rad(ind_s), real(xfrachs_real((ind_s),4)),'r.');
% polar(windd_math_rad(ind_s), xcorr_real(ind_s),'bx'); 
% %%% Plot the site:
%   h1 =  polar(angles_sorted,dist_sorted);
%   set(h1,'LineStyle','-','LineWidth',2,'Color',[1 0.5 0.8]);
% %%% Set the size of the plot
% rlim = 1000;axis([-1 1 -1 1]*rlim); % Sets the limits for the graph:
% %%% Plot Contour Distancs Rings
% plot_ang = (0:pi/180:2*pi)';
% for pl_dist = 100:100:900
%     h2 = polar(plot_ang,[pl_dist.*ones(length(plot_ang),1)]);
%   set(h2,'LineStyle','--','LineWidth',2,'Color',[0.5 0.5 0.5]);
%   t1 = text(0,pl_dist+10,num2str(pl_dist));
%   set(t1, 'FontSize',12,'Color','k');
% end
% %%% legend
% legend('X_{max}','X_{70}','X_{80}','boundary')
% 
% 
% 
% 
% % 
% % % Plot Z/L
% % figure(5); hold on
% % plot(zL,'bo')
% % plot(ustr,'rx')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[-20 20],'FontSize',12);
% % xlabel('Hour','FontSize',12)
% % ylabel('Obukhov length Stability, z/L','FontSize',12)
% % %aa = legend('Heat-corrected','un-corrected',1);
% % %set(aa,'Vis','on');
% % 
% % 
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Plot flux footprint
% % figure(10)
% % %plot(t,xcorrm,'ro', t,xcorrhs,'b^')
% % plot(real(xcorrhs),'b^')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 1000],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance where maximum flux originated (m)','FontSize',12)
% % aa = legend('Heat-corrected','un-corrected',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP39_Xmax; 
% % 
% % % Plot flux footprint
% % figure(11)
% % %plot(t,xfracm,'r^',t,xfrachs,'bo')
% % plot(real(xfrachs),'ro')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 2000],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance from which 80% flux originates (m)','FontSize',12)
% % aa = legend('Heat-corrected','un-corrected',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP39_Xfrac80; 
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Ustar applied to eliminate bas fluxes
% % ind = find(ustr > ustrTH);
% % 
% % xcorrhsX = NaN*(1:(length(t)));
% % xcorrhsX(ind) = xcorrhs(ind);
% % 
% % xfrachsX = NaN*(1:(length(t)));
% % xfrachsX(ind) = xfrachs(ind);
% % 
% % % Plot flux footprint
% % figure(12)
% % %plot(t,xcorrm,'ro', t,xcorrhs,'b^')
% % plot(real(xcorrhsX),'b^')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 1000],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance where maximum flux originated (m)','FontSize',12)
% % aa = legend('Heat-corrected','un-corrected',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP39_Xmax_ustar; 
% % 
% % % Plot flux footprint
% % figure(13)
% % %plot(t,xfracm,'r^',t,xfrachs,'bo')
% % plot(real(xfrachsX),'ro')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 2000],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance from which 80% flux originates (m)','FontSize',12)
% % aa = legend('Heat-corrected','un-corrected',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP39_Xfrac80_ustar; 
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Plot footprint for unstable and neutral conditions only
% % 
% % ind = find(zL <= 0);
% % xcorrhsXX = NaN*(1:(length(t)));
% % xcorrhsXX(ind) = xcorrhs(ind);
% % xcorrhsXX = xcorrhsXX';
% % 
% % xfrachsXX = NaN*(1:(length(t)));
% % xfrachsXX(ind) = xfrachs(ind);
% % xfrachsXX = xfrachsXX';
% % 
% % % Plot flux footprint
% % figure(14)
% % %plot(t,xcorrm,'ro', t,xcorrhs,'b^')
% % plot(real(xcorrhsXX),'b^')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 140],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance where maximum flux originated (m)','FontSize',12)
% % aa = legend('Unstable',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP02_Xmax_zL; 
% % 
% % % Plot flux footprint
% % figure(15)
% % %plot(t,xfracm,'r^',t,xfrachs,'bo')
% % plot(real(xfrachsXX),'ro')
% % %set(gca,'box','on','xlim',[0 365],'FontSize',12);
% % set(gca,'box','on','ylim',[0 700],'FontSize',12);
% % xlabel('Day of Year)','FontSize',12)
% % ylabel('Distance from which 80% flux originates (m)','FontSize',12)
% % aa = legend('Unstable',1);
% % set(aa,'Vis','on');
% % 
% % %print -dmeta  TP02_Xfrac80_zL; 
% end
