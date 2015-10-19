function [final_out f_out] = mcm_Gapfill_LRC_Lasslop_VPD(data, plot_flag, debug_flag)
%%% mcm_Gapfill_LRC_Lasslop.m
%%% usage: master = mcm_Gapfill_LRC_Lasslop(data, plot_flag, debug_flag)
%%%
%%% This function fills NEE data using the LRC method introduced by Lasslop
%%% (2010). Two different approaches for Light Response Curve (LRC)
%%% application were presented: using a VPD-regulated GPP formulation, and
%%% a simpler method that does not use the VPD-regulated term.  This
%%% function determines both, but ideally will use the VPD-regulated filled
%%% NEE as the final filled output.
%%%
%%% Inputs:
%%% data (master structure file with all met, flux, and ancillary info
%%% plot_flag - set to 1 if you want figure output displayed and saved
%%% debug_flag - used to skip given sections of code when developing
%%%
%%% Created Nov 5, 2010 by JJB.
f_out = [];
if nargin == 1;
plot_flag = 1;
debug_flag = 0;
elseif nargin == 2
    debug_flag = 0;
end
%%%%%%%%
warning off all
%%%%%%%%
if plot_flag == 1;
    ls = addpath_loadstart;
    fig_path = [ls 'Matlab/Figs/Gapfilling/LRC_Lasslop/' data.site '/'];
    jjb_check_dirs(fig_path);
    
    %%% Pre-defined variables, mostly for plotting:
%     test_Ts = (-10:2:26)';
%     test_PAR = (0:200:2400)';
    [clrs clr_guide] = jjb_get_plot_colors;
end
NEE_tags = {'LRC_Lasslop_VPD'};
year_start = data.year_start;
year_end = data.year_end;

%% Part 1: Establish the appropriate u* threshold:
%%% 1a: The Reichstein, 2005 approach:
if isfield(data,'Ustar_th')
    disp('u*_{TH} already established -- not calculated.');
else
    [data.Ustar_th] = mcm_Ustar_th_Reich(data);
end

%%% Standard Deviation Estimates:
%%% If the field exists, then we'll assume we want to use WSS.
%%% 1. If NEE_std does not exist, use OLS:
if isfield(data,'NEE_std')==0
    data.costfun = 'OLS';
    data.NEE_std = ones(length(data.Year),1); 
else
    % If it does exist, check if data.costfun exists:
    if isfield(data,'costfun')==1
        % If data.costfun exists, do nothing - we're all set
        if strcmp(data.costfun,'OLS')
        data.NEE_std = ones(length(data.Year),1); 

        end
    else
        % If it doesn't, assume we want WSS, since there is std data:
        data.costfun = 'WSS';
    end
end

if isfield(data,'min_method')==1
else
    data.min_method = 'NM';
end
% seasons = [1 3; 4 6; 7 9; 10 12]; % Starting and ending months for seasons
% ctr = 1;
% for year = year_start:1:year_end
%     for seas = 1:1:4
%         ind = find(data.Year == year & data.Month >= seasons(seas,1) & data.Month <= seasons(seas, 2));
%         [u_th_est seas_u_th(seas,ctr)] = Reichsten_uth(data.NEE(ind), data.Ts5(ind), data.Ustar(ind), data.RE_flag(ind));
%     end
%     %%% Select annual u*_th as the maximum of seasonal esimates
%     %%% (conservative)
%     %     Ustar_th(ctr,1) = nanmax(seas_u_th(:,ctr));
%     Ustar_th(ctr,1) = nanmedian(seas_u_th(:,ctr)); % Changed to median:
%     data.Ustar_th(data.Year == year,1) = Ustar_th(ctr,1);
%     ctr = ctr+1;
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Deriving Eo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if debug_flag ~= 2
    %%%
    Ts_in = data.Ts2; %%% Using 2cm soil temperature as temperature for regression.
    %%%
    RE_raw = NaN.*data.NEE;
    xi = (1:1:length(RE_raw))';
%     ind_param.RE = find((data.Ustar >= data.Ustar_th & ~isnan(data.Ts5) & ~isnan(data.NEE.*data.NEE_std) & data.PAR < 15 ) |... % growing season
%         ( data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );  % non-growing season
%     ind_param.RE = find(data.Ustar >= data.Ustar_th & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));
   ind_param.RE = find((data.PAR >= 15 |data.Ustar >= data.Ustar_th) & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));

