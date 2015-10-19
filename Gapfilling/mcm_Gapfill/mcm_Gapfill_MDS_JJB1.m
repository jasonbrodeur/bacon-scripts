function [final_out f_out] = mcm_Gapfill_MDS_JJB1(data, plot_flag, debug_flag)
%%% This function fills NEE data using the Euroflux standard
%%% protocols, using the MDS approach, as outlined by Reichstein, 2005,
%%% with the following modifications:
%%%% A. ustar_th derivation:
%%%% 1. Derivation is accomplished using a month-sized window used at
%%%% bi-monthly intervals

%%% Created in its current form by JJB, Nov 3, 2010.
%%% usage: [master] = mcm_Gapfill_MDS(data, Ustar_th, plot_flag)
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
    fig_path = [ls 'Matlab/Figs/Gapfilling/MDS_JJB1/' data.site '/'];
    jjb_check_dirs(fig_path);
    %%% Pre-defined variables, mostly for plotting:
%     test_Ts = (-10:2:26)';
%     test_PAR = (0:200:2400)';
    [clrs clr_guide] = jjb_get_plot_colors;
end

year_start = data.year_start;
year_end = data.year_end;
%% Part 1: Establish the appropriate u* threshold:
%%% 1 Reichstein, 2005 approach, but calculated for different intervals:
if isfield(data,'Ustar_th')
    disp('u*_{TH} already established -- not calculated.');
else
    [data.Ustar_th f_ustar_th] = mcm_Ustar_th_JJB(data,1);
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


