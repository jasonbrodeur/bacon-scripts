function [final_out f_out] = mcm_Gapfill_FCRN(data, Ustar_th, plot_flag)
%%% This function fills NEE data using the fluxnet-canada (CCP) standard
%%% protocols, using a logistic RE-Ts function, and a Michaelis-Menten
%%% GEP-PAR function.  Both models are adjusted for bias offset by use of
%%% a time-varying-parameter.
%%% Created in its current form by JJB, March 8, 2010.
%%% usage: mcm_FCRN_Gapfill(site, year_start, year_end, Ustar_th)
% if plot_flag == 1;
%%% Pre-defined variables, mostly for plotting:
f_out = [];
test_Ts = (-10:2:26)';
test_PAR = (0:200:2400)';
[clrs] = jjb_get_plot_colors;
% test_VPD = (0:0.2:3)';
% test_SM = (0.045:0.005:0.10)';
% end

%% Ustar Threshold -- default is simple fixed threshold
%%% Enforced if data.Ustar_th does not exist:
if isfield(data,'Ustar_th')
    if plot_flag ~=-9
        disp('u*_{TH} already established -- not calculated.');
    end
else
    data.Ustar_th = Ustar_th.*ones(length(data.Year),1);
end
%%%%%%%%
warning off all
%%%%%%%%
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

year_start = data.year_start;
year_end = data.year_end;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Part 1: Respiration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% resp_day_constraints = [0 367];
% Calculate Rraw:
Rraw(1:length(data.NEE),1) = NaN;
RE_model(1:length(data.NEE),1) = NaN;

% ind_Rraw = find((data.Ustar >= data.Ustar_th & ~isnan(data.NEE) & data.PAR < 15) |... % growing season
%     (data.Ustar >= data.Ustar_th & ~isnan(data.NEE) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)) );    % non-growing season
%  ind_Rraw = find((data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std) & data.PAR < 15 ) |... % growing season
%         (data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std) &  ((data.Ts2<0.5 & data.Ta < 2)|(data.Ts2<2 & data.Ta < 0)) ) );% non-growing season
%  ind_Rraw = find(data.Ustar >= data.Ustar_th & data.GEP_flag == 0 & ~isnan(data.NEE));% non-growing season
 ind_Rraw = find((data.PAR >= 15 |data.Ustar >= data.Ustar_th) & data.GEP_flag == 0 & ~isnan(data.NEE)); % all-seasons

Rraw(ind_Rraw) = data.NEE(ind_Rraw);

%%% Run through Ts_RE_logistic function:
ctr = 1;
ind_param = struct;
c_hat = struct; y_hat = struct; y_pred = struct; stats = struct;
sigma = struct; err = struct; exitflag = struct; num_iter = struct;
for year = year_start:1:year_end
    clear global;
%     ind_param(ctr).RE = find((data.Year == year &data.Ustar >= data.Ustar_th & ~isnan(data.Ts5) & ~isnan(data.NEE.*data.NEE_std) & data.PAR < 15) |... % growing season
%         (data.Year == year & data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std) & data.Ts5 < -1  ) );                                   % non-growing season
%             ind_param(ctr).RE = find((data.Year == year & data.Ustar >= data.Ustar_th & ~isnan(data.Ts5.*data.SM_a_filled.*data.NEE.*data.NEE_std) & data.PAR < 15 ) |... % growing season
%             (data.Year == year & data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std.*data.SM_a_filled) & ((data.Ts2<0.5 & data.Ta < 2)|(data.Ts2<2 & data.Ta < 0))  ) );                                   % non-growing season
% ind_param(ctr).RE = find(data.Year == year & data.Ustar >= data.Ustar_th & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));
        ind_param(ctr).RE = find(data.Year == year & (data.PAR >= 15 |data.Ustar >= data.Ustar_th) & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));

    % Run Minimization:
    options.costfun =data.costfun; options.min_method = data.min_method;
    [c_hat(ctr).RE, y_hat(ctr).RE, y_pred(ctr).RE, stats(ctr).RE, sigma(ctr).RE, err(ctr).RE, exitflag(ctr).RE, num_iter(ctr).RE] = ...
        fitresp([8 0.2 12], 'fitresp_2A', data.Ts5(ind_param(ctr).RE), data.NEE(ind_param(ctr).RE), data.Ts5(data.Year == year), data.NEE_std(ind_param(ctr).RE), options);
    RE_model(data.Year == year,1) = y_pred(ctr).RE;
    ctr = ctr+1;
end
%%% Calculate Time-varying-parameter:
rw = jjb_AB_gapfill(RE_model, Rraw, [],200, 10, 'off', [], [], 'rw');
%%% Adjust modeled RE by TVP:
RE_tvp_adj = RE_model.*rw(:,2);