RE_raw(ind_param.RE,1) = data.NEE(ind_param.RE,1);
    %     RE_filled = NaN.*ones(length(RE_raw),1);
    options.min_method = data.min_method; options.f_coeff = [];options.costfun = data.costfun;
    win_size = round(12*48/2); % 12 days of hhours (divided by 2 to make one-sided)
    incr = (2*48); % increment by 2 days
    wrap_RE = [RE_raw(end-win_size+1:end,1); RE_raw; RE_raw(1:win_size,1)];
    wrap_Ts = [Ts_in(end-win_size+1:end,1); Ts_in; Ts_in(1:win_size,1)];
    wrap_ind = [xi(length(xi)-win_size+1:end,1); xi; xi(1:win_size,1)];
    wrap_NEE_std = [data.NEE_std(end-win_size+1:end,1); data.NEE_std; data.NEE_std(1:win_size,1)];    
    centres = (win_size+1:incr:length(wrap_ind)-win_size)';
    Eo_wrap = NaN.*ones(length(wrap_ind),2);
    rRMSE_wrap = NaN.*ones(length(wrap_ind),2);
    if centres(end) < length(wrap_RE)-win_size; centres = [centres; length(wrap_RE)-win_size]; end
    %     centres = centres + win_size;
    %%%% Variables to use within loop:
    c_hat_RE = NaN.*ones(length(centres),2);
    stats_RE = NaN.*ones(length(centres),2);
    rel_error_RE = NaN.*ones(length(centres),1);
    num_pts = NaN.*ones(length(centres),1);
    
    %%% Windowed Parameterization for Eo (Eo_short): %%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:1:length(centres)
        try
            RE_temp = wrap_RE(centres(i)-win_size:centres(i)+win_size);
            Ts_temp = wrap_Ts(centres(i)-win_size:centres(i)+win_size);
            NEE_std_temp = wrap_NEE_std(centres(i)-win_size:centres(i)+win_size);            
            ind_use = find(~isnan(RE_temp.*NEE_std_temp)); 
            RE_use = RE_temp(ind_use);
            Ts_use = Ts_temp(ind_use);
            NEE_std_use = NEE_std_temp(ind_use);            
            num_pts(i,1) = length(RE_use);
            if num_pts(i,1) < 10
                c_hat_RE(i,1:2) = NaN;
                stats_RE(i,1:2) = NaN;
                rel_error_RE(i,1) = NaN;
            elseif (max(Ts_use) - min(Ts_use)) < 5
                c_hat_RE(i,1:2) = NaN;
                stats_RE(i,1:2) = NaN;
                rel_error_RE(i,1) = NaN;
            else
                % Run parameterization, gather c_hat values:
                clear global;
                [c_hat_RE(i,:), y_hat(i).RE, y_pred(i).RE, stats(i).RE, sigma(i).RE, err(i).RE, exitflag(i).RE, num_iter(i).RE] = ...
                    fitresp([10 100], 'fitresp_1C', Ts_use , RE_use, wrap_Ts(centres(i)-win_size:centres(i)+win_size),NEE_std_use, options);
                % gather stats:
                stats_RE(i,1:2) = [stats(i).RE.rRMSE stats(i).RE.MAE];
                rel_error_RE(i,1) = std(y_pred(i).RE)./nanmean(y_pred(i).RE);
                if c_hat_RE(i,2) > 75 && c_hat_RE(i,2) < 450 && stats_RE(i,1) < 0.65
                    Eo_wrap(centres(i)-win_size:centres(i)+win_size, rem(i,2)+1) = c_hat_RE(i,2);
                    rRMSE_wrap(centres(i)-win_size:centres(i)+win_size, rem(i,2)+1) = stats_RE(i,1);
                end
            end
            
        catch
            disp(i);
        end
        clear *_temp *_use;
    end
end

%%%
%%% There will be occasions where we get 2 estimates of Eo for a given
%%% half-hour.  Resolve this by taking a weighted mean of the two values,
%%% inversely weighted by the value of rRMSE associated with the Eo
%%% measurement:
sum_rRMSE = nansum(rRMSE_wrap,2); sum_rRMSE(sum_rRMSE==0) = NaN;
rRMSE_weights = [rRMSE_wrap(:,2)./sum_rRMSE rRMSE_wrap(:,1)./sum_rRMSE ];
ind_r1 = find(rRMSE_weights(:,1) == 1);
ind_r2 = find(rRMSE_weights(:,2) == 1);
rRMSE_weights(ind_r1,1) = NaN; rRMSE_weights(ind_r1,2) = 1;
rRMSE_weights(ind_r2,2) = NaN; rRMSE_weights(ind_r2,1) = 1;
weighted_Eomean = nansum([Eo_wrap(:,1).*rRMSE_weights(:,1) Eo_wrap(:,2).*rRMSE_weights(:,2)],2 );
weighted_Eomean(weighted_Eomean == 0,1) = NaN;
Eo_mean = nanmean(Eo_wrap,2);