% ctr = 1;
% data.recnum = NaN.*ones(length(data.PAR),1);
% win_size = 16*48;
% centres(:,1) = (10*48:16*48:17520);
% for year = year_start:1:year_end
%     data.recnum(data.Year == year) = 1:1:yr_length(year,30);
%     dt_ctr = 1;
%     for dt_centres = 10*48:16*48:yr_length(year,30)%seas = 1:1:4
%         ind_bot = max(1,dt_centres-win_size);
%         ind_top = min(dt_centres+win_size,yr_length(year,30));
%         ind = find(data.Year == year & data.recnum >= ind_bot & data.recnum <= ind_top);
%         [u_th_est biweek_u_th(dt_ctr,ctr)] = Reichsten_uth(data.NEE(ind), data.Ts5(ind), data.Ustar(ind), data.RE_flag(ind));
%         dt_ctr = dt_ctr+1;
%     end
%     ctr = ctr+1;
% end
% 
% %%% Average for each data window over all years (using median or mean):
% Ustar_th_all = nanmedian(biweek_u_th,2);
% Ustar_th_all2 = nanmean(biweek_u_th,2);
% ctr = 1;
% L = '';
% for year = year_start:1:year_end
% %%% interpolate between points:
% % step 1: interpolate out to the ends:
% use_pts = (1:1:(yr_length(year,30)-centres(end))+(centres(1)))';
% ust_fill = [Ustar_th_all2(end); Ustar_th_all2(1)];
% x = [1; use_pts(end)];
% ust_interp = interp1(x,ust_fill,use_pts);
% centres_tmp = [1; centres; yr_length(year,30)];
% Ustar_th_all_tmp = [ust_interp(yr_length(year,30)-centres(end)+1); Ustar_th_all2; ust_interp(yr_length(year,30)-centres(end))];
% Ustar_th_interp = interp1(centres_tmp,Ustar_th_all_tmp,(1:1:yr_length(year,30))');
% data.Ustar_th(data.Year == year,1) = Ustar_th_interp;
% ctr = ctr+1;
% clear centres_tmp Ustar_th_all_tmp Ustar_th_interp ust_interp x ust_fill use_pts;
% L = [L '''' num2str(year) '''' ','];
% end
% L = [L '''' 'Median' '''' ',' '''' 'Mean' ''''];
% 
% if plot_flag == 1
%    figure(1);clf; 
%    for k = 1:1:ctr-1
%        h1(k) = plot(centres,biweek_u_th(:,k),'.-','Color',clrs(k,:));hold on;
%    end
%    h1(k+1) = plot(centres,Ustar_th_all,'-','LineWidth',5,'Color',[0.5 0.5 0.5]); hold on;
%    h1(k+2) = plot(centres,Ustar_th_all2,'-','LineWidth',5,'Color',[1 0 0.5]); hold on;
%    eval(['legend(h1,' L ')']);
% %    legend(h1,'2003','2004','2005','2006','2007','2008','2009','Median','Mean')
%    ylabel('u^{*}', 'FontSize',16)
%    set(gca, 'FontSize',14);
%    print('-dpdf',[fig_path 'u*_th']);
% close all;
% end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% RESPIRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if debug_flag ~= 2
    RE_raw = NaN.*data.NEE;
%     ind_param.RE = find((data.Ustar >= data.Ustar_th & ~isnan(data.Ts5) & ~isnan(data.NEE.*data.NEE_std) & data.PAR < 15 ) |... % growing season
%         ( data.Ustar >= data.Ustar_th & ~isnan(data.NEE.*data.NEE_std) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );  % non-growing season
%      ind_param.RE = find(data.Ustar >= data.Ustar_th & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));
    ind_param.RE = find((data.PAR >= 15 |data.Ustar >= data.Ustar_th) & data.RE_flag == 2 & ~isnan(data.Ts5.*data.NEE.*data.NEE_std));

    RE_raw(ind_param.RE,1) = data.NEE(ind_param.RE,1);
    RE_pred_short = NaN.*ones(length(RE_raw),1);
    RE_pred_long = NaN.*ones(length(RE_raw),1);
    RE_filled_short =  RE_raw;
    RE_filled_long = RE_raw;
    ctr = 1;
    for year = year_start:1:year_end
        RE_in = RE_raw(data.Year == year);
        NEE_std = data.NEE_std(data.Year == year);
        % index for RE data that can be used in parameterization
        % ind_param(ctr).RE = find((data.Year == year &data.Ustar >= Ustar_th(ctr,1) & ~isnan(data.Ts5) & ~isnan(data.NEE) & data.PAR < 15 ) |... % growing season
        %             (data.Year == year & data.Ustar >= Ustar_th(ctr,1) & ~isnan(data.NEE) & ((data.dt < 85 | data.dt > 335) & data.Ts5 < 0.2)  ) );  % non-growing season
        % RE_out = Reich_RE(data, year,
        % RE_in(ind_param(ctr).RE) = data.NEE(ind_param(ctr).RE);
        % RE_in = RE_in(data.Year == year);
        Ts_in = data.Ts5(data.Year == year);
        % Ustar_in = data.Ustar(data.Year == year);
        disp(['year = ' num2str(year)]);
        [RE_short_tmp RE_long_tmp fR] = Reich_RE(RE_in, Ts_in, year,plot_flag, data.costfun, NEE_std);
        % RE_short_tmp and RE_
        RE_pred_short(data.Year == year,1) = RE_short_tmp;
        RE_pred_long(data.Year == year,1) = RE_long_tmp;
        clear RE_short_tmp RE_long_tmp;
        
        if plot_flag == 1
        %%% Print the figures to file:
        for i = 1:1:length(fR); figure(fR(i)); print('-dpdf',[fig_path 'RE_fig' num2str(i) '_' num2str(year)]); end
        close all;
        end
        % options.min_method ='NM'; options.f_coeff = [];
        %     [c_hat(ctr).RE, y_hat(ctr).RE, y_pred(ctr).RE, stats(ctr).RE, sigma(ctr).RE, err(ctr).RE, exitflag(ctr).RE, num_iter(ctr).RE] = ...
        %         fitresp([10 100], 'fitresp_1C', data.Ts5(ind_param(ctr).RE) , data.NEE(ind_param(ctr).RE), data.Ts5(data.Year == year),[], options);
        ctr = ctr+1;
    end
    RE_filled_short(isnan(RE_filled_short),1) = RE_pred_short(isnan(RE_filled_short),1);
    RE_filled_long(isnan(RE_filled_long),1) = RE_pred_long(isnan(RE_filled_long),1);
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% NEE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conditions:
% 1. flux data is missing, but all met data available at that time:
%%% - missing value replaced by the average value under similar
%%% meteorological conditions within a +/-7-day (=14 day) window
%%% Sim. met conditions =
%%% PAR < 75umolm-2s-1; dTa < 2.5C; dVPD < 0.5kPa;  % Altered from Rg < 50Wm-2
%%% to PAR < 75umolm-2s-1
%%% - if no sim conditions within +/-7 days, then go to +/-14 day window.
% 2. flux data and most met data is missing, but PAR is available at that time:
%%% - missing value replaced by the average value under similar
%%% meteorological conditions within a +/-7-day (=14 day) window
%%% Sim. met conditions =
%%% PAR < 75umolm-2s-1;
%%% - if no sim conditions within +/-7 days, then fail.
% 3. flux data and met data is missing:
%%% - missing value replaced by the average value under similar
%%% meteorological conditions within a +/-7-day (=14 day) window
%%% Sim. met conditions =
%%% PAR < 75umolm-2s-1; dTa < 2.5C; dVPD < 0.5kPa;  % Altered from Rg < 50Wm-2
%%% to PAR < 75umolm-2s-1
%%% - if no sim conditions within +/-7 days, then go to +/-14 day window.
% Filled Data Quality Indicators:
%%% A (or 1) -
%%% - data filled using method 1 (7 or 14 days) or method (+/-7days)
%%% - Interpolated from previous and following half-hours
%%% B (or 2) -
%%% - Method 3, using data from same time of day for +/- 1 day
%%% - Method 1 for +/- <=28 days, Method 2 for +/- 14 days
%%% C (or 3) -
%%% Method 1 for > +/- > 28 days, Method 2 for +/- > 14 days
%%% - Method 3, using data > +/- 1 day

% We should be able to do this for all data at once, since there is no
% parameterizatoin of the method based on year

%%% Clean NEE - Remove times where u* is below threshold:
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
% ind_gap = find(isnan(NEE_clean));
wrap_amt = 10*48;
NEE_clean_wrap = [NEE_clean(end-wrap_amt+1:end,1); NEE_clean; NEE_clean(1:wrap_amt,1)];
ind_gap_wrap = find(isnan(NEE_clean_wrap));

ind_all = (1:1:length(NEE_clean))';
ind_all_wrap = [ind_all(end-wrap_amt+1:end,1)-length(NEE_clean); ind_all; ind_all(1:wrap_amt,1)+length(NEE_clean)];

ind_gaps = ind_all_wrap(ind_gap_wrap);
%%% Pre-allocate the filled NEE dataset; use 10 columns, representing different methods of filling:
NEE_fill_wrap = NaN.*ones(length(NEE_clean_wrap),12);
for j = 1:1:12
    NEE_fill_wrap(:,j) = NEE_clean_wrap;
end
NEE_clean_interp = NEE_clean_wrap;

PAR_wrap = [data.PAR(end-wrap_amt+1:end,1); data.PAR; data.PAR(1:wrap_amt,1)];
Ta_wrap = [data.Ta(end-wrap_amt+1:end,1); data.Ta; data.Ta(1:wrap_amt,1)];
VPD_wrap = [data.VPD(end-wrap_amt+1:end,1); data.VPD; data.VPD(1:wrap_amt,1)];
dt_wrap = [data.dt(end-wrap_amt+1:end,1); data.dt; data.dt(1:wrap_amt,1)];
year_wrap = [data.Year(end-wrap_amt+1:end,1); data.Year; data.Year(1:wrap_amt,1)];

%%% Interpolate values for NEE_clean:
dt = (1:1:length(NEE_clean_wrap))';
tmp_NEE_clean_interp = interp1q(dt(~isnan(NEE_clean_wrap),1), NEE_clean_wrap(~isnan(NEE_clean_wrap),1), dt);
tmp_diff1 = diff(ind_gap_wrap);
tmp_diff2 = tmp_diff1(2:end);
ind_interp = ind_gap_wrap(find(tmp_diff1(1:end-1) > 1 & tmp_diff2 >1)+1,1);
NEE_clean_interp(ind_interp,1) = tmp_NEE_clean_interp(ind_interp,1);
clear tmp* dt ind_interp;
% tic;

%% ####################### COMPLETELY ASIDE ##############################
%%% Can we simplify this method using reshaped column vectors instead of
%%% endless loops?
%%% No, I don't think we can, since we're not filling data from the exact
%%% same hhour from a different day, but instead taking values from any
%%% time during a given period (i.e. 2 weeks), when the met values are
%%% acceptibly close to the conditions in the hhour at question.
%##########################################################################
%%%%%%%%%%%%%%%%%%%%%%%
%%
% h = waitbar(0,'Running NEE filling method');
%%% List of all gaps:
PAR_diff = NaN.*ones(length(PAR_wrap),1);
VPD_diff = NaN.*ones(length(VPD_wrap),1);
Ta_diff = NaN.*ones(length(Ta_wrap),1);
dt_diff = NaN.*ones(length(dt_wrap),1);
year_diff = NaN.*ones(length(year_wrap),1);

for k = 1:1:length(ind_gaps)
%     waitbar(k/length(ind_gaps));
    % only fill the data if we're actually in real data (don't fill for the
    % wrapped data)
    if ind_gaps(k) > 0 && ind_gaps(k) <= length(NEE_clean)
        bot_get = max(1, ind_gaps(k)-1681);
        top_get = min(ind_gaps(k)+1680, length(PAR_diff));
        %         PAR_diff = abs(PAR_wrap(ind_gap_wrap(k)) - PAR_wrap);
        %         Ta_diff =  abs(Ta_wrap(ind_gap_wrap(k)) - Ta_wrap);
        %         VPD_diff = abs(VPD_wrap(ind_gap_wrap(k)) - VPD_wrap);
        %         dt_diff = abs(dt_wrap(ind_gap_wrap(k)) - dt_wrap);
        %         year_diff = abs(year_wrap(ind_gap_wrap(k)) - year_wrap);
        PAR_diff(bot_get:top_get,1) = abs(PAR_wrap(ind_gap_wrap(k)) - PAR_wrap(bot_get:top_get,1));
        VPD_diff(bot_get:top_get,1) = abs(VPD_wrap(ind_gap_wrap(k)) - VPD_wrap(bot_get:top_get,1));
        Ta_diff(bot_get:top_get,1) = abs(Ta_wrap(ind_gap_wrap(k)) - Ta_wrap(bot_get:top_get,1));
        dt_diff(bot_get:top_get,1) = abs(dt_wrap(ind_gap_wrap(k)) - dt_wrap(bot_get:top_get,1));
        year_diff(bot_get:top_get,1) = abs(year_wrap(ind_gap_wrap(k)) - year_wrap(bot_get:top_get,1));
        %%%%%% Method 1: 4 loops through the data %%%%%%%%%%%%%%%%%%%%%%%%%
        win_ctr = 1;
        for win = 7:7:28
            ind_bot = max(ind_gap_wrap(k)-win.*48, 1);
            ind_top = min(ind_gap_wrap(k)+win.*48, length(PAR_diff));
            ind_ok = find(PAR_diff(ind_bot:ind_top,1) < 75 & Ta_diff(ind_bot:ind_top,1) < 2.5 & ...
                VPD_diff(ind_bot:ind_top,1) < 0.5 & ~isnan(NEE_clean_wrap(ind_bot:ind_top,1)) );
            if isempty(ind_ok) == 1
                NEE_fill_wrap(ind_gap_wrap(k),win_ctr) =  NaN;
            else
                NEE_fill_wrap(ind_gap_wrap(k),win_ctr) = mean(NEE_clean_wrap(ind_bot+ind_ok-1,1));
            end
            win_ctr = win_ctr+1;
            %%%%% Method 2: 3 loops through data (7, 14, 21 days)
            if win <=21
                ind_ok2 = find(PAR_diff(ind_bot:ind_top,1) < 75 & ~isnan(NEE_clean_wrap(ind_bot:ind_top,1)) );
                if isempty(ind_ok2) == 1
                    NEE_fill_wrap(ind_gap_wrap(k),win_ctr) =  NaN;
                else
                    NEE_fill_wrap(ind_gap_wrap(k),win_ctr) = mean(NEE_clean_wrap(ind_bot+ind_ok2-1,1));
                end
                win_ctr = win_ctr + 1;
            end
            clear ind_ok*;
        end
    else
    end
end
% t1 = toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Method 3: First do linear interpolation (if possible); %%%%%%%%%%%%%%%%
%%% 3a: Fill by linear interpolation for the given half hour:
NEE_fill_wrap(isnan(NEE_fill_wrap(:,win_ctr)),win_ctr) = NEE_clean_interp(isnan(NEE_fill_wrap(:,win_ctr)),1);
win_ctr = win_ctr + 1;
%%% Method 3 (b--d):
%%% - look for substitutes from nearby days at same time; then
%%% - linearly interpolate from nearby hours
rs = reshape(NEE_clean_wrap,48,[]);
rs_interp = reshape(NEE_clean_interp,48,[]);
[r1 c1] = find(isnan(rs));
rs1_same = rs; rs7_same = rs; rs7_all = rs_interp; rs14_all = rs_interp;
for i = 1:1:length(c1)
    if c1(i)>=8 && c1(i)<= (size(rs,2)-7)
        rs7_same(r1(i),c1(i)) = nanmean((rs(r1(i), c1(i)-7:c1(i)+7))');
    end
    if c1(i)>=8 && c1(i)<= (size(rs,2)-7)
        rs7_all(r1(i),c1(i)) = nanmean((rs_interp(r1(i), c1(i)-7:c1(i)+7))');
    end
    if c1(i)>=15 && c1(i)<= (size(rs,2)-14)
        rs14_all(r1(i),c1(i)) = nanmean((rs_interp(r1(i), c1(i)-14:c1(i)+14))');
    end
    if c1(i)>=2 && c1(i)<= (size(rs,2)-1)
        rs1_same(r1(i),c1(i)) = nanmean((rs(r1(i), c1(i)-1:c1(i)+1))');
    end
end
%%% 3b: Fill by values at the exact same hhour for span of +/-7 days
NEE_fill_wrap(:,win_ctr) = rs7_same(:);
win_ctr = win_ctr+1;
%%% 3c: Fill by values interpolated for span of +/-7 days
NEE_fill_wrap(:,win_ctr) = rs7_all(:);
win_ctr = win_ctr+1;
%%% 3d: Fill by values real or interpolated for span of +/-14 days
NEE_fill_wrap(:,win_ctr) = rs14_all(:);
win_ctr = win_ctr+1;
%%% 3e: Fill by real values from adjacent days, same hhour
NEE_fill_wrap(:,win_ctr) = rs1_same(:);

%%%%%%%%%%%%%%
%%% Trim the filled data down to the proper size, calculate gaps in each:
NEE_fill_final = NaN.*ones(length(NEE_clean),12);
for i = 1:1:size(NEE_fill_wrap,2)
    NEE_fill_final(:,i) = NEE_fill_wrap(wrap_amt+1:end-wrap_amt,i);
    num_gaps(i,1) = length(find(isnan(NEE_fill_final(:,i))));
end
% t_fulltime = toc
% close(h) % Closes the progress bar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fill the NEE data, using order specified by Reichstein:
% Structure of NEE_fill_wrap:
% col   1: Method 1 (7)
%       2: Method 2(7)
%       3: Method 1(14)
%       4: Method 2(14)
%       5: Method 1(21)
%       6: Method 2(21)
%       7: Method 1(28)
%       8: Method 3(interpolated in situ)
%       9: Method 3(exact +/-7)
%       10: Method 3(interp +/-7)
%       11: Method 3(real or interp +/-14)
%       12: Method 3(exact +/- 1)
fill_order =  [1 3 2 8 12 5 7 4 6 9 10 11]'; % column numbers in order of priority
fill_quality =[1 1 1 1 2  2 2 2 3 3 3  3]';  % Quality corresponding to column number
NEE_fill = NEE_clean;
NEE_fill_quality = NaN.*ones(length(NEE_clean),1); % Keep track of data quality
NEE_fill_quality(~isnan(NEE_fill),1) = 0;
for i = 1:1:size(NEE_fill_wrap,2)
    ind_fill = find(isnan(NEE_fill) & ~isnan(NEE_fill_final(:,fill_order(i))));
    NEE_fill(ind_fill,1) = NEE_fill_final(ind_fill,fill_order(i));
    NEE_fill_quality(ind_fill,1) = fill_quality(i);
end
num_gaps_final = length(find(isnan(NEE_fill_quality)));
disp(['Final Gaps in NEE = ' num2str(num_gaps_final)]);
for k = 0:1:3
    num_dp = length(find(NEE_fill_quality==k));
disp(['# data points of quality ' num2str(k) ': ' num2str(num_dp) '; = ' num2str((num_dp*100)/length(NEE_fill_quality)) ' %']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Try and get GEP estimates by using filled RE and filled NEE:
if debug_flag ~=2
    GEP_filled = zeros(length(NEE_fill),1);
    GEP_est = RE_pred_short - NEE_fill;
%     ind_GEP = data.PAR >= 15 & ((data.dt > 85 & data.dt < 330 & (data.GDD > 8 | data.Ts5 >= 1 & data.Ta > 2)) ...
%         | data.dt > 330 & data.Ts5 >= 1.25 & data.Ta > 2);
ind_GEP = find(data.GEP_flag>=1);
    
    GEP_filled(ind_GEP,1) = GEP_est(ind_GEP,1);
    GEP_filled(GEP_filled < 0) = 0;
end


%% Plot the final data:
if plot_flag ~=-9
    f_out = figure('Name', 'Final Filled Data');clf
    title('Final Filled Data');
    subplot(2,1,1); title('NEE');
    plot(NEE_fill); hold on;
    plot(NEE_clean,'k.')
    legend('filled','measured');
    subplot(2,1,2);
    hold on;
    plot(RE_filled_short,'r')
    plot(-1.*GEP_filled,'g');
    ylabel('GEE                      RE');
    legend('RE, GEE');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Output the final data:
final_out = struct;
sum_labels = {'Year';'NEE_filled';'NEE_pred'; 'GEP_filled';'GEP_pred';'RE_filled';'RE_pred'};

if debug_flag ~=2
    master.Year = data.Year;
    master.NEE_clean = NEE_clean;
    master.NEE_filled = NEE_fill;
    master.NEE_quality = NEE_fill_quality;    
    master.RE_filled = RE_filled_short;
    master.RE_filled_long= RE_filled_long;
    master.GEP_filled = GEP_filled;
    master.GEP_pred = GEP_est;
    master.RE_pred = RE_pred_short;
    master.RE_pred_long = RE_pred_long;
    
    %%% Do Sums:
    ctr = 1;
    for year = year_start:1:year_end
%         master.sums(ctr,1) = year;
%         master.sums(ctr,2) = sum(master.NEE_filled(data.Year==year)).*0.0216;
%         master.sums(ctr,3) = sum(master.GEP_filled(data.Year==year)).*0.0216;
%         master.sums(ctr,4) = sum(master.RE_filled_short(data.Year==year)).*0.0216;
%         master.sums(ctr,5) = sum(master.RE_filled_long(data.Year == year)).*0.0216;
        master.sums(ctr,1) = year;
        master.sums(ctr,2) = sum(master.NEE_filled(data.Year==year)).*0.0216;
        master.sums(ctr,3) = NaN; % NEE_pred not available in this method.
        master.sums(ctr,4) = sum(master.GEP_filled(data.Year==year)).*0.0216;
        master.sums(ctr,5) = sum(master.GEP_pred(data.Year==year)).*0.0216;
        master.sums(ctr,6) = sum(master.RE_filled(data.Year==year)).*0.0216;
        master.sums(ctr,7) = sum(master.RE_pred(data.Year==year)).*0.0216;
ctr = ctr + 1;
    end
final_out.master.sum_labels = sum_labels;
final_out.master = master;
final_out(1).tag = 'MDS_JJB1';   
end
disp('mcm_Gapfill_MDS_JJB1 done!');
% save([ls 'Matlab/Data/Gapfilling/TP39/MDS_JJB1_fill_2003-2009.mat'], 'master')
end

%% END OF MAIN FUNCTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [RE_short RE_long fR] = Reich_RE(RE_in, Ts_in, year_in, plot_flag, costfun, NEE_std)
%%% Note: RE_short and RE_long are PREDICTED values -- not filled.
%%%
if plot_flag == 1
else
    fR = [];
end
yr_str = num2str(year_in);
options.min_method ='NM'; options.f_coeff = [];options.costfun = costfun;

win_size = round(15*48/2); % 15 days of hhours (divided by 2 to make one-sided)
incr = (5*48); % increment by 5 days
% len_data = yr_length(year,30);
% Wrap the variables around so we can start interval centre on the start of
% the data:
wrap_RE = [RE_in(end-win_size+1:end,1); RE_in; RE_in(1:win_size,1)];
wrap_Ts = [Ts_in(end-win_size+1:end,1); Ts_in; Ts_in(1:win_size,1)];
wrap_NEE_std = [NEE_std(end-win_size+1:end,1); NEE_std; NEE_std(1:win_size,1)];
% Set the centres for windows:
centres = (1:incr:length(RE_in))';
if centres(end) < length(RE_in); centres = [centres; length(RE_in)]; end
centres = centres + win_size;
% RE_pred = NaN.*ones(length(wrap_RE),1);
%% Step 1a: Windowed Parameterization for Eo (Eo_short):
for i = 1:1:length(centres)
%     if i == 75;
%         disp('hold')
%     end
    try
        RE_temp = wrap_RE(centres(i)-win_size:centres(i)+win_size);
        Ts_temp = wrap_Ts(centres(i)-win_size:centres(i)+win_size);
        NEE_std_temp = wrap_NEE_std(centres(i)-win_size:centres(i)+win_size);
        ind_use = find(~isnan(RE_temp.*NEE_std_temp));
        RE_use = RE_temp(ind_use);
        Ts_use = Ts_temp(ind_use);
        NEE_std_use = NEE_std_temp(ind_use);
        num_pts(i,1) = length(RE_use);
        if num_pts(i,1) < 20
            c_hat_RE(i,1:2) = NaN;
            stats_RE(i,1:2) = NaN;
            rel_error_RE(i,1) = NaN;
        elseif (max(Ts_use) - min(Ts_use)) < 4
            c_hat_RE(i,1:2) = NaN;
            stats_RE(i,1:2) = NaN;
            rel_error_RE(i,1) = NaN;
            
        else
            clear global;
            % Run parameterization, gather c_hat values:
            [c_hat_RE(i,:), y_hat(i).RE, y_pred(i).RE, stats(i).RE, sigma(i).RE, err(i).RE, exitflag(i).RE, num_iter(i).RE] = ...
                fitresp([10 100], 'fitresp_1C', Ts_use , RE_use, wrap_Ts(centres(i)-win_size:centres(i)+win_size),NEE_std_use, options);
            % gather stats:
            stats_RE(i,1:2) = [stats(i).RE.rRMSE stats(i).RE.MAE];
            rel_error_RE(i,1) = std(y_pred(i).RE)./nanmean(y_pred(i).RE);
        end
    catch
        disp(i);
    end
    %     RE_pred(centres(i)-win_size:centres(i)+win_size) = y_pred(i).RE;
end

%% Step 1b: All-year parametization for Eo (Eo_long):
RE_param = RE_in(~isnan(RE_in.*NEE_std));
Ts_param = Ts_in(~isnan(RE_in.*NEE_std));
NEE_param = NEE_std(~isnan(RE_in.*NEE_std));
% Run parameterization, gather c_hat values:
clear global;
[c_hat_RE_all, y_hat_RE_all, y_pred_RE_all, stats_RE_all, sigma_RE_all, err_RE_all, exitflag_RE_all, num_iter_RE_all] = ...
    fitresp([10 100], 'fitresp_1C', Ts_param , RE_param, Ts_in,NEE_param, options);

%% Step 2: Select the proper value of Eo_short:
%%% Filter out to use only good periods (Eo 0-450, rel error < %50)
ind_use_Eo = find(c_hat_RE(:,2) > 0 & c_hat_RE(:,2) < 450 & rel_error_RE < 0.5);
Eo_use = c_hat_RE(ind_use_Eo,2);
error_use = rel_error_RE(ind_use_Eo);
stats_use = stats_RE(ind_use_Eo,:);
%%% Approach 1: Use the 3 periods with the smallest relative root mean
%%% square error (rRMSE).  Changed from relative error.
[sort_error ind_sort_error] = sort(stats_use(:,1),'ascend');
try
    Eo_short1 = mean(Eo_use(ind_sort_error(1:3)));
catch
    Eo_short1 = NaN;
end
%%% Approach 2: Use all periods, but weight by the relative error:
% tot_error = sum(rel_error_RE(ind_use_Eo));
weight1 = (1./error_use)./(sum(1./error_use)); % weight using rel error
weight2 = (1./stats_use(:,1))./(sum(1./stats_use(:,1))); % weight using rRMSE
Eo_short2a = sum(Eo_use.*weight1);
Eo_short2b = sum(Eo_use.*weight2);

disp(['Eo_short1 = ' num2str(Eo_short1)]);
disp(['Eo_short2a = ' num2str(Eo_short2a)]);
disp(['Eo_short2b = ' num2str(Eo_short2b)]);

%%% Select values for Eo short and long
Eo_short = Eo_short2b;
Eo_long = c_hat_RE_all(1,2);

if plot_flag == 1;
%%% Plot results for Eo:
fR(1) = figure(1);clf;
plot(centres(ind_use_Eo,1),Eo_use(:,1),'.-'); hold on;
plot([1 centres(end)], [Eo_long Eo_long],'r--');
plot([1 centres(end)], [Eo_short Eo_short],'g--');
legend('E_{0,used}','E_{0,long}', 'E_{0,short}');
title(['Year = ' yr_str '; E_{0} estimates']);
set(gca, 'FontSize', 14);

fR(2) = figure(2);clf;
[AX h1 h2] = plotyy((1:1:length(Ts_in)),Ts_in, (1:1:length(Ts_in)), y_pred_RE_all,@line, @line);hold on;
set(get(AX(2),'YLabel'), 'String','Re','FontSize', 16,'Color', [0 0.6 0])
set(get(AX(1),'YLabel'), 'String','Ts','FontSize', 16, 'Color','b')
% Set y ticks and labels:
set(AX(2),'YTick', [0:5:15]', 'YTickLabel',{'0';'5';'10';'15'},'FontSize',16)
set(AX(1),'YTick', [-5:10:25]', 'YTickLabel',{'-5';'5';'15';'25'},'FontSize',16)
set(AX(1),'XLim',[1 length(Ts_in)],'YLim',[-5 25])
set(AX(2),'XLim',[1 length(Ts_in)])
title(['Year = ' yr_str '; RE (all year) & Ts']);
set(AX(2), 'FontSize', 14);
set(AX(1), 'FontSize', 14);
end
% disp('Eo done');

%% Step 3: Windowed parameterization for Rref, using Eo_short and Eo_long:
%%% Instead of using strict 4 day window (like in Richardson), use a total
%%% of 100 available data points, and place that value of Rref at the arithmetic m
%%% mean of the data points index value:
win_size2 = 100;
incr2 = 25;
ind_use = find(~isnan(RE_in.*NEE_std));
%%% Wrap the data:
RE_wrap2 = [RE_in(ind_use(end-(win_size2/2 -1):end),1); RE_in(ind_use); RE_in(ind_use(1:win_size2/2),1)];
Ts_wrap2 = [Ts_in(ind_use(end-(win_size2/2 -1):end),1); Ts_in(ind_use); Ts_in(ind_use(1:win_size2/2),1)];
NEE_std_wrap2 = [NEE_std(ind_use(end-(win_size2/2 -1):end),1); NEE_std(ind_use); NEE_std(ind_use(1:win_size2/2),1)];
ind_wrap2 = [ind_use(end-(win_size2/2 -1):end,1)-length(RE_in); ind_use; ind_use(1:win_size2/2,1)+length(RE_in)];

st_pts = (1:incr2:length(ind_wrap2)- win_size2)';

for j = 1:1:length(st_pts)
    RE_temp = RE_wrap2(st_pts(j):st_pts(j)+win_size2-1,1);
    Ts_temp = Ts_wrap2(st_pts(j):st_pts(j)+win_size2-1,1);
    ind_temp = ind_wrap2(st_pts(j):st_pts(j)+win_size2-1,1);
    NEE_std_temp = NEE_std_wrap2(st_pts(j):st_pts(j)+win_size2-1,1);
    
    data_centre(j,1) = round(mean(ind_temp));
    % Run Rref parameterization for Eo_long:
    clear global;
    options.f_coeff = [NaN, Eo_long];
    [c_hat_Rref_long(j,:), y_hat, y_pred, stats, sigma, err, exitflag, num_iter] = ...
        fitresp([10 Eo_long], 'fitresp_1C', Ts_temp , RE_temp, Ts_temp,NEE_std_temp, options);
    stats_Rref_long(j,1:2) = [stats.rRMSE stats.MAE];
    % Run Rref parameterization for Eo_short:
    clear stats global;
    options.f_coeff = [NaN, Eo_short];
    [c_hat_Rref_short(j,:), y_hat, y_pred, stats, sigma, err, exitflag, num_iter] = ...
        fitresp([10 Eo_short], 'fitresp_1C', Ts_temp , RE_temp, Ts_temp,NEE_std_temp, options);
    stats_Rref_short(j,1:2) = [stats.rRMSE stats.MAE];
    clear stats global;
end
%%% Can we linearly interpolate the values in between?
xi = (1:1:length(RE_in))';
first_Rref_long = c_hat_Rref_long(find(~isnan(c_hat_Rref_long),1,'first'),1);
Rref_long_interp = interp1(data_centre,c_hat_Rref_long(:,1),xi,'linear',first_Rref_long);
first_Rref_short = c_hat_Rref_short(find(~isnan(c_hat_Rref_short),1,'first'),1);
Rref_short_interp = interp1(data_centre,c_hat_Rref_short(:,1),xi,'linear',first_Rref_short);

if plot_flag == 1;
fR(3) = figure(3);clf;
plot(data_centre,c_hat_Rref_long(:,1),'bo');hold on;
f4(1) = plot(xi, Rref_long_interp,'b--');
plot(data_centre,c_hat_Rref_short(:,1),'ro');hold on;
f4(2) = plot(xi, Rref_short_interp,'r--');
legend(f4,'Rref_{Eo,long}', 'Rref_{Eo,short}');
title(['Year = ' yr_str '; Rref']);
set(gca, 'FontSize', 14);
end
% tic;
%%% Step 4: Evaluate each set of parameters to get estimates of RE:
RE_long = NaN.*ones(length(RE_in),1);
RE_short = NaN.*ones(length(RE_in),1);
for k = 1:1:length(RE_in)
    RE_long(k,1) = fitresp_1C([Rref_long_interp(k,1) Eo_long],Ts_in(k,1));
    RE_short(k,1) = fitresp_1C([Rref_short_interp(k,1) Eo_short],Ts_in(k,1));
end
% t = toc
%%% Plot both estimates:
if plot_flag == 1;
fR(4) = figure(4);clf;
[AX h1 h2] = plotyy((1:1:length(Ts_in)),RE_long, (1:1:length(Ts_in)), RE_short,@line, @line);hold on;
set(get(AX(2),'YLabel'), 'String','RE_{short}','FontSize', 16,'Color', [0 0.6 0])
set(get(AX(1),'YLabel'), 'String','RE_{long}','FontSize', 16, 'Color','b')
% Set y ticks and labels:
% set(AX(2),'YTick', [0:5:15]', 'YTickLabel',{'0';'5';'10';'15'},'FontSize',16)
% set(AX(1),'YTick', [0:5:15]',
% 'YTickLabel',{'0';'5';'10';'15'},'FontSize',16)
set(AX(1),'YTick', [0:2:16]', 'YTickLabel',{0:2:16},'FontSize',16)
set(AX(2),'YTick', [0:2:16]', 'YTickLabel',{0:2:16},'FontSize',16)
set(AX(1),'XLim',[1 length(Ts_in)],'YLim',[0 12])
set(AX(2),'XLim',[1 length(Ts_in)],'YLim',[0 12])
title(['Year = ' yr_str '; Estimates RE']);
set(AX(2), 'FontSize', 14);
set(AX(1), 'FontSize', 14);
end
end