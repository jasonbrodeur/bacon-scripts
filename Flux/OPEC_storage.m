function [NEE_raw dcdt Jtfill dcdt_1h_final dcdt_2h_final] = OPEC_storage(site, yr_list, Fc, CO2_top, CO2_cpy, Ta)


%% OPEC_storage.m
% This program calculates the changes in the amount of CO2 and heat stored beneath
% the OPEC sensor, using CO2 concentration and temperature measured at the top of the
% canopy, or measured at different points in the profile
% Created July 31, 2007 by JJB
% Inputs are year, site and input_loc
% input_loc is simply 'met' or 'flux' and specifies if raw files are coming
% from the met data or the flux data
% Dr. Arain -- Please use the 'flux' option
% Modified Feb 25, 2008 by JJB
%       - included raw NEE calculation into function, so that only Met_SHF
%       and OPEC_storage have to be used before going to flux calculation
%       scripts.


% Constants:
Ma = 28.97; % approx molar mass of dry air:
rho_a = 1200;  % approx density of dry air (g/m3)

%%% Prepare outputs:
NEE_raw = NaN.*ones(length(yr_list),1);
Jtfill =  NaN.*ones(length(yr_list),1);
dcdt   =  NaN.*ones(length(yr_list),1);
dcdt_1h_final =  NaN.*ones(length(yr_list),1);
dcdt_2h_final =  NaN.*ones(length(yr_list),1);

%%% Cycle through years, do storage calculations:
min_yr = min(yr_list);
max_yr = max(yr_list);