if plot_flag == 1;
figure(5);clf
plot(Eo_mean,'b');hold on;
plot(weighted_Eomean,'r');
legend('Un-weighted', 'rRMSE-weighted');
clear sum_rRMSE rRMSE_weights ind_r*
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fill in gaps in Eo by using previous values for each of the windows:
% First, fill in what we can using previous data:
for i = 1:1:length(centres)
    %%% Find the last non-NAN number of Eo:
    last_good = weighted_Eomean(find(~isnan( weighted_Eomean(1:centres(i)-win_size,1) ) ,1, 'last'),1);
    if ~isempty(last_good)
        if ~isempty(find(isnan(weighted_Eomean(centres(i)-win_size:centres(i)+win_size)), 1))
            weighted_Eomean(centres(i)-win_size:centres(i)+win_size) = last_good;
        end
    end
    clear last_good;
end

for i = 1:1:length(centres)
    %%% Find the last non-NAN number of Eo:
    last_good = weighted_Eomean(find(~isnan( weighted_Eomean(1:centres(i)-win_size,1) ) ,1, 'last'),1);
    if isempty(last_good)
        % if it's empty, that means we have to take the last good at
        % the end of the year:
        last_good = weighted_Eomean(find(~isnan(weighted_Eomean),1,'last'),1);
    end
    if ~isempty(find(isnan(weighted_Eomean(centres(i)-win_size:centres(i)+win_size)), 1))
        weighted_Eomean(centres(i)-win_size:centres(i)+win_size) = last_good;
    else
    end
    clear last_good;
end

