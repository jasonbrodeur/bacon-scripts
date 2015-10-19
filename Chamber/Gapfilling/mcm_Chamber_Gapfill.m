%%%% Load data:
clearvars;
close all;
year = 2008:1:2014;

ls = addpath_loadstart;
master_path = [ls 'Matlab/Data/Master_Files/'];
trenched_path = [ls 'Matlab/Data/Met/Final_Cleaned/TP39_trenched/'];
chamber_path = [ls 'Matlab/Data/Flux/ACS/TP39_chamber/Final_Cleaned/'];
output_path = [ls 'Matlab/Data/Flux/Gapfilling/TP39_chamber/'];
clrs = jjb_get_plot_colors;

% Load met data:
TP39_orig = load([master_path 'TP39/TP39_gapfill_data_in.mat']);
figure(3);clf;
figure(4);clf;

for yr_ctr = 1:1:length(year)
    yr = year(yr_ctr);
   
    if yr == 2013
        % Load the chamber flux data:
        ch2013 = load([chamber_path 'TP39_chamber_ACS_cleaned_2013.mat']);
        ch2012 = load([chamber_path 'TP39_chamber_ACS_cleaned_2012.mat']);
        ch2014 = load([chamber_path 'TP39_chamber_ACS_cleaned_2014.mat']);
        ch = [ch2012; ch2013; ch2014];
        clear ch20*
        TP39.data = trim_data_files(TP39_orig.data,2012,2014,1);
        
        Ts = TP39.data.Ts5;
        SM = TP39.data.SM_a_filled;       
    else 
        % Load the chamber flux data:
        ch = load([chamber_path 'TP39_chamber_ACS_cleaned_' num2str(yr) '.mat']);
        
        TP39.data = trim_data_files(TP39_orig.data,yr,yr,1);
        Ts = TP39.data.Ts5;
        SM = TP39.data.SM_a_filled;
    end 
        
        % Cycle through chambers
        for i = 1:1:8
            if yr == 2013;
            efflux = [ch(1).master.data{6}(1:yr_length(2012,30),i); ch(2).master.data{6}(1:yr_length(2013,30),i); ch(3).master.data{6}(1:yr_length(2014,30),i)];
            pct_filled(yr_ctr,i) = length(find(isnan(efflux(17569:17568+17520))==1))./length(Ts(17569:17568+17520));
            else
            efflux = ch.master.data{6}(1:length(Ts),i);
            pct_filled(yr_ctr,i) = length(find(isnan(efflux)==1))./length(Ts);
            end
            ind = find(~isnan(efflux.*SM.*Ts));%create an index where the efflux, Ts and SM all have data points
            Xin = [Ts(ind,1) SM(ind,1)];%create x input
            Yin = efflux(ind,1);%create y input
            Yfill = Yin;
            X_eval = [Ts SM];
            options.costfun ='OLS'; options.min_method ='NM'; options.f_coeff = [NaN NaN NaN NaN];%this chooses the optimization and cost funtions,
            
            %%%%%%%%%%%%%%%% % Q10 - Ts+SM
            % Run parameterization:
            [c_hat_3B{yr_ctr,1}(i,:), y_hat_3B, y_pred_3B{yr_ctr,1}(:,i), stats_3B{yr_ctr,i}, sigma_3B{yr_ctr,i}, err_3B, exitflag_3B, num_iter_3B] = ...
                fitresp([3 2 8 100], 'fitresp_3B', Xin, Yin, X_eval, [], options);%choose model type for Ts and Efflux and SM and norm. efflux
            
            % Fill gaps for the given chamber, given year:
            
            if yr == 2013;
            Yfill3B{yr_ctr,1}(:,i) = efflux(17569:17568+17520);
            Yfill3B{yr_ctr,1}(isnan(efflux(17569:17568+17520))==1,i) = y_pred_3B{yr_ctr,1}(isnan(efflux(17569:17568+17520))==1,i);    
            else
            Yfill3B{yr_ctr,1}(:,i) = efflux;
            Yfill3B{yr_ctr,1}(isnan(efflux)==1,i) = y_pred_3B{yr_ctr,1}(isnan(efflux)==1,i);
            end
            % Calculate sums:
            sum_ypred3B(yr_ctr,i) = sum(y_pred_3B{yr_ctr,1}(:,i)).*0.0216;
            sum_yfill3B(yr_ctr,i) = sum(Yfill3B{yr_ctr,1}(:,i)).*0.0216;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%% % Logistic - Ts only
            %         [c_hat_2A(i,:), y_hat_2A, y_pred_2A, stats_2A{i}, sigma_2A, err_2A, exitflag_2A, num_iter_2A] = ...
            %             fitresp([10 0.15 15], 'fitresp_2A', Xin, Yin, X_eval, [], options);%choose model type for Ts and Efflux and SM and norm. efflux
            %         Yfill2A(:,i) = efflux;
            %         Yfill2A(isnan(efflux)==1,i) = y_pred_2A(isnan(efflux)==1);
            %         sum_ypred2A(i,1) = sum(y_pred_2A);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%% % Logistic - Ts + SM
            [c_hat_2B{yr_ctr,1}(i,:), y_hat_2B, y_pred_2B{yr_ctr,1}(:,i), stats_2B{yr_ctr,i}, sigma_2B, err_2B, exitflag_2B, num_iter_2B] = ...
                fitresp([10 0.15 15 1 1], 'fitresp_2B', Xin, Yin, X_eval, [], options);%choose model type for Ts and Efflux and SM and norm. efflux
            % Fill gaps for the given chamber, given year:
             if yr == 2013;
            Yfill2B{yr_ctr,1}(:,i) = efflux(17569:17568+17520);
            Yfill2B{yr_ctr,1}(isnan(efflux(17569:17568+17520))==1,i) = y_pred_2B{yr_ctr,1}(isnan(efflux(17569:17568+17520))==1,i);    
            else
            Yfill2B{yr_ctr,1}(:,i) = efflux;
            Yfill2B{yr_ctr,1}(isnan(efflux)==1,i) = y_pred_2B{yr_ctr,1}(isnan(efflux)==1,i);
             end
            % Calculate sums:
            sum_ypred2B(yr_ctr,i) = sum(y_pred_2B{yr_ctr,1}(:,i)).*0.0216;
            sum_yfill2B(yr_ctr,i) = sum(Yfill2B{yr_ctr,1}(:,i)).*0.0216;
            
            
            if yr == 2013;
                figure(3);
                subplot(3,3,i);
                plot(Yfill2B{yr_ctr,1}(:,i));
                figure(4);
                subplot(3,3,i);
                plot(Yfill3B{yr_ctr,1}(:,i)); 
            disp(['Efflux for chamber ' num2str(i) ', model: 2B(Q10): '  num2str(sum_yfill2B(yr_ctr,i))])
            disp(['Efflux for chamber ' num2str(i) ', model: 3B(logi): '  num2str(sum_yfill3B(yr_ctr,i))])
            disp(['Percent data filled, chamber ' num2str(i) ': ' num2str(pct_filled(yr_ctr,i)) ])
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %         figure(f_ch);
            %         hch(i) = plot(y_pred_3B,'Color',clrs(i,:));hold on;
            %
            %         figure(f_ch2A);
            %         hch2A(i) = plot(y_pred_2A,'Color',clrs(i,:));hold on;
            %
            %         figure(f_ch2B);
            %         hch2B(i) = plot(y_pred_2B,'Color',clrs(i,:));hold on;
            %
        end
end

%% Export Data:

% Filled data to Excel format
for yr_ctr = 1:1:length(year)
    yr = year(yr_ctr);
    tmp = Yfill2B{yr_ctr,1};
    csvwrite([output_path 'TP39_chamber_filled2B_' num2str(yr) '.csv'],tmp);
    clear tmp;
    tmp = Yfill3B{yr_ctr,1};
    csvwrite([output_path 'TP39_chamber_filled3B_' num2str(yr) '.csv'],tmp);
end

% Sums
csvwrite([output_path 'TP39_chamber_filled2B_sums.csv'],sum_yfill2B);
csvwrite([output_path 'TP39_chamber_filled3B_sums.csv'],sum_yfill3B);
csvwrite([output_path 'TP39_chamber_pctfilled.csv'],pct_filled);

% Filled Data in .mat format:
save([output_path 'TP39_chamber_filled3B.mat'],'Yfill3B');
save([output_path 'TP39_chamber_filled2B.mat'],'Yfill2B');


% Stats
save([output_path 'TP39_chamber_filled3B_stats.mat'],'stats_3B');
save([output_path 'TP39_chamber_filled2B_stats.mat'],'stats_2B');