for yr = min_yr:1:max_yr
    ind = find(yr_list==yr);
    try
        output = params(yr, site, 'CO2_storage');
        z = output(:,1); z_top = output(:,2); z_cpy = output(:,3); col_flag = output(:,4);
        skip_year = 0;
    catch
        skip_year = 1;
    end
    
    %%%%%% Do storage calculations (provided it can find parameter data)
    if skip_year == 0
        Ta_tmp = Ta(ind);
        CO2_top_tmp = CO2_top(ind);
        CO2_cpy_tmp = CO2_cpy(ind);
        
        Jt = NaN.*ones(length(ind),1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Heat Storage:
        %%% Shift Temperature data by one point and take difference to get
        %%% dT/dt
        %%% Also cuts off the extra data point that is created by adding NaN
        T1top = [NaN; Ta_tmp(1:length(Ta_tmp)-1)];
        T2top = [Ta_tmp(1:length(Ta_tmp)-1) ; NaN];
        
        %%% Heat Storage
        dTdt = T1top-T2top;
        Jt(:,1) = 22.25.*0.6.*dTdt +1.66;    %% Blanken et al. (1997)
        Jt(1,1) = Jt(2,1); Jt(length(ind),1) = Jt(length(ind)-1,1);
        %%% Fill small gaps with linear interp:
        try
        [Jtfill_tmp] = jjb_interp_gap(Jt,[], 3);
        catch
            disp(['Error calculating Jt for ' num2str(yr) '. Likely Jt is blank.'])
            Jtfill_tmp = Jt;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% CO2 Storage:
        %%% Shift CO2_top data by one point and take difference to get dc/dt
        %%% Also cuts off the extra data point that is created by adding NaN
        c1top = [NaN; CO2_top_tmp(1:length(CO2_top_tmp)-1)];
        c2top = [CO2_top_tmp(1:length(CO2_top_tmp)-1) ; NaN];
        c1cpy = [NaN; CO2_cpy_tmp(1:length(CO2_cpy_tmp)-1)];
        c2cpy = [CO2_cpy_tmp(1:length(CO2_cpy_tmp)-1) ; NaN];
        
        %%%%%%%%%%%%%%%%%%%%% 1-height %%%%%%%%%%%%%%%%%%%%
        %%% Calculate CO2 storage in column below system: One-Height approach
        %%%*** Note the output of this is in umol/mol NOT IN mg/m^3 ***********
        dcdt_1h(:,1) = (c2top-c1top).*(rho_a./Ma).*(z./1800);
        
        %%%%%%%%%%%%%%%%% 2-height %%%%%%%%%%%%%%%%%%%%%%%%%%
        switch col_flag(1,1)
            case 2
                %%% top
                dcdt_top = (c2top-c1top).*(rho_a./Ma).*(z_top./1800);
                
                %%% bottom
                dcdt_cpy = (c2cpy-c1cpy).*(rho_a./Ma).*(z_cpy./1800);   %%
                
            case 1
                dcdt_top(1:length(ind),1) = NaN;
                dcdt_cpy(1:length(ind),1) = NaN;
        end
        
        %%% Add top and bottom storages
        dcdt_2h(:,1) = dcdt_top + dcdt_cpy;  %% 2-height storage in umol/mol m^-2s^-1

        %%% Do the first-through removal of large outliers:
        dcdt_1h(abs(dcdt_1h) > 20) = NaN;
        dcdt_2h(abs(dcdt_2h) > 20) = NaN;

        %%% Consolidate the 1 and 2-height estimates:
        mean_dcdt(1:length(dcdt_1h),1) = NaN;
        mean_dcdt(~isnan(dcdt_1h.*dcdt_2h),1) = mean([dcdt_1h(~isnan(dcdt_1h.*dcdt_2h),1)' ; dcdt_2h(~isnan(dcdt_1h.*dcdt_2h),1)']);
        mean_dcdt(isnan(mean_dcdt),1) = dcdt_2h(isnan(mean_dcdt),1);
        mean_dcdt(isnan(mean_dcdt),1) = dcdt_1h(isnan(mean_dcdt),1);

        NEE_raw(ind,1) = Fc(ind) + mean_dcdt;
        dcdt(ind,1) = mean_dcdt;
        Jtfill(ind,1) = Jtfill_tmp;
        dcdt_1h_final(ind,1) = dcdt_1h;
        dcdt_2h_final(ind,1) = dcdt_2h;
            
    else
        disp([num2str(yr) ' skipped because no parameter data exists in params.m']);
        NEE_raw(ind) = NaN; Jtfill(ind) = NaN; dcdt(ind) = NaN;
        
    end
    
    clear z z_top zcpy col_flag *_tmp Jt dcdt_1h dcdt_2h dcdt_top dcdt_cpy c1* c2* mean_dcdt ;
end
%%% Plot the final results:
        figure('Tag','Storage_NEE','Name', 'dcdt + NEE');clf;
        subplot(211)
        plot(dcdt_1h_final,'b'); hold on;
        plot(dcdt_2h_final,'g');
        plot(dcdt,'r')
        legend('1-height', '2-height', 'Final Used')
        title('Storage')
        ylabel('\mu mol m^{-2} s^{-1}')
        subplot(212)
        plot(Fc,'k');hold on;
        plot(NEE_raw,'b');
        title('Fc, NEE')
        ylabel('\mu mol m^{-2} s^{-1}')
legend('Fc', 'NEE');
% 
% %% Remove outliers
% 
% %%% Do the first-through removal of large outliers:
% dcdt_1h(abs(dcdt_1h) > 20) = NaN;
% dcdt_2h(abs(dcdt_2h) > 20) = NaN;
% 
% figure('Name', 'OPEC_storage_all: dcdt');clf;
% plot(dcdt_1h,'b'); hold on;
% plot(dcdt_2h,'g');
% legend('1-height', '2-height')
% 
% %%% We somehow need to quality control these CO2 storage estimates, since
% %%% we'll have to make a single estimate out of these-- average them?
% mean_ds(1:length(dcdt_1h),1) = NaN;
% % ind_both = find(~isnan(dcdt_1h.*dcdt_2h));
% mean_ds(~isnan(dcdt_1h.*dcdt_2h),1) = mean([dcdt_1h(~isnan(dcdt_1h.*dcdt_2h),1)' ; dcdt_2h(~isnan(dcdt_1h.*dcdt_2h),1)']);
% mean_ds(isnan(mean_ds),1) = dcdt_1h(isnan(mean_ds),1);
% mean_ds(isnan(mean_ds),1) = dcdt_2h(isnan(mean_ds),1);
% 
% plot(mean_ds,'r')
% 
% %%% Fill small gaps by linear interpolation??:
% 
% NEE_raw = FC + mean_ds;
% figure('Name', 'OPEC_storage_all: NEE');clf;
% plot(NEE_raw,'k');
%

