function [] = OPEC_compiler(site)
%%% OPEC_compiler.m
%%% usage: OPEC_compiler()
%%%
%%%
%%% This function compiles OPEC data from 3 different sources:
%%% 1. hhour data calculated from high frequency data (through EdiRe)
%%% 2. hhour data calculated from 10-min averages
%%% 3. hhour data from pre-existing data, which was calculated pre-2007,
%%% and for which some of the raw 10min and hfreq data was not found, and
%%% therefore, could not be calculated.
%%%*** Data will be included into the final matrix with preference given
%%%    according to the rankings above..
%%%
%%% Created July 29, 2010 by JJB
%
%
%

if nargin == 0 || isempty(site)==1 || (~isempty(site) && ~ischar(site))
    site = input('Enter Site Name (e.g. TP74, TP02, etc): ','s'); %Gets site name
end
% if nargin < 2
%     qtflag = 0;
% end
ls = addpath_loadstart('off');
%%% Declare Paths:
% load_path_cleaned = [ls 'Matlab/Data/Flux/OPEC/' site '/Final_Cleaned/']; % For the cleaned-up data...
load_path_calc    = [ls 'Matlab/Data/Flux/OPEC/' site '/Final_Calculated/']; % For new data created (rotated, storage)
% load_path_master =  [ls 'Matlab/Data/Master_Files/' site '/'];
% met_path = [ls 'Matlab/Data/Met/Final_Cleaned/' site '/']; % Data where the final_cleaned met data is stored...


% %%% Load the old data first:
% %%%
% Fc = [];  Ustar = []; LE = []; Hs = [];  CO2_top = []; CO2_cpy = []; H2O_top = [];
% NEE = []; dcdt = []; Jt = [];
% 
% % ctr = 1;
% for i = 2002:1:2014
%     if i <= 2008
%         try tmp_Fc = load([load_path_cleaned site '_' num2str(i) '.Fc']);catch; disp(['Fc err, ' num2str(i)]);tmp_Fc = NaN.*ones(yr_length(i, 30),1); end; Fc = [Fc ; tmp_Fc];
%         try tmp_Ustar = load([load_path_cleaned site '_' num2str(i) '.Ustar']);catch;  disp(['u* err, ' num2str(i)]);tmp_Ustar = NaN.*ones(yr_length(i, 30),1); end; Ustar = [Ustar ; tmp_Ustar];
%         try tmp_LE = load([load_path_cleaned site '_' num2str(i) '.LE']);catch;  disp(['LE err, ' num2str(i)]);tmp_LE = NaN.*ones(yr_length(i, 30),1); end; LE = [LE ; tmp_LE];
%         try tmp_Hs = load([load_path_cleaned site '_' num2str(i) '.Hs']);catch;  disp(['Hs err, ' num2str(i)]);tmp_Hs = NaN.*ones(yr_length(i, 30),1); end; Hs = [Hs ; tmp_Hs];
%         try tmp_CO2_top = load([load_path_cleaned site '_' num2str(i) '.CO2_irga']);catch;  disp(['CO2_top err, ' num2str(i)]);tmp_CO2_top = NaN.*ones(yr_length(i, 30),1); end; CO2_top = [CO2_top ; tmp_CO2_top];
%         try tmp_CO2_cpy = load([load_path_cleaned site '_' num2str(i) '.CO2_cpy']);catch;  disp(['CO2_cpy err, ' num2str(i)]);tmp_CO2_cpy = NaN.*ones(yr_length(i, 30),1); end; CO2_cpy = [CO2_cpy ; tmp_CO2_cpy];
%         try tmp_H2O_top = load([load_path_cleaned site '_' num2str(i) '.H2O_irga']);catch;  disp(['H2O_top err, ' num2str(i)]);tmp_H2O_top = NaN.*ones(yr_length(i, 30),1); end; H2O_top = [H2O_top ; tmp_H2O_top];
%         try tmp_NEE_raw = load([load_path_calc site '_' num2str(i) '.NEE_raw']);catch;  disp(['NEE err, ' num2str(i)]);tmp_NEE_raw = NaN.*ones(yr_length(i, 30),1); end; NEE = [NEE ; tmp_NEE_raw];
%         try tmp_dcdt = load([load_path_calc site '_' num2str(i) '.dcdt']);catch;  disp(['dcdt err, ' num2str(i)]);tmp_dcdt = NaN.*ones(yr_length(i, 30),1); end; dcdt = [dcdt ; tmp_dcdt];
%         try tmp_Jt = load([load_path_calc site '_' num2str(i) '.Jt']);catch;  disp(['Jt err, ' num2str(i)]);tmp_Jt = NaN.*ones(yr_length(i, 30),1); end; Jt = [Jt ; tmp_Jt];
%     else
%         to_fill = NaN.*ones(yr_length(i,30),1);
%         Fc = [Fc ;to_fill]; Ustar = [Ustar ;to_fill]; LE = [LE ;to_fill];
%         Hs = [Hs ;to_fill]; CO2_top = [CO2_top ;to_fill]; CO2_cpy = [CO2_cpy ;to_fill];
%         H2O_top = [H2O_top ;to_fill]; NEE = [NEE ;to_fill]; dcdt = [dcdt ;to_fill];
%         Jt = [Jt ;to_fill];
%     end
%     clear to_fill ;
% end
% 
% old_data.data = [Fc Ustar LE Hs CO2_top CO2_cpy H2O_top NEE dcdt Jt];
% old_data.labels = {'Fc'; 'Ustar'; 'LE'; 'Hs'; 'CO2_top'; 'CO2_cpy'; 'H2O_top'; 'NEE'; 'dcdt'; 'Jt';};
% clear Fc Ustar LE Hs CO2_top CO2_cpy H2O_top NEE_raw dcdt Jt;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the Master Files:
OPEC_EdiRe = load([load_path_calc site '_OPEC_EdiRe_calc.mat']);
OPEC_10min = load([load_path_calc site '_OPEC_30min_calc.mat']);