% Trim weighted_Eomean to the proper size:
Eo_weighted = weighted_Eomean(win_size+1:length(weighted_Eomean)-win_size,1);
clear weighted_Eomean;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Step 1a: All-year parametization for Eo (Eo_long):
RE_param = RE_raw(~isnan(RE_raw.*data.NEE_std));
Ts_param = Ts_in(~isnan(RE_raw.*data.NEE_std));
NEE_std_param = data.NEE_std(~isnan(RE_raw.*data.NEE_std));
clear global;
% Run parameterization, gather c_hat values:
[c_hat_RE_all, y_hat_RE_all, y_pred_RE_all, stats_RE_all, sigma_RE_all, err_RE_all, exitflag_RE_all, num_iter_RE_all] = ...
    fitresp([10 100], 'fitresp_1C', Ts_param , RE_param, Ts_in,NEE_std_param, options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Looking at this, it may be more suitable to use rRMSE cutoff of 0.65
%%%% (65%), instead of a relative error cutoff, since the relative error is
%%%% going to be directly determined by the value of Eo.

%%% Step 1b: Estimate Dynamic Eo:
%%% Filter out to use only good periods (Eo 50-450, rel error < %50)
% ind_use_Eo1 = find(c_hat_RE(:,2) > 50 & c_hat_RE(:,2) < 450 & rel_error_RE < 0.5);
ind_use_Eo = find(c_hat_RE(:,2) > 100 & c_hat_RE(:,2) < 550 & stats_RE(:,1) < 0.65);

Eo_use = c_hat_RE(ind_use_Eo,2);
centres_use = centres(ind_use_Eo,1);
%%% Interpolate Between good estimates of Eo:
Eo_interp = interp1(centres_use-win_size,Eo_use,xi);
%%% Fill in NaNs outside first and last data points:
early_nans = find(xi < xi(end)/2 & isnan(Eo_interp));
Eo_interp(early_nans, 1) = Eo_interp(find(~isnan(Eo_interp),1,'first'),1);
late_nans = find(xi >= xi(end)/2 & isnan(Eo_interp));
Eo_interp(late_nans, 1) = Eo_interp(find(~isnan(Eo_interp),1,'last'),1);

%%% Plot results for Eo:
if plot_flag == 1;

f2 = figure(2);clf;
ctr = 1;
for year = year_start:1:year_end
    if year_start-year_end > 7
        subplot(5,2,ctr);
    else
        subplot(4,2,ctr);
    end
    plot([1 17568],[c_hat_RE_all(1,2) c_hat_RE_all(1,2)],'r--','LineWidth', 1.5); hold on;
    ind_st(ctr,1) = find(data.Year==year,1,'first');
    ind_end(ctr,1) = find(data.Year==year,1,'last');
    centres_tmp = centres_use(centres_use >= ind_st(ctr,1) & centres_use <= ind_end(ctr,1));
    Eo_tmp = Eo_use(centres_use >= ind_st(ctr,1) & centres_use <= ind_end(ctr,1));
    plot(centres_tmp-ind_st(ctr,1)+1,Eo_tmp,'.','Color',clrs(ctr,:));hold on;
    plot(xi(ind_st(ctr,1)-ind_st(ctr,1)+1:ind_end(ctr,1)-ind_st(ctr,1)+1,1),...
        Eo_weighted(ind_st(ctr,1):ind_end(ctr,1),1),'--','Color',clrs(ctr,:), 'LineWidth',2);
    h1(ctr,1) = plot(xi(ind_st(ctr,1)-ind_st(ctr,1)+1:ind_end(ctr,1)-ind_st(ctr,1)+1,1),...
        Eo_interp(ind_st(ctr,1):ind_end(ctr,1),1),'-','Color',clrs(ctr,:));
    title(num2str(year));
    ylabel('E_{0}');
    set(gca,'YTick', [0:100:500]);
    if ctr == 1
        title('E_{0} estimates - no VPD');
    end
    ctr = ctr+1;
end
% legend('boxoff')
print('-dpdf',[fig_path 'LRC_noVPD_Eo_annual']);

f1 = figure(1);clf;
plot(centres_use,Eo_use(:,1),'go'); hold on;
plot([xi(1) xi(end)],[c_hat_RE_all(1,2) c_hat_RE_all(1,2)],'c--','LineWidth', 1.5);
plot(xi,Eo_interp, 'b-');
plot(xi,Eo_weighted,'r-');
title(['Years ' num2str(year_start) '-' num2str(year_end) ', E_{0} estimates - no VPD']);
set(gca,'XTick', ind_st, 'XTickLabel', {year_start:1:year_end}, 'FontSize', 14);
axis([1 xi(end) 50 450])
legend('Obs E_{0}','Eo-annual','Inerp E_{0}','Weighted E_{0}',3,'Orientation','Horizontal');
print('-dpdf',[fig_path 'LRC_noVPD_Eo_all']);
end
clear wrap_* centres global
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Step 2: Estimate NEE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Estimation of NEE occurs in 3 different ways:
% 1. _noVPD
%%% Use nighttime-estimated Eo (above).  Derive other params from daytime
% 2. _noVPDall
%%% Derive Eo and other params from daytime.  Eo is static and singular.
% 3. _VPD
%%% Use nighttime-estimated Eo (above).  Modify Beta value based on VPD
%%% value.  Introduce new parameter for Beta scaling -- k.

NEE_clean = data.NEE;
% NEE_clean(data.PAR < 15 & data.Ustar < data.Ustar_th, 1) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following was changed to 150 on May 19, 2011 by JJB
% This change was implemented to reduce the GEP < 0 events that occur at 
% sundown/sunup that get included into NEE, but get excluded from GEP (set
% to zero).  This change will make things more consistent between NEE and
%  (RE_filled - GEP_filled).
NEE_clean((data.PAR < 15 & data.Ustar < data.Ustar_th) | ...
    (data.PAR < 150 & data.GEP_flag>=1 & data.Ustar< data.Ustar_th),1) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preliminary NEE fill column vectors:
NEE_fill = NaN.*ones(length(NEE_clean),3);
for i = 1:1:3
    NEE_fill(~isnan(NEE_clean),i) = NEE_clean(~isnan(NEE_clean),1);
end

win_size = round(4*48/2);
incr = 2*48;
%%% Wrap the variables:
wrap_Ts = [data.Ts2(end-win_size+1:end,1); data.Ts2; data.Ts2(1:win_size,1)];
wrap_PAR = [data.PAR(end-win_size+1:end,1); data.PAR; data.PAR(1:win_size,1)];
wrap_Eo = [Eo_weighted(end-win_size+1:end,1); Eo_weighted; Eo_weighted(1:win_size,1)];
wrap_VPD = [data.VPD(end-win_size+1:end,1); data.VPD; data.VPD(1:win_size,1)];
wrap_ind = [xi(length(xi)-win_size+1:end,1); xi; xi(1:win_size,1)];
wrap_NEE = [NEE_clean(end-win_size+1:end,1); NEE_clean; NEE_clean(1:win_size,1)];
wrap_NEE_std = [data.NEE_std(end-win_size+1:end,1); data.NEE_std; data.NEE_std(1:win_size,1)];

centres = (win_size+1:incr:length(wrap_ind)-win_size)';
if centres(end) < length(wrap_NEE)-win_size; centres = [centres; length(wrap_NEE)-win_size]; end
%%%% Variables to use within loop:
c_hat1 = NaN.*ones(length(centres),5);
stats1= NaN.*ones(length(centres),2); 
y_pred1 = NaN.*ones(length(wrap_NEE),2); 
num_pts = NaN.*ones(length(centres),1); num_pts_d = NaN.*ones(length(centres),1);
num_pts_n = NaN.*ones(length(centres),1);

Rref_start = NaN.*ones(length(centres),1);
beta_start = NaN.*ones(length(centres),1);

    n_coeffs = 4;
    options.costfun =data.costfun; options.min_method = data.min_method;options.f_coeff = [];
    fun_name = 'fitGEP_Lasslop_VPD';
    coeffs_use = [1 2 3 5];

%%% Windowed Parameterization:
for i = 1:1:length(centres)
%     tic
    Ts_temp = wrap_Ts(centres(i)-win_size:centres(i)+win_size);
    PAR_temp = wrap_PAR(centres(i)-win_size:centres(i)+win_size);
    Eo_temp = wrap_Eo(centres(i)-win_size:centres(i)+win_size);
    VPD_temp = wrap_VPD(centres(i)-win_size:centres(i)+win_size);
    NEE_temp = wrap_NEE(centres(i)-win_size:centres(i)+win_size);
    NEE_std_temp = wrap_NEE_std(centres(i)-win_size:centres(i)+win_size);
    ind_check = Ts_temp.*PAR_temp.*Eo_temp.*VPD_temp.*NEE_temp.*NEE_std_temp;
    
    %%% Determine the starting values for Rref:    
    try Rref_start(i,1) = nanmean(NEE_temp(PAR_temp< 15,1)); catch; Rref_start(i,1) = NaN; end
    if isempty(Rref_start(i,1))==1 || isnan(Rref_start(i,1))==1 || Rref_start(i,1) >100; Rref_start(i,1) = 5; 
    elseif Rref_start(i,1)<0; Rref_start(i,1) = 2; 
    end
    %%% Determine the starting values for beta: 
    try beta_start(i,1) = abs(quantile(NEE_temp,0.03)-quantile(NEE_temp,0.97));    
    catch; beta_start(i,1) = NaN; end
        if isempty(beta_start(i,1))==1 || isnan(beta_start(i,1))==1 || beta_start(i,1) > 100; beta_start(i,1) = 20; 
    elseif beta_start(i,1)<=0; beta_start(i,1) = 0.5; 
        end
        
       start_coeffs = [0.05 beta_start(i,1) Rref_start(i,1) 400 0];

    % Run parameterization, gather c_hat values:
    X_eval = [PAR_temp Ts_temp Eo_temp VPD_temp];
    X_in = [PAR_temp(~isnan(ind_check)==1) Ts_temp(~isnan(ind_check)==1) ...
        Eo_temp(~isnan(ind_check)==1) VPD_temp(~isnan(ind_check)==1)];
    num_pts(i,1) = size(X_in,1);
    num_pts_d(i,1) = length(find(X_in(:,1)>15));
    num_pts_n(i,1) = length(find(X_in(:,1)<=15));
    clear global;
    
    [c_hat, y_hat, y_pred, stats, sigma, err, exitflag, num_iter] = ...
        fitGEP(start_coeffs(coeffs_use), fun_name, X_in ,NEE_temp(~isnan(ind_check)),  X_eval, NEE_std_temp(~isnan(ind_check)), options);
    % predicted values:
    y_pred1(centres(i)-win_size:centres(i)+win_size,rem(i,2)+1) = y_pred;
    % gather stats:
    stats1(i,1:2) = [stats.rRMSE stats.Ei];
    % Coefficients: [alpha beta rRef]
    c_hat1(i,1:n_coeffs) = c_hat;
    clear c_hat y_pred stats;
    clear global
    
% t = toc;
%     if rem(i,100) == 0
% disp(['run ' num2str(i) ' completed in ' num2str(t) ' seconds.'])
%     end   
end


%%% Plot some stuff for checking:
if plot_flag == 1;
f3 = figure();clf;
plot(wrap_NEE,'k.-');hold on; plot(y_pred1)
axis([1 length(y_pred1) -25 15]);title('noVPD');
end
%%%%%%%%%%%%%%%  CLEANING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Now, we need to go through the estimated parameters, and deal with any
%%% unacceptible values:
% c_hat1 = c_hat1_pre;c_hat2 = c_hat2_pre;c_hat3 = c_hat3_pre;
% 1. Make all coefficients NaN when Rref < 0:
c_hat1(c_hat1(:,3)<0,:)= NaN; %c_hat2(c_hat2(:,3)<0,:)= NaN; c_hat3(c_hat3(:,3)<0,:)= NaN;
% 1b. Set all coefficients to zero when 
% 2a. Alpha less than zero is zero:
c_hat1(c_hat1(:,1)<0,1)= 0; %c_hat2(c_hat2(:,1)<0,1)= 0; c_hat3(c_hat3(:,1)<0,1)= 0;
% 2b. Alpha greater than 0.2 is NaN:
c_hat1(c_hat1(:,1)>0.2,1)= NaN; %c_hat2(c_hat2(:,1)>0.2,1)= NaN; c_hat3(c_hat3(:,1)>0.2,1)= NaN;
% 3a. Beta less than zero is zero:
c_hat1(c_hat1(:,2)<=0,2)= 0.01; %c_hat2(c_hat2(:,2)<=0,2)= 0.01; c_hat3(c_hat3(:,2)<=0,2)= 0.01;
% 3b. Beta greater than 50 -> set all parameters to NaN:
c_hat1(c_hat1(:,2)>50,:)= NaN; %c_hat2(c_hat2(:,2)>50,:)= NaN; c_hat3(c_hat3(:,2)>50,:)= NaN;
% 4. k value less than 0 = 0 (c_hat3 only):
c_hat1(c_hat1(:,4)<0,4)= 0;
%********* 5. Eo value outside of range is equal to end of range (c_hat2 only):
%********* c_hat2(c_hat2(:,4)>550,4)= 550; c_hat2(c_hat2(:,4)< 100,4)= 100;
% 6. Remove coefficients when there is less than 10 points in the day and
% 10 data points in the night:
% ind_nan_pts = find(num_pts_d < 10 | num_pts_n < 10);
c_hat1(num_pts_d < 10 | num_pts_n < 10,:) = NaN; %c_hat2(ind_nan_pts,:) = NaN; c_hat3(ind_nan_pts,:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FILL EMPTY SPOTS IN PARAMETERS, PREDICT NEE: %%%%%%%%%%%%%%%%

%%% We should also be able to model RE and GEP as well, using the filled
%%% parameters and the given equations:

y_pred1NEE = NaN.*ones(length(wrap_NEE),2); 
y_pred1RE = NaN.*ones(length(wrap_NEE),2);
y_pred1GEP = NaN.*ones(length(wrap_NEE),2);

clear global;

for i = 1:1:length(centres)
    %%% Fix for _noVPD:
    for k = 1:1:n_coeffs % cycle through coefficient columns:
        % If the first value is NaN, set it to the last previous OK value:
        if i ==1 
            if isnan(c_hat1(1,k))==1; c_hat1(1,k) = c_hat1(find(~isnan(c_hat1(:,k)),1,'last'),k); end  
        else
        if isnan(c_hat1(i,k))==1; c_hat1(i,k) = c_hat1(find(~isnan(c_hat1(1:i,k)),1,'last'),k); end
        end
    end
    
    %%%% Now, we can use the filled numbers to make new predictions:
    Ts_temp = wrap_Ts(centres(i)-win_size:centres(i)+win_size);
    PAR_temp = wrap_PAR(centres(i)-win_size:centres(i)+win_size);
    Eo_temp = wrap_Eo(centres(i)-win_size:centres(i)+win_size);
    VPD_temp = wrap_VPD(centres(i)-win_size:centres(i)+win_size);
    NEE_temp = wrap_NEE(centres(i)-win_size:centres(i)+win_size);
    
      X_eval = [PAR_temp Ts_temp Eo_temp VPD_temp];
  
      %%%% Estimate for _noVPD:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % NEE:
      y_tmp = feval(fun_name,c_hat1(i,1:n_coeffs),X_eval);
      y_pred1NEE(centres(i)-win_size:centres(i)+win_size,rem(i,2)+1) = y_tmp;clear y_tmp;
      % RE - We'll make alpha = 0, which removes GEP:
      y_tmp = feval(fun_name,[0 c_hat1(i,2:n_coeffs)],X_eval);
      y_pred1RE(centres(i)-win_size:centres(i)+win_size,rem(i,2)+1) = y_tmp;clear y_tmp;
      % GEP - We'll make Rref = 0, which removes RE:
      c_tmp = c_hat1(i,1:n_coeffs);
      c_tmp(1,3) = 0;
      y_tmp = feval(fun_name,c_tmp,X_eval);
      clear c_tmp;
      y_pred1GEP(centres(i)-win_size:centres(i)+win_size,rem(i,2)+1) = -1.*y_tmp;clear y_tmp;

   
      
%%% Make a vector the same length as y_pred that records the centre 
%%% position associated with that window:      
win_start = centres(i)-win_size; 
win_end = centres(i)+win_size;
c_loc(win_start:win_end,rem(i,2)+1) = centres(i);
end

if plot_flag == 1;
%%% Plot the newly predicted NEE for checking:
f4a = figure();clf;
subplot(211);plot(wrap_NEE,'k.-');hold on; plot(y_pred1NEE)
axis([1 length(y_pred1NEE) -25 15]);title(NEE_tags{1,1});
subplot(212);plot(y_pred1RE,'r');hold on; plot(-1.*y_pred1GEP,'g');
axis([1 length(y_pred1NEE) -45 25]);title(NEE_tags{1,1});
print('-djpeg', [fig_path 'model_results_' NEE_tags{1,1}]);
legend('RE','GEE')

f10 = figure();clf;
subplot(311);
plot(y_pred1(:,1),'k');
axis([1 length(y_pred1) -20 20])
subplot(312);
plot((1:2*48:size(c_hat1,1).*2*48),stats1(:,1),'k');
axis([1 length(stats1)*2*48 0 1])
subplot(313);
[AX h1 h2] = plotyy((1:2*48:size(c_hat1,1).*2*48),c_hat1(:,1), (1:2*48:size(c_hat1,1).*2*48), c_hat1(:,2),@line, @line);hold on;
set(get(AX(2),'YLabel'), 'String','\beta','FontSize', 16,'Color', [0 0.6 0])
set(get(AX(1),'YLabel'), 'String','\alpha','FontSize', 16, 'Color','b')
set(h1,'LineWidth', 2);
set(h2,'LineWidth', 1.5);
% Set y ticks and labels:
set(AX(1),'YTick', [-0.05:0.05:0.2]', 'YTickLabel',{-0.05:0.05:0.2},'FontSize',16)
set(AX(2),'YTick', [-5:5:55]', 'YTickLabel',{-5:5:55},'FontSize',16)
set(AX(1),'XLim',[1 size(c_hat1,1)*2*48],'YLim',[-0.05 0.2])
set(AX(2),'XLim',[1 size(c_hat1,1)*2*48], 'YLim', [-5 55])
title(['All years, \alpha and \beta']);
set(AX(2), 'FontSize', 14, 'YGrid', 'on');
set(AX(1), 'FontSize', 14);
% print('-djpeg', [fig_path 'fixed_alpha_NEE_results']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% GET FINAL NEE, RE, GEP ESTIMATES: %%%%%%%%%%%%%%%%

%%% Merge the two columns of y_pred data into a single estimated value
% Do this by weighting the data by its proximity to the centre of the
% estimation window:
NEE_pred = NaN.*ones(length(y_pred1NEE),1);
GEP_pred = NaN.*ones(length(y_pred1NEE),1);
RE_pred = NaN.*ones(length(y_pred1NEE),1);

centre_dist = [abs(c_loc(:,1) - (1:1:length(y_pred1NEE))') abs(c_loc(:,2) - (1:1:length(y_pred1NEE))')];
total_dist = nansum(centre_dist,2);
ind_nan1 = find(isnan(centre_dist(:,1))==1);
ind_nan2 = find(isnan(centre_dist(:,2))==1);
weights = [(total_dist - centre_dist(:,1))./total_dist (total_dist - centre_dist(:,2))./total_dist ];
% First, apply the weighted mean measurement into appropriate hhour:
NEE_pred(:,1) = sum(y_pred1NEE.*weights,2);
GEP_pred(:,1) = sum(y_pred1GEP.*weights,2);
RE_pred(:,1) = sum(y_pred1RE.*weights,2);

% Second, if we only have a measurement from one column, use it:
NEE_pred(ind_nan1,1) = y_pred1NEE(ind_nan1,2); NEE_pred(ind_nan2,1) = y_pred1NEE(ind_nan2,1);
GEP_pred(ind_nan1,1) = y_pred1GEP(ind_nan1,2); GEP_pred(ind_nan2,1) = y_pred1GEP(ind_nan2,1);
RE_pred(ind_nan1,1) = y_pred1RE(ind_nan1,2); RE_pred(ind_nan2,1) = y_pred1RE(ind_nan2,1);

if plot_flag == 1;
f11 = figure();clf;
subplot(3,1,1)
h1 = plot(wrap_NEE,'k.-');hold on;h2 = plot(NEE_pred); 
legend(h2, NEE_tags{1,1})
ylabel('NEE');
subplot(3,1,2)
h2 = plot(GEP_pred); 
legend(h2, NEE_tags{1,1})
ylabel('GEP');
subplot(3,1,3)
h2 = plot(RE_pred); 
legend(h2, NEE_tags{1,1})
ylabel('RE');
print('-djpeg', [fig_path 'NEE_RE_GEP_pred']);
end

%%% Trim the datafiles to the appropriate length:
NEE_pred_final = NEE_pred(win_size+1:length(NEE_pred)-win_size,1);
GEP_pred_final = GEP_pred(win_size+1:length(GEP_pred)-win_size,1);
RE_pred_final = RE_pred(win_size+1:length(RE_pred)-win_size,1);

%% Plot the final data:
if plot_flag ~=-9
    f_out = figure('Name', 'Final Filled Data');clf
    subplot(2,1,1); title('NEE');
    plot(NEE_pred_final); hold on;
    plot(NEE_clean,'k.')
    legend(NEE_tags{1,1},'measured');
    subplot(2,1,2);
    hold on;
    plot(RE_pred,'r')
    h1 = plot(-1.*GEP_pred);
    ylabel('GEE                      RE');
    legend(h1,NEE_tags{1,1});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% SAVE THE FINAL NEE, GEP, RE DATA and SUMS: %%%%%%%%%%%%%%%%
final_out = struct;
sum_labels = {'Year';'NEE_filled';'NEE_pred'; 'GEP_filled';'GEP_pred';'RE_filled';'RE_pred'};

NEE_fill(isnan(NEE_fill(:,1)),1) = NEE_pred_final(isnan(NEE_fill(:,1)),1);
num_gaps(1,1) = length(find(isnan(NEE_fill(:,1))));
disp(['Total of ' num2str(num_gaps(1,1)) ' gaps in ' NEE_tags{1,1}])

master.Year = data.Year;
master.NEE_clean = NEE_clean;
master.NEE_filled = NEE_fill(:,1);
master.NEE_pred = NEE_pred_final(:,1);
master.GEP_pred = GEP_pred_final(:,1);
master.RE_pred = RE_pred_final(:,1);
ctr = 1;
  for year = year_start:1:year_end
        master.sums(ctr,1) = year;
        master.sums(ctr,2) = sum(master.NEE_filled(data.Year==year)).*0.0216;
        master.sums(ctr,3) = sum(master.NEE_pred(data.Year==year)).*0.0216;
        master.sums(ctr,4) = NaN; % GEP_filled not possible with this method.
        master.sums(ctr,5) = sum(master.GEP_pred(data.Year==year)).*0.0216;
        master.sums(ctr,6) = NaN; % RE_filled not possible with this method.
        master.sums(ctr,7) = sum(master.RE_pred(data.Year==year)).*0.0216;        

        ctr = ctr + 1;
  end
  master.sum_labels = sum_labels;

% save([ls 'Matlab/Data/Gapfilling/TP39/Lasslop_' NEE_tags{i,1} '_fill_2003-2009.mat'],'master')  
  final_out(1).master = master;
  final_out(1).tag = NEE_tags{1,1};

    clear master

disp('mcm_Gapfill_LRC_Lasslop_VPD done!');

end
%% END OF MAIN FUNCTION: