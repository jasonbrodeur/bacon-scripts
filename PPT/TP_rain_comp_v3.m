% TP_rain_comp.m
%% This script attempts to fix problems with PPT data for TP met stations
%% OPTION - adjust this to toggle between options:
% opt = 2;
%% Path -- change to location of attached (unzipped) zip file
% clear all
% close all
addpath_loadstart
clrs = [1 0 0; 0 1 0; 0 0 1; 0 0 0; 0.5 0.5 0.2; 0.1 0.6 0.7; 0.1 0.3 0.6];
path = [loadstart 'Matlab/Data/'];
% 
% if exist([path 'PPT/TP39_PPT.mat'])==2 & exist([path 'PPT/TP02_PPT.mat'])==2 & ...
% exist([path 'PPT/delhi_PPT.mat'])==2
try 
    TP39_tmp  = load([path 'PPT/TP39_PPT.mat']);
    TP02_tmp  = load([path 'PPT/TP02_PPT.mat']);
    delhi_tmp  = load([path 'PPT/delhi_PPT.mat']);
    TP02 = TP02_tmp.TP02;
    TP39 = TP39_tmp.TP39;
    delhi = delhi_tmp.delhi;
   clear *_tmp  
catch   

%% Step 1: Load Processed data from Met Sites:\
ctr = 1;
for year = 2003:1:2005
    TP02(ctr).hh = load([path 'Flux/OPEC/Organized2/TP02/Column/TP02_' num2str(year) '.029']);
    TP39(ctr).hhRMY = load([path 'Flux/OPEC/Organized2/TP39/Column/TP39_' num2str(year) '.036']);
    TP39(ctr).hhCS = NaN.*ones(length(TP39(ctr).hhRMY),1);

    ctr = ctr + 1;

end

for year = 2006:1:2007
    TP02(ctr).hh = load([path 'Met/Cleaned3/TP02/TP02_' num2str(year) '.014']);
    TP39(ctr).hhRMY = load([path 'Met/Cleaned3/TP39/TP39_' num2str(year) '.017']);
    TP39(ctr).hhCS = load([path 'Met/Cleaned3/TP39/TP39_' num2str(year) '.038']);
    ctr = ctr + 1;

end

%%% Make a combined TP39 dataset
for k = 1:1:5
    TP39(k).hh = TP39(k).hhRMY;
end
TP39(5).hh(9150:17520) = TP39(5).hhCS(9150:17520);

%% Load data submitted to CCP:
ctr = 1;
for year = 2003:1:2007
    tmp = load([path 'CCP/Final_dat/TP02_final_' num2str(year) '.dat']);
    TP02(ctr).CCP = tmp(:,35);
    TP02(ctr).PAR = tmp(:,27);
    TP02(ctr).RH = tmp(:,31);
    TP02(ctr).WS = tmp(:,32);
    TP02(ctr).SM5a = tmp(:,48);
    TP02(ctr).SM5b = tmp(:,53);
    clear tmp;
    tmp = load([path 'CCP/Final_dat/TP39_final_' num2str(year) '.dat']);
    TP39(ctr).CCP = tmp(:,45);
    TP39(ctr).PAR = tmp(:,33);
    TP39(ctr).RH = tmp(:,39);
    TP39(ctr).WS = tmp(:,42);
    TP39(ctr).SM5a = tmp(:,58);
    TP39(ctr).SM5b = tmp(:,63);

    clear tmp;
    ctr = ctr +1;

end
%% Load data in TP_PPT_adj2 to see what is going on with it:

tmp_TP39 = load([path 'PPT/TP39_adj2.dat']);
tmp_TP02 = load([path 'PPT/TP02_adj2.dat']);

for j = 1:1:5
    TP39(j).adj = tmp_TP39(:,j);
    TP02(j).adj = tmp_TP02(:,j);

end
clear tmp*

%% Load in Delhi (daily) Data
delhi_tmp = load([path 'PPT/Delhi_PPT_02-08.dat']);
for k = 1:1:5
    delhi(k).day = delhi_tmp(:,k+1);
end
clear delhi_tmp

%% Get annual numbers and cumulative sums:
for j = 1:1:5
    TP39(j).hhRMY_cum = nan_cumsum(TP39(j).hhRMY);
    TP39(j).hhCS_cum = nan_cumsum(TP39(j).hhCS);
    TP39(j).CCP_cum = nan_cumsum(TP39(j).CCP);
    TP02(j).hh_cum = nan_cumsum(TP02(j).hh);
    TP02(j).CCP_cum = nan_cumsum(TP02(j).CCP);

    % daily averages
    TP39(j).dayRMY = daily_sum(TP39(j).hhRMY,48);
    TP39(j).dayCS = daily_sum(TP39(j).hhCS,48);
    TP39(j).dayCCP = daily_sum(TP39(j).CCP,48);
    TP39(j).day = daily_sum(TP39(j).hh,48);
    TP39(j).day_adj = daily_sum(TP39(j).adj,48);

    TP02(j).day = daily_sum(TP02(j).hh,48);
    TP02(j).dayCCP = daily_sum(TP02(j).CCP,48);
    TP02(j).day_adj = daily_sum(TP02(j).adj,48);

    % Daily Cumulative Sums:
    TP39(j).dayRMY_cum = nan_cumsum(TP39(j).dayRMY);
    TP39(j).dayCS_cum = nan_cumsum(TP39(j).dayCS);
    TP39(j).dayCCP_cum = nan_cumsum(TP39(j).dayCCP);
    TP39(j).day_cum = nan_cumsum(TP39(j).day);
    TP39(j).day_adj_cum = nan_cumsum(TP39(j).day_adj);

    TP02(j).day_cum = nan_cumsum(TP02(j).day);
    TP02(j).dayCCP_cum = nan_cumsum(TP02(j).dayCCP);
    delhi(j).day_cum = nan_cumsum(delhi(j).day);
    TP02(j).day_adj_cum = nan_cumsum(TP02(j).day_adj);

end

%% Save the 3 variables:
save([path 'PPT/TP39_PPT'],'TP39');
save([path 'PPT/TP02_PPT'],'TP02');
save([path 'PPT/delhi_PPT'],'delhi');

end %end to the 'try'

%%
% Problems to consider:
% A) events measured where no events occurred (accidental tips)
% B) overestimation when the bucket was not properly upright
% C) underestimation at other times (not entirely sure why this happens -- winter freezing, high winds, multiplier set wrong)
% D) complete misses by rain guage (broken/ missing data)
% 
% Step 1: Identifying:
% For A: filter out with high PAR, b) low RH (< 85 maybe, since it's average?). 
% For B: comparison with other stations (although definitely not foolproof)
% For C: Also by comparison
% For D: Also by comparison.. can also check Soil Moisture.

%%% Plot PAR observed for each hhour rain event at TP39,02:
for j = 1:1:5
    PAR(j).TP39 = TP39(j).PAR((TP39(j).hh > 0),1);
    PAR(j).TP02 = TP39(j).PAR((TP02(j).hh > 0),1);  
    PPT_events(1,j) = length(find(TP39(j).hh > 0));
     PPT_events(2,j) = length(find(TP02(j).hh > 0));
    figure(99)
    plot(PAR(j).TP39,'.','Color',clrs(j,:)); hold on
     figure(98)
    plot(PAR(j).TP02,'.','Color',clrs(j,:)); hold on
    
end
    
fignum = 10;
%%% Plot regression between different daily values and Delhi:
for j = 1:1:5
    figure(fignum)
    subplot(3,2,j)
    plot(delhi(j).day(1:length(TP39(j).day),1) ,TP39(j).day,'b.'); hold on;
    plot([0 50], [0 50], 'k--');
    ylabel('TP39')
    xlabel('Delhi');
    axis([0 50 0 50])
    
    
    figure(fignum+1)
    subplot(3,2,j)
    plot(delhi(j).day(1:length(TP02(j).day),1),TP02(j).day,'b.'); hold on;
    plot([0 50], [0 50], 'k--');
    ylabel('TP02')
    xlabel('Delhi');    
     axis([0 50 0 50])
end






%% Plot Daily Cumulative Sums
% figure(fnum); clf
for j = 1:1:5
    %     subplot(3,2,j)
    figure(j); clf
    plot(delhi(j).day_cum,'b-','LineWidth',2); hold on;
    plot(TP39(j).dayRMY_cum,'r-','LineWidth',1.5)
    plot(TP39(j).dayCS_cum,'k-')
    plot(TP39(j).dayCCP_cum,'g--')


    plot(TP39(j).day_adj_cum,'--','Color',clrs(5,1:3))
    plot(TP39(j).day_cum,':','Color',clrs(6,1:3))

    plot(TP02(j).day_cum,'m-','LineWidth',1.5)
    plot(TP02(j).dayCCP_cum,'c--')
    plot(TP02(j).day_adj_cum,'-','Color',clrs(7,1:3))

    legend('delhi','39-rmy','39-cs','39-ccp', '39-adj', '39-corr','02-rmy','02-ccp', '02-adj',2)
end


fnum = 1;
fnum = fnum+1;

%%% What we see in this graph:
% 2003:
% TP39 RMY data is same as CCP
% TP02 RMY data same as CCP - but correction for giant spike.
% Similarity between delhi and TP39
%%%
% 2004:
% TP39 RMY data is same as CCP
% TP02 RMY data same as CCP - but flatline after day ~ 195.
% Similarity between delhi and TP39
%%%
% 2005:
% TP39 RMY data is same as CCP
% TP02 RMY data same as CCP - but flatline after day ~ 195.
% Similarity between TP02 and TP39 -- but quite lower than delhi
%%%
% 2006:
% TP39 RMY data is NOT the same as CCP -- RMY > CCP
% TP02 RMY data same as CCP.
% CLOSE Similarity between delhi and TP02 -- but TP39 overest by 300-400 mm
%%%
% 2004:
% TP39 RMY data is same as CCP
% TP02 RMY data same as CCP - but flatline after day ~ 195.
% Similarity between delhi and TP39




%% 1. See what numbers were submitted to CCP:
% figure(1);clf
% figure(2);clf
% for j = 1:1:5
%     figure(1)
% subplot(2,3,j)
% plot(TP39(j).hhRMY(:,1), TP39(j).CCP(:,1),'b.');hold on;
% plot([0 50],[0 50],'k--')
% title ('TP39 RMY vs CCP');
%
% figure(2)
% subplot(2,3,j)
% plot(TP02(j).hh(:,1), TP02(j).CCP(:,1),'b.'); hold on;
% plot([0 50], [0 50],'k--')
% title ('TP02 RMY vs CCP');
% end
%
% %%% It appears that:
% % TP39
% % data from 2003-2005 are straight from the RMY
% % data from 2006-2007 are processed
% % TP02
% % all data is from site.
%
%
%
%
%
% %% 2. Investigate difference between RMY and CS
% %% during overlap in 2007:
% % CS between 9150:17520
% % RMY between 0 and 13900
% % overlap: 9150:13900
% overlap = (9150:1:13900)';
% figure(3); clf
% plot(TP39(5).hhRMY(overlap,1), TP39(5).hhCS(overlap,1),'b.');
% t = polyfit(TP39(5).hhRMY(overlap,1),TP39(5).hhCS(overlap,1),1);
% %%% RMY is nearly 2x higher than CS estimates.
%
% %% Let's compare
%
%
% %% Load daily files:
% Delhi_data = dlmread([path 'Delhi_Day_Precip_2002_2007.csv'], ',');
% Delhi_PPT = Delhi_data(2:367,1:6); % 2002-2007 data
% TP02_data = load([path 'TP02_Daily_Precip_2002_2007.txt']);
% %% Load 1/2 hourly files
% TP39hh = dlmread([path 'TP39_hh_Precip.csv'],',');
% TP39_2007_RMY = load([path 'Met1_2007.017']);
% TP02hh = dlmread([path 'TP02_hh_Precip.csv'],',');
% %% Rules:
% % MET 4:
% % if Ta < 0 - use Delhi data
% % treat summer data as real data, unless a problem is found.
% %%% Missing data:
% % take rainfall hours from Met 1
% % apply proportion to Delhi daily data
%
% for k = 1:1:5
%     TP02(k).data = TP02hh(:,k);
%     TP02(k).cumsum = cumsum(TP02hh(:,k));
%     TP02(k).nancumsum = nancumsum(TP02hh(:,k));
%     TP02(k).nans = find(isnan(TP02hh(:,k)));
%     TP02(k).ptsused = length(find(~isnan(TP02hh(:,k))));
%
%     TP39(k).data = TP39hh(:,k);
%     TP39(k).cumsum = cumsum(TP39hh(:,k));
%     TP39(k).nancumsum = nancumsum(TP39hh(:,k));
%     TP39(k).nans = find(isnan(TP39hh(:,k)));
%     TP39(k).ptsused = length(find(~isnan(TP39hh(:,k))));
%
%     %     figure(1)
%     Delhi_cumsum = nancumsum(Delhi_PPT);
%     Delhi_tot = Delhi_cumsum(end,:);
%
% end
%
% %% Quickly compare number outputs between 3 sites for each year.
%
% figure(2); clf
%
% for j = 1:1:5
%     plot(j,TP02(j).nancumsum(end),'r.'); hold on
%     plot(j,TP39(j).nancumsum(end),'b.');
%     plot(j,Delhi_tot(j+1),'g.');
%
% end
%
%
% %% Just for fun -- seeing if stuff fits together:
% comb_PPT = [TP39_2007_RMY(1:9150); TP39hh(9151:17520,5)];
% comb_PPT_nansum = nansum(comb_PPT) % gives value of 704.74 (compare to delhi 749.3)
%
% comb_PPT2 = [TP39_2007_RMY(1:13565); TP39hh(13566:17520,5)];
% comb_PPT_nansum2 = nansum(comb_PPT2) % gives value of 826.33 (compare to delhi 749.3)
%
% %% Adding both rain guage data together for TP39, 2007:
% TP39hh(1:17520,5) = comb_PPT;
%
% %% Scatterplot btw RMY and CS rainguages:
% ok_data = find (~isnan(TP39_2007_RMY) & ~isnan(TP39hh(1:17520,5)) & TP39_2007_RMY > 0 & TP39hh(1:17520,5) > 0 );
% figure(7); clf
% plot(TP39hh(ok_data,5),TP39_2007_RMY(ok_data),'b.')
% p = polyfit(TP39hh(ok_data,5),TP39_2007_RMY(ok_data),1);
% pred_RMY = polyval(p,TP39hh(ok_data,5));
% rsq = rsquared(TP39_2007_RMY(ok_data), pred_RMY);
% %%% Results - RMY is consistently 2X higher than CS Rsq = 0.94
%
% %% %%%%%%%%%%%%%%***********************%%%%%%%%%%%%***********************
%
% %% Adjust data based on delhi daily totals and timing of events as taken
% %% from each site.
%
% TP39_adj(1:17568,1:5) = NaN; TP39_adj2(1:17568,1:5) = NaN;
% TP02_adj(1:17568,1:5) = NaN; TP02_adj2(1:17568,1:5) = NaN;
%
% TP02_raw_daysum(1:366,1:5) = NaN; TP39_raw_daysum(1:366,1:5) = NaN;
%
% TP39_adj_daysum(1:366,1:5) = NaN; TP39_adj2_daysum(1:366,1:5) = NaN;
% TP02_adj_daysum(1:366,1:5) = NaN; TP02_adj2_daysum(1:366,1:5) = NaN;
%
% %%% Cycle through years
% for yr = 1:1:5
%     disp(yr);
%
%     for day = 1:1:366
%         switchflag39 = 0; switchflag02 = 0;
%         %%%%% finds if there is PPT recorded during a day at each site:
%         daytot = Delhi_PPT(day,yr+1); if daytot > 0; Delhi_flag = 1; else Delhi_flag = 0; end;% gets the daily precip
%         daytot39 = nansum(TP39hh(day*48-47:day*48,yr)); if daytot39 > 0; TP39_flag = 1; else TP39_flag = 0; end;% daily sum
%         daytot02 = nansum(TP02hh(day*48-47:day*48,yr)); if daytot02 > 0; TP02_flag = 1; else TP02_flag = 0; end % daily sum
%
%         %%%% CASE A: All guages report zero rain:
%         if Delhi_flag == 0 && TP39_flag == 0 && TP02_flag == 0;
%             TP39_adj1(day*48-47:day*48,yr) = 0; TP39_adj2(day*48-47:day*48,yr) = 0; TP39_adj3(day*48-47:day*48,yr) = 0;
%             TP39_adj4(day*48-47:day*48,yr) = 0; TP39_adj5(day*48-47:day*48,yr) = 0; TP39_adj6(day*48-47:day*48,yr) = 0;
%             TP39_adj7(day*48-47:day*48,yr) = 0; TP39_adj8(day*48-47:day*48,yr) = 0;
%
%             TP02_adj1(day*48-47:day*48,yr) = 0; TP02_adj2(day*48-47:day*48,yr) = 0; TP02_adj3(day*48-47:day*48,yr) = 0;
%             TP02_adj4(day*48-47:day*48,yr) = 0; TP02_adj5(day*48-47:day*48,yr) = 0; TP02_adj6(day*48-47:day*48,yr) = 0;
%             TP02_adj7(day*48-47:day*48,yr) = 0; TP02_adj8(day*48-47:day*48,yr) = 0;
%
%             %%%% CASE B: All guages report 1:
%         elseif Delhi_flag == 1 && TP39_flag == 1 && TP02_flag == 1;
%             TP39_adj1(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj2(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj3(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%             TP39_adj4(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj5(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj6(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%             TP39_adj7(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj8(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%
%             TP02_adj1(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj2(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj3(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%             TP02_adj4(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj5(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj6(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%             TP02_adj7(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj8(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%
%             %%%% CASE C: Delhi reports no rain, but the other two guages do:
%         elseif Delhi_flag == 0 && TP39_flag+TP02_flag == 2;
%             TP39_adj1(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj2(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj3(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%             TP39_adj4(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj5(day*48-47:day*48,yr) = 0; TP39_adj6(day*48-47:day*48,yr) = 0;
%             TP39_adj7(day*48-47:day*48,yr) = 0; TP39_adj8(day*48-47:day*48,yr) = 0;
%
%             TP02_adj1(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj2(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj3(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%             TP02_adj4(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj5(day*48-47:day*48,yr) = 0; TP02_adj6(day*48-47:day*48,yr) = 0;
%             TP02_adj7(day*48-47:day*48,yr) = 0; TP02_adj8(day*48-47:day*48,yr) = 0;
%
%             %%%% CASE D: Delhi reports rain and so does one of the two other stations:
%         elseif Delhi_flag == 1 && TP39_flag+TP02_flag == 1;
%
%             if Delhi_flag == 1 && TP39_flag== 1 && TP02_flag == 0;
%                 TP39_adj1(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj2(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj3(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%                 TP39_adj4(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj5(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj6(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%                 TP39_adj7(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj8(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%                 dayfrac39 = TP39hh(day*48-47:day*48,yr)./daytot39;
%
%                 TP02_adj1(day*48-47:day*48,yr) = dayfrac39.*daytot; TP02_adj2(day*48-47:day*48,yr) = dayfrac39.*daytot; TP02_adj3(day*48-47:day*48,yr) = dayfrac39.*daytot;
%                 TP02_adj4(day*48-47:day*48,yr) = dayfrac39.*daytot; TP02_adj5(day*48-47:day*48,yr) = dayfrac39.*daytot; TP02_adj6(day*48-47:day*48,yr) = dayfrac39.*daytot;
%                 TP02_adj7(day*48-47:day*48,yr) = dayfrac39.*daytot; TP02_adj8(day*48-47:day*48,yr) = dayfrac39.*daytot;
%
%             elseif Delhi_flag == 1 && TP39_flag== 0 && TP02_flag == 1;
%                 TP02_adj1(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj2(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj3(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%                 TP02_adj4(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj5(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj6(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%                 TP02_adj7(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj8(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%                 datfrac02 = TP02hh(day*48-47:day*48,yr)./daytot02;
%                 TP39_adj1(day*48-47:day*48,yr) = dayfrac02.*daytot; TP39_adj2(day*48-47:day*48,yr) = dayfrac02.*daytot; TP39_adj3(day*48-47:day*48,yr) = dayfrac02.*daytot;
%                 TP39_adj4(day*48-47:day*48,yr) = dayfrac02.*daytot; TP39_adj5(day*48-47:day*48,yr) = dayfrac02.*daytot; TP39_adj6(day*48-47:day*48,yr) = dayfrac02.*daytot;
%                 TP39_adj7(day*48-47:day*48,yr) = dayfrac02.*daytot; TP39_adj8(day*48-47:day*48,yr) = dayfrac02.*daytot;
%             end
%
%             %%%% CASE E: Delhi reads precip, but there is no rain at either station:
%         elseif Delhi_flag == 1 && TP39_flag+TP02_flag == 0;
%
%             TP39_adj1(day*48-47:day*48,yr) = daytot./48; TP39_adj2(day*48-47:day*48,yr) = 0; TP39_adj3(day*48-47:day*48,yr) = daytot./48;
%             TP39_adj4(day*48-47:day*48,yr) = 0; TP39_adj5(day*48-47:day*48,yr) = daytot./48; TP39_adj6(day*48-47:day*48,yr) = 0;
%             TP39_adj7(day*48-47:day*48,yr) = daytot./48; TP39_adj8(day*48-47:day*48,yr) = 0;
%
%             TP02_adj1(day*48-47:day*48,yr) = daytot./48; TP02_adj2(day*48-47:day*48,yr) = 0; TP02_adj3(day*48-47:day*48,yr) = daytot./48;
%             TP02_adj4(day*48-47:day*48,yr) = 0; TP02_adj5(day*48-47:day*48,yr) = daytot./48; TP02_adj6(day*48-47:day*48,yr) = 0;
%             TP02_adj7(day*48-47:day*48,yr) = daytot./48; TP02_adj8(day*48-47:day*48,yr) = 0;
%
%             %%%% CASE F: Delhi reads precip, but there is no rain at either station:
%         elseif Delhi_flag == 0 && TP39_flag+TP02_flag == 1;
%             if Delhi_flag == 0 && TP39_flag == 1 && TP02_flag == 0;
%                 TP39_adj1(day*48-47:day*48,yr) = 0; TP39_adj2(day*48-47:day*48,yr) = 0; TP39_adj3(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%                 TP39_adj4(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj5(day*48-47:day*48,yr) = 0; TP39_adj6(day*48-47:day*48,yr) = 0;
%                 TP39_adj7(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr); TP39_adj8(day*48-47:day*48,yr) = TP39hh(day*48-47:day*48,yr);
%
%                 TP02_adj1(day*48-47:day*48,yr) = 0; TP02_adj2(day*48-47:day*48,yr) = 0; TP02_adj3(day*48-47:day*48,yr) = 0;
%                 TP02_adj4(day*48-47:day*48,yr) = 0; TP02_adj5(day*48-47:day*48,yr) = 0; TP02_adj6(day*48-47:day*48,yr) = 0;
%                 TP02_adj7(day*48-47:day*48,yr) = 0; TP02_adj8(day*48-47:day*48,yr) = 0;
%
%             elseif Delhi_flag == 0 && TP39_flag == 1 && TP02_flag == 0;
%                 TP39_adj1(day*48-47:day*48,yr) = 0; TP39_adj2(day*48-47:day*48,yr) = 0; TP39_adj3(day*48-47:day*48,yr) = 0;
%                 TP39_adj4(day*48-47:day*48,yr) = 0; TP39_adj5(day*48-47:day*48,yr) = 0; TP39_adj6(day*48-47:day*48,yr) = 0;
%                 TP39_adj7(day*48-47:day*48,yr) = 0; TP39_adj8(day*48-47:day*48,yr) = 0;
%
%                 TP02_adj1(day*48-47:day*48,yr) = 0; TP02_adj2(day*48-47:day*48,yr) = 0; TP02_adj3(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%                 TP02_adj4(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj5(day*48-47:day*48,yr) = 0; TP02_adj6(day*48-47:day*48,yr) = 0;
%                 TP02_adj7(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr); TP02_adj8(day*48-47:day*48,yr) = TP02hh(day*48-47:day*48,yr);
%
%             end
%
%         end % ends 'if' loop
%         TP39_adj1_daysum(day,yr) = nansum(TP39_adj1(day*48-47:day*48,yr)); TP39_adj2_daysum(day,yr) = nansum(TP39_adj2(day*48-47:day*48,yr));
%         TP39_adj3_daysum(day,yr) = nansum(TP39_adj3(day*48-47:day*48,yr)); TP39_adj4_daysum(day,yr) = nansum(TP39_adj4(day*48-47:day*48,yr));
%         TP39_adj5_daysum(day,yr) = nansum(TP39_adj5(day*48-47:day*48,yr)); TP39_adj6_daysum(day,yr) = nansum(TP39_adj6(day*48-47:day*48,yr));
%         TP39_adj7_daysum(day,yr) = nansum(TP39_adj7(day*48-47:day*48,yr)); TP39_adj8_daysum(day,yr) = nansum(TP39_adj8(day*48-47:day*48,yr));
%
%         TP02_adj1_daysum(day,yr) = nansum(TP02_adj1(day*48-47:day*48,yr)); TP02_adj2_daysum(day,yr) = nansum(TP02_adj2(day*48-47:day*48,yr));
%         TP02_adj3_daysum(day,yr) = nansum(TP02_adj3(day*48-47:day*48,yr)); TP02_adj4_daysum(day,yr) = nansum(TP02_adj4(day*48-47:day*48,yr));
%         TP02_adj5_daysum(day,yr) = nansum(TP02_adj5(day*48-47:day*48,yr)); TP02_adj6_daysum(day,yr) = nansum(TP02_adj6(day*48-47:day*48,yr));
%         TP02_adj7_daysum(day,yr) = nansum(TP02_adj7(day*48-47:day*48,yr)); TP02_adj8_daysum(day,yr) = nansum(TP02_adj8(day*48-47:day*48,yr));
%
%     end % ends day loop
%     TP39(yr).dayraw = TP39_raw_daysum(:,yr);
%     TP39(yr).PPT_adj1 = TP39_adj1(:,yr); TP39(yr).adj1cumsum = nancumsum(TP39_adj1(:,yr)); TP39(yr).adj1sum = TP39(yr).adj1cumsum(end); TP39(yr).dayadj1 = TP39_adj_day1sum(:,yr);
%     TP39(yr).PPT_adj2 = TP39_adj2(:,yr); TP39(yr).adj2cumsum = nancumsum(TP39_adj2(:,yr)); TP39(yr).adj2sum = TP39(yr).adj2cumsum(end); TP39(yr).dayadj2 = TP39_adj_day2sum(:,yr);
%     TP39(yr).PPT_adj3 = TP39_adj3(:,yr); TP39(yr).adj3cumsum = nancumsum(TP39_adj3(:,yr)); TP39(yr).adj3sum = TP39(yr).adj3cumsum(end); TP39(yr).dayadj3 = TP39_adj_day3sum(:,yr);
%     TP39(yr).PPT_adj4 = TP39_adj4(:,yr); TP39(yr).adj4cumsum = nancumsum(TP39_adj4(:,yr)); TP39(yr).adj4sum = TP39(yr).adj4cumsum(end); TP39(yr).dayadj4 = TP39_adj_day4sum(:,yr);
%     TP39(yr).PPT_adj5 = TP39_adj5(:,yr); TP39(yr).adj5cumsum = nancumsum(TP39_adj5(:,yr)); TP39(yr).adj5sum = TP39(yr).adj5cumsum(end); TP39(yr).dayadj5 = TP39_adj_day5sum(:,yr);
%     TP39(yr).PPT_adj6 = TP39_adj6(:,yr); TP39(yr).adj6cumsum = nancumsum(TP39_adj6(:,yr)); TP39(yr).adj6sum = TP39(yr).adj6cumsum(end); TP39(yr).dayadj6 = TP39_adj_day6sum(:,yr);
%     TP39(yr).PPT_adj7 = TP39_adj7(:,yr); TP39(yr).adj7cumsum = nancumsum(TP39_adj7(:,yr)); TP39(yr).adj7sum = TP39(yr).adj7cumsum(end); TP39(yr).dayadj7 = TP39_adj_day7sum(:,yr);
%     TP39(yr).PPT_adj8 = TP39_adj8(:,yr); TP39(yr).adj8cumsum = nancumsum(TP39_adj8(:,yr)); TP39(yr).adj8sum = TP39(yr).adj8cumsum(end); TP39(yr).dayadj8 = TP39_adj_day8sum(:,yr);
%
%     TP02(yr).dayraw = TP02_raw_daysum(:,yr);
%     TP02(yr).PPT_adj1 = TP02_adj1(:,yr); TP02(yr).adj1cumsum = nancumsum(TP02_adj1(:,yr)); TP02(yr).adj1sum = TP02(yr).adj1cumsum(end); TP02(yr).dayadj1 = TP02_adj_day1sum(:,yr);
%     TP02(yr).PPT_adj2 = TP02_adj2(:,yr); TP02(yr).adj2cumsum = nancumsum(TP02_adj2(:,yr)); TP02(yr).adj2sum = TP02(yr).adj2cumsum(end); TP02(yr).dayadj2 = TP02_adj_day2sum(:,yr);
%     TP02(yr).PPT_adj3 = TP02_adj3(:,yr); TP02(yr).adj3cumsum = nancumsum(TP02_adj3(:,yr)); TP02(yr).adj3sum = TP02(yr).adj3cumsum(end); TP02(yr).dayadj3 = TP02_adj_day3sum(:,yr);
%     TP02(yr).PPT_adj4 = TP02_adj4(:,yr); TP02(yr).adj4cumsum = nancumsum(TP02_adj4(:,yr)); TP02(yr).adj4sum = TP02(yr).adj4cumsum(end); TP02(yr).dayadj4 = TP02_adj_day4sum(:,yr);
%     TP02(yr).PPT_adj5 = TP02_adj5(:,yr); TP02(yr).adj5cumsum = nancumsum(TP02_adj5(:,yr)); TP02(yr).adj5sum = TP02(yr).adj5cumsum(end); TP02(yr).dayadj5 = TP02_adj_day5sum(:,yr);
%     TP02(yr).PPT_adj6 = TP02_adj6(:,yr); TP02(yr).adj6cumsum = nancumsum(TP02_adj6(:,yr)); TP02(yr).adj6sum = TP02(yr).adj6cumsum(end); TP02(yr).dayadj6 = TP02_adj_day6sum(:,yr);
%     TP02(yr).PPT_adj7 = TP02_adj7(:,yr); TP02(yr).adj7cumsum = nancumsum(TP02_adj7(:,yr)); TP02(yr).adj7sum = TP02(yr).adj7cumsum(end); TP02(yr).dayadj7 = TP02_adj_day7sum(:,yr);
%     TP02(yr).PPT_adj8 = TP02_adj8(:,yr); TP02(yr).adj8cumsum = nancumsum(TP02_adj8(:,yr)); TP02(yr).adj8sum = TP02(yr).adj8cumsum(end); TP02(yr).dayadj8 = TP02_adj_day8sum(:,yr);
% end
%
%
%
%
% %     %% Compare the results:
% %     results(1:8,1:5) = NaN;
% %     results(1,1:5) = Delhi_tot(1,2:6); % Delhi numbers
% %     for k = 1:1:5
% %         results(2,k) = TP39(k).nancumsum(end);
% %         results(3,k) = TP39(k).adjsum;
% %         results(4,k) = TP39(k).adj2sum;
% %         results(5,k) = TP02(k).nancumsum(end);
% %         results(6,k) = TP02(k).adjsum;
% %         results(7,k) = TP02(k).adj2sum;
% %
% %
% %         figure(10+k);clf
% %         plot(nancumsum(Delhi_PPT(:,k+1)),'b-'); hold on
% %         plot(nancumsum(TP39(k).dayraw),'r-');
% %         plot(nancumsum(TP39(k).dayadj),'r--');
% %         plot(nancumsum(TP39(k).dayadj2),'r:');
% %         plot(nancumsum(TP02(k).dayraw),'g-');
% %         plot(nancumsum(TP02(k).dayadj),'g--');
% %         plot(nancumsum(TP02(k).dayadj2),'g:');
% %
% %         legend('Delhi','TP39raw','TP39adj1','TP39adj2','TP02raw','TP02adj1','TP02adj2',2);
% %     end
% %     %% Package the data:
% %
% % for k = 1:1:5
% % out_TP02_raw(:,k) = TP02(k).data;
% % out_TP02_adj1(:,k) = TP02(k).PPT_adj1;
% % out_TP02_adj2(:,k) = TP02(k).PPT_adj2;
% %
% % for k = 1:1:5
% % out_TP02_raw(:,k) = TP02(k).data;
% % out_TP02_adj1(:,k) = TP02(k).PPT_adj1;
% % out_TP02_adj2(:,k) = TP02(k).PPT_adj2;