%%% Do some checks on the data to make sure they are equivalent and
%%% suitable for combining
error_flag = 0;
if ~isequal(OPEC_EdiRe.master.labels, OPEC_10min.master.labels)
    disp('Labels for 10min and EdiRe data are not the same -- look to correct this:');
    error_flag = 1;
end
if ~isequal(size(OPEC_EdiRe.master.data),size(OPEC_10min.master.data))
    disp('10min and EdiRe data are not the same size - look to correct this:');
    error_flag = 1;
end

if error_flag == 1
    cont = input('Errors detected: enter <1> to continue, <0> to end > ');
else
    cont = 1;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Set overrides for shifts here:
% switch site
%     case 'TP74'
%         shift_override = [];
%     case 'TP89'
%         shift_override = [];
%     case 'TP02'
%         shift_override = [];
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if cont == 1
    %%% First, make a new master file, which is equivalent to EdiRe Data:
    master.data = OPEC_EdiRe.master.data;
    master.labels = OPEC_EdiRe.master.labels;
    %%% Next, we can add in the 10min data whenever there is an NaN
    %%% We can do this since we know both datasets to be temporally
    %%% aligned
    for k = 1:1:size(OPEC_EdiRe.master.data,2)
        [right_col] = mcm_find_right_col(master.labels,char(OPEC_10min.master.labels(k,1)));
        if isempty(right_col)
            disp(['Could not find the variable ' char(OPEC_10min.master.labels(k,1)) ' in the 10min file.']);
        else
            master.data(isnan(master.data(:,k)),k) = OPEC_10min.master.data(isnan(master.data(:,k)),right_col);
        end
        clear right_col;
    end

    %%% Save the new master file:
    
    save([load_path_calc site '_OPEC_final_calc.mat'],'master')
    disp(['Final Master File Saved to ' load_path_calc site '_OPEC_final_calc.mat']);
else
    disp('Final Master not saved due to problems with data.');
end
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %%% Following lines were previously placed after loop filling in data
    %%% from EdiRe and 10min files into the master.  It turns out that the
    %%% old data is not needed, as all the measurement periods have been
    %%% accounted for, between the 10min and the EdiRe data.