if plot_flag == 1;
    %%% Plot the relationships for RE-Ts for each year:
    figure('Name', 'Annual REvsTs');clf;
    ctr = 1;
    for year = year_start:1:year_end
        test_Ts_y =    (c_hat(ctr).RE(1))./(1 + exp(c_hat(ctr).RE(2).*(c_hat(ctr).RE(3)-test_Ts)));
        plot(test_Ts, test_Ts_y,'-','Color', clrs(ctr,:)); hold on;
        ctr = ctr+1;
    end
    legend(num2str((year_start:1:year_end)'));
    
    %%% Plot estimates with raw data:
    figure('Name','RE - raw vs. modeled');clf;
    plot(Rraw,'k');hold on;
    plot(RE_model,'b');
    plot(RE_tvp_adj,'r')
    legend('raw','model', 'adjusted')
    
    %%% Calculate stats for each:
    [RE_stats(1,1) RE_stats(1,2) RE_stats(1,3) RE_stats(1,4)] = model_stats(RE_model, Rraw,'off');
    [RE_stats(2,1) RE_stats(2,2) RE_stats(2,3) RE_stats(2,4)] = model_stats(RE_tvp_adj, Rraw,'off');
    %%% display stats on screen:
    disp('Stats for Each RE Model:');
    disp('              RMSE    |    rRMSE |     MAE     |   BE ');
    disp(['modeled:      ' num2str(RE_stats(1,:))]);
    disp(['tvp-adjusted: ' num2str(RE_stats(2,:))]);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% PHOTOSYNTHESIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GEPraw = RE_tvp_adj - data.NEE;
%%% Updated May 19, 2011 by JJB:
GEPraw(data.PAR < 15 | (data.PAR <= 150 & data.Ustar < data.Ustar_th) ) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%
GEP_model = zeros(length(GEPraw),1);
GEP_pred = NaN.*ones(length(GEPraw),1);
if plot_flag == 1;
    figure('Name','GEP-PAR relationship');clf
end
ctr = 1;
for year = year_start:1:year_end
    clear global
    %%% Index of good data to use for model parameterization:
%       ind_param(ctr).GEP = find(data.Ts2 > 1 & data.Ta > 2 & data.PAR > 15 & ~isnan(GEPraw) & data.Year == year & ~isnan(data.NEE_std));
% ind_param(ctr).GEP = find(data.Year == year & ~isnan(GEPraw.*data.NEE_std.*data.PAR) & data.GEP_flag==2);
ind_param(ctr).GEP = find(data.Year == year & ~isnan(GEPraw.*data.NEE_std.*data.PAR) & data.GEP_flag==2); % & ( (data.PAR >= 15 & data.PAR <200 & data.Ustar >= data.Ustar_th) | data.PAR >= 200 ));

    %%% use M-M function to get coefficients for GEP-PAR relationship:
    options.costfun =data.costfun; options.min_method = data.min_method;
    [c_hat(ctr).GEP, y_hat(ctr).GEP, y_pred(ctr).GEP, stats(ctr).GEP, sigma(ctr).GEP, err(ctr).GEP, exitflag(ctr).GEP, num_iter(ctr).GEP] = ...
        fitGEP([0.1 40], 'fitGEP_1H1', data.PAR(ind_param(ctr).GEP),GEPraw(ind_param(ctr).GEP),  data.PAR(data.Year == year), data.NEE_std(ind_param(ctr).GEP), options);
    % [GEP_coeff(ctr,:) GEP_pred GEP_r2 GEP_sigma] = hypmain1([0.01 10 0.1], 'fit_hyp1', data.PAR(ind_param_GEP), GEPraw(ind_param_GEP), data.NEE_std(ind_param_GEP));
    %%% Estimate GEP for the given year:
    GEP_pred(data.Year == year) = y_pred(ctr).GEP;
    
    %GEP_coeff(ctr,1).*data.PAR(data.Year==year,1).*GEP_coeff(ctr,2)./...
    %    (GEP_coeff(ctr,1).*data.PAR(data.Year==year,1) + GEP_coeff(ctr,2));
    %%% GEP relationship for plotting:
    test_PAR_y = c_hat(ctr).GEP(1).*test_PAR.*c_hat(ctr).GEP(2)./...
        (c_hat(ctr).GEP(1).*test_PAR + c_hat(ctr).GEP(2));
    %%% Plot relationships:
    if plot_flag == 1;
        plot(test_PAR, test_PAR_y,'-','Color', clrs(ctr,:)); hold on;
    end
    clear GEP_r2 GEP_sigma test_PAR_y;
    ctr = ctr+1;
end
if plot_flag == 1;
    legend(num2str((year_start:1:year_end)'));
end
%%% Clean up any problems that may exist in the data:
% ind_GEP = find(data.PAR >= 15 & ((data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%     | (data.dt > 330 | data.dt < 85) & data.Ts2 >= 1 & data.Ta > 2));
ind_GEP = find(data.GEP_flag>=1);

GEP_model(ind_GEP) = GEP_pred(ind_GEP);

%%% Calculate Time-varying-parameter:
pw = jjb_AB_gapfill(GEP_model, GEPraw, [],200, 10, 'off', [], [], 'rw');
%%% Adjust modeled GEP by TVP:
GEP_tvp_adj = GEP_model.*pw(:,2);

if plot_flag == 1;
    %%% Plot estimates with raw data:
    figure('Name','GEP - raw vs. modeled');clf;
    plot(GEPraw,'k');hold on;
    plot(GEP_pred,'c');
    plot(GEP_model,'b');
    plot(GEP_tvp_adj,'r')
    legend('raw','pred','modeled (cleaned)', 'adjusted')
    
    %%% Calculate stats for each:
    [GEP_stats(1,1) GEP_stats(1,2) GEP_stats(1,3) GEP_stats(1,4)] = model_stats(GEP_model, GEPraw,'off');
    [GEP_stats(2,1) GEP_stats(2,2) GEP_stats(2,3) GEP_stats(2,4)] = model_stats(GEP_tvp_adj, GEPraw,'off');
    %%% display stats on screen:
    disp('Stats for Each GEP Model:');
    disp('             RMSE    |    rRMSE  |  MAE     |    BE ');
    disp(['modeled:      ' num2str(GEP_stats(1,:))]);
    disp(['tvp-adjusted: ' num2str(GEP_stats(2,:))]);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  Final Filling & Output  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Clean NEE (ustar filtering):
NEE_raw = data.NEE;
NEE_clean = NEE_raw;
% NEE_clean(data.PAR < 15 & data.Ustar < data.Ustar_th,1) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following was changed to 150 on May 19, 2011 by JJB
% This change was implemented to reduce the GEP < 0 events that occur at 
% sundown/sunup that get included into NEE, but get excluded from GEP (set
% to zero).  This change will make things more consistent between NEE and
%  (RE_filled - GEP_filled).
NEE_clean((data.PAR < 15 & data.Ustar < data.Ustar_th) | ...
    (data.PAR < 150 & data.GEP_flag>=1 & data.Ustar< data.Ustar_th),1) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fill RE - Use raw data when Ustar > threshold; otherwise, use model+tvp
RE_filled(1:length(Rraw),1) = RE_tvp_adj;
%%%% Uncomment this:
RE_filled(~isnan(Rraw) & data.Ustar >= data.Ustar_th,1) = Rraw(~isnan(Rraw) & data.Ustar >= data.Ustar_th,1);

%%% Fill GEP:
GEP_filled = zeros(length(GEPraw),1);
% fill any nans in GEPraw with GEP_model:
GEPraw(isnan(GEPraw) | GEPraw < 0,1) = GEP_tvp_adj(isnan(GEPraw) | GEPraw < 0,1);
% Now, substitute GEPraw into GEP_filled when applicable (set by ind_GEP)
% ind_GEP = find(data.PAR >= 15 & ((data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%     | data.dt > 330 & data.Ts5 >= 1.25 & data.Ta > 2));
% ind_GEP = find(data.PAR >= 15 & ((data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%     | (data.dt > 330 | data.dt < 85) & data.Ts2 >= 1 & data.Ta > 2));
ind_GEP = find(data.GEP_flag>=1);
GEP_filled(ind_GEP) = GEPraw(ind_GEP);

% GEP_filled = GEPraw;
% GEP_filled(data.PAR < 15 | data.Ts5 < 0.5 | GEP_filled < 0) = NaN;
% GEP_filled(isnan(GEP_filled),1) = GEP_tvp_adj(isnan(GEP_filled),1);

%%% Fill NEE:
NEE_filled = NEE_clean;
NEE_filled(isnan(NEE_filled),1) = RE_filled(isnan(NEE_filled),1) - GEP_filled(isnan(NEE_filled),1);

%% Plot the final output:
if plot_flag ~= -9
    f_out = figure('Name', 'Final Filled Data');clf
    subplot(2,1,1); title('NEE');
    plot(NEE_filled); hold on;
    plot(NEE_clean,'k.')
    plot(find(isnan(NEE_clean)),NEE_filled(isnan(NEE_clean)),'r.');
    legend('filled','measured', 'original gaps');
    subplot(2,1,2);
    hold on;
    plot(RE_filled,'r')
    plot(-1.*GEP_filled,'g')
    legend('RE','GEE');
end

%% The final loop to calculate annual sums and check for holes remaining in data:
final_out = struct;
sum_labels = {'Year';'NEE_filled';'NEE_pred'; 'GEP_filled';'GEP_pred';'RE_filled';'RE_pred'};

%%% Assign data to master file:
master.Year = data.Year;
master.NEE_clean = NEE_clean;
master.NEE_filled = NEE_filled;
master.NEE_pred = RE_tvp_adj-GEP_tvp_adj;
master.RE_filled = RE_filled;
master.GEP_filled = GEP_filled;
master.GEP_pred = GEP_tvp_adj;
master.RE_pred = RE_tvp_adj;
master.c_hat = c_hat;

%%% Do Sums:
ctr = 1;
for year = year_start:1:year_end
    if year == 2002;
        NEE_filled(1:8,1) = NEE_filled(9,1);
        RE_filled(1:8,1) = RE_filled(9,1);
        GEP_filled(1:8,1) = GEP_filled(9,1);
    end
    master.sums(ctr,1) = year;
    master.sums(ctr,2) = sum(master.NEE_filled(data.Year==year)).*0.0216;
    master.sums(ctr,3) = sum(master.NEE_pred(data.Year==year)).*0.0216;
    master.sums(ctr,4) = sum(master.GEP_filled(data.Year==year)).*0.0216;
    master.sums(ctr,5) = sum(master.GEP_pred(data.Year==year)).*0.0216;
    master.sums(ctr,6) = sum(master.RE_filled(data.Year==year)).*0.0216;
    master.sums(ctr,7) = sum(master.RE_pred(data.Year==year)).*0.0216;
    ctr = ctr + 1;
end
final_out.master = master;
final_out.master.sum_labels = sum_labels;
final_out.tag = 'FCRN';

if plot_flag ~= -9
    disp('mcm_Gapfill_FCRN done!');
end
end
% ctr = 1;
% for yr_ctr = year_start:1:year_end
%     holes(ctr,1) = yr_ctr;
%     try
%         %%% Special fix for 2002 -- we lost 8 datapoints due to UTC timeshift:
%         if yr_ctr == 2002;
%             NEE_filled(1:8,1) = NEE_filled(9,1);
%             RE_filled(1:8,1) = RE_filled(9,1);
%             GEP_filled(1:8,1) = GEP_filled(9,1);
%         end
%
%         NEE_sum(ctr,1) = sum(NEE_filled(data.Year== yr_ctr,1)).*0.0216  ; % sums is annual sum
%         GEP_sum(ctr,1) = sum(GEP_filled(data.Year== yr_ctr,1)).*0.0216  ;
%         RE_sum(ctr,1) = sum(RE_filled(data.Year== yr_ctr,1)).*0.0216  ;
%         holes(ctr,2:4) = [length(find(isnan(NEE_filled(data.Year == yr_ctr,1)))) ...
%                         length(find(isnan(RE_filled(data.Year == yr_ctr,1)))) ...
%                         length(find(isnan(GEP_filled(data.Year == yr_ctr,1))))] ;
%     catch
%         disp(['something went wrong calculating sums, year: ' num2str(yr_ctr)]);
%         NEE_sum(ctr,1) = NaN;
%         GEP_sum(ctr,1) =  NaN;
%         RE_sum(ctr,1) =  NaN;
%         holes(ctr,1:3) = NaN;
%     end
%
% ctr = ctr+1;
% end
% if plot_flag == 1;
% sums = [holes(:,1) NEE_sum(:,1) RE_sum(:,1) GEP_sum(:,1)];
% disp('Number of NaNs outstanding in data: Year | NEE | RE | GEP ');
% disp(holes);
% disp('Annual Totals: Year | NEE | RE | GEP ');
% disp(sums)
% end
% %% Compile data and save:
% master.data = [data.Year NEE_raw NEE_clean NEE_filled GEP_filled RE_filled RE_tvp_adj GEP_tvp_adj];
% master.sums = sums;
% master.labels = {'Year'; 'NEE_raw'; 'NEE_clean'; 'NEE_filled'; 'GEP_filled'; 'RE_filled'; 'RE_model'; 'GEP_model'};

%
% master.data.Year = data.Year(:,1);
% master.data.NEE_raw = NEE_raw(:,1);
% master.data.NEE_clean = NEE_clean(:,1);
% master.data.NEE_filled = NEE_filled(:,1);
% master.data.GEP_filled = GEP_filled(:,1);
% master.data.RE_filled = RE_filled(:,1);
%
% master.data.RE_model = RE_tvp_adj;
% master.data.GEP_model = GEP_tvp_adj;
% master.data.sums = sums;



% save([save_path site '_FCRN_GapFilled_' num2str(year_start) '_' num2str(year_end) '_ust_th = ' num2str(Ustar_th)  fp_options.addtoname '.mat'],'master');