% % %     %%% Next, shift the old data to conform to the other data sources.
% % %     %%% Wind Speed from the CSAT was not recorded, so the best possibility
% % %     %%% is to use u*, which will only give us the shift during periods when
% % %     %%% we have data from one of the two other sources....
% % %     old_DAT = old_data.data(:,mcm_find_right_col(old_data.labels,'Ustar'));
% % %     OPEC_DAT = master.data(:,mcm_find_right_col(master.labels, 'u_star'));
% % %     old_DAT(old_DAT>1.5,1) = NaN;
% % %     OPEC_DAT(OPEC_DAT>1.5,1) = NaN;
% % %     
% % %     [start_times] = OPEC_find_intervals(old_DAT, 30, 300);
% % %     num_lags = 16; % The maximum number of shifts to check correlation for is 15 half-hours (8 hours).
% % %     [r_old c_old] = size(old_data.data);
% % %     shifted_old = NaN.*ones(r_old, c_old);
% % %     %     shifted_master(:,1:6) = master.data(:,1:6);
% % %     
% % %     %%% Run through each of the measurement periods and try and find the shift
% % %     ccorr = []; lags = [];
% % %     for j = 1:1:length(start_times)
% % %         clear *_tmp;
% % %         
% % %         old_DAT_tmp  = old_DAT(start_times(j,1):start_times(j,2),1);
% % %         OPEC_DAT_tmp = OPEC_DAT(start_times(j,1):start_times(j,2),1);
% % %         
% % %         %%% Continuous segment xcorr
% % %         try
% % %             [output(j).seg] = segment_xcorr(old_DAT_tmp, OPEC_DAT_tmp, num_lags);
% % %             pts_to_shift_seg(j,1) = output(j).seg(output(j).seg(:,3) == max(output(j).seg(:,3)),4);
% % %         catch
% % %             pts_to_shift_seg(j,1) = NaN;
% % %         end
% % %         %%% Moving window x-correlation:
% % %         try
% % %             [output(j).mw] = mov_window_xcorr(old_DAT_tmp, OPEC_DAT_tmp, num_lags);
% % %             pts_to_shift_mw(j,1) = mode(output(j).mw(:,2));
% % %         catch
% % %             pts_to_shift_mw(j,1) = NaN;
% % %         end
% % %         
% % %         try
% % %             %%% Traditional x-correlation for entire period
% % %             old_DAT_tmp(isnan(old_DAT_tmp),1) = 0;
% % %             OPEC_DAT_tmp(isnan(OPEC_DAT_tmp),1) = 0;
% % %             
% % %             
% % %             ind_tmp = find(~isnan(old_DAT_tmp.*OPEC_DAT_tmp));
% % %             [ccorr_tmp lags_tmp] = xcorr(old_DAT_tmp(ind_tmp), OPEC_DAT_tmp(ind_tmp), num_lags);
% % %             lags = [lags lags_tmp'];
% % %             ccorr = [ccorr ccorr_tmp];
% % %             ccorr(:,j) = ccorr(:,j)./(max(ccorr(:,j)));
% % %             pts_to_shift(j,1) = lags(ccorr(:,j) == 1,j);
% % %             % % % % %     ccorr(1:num_lags*2+1,j) = ccorr_tmp(1:num_lags*2+1,1);
% % %             % % % % %         lags(1:num_lags*2+1,j) = lags_tmp(1:num_lags*2+1);
% % %         catch
% % %             disp(['Error on loop ' num2str(j) ', data starting at ' num2str(start_times(j,1)) ]);
% % %             pts_to_shift(j,1) = NaN;
% % %             lags = [lags(:,1:j-1) NaN.*ones(num_lags.*2+1,1)];
% % %             ccorr = [ccorr(:,1:j-1) NaN.*ones(num_lags.*2+1,1)];
% % %         end
% % %     end
% % %     
% % %     %%% Override shifts if set above:
% % %     if ~isempty(shift_override)
% % %         for k = 1:1:size(shift_override,1)
% % %             try
% % %                 indfirst = find(shift_override(k,1)==start_times(:,1));
% % %                 indlast = find(shift_override(k,2)==start_times(:,2));
% % %                 if indfirst > 0 && indlast > 0 && indfirst==indlast
% % %                     pts_to_shift(indfirst,1) = shift_override(k,3);
% % %                     disp(['Overridden shift value for : start time group ' num2str(indfirst)]);
% % %                     
% % %                 else
% % %                     disp(['indexes for first and last shift overrides do not match. Override not completed for override: ' num2str(k)]);
% % %                 end
% % %             catch
% % %                 disp(['Problem with override. Override not completed for override: ' num2str(k)]);
% % %             end
% % %             clear indfirst indlast
% % %         end
% % %     end
% % %     
% % %     %%% Apply shifts and ask the user if they are happy with the results:
% % %     add_to_plot = [];
% % %     for j = 1:1:length(start_times)
% % %         tmp_add = (start_times(j,1):20:start_times(j,2))';
% % %         add_to_plot = [add_to_plot ; tmp_add j.*ones(length(tmp_add),1)];
% % %         clear tmp_add;
% % %         if isnan(pts_to_shift(j,1)) == 1;
% % %             try
% % %                 switch j
% % %                     case 1
% % %                         pts_to_shift(1,1) = pts_to_shift(2,1);
% % %                     case length(j)
% % %                         pts_to_shift(length(j),1) = pts_to_shift(length(j)-1,1);
% % %                     otherwise
% % %                         pts_to_shift(j,1) = ceil(nanmean([pts_to_shift(j-1,1); pts_to_shift(j+1,1)]));
% % %                 end
% % %                 disp(['Shift for data section ' num2str(j) ' is estimated at ' num2str(pts_to_shift(j,1)) '.']);
% % %             catch
% % %                 disp(['Could not estimate a lag time for start_time ' num2str(j) '. Set to zero.']);
% % %             end
% % %         end
% % %         % Shift the OPEC data ahead by specified number of points if shift is +
% % %         if pts_to_shift(j,1) > 0
% % %             clear ind_shifted
% % %             ind_shifted = (start_times(j,1)+pts_to_shift(j,1):1:start_times(j,2)+pts_to_shift(j,1));
% % %             shifted_old(ind_shifted,1:c_old) = old_data.data(start_times(j,1):start_times(j,2),1:c_old);
% % %             % Shift OPEC data backwards if it is a -'ve shift
% % %         elseif pts_to_shift(j,1) < 0
% % %             clear ind_shifted
% % %             ind_shifted = (start_times(j,1)+pts_to_shift(j,1):1:start_times(j,2)+pts_to_shift(j,1));
% % %             if ~isempty(find(ind_shifted<1, 1)) % fix case where we are shifting beyond the start date:
% % %                 ind_shifted = (1:1:start_times(j,2)+pts_to_shift(j,1));
% % %                 start_times(j,1) = length(find(ind_shifted<1)) + 1;
% % %             end
% % %             shifted_old(ind_shifted,1:c_old) = old_data.data(start_times(j,1):start_times(j,2),1:c_old);
% % %             % If shift = 0, don't touch it.
% % %         elseif pts_to_shift(j,1) == 0
% % %             ind_shifted = (start_times(j,1):1:start_times(j,2));
% % %             shifted_old(ind_shifted,1:c_old) = old_data.data(start_times(j,1):start_times(j,2),1:c_old);
% % %         end
% % %     end
% % %     
% % %     %%% Plot the unshifted and shifted timeseries, along with Met and
% % %     %%% OPEC_10min data:
% % %     close(findobj('Tag','Pre-Shift'));
% % %     figure('Name','Data_Alignment: Pre-Shift','Tag','Pre-Shift');
% % %     figure(findobj('Tag','Pre-Shift'));clf;
% % %     plot(OPEC_DAT,'b','LineWidth',3);hold on;
% % %     plot(old_DAT,'Color',[0.8 0.8 0.8]);
% % %     plot(shifted_old(:,mcm_find_right_col(old_data.labels,'Ustar')),'g');
% % %     legend('OPEC u_*', 'Orig old u_*',  'Corr OPEC u_*');
% % %     grid on;
% % %     set(gca, 'XMinorGrid','on');
% % %     for ii = 1:1:length(add_to_plot)
% % %         text(add_to_plot(ii,1),2,num2str(add_to_plot(ii,2)),'Color','k')
% % %     end
% % %     
% % % %%% Create output information for the user:
% % % output_data = [(1:1:length(start_times))' start_times pts_to_shift];
% % % disp(output_data);    
% % %     
% % %  disp('Shifting Complete');   
    
    
    

