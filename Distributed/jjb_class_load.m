function [vars_out] = jjb_class_load(program, yr, site, flux_source, met_source)

%%
if ispc == 1

    data_loc = 'C:/Home/';
else

    data_loc = '/home/jayb/'; % this loads and writes data to and from the portable hard disk
end

%%
% output_path = ['C:\HOME\MATLAB\Data\Class_files\NEP_ests\Met' site '\'];


% function [] = CCP_output(yr, site_num, flux_source, met_source)
% site_num = '3';
% yr = 2006;
% site_num = 1;
% flux_source = 'processed';
% met_source = 'master';

% %% Make Sure site and year are in proper format
% site_label = [1 39; 2 74; 3 89; 4 02];
if ischar(site) == false
    site = num2str(site);
end
if ischar(yr) == false
    yr = num2str(yr);
end
% site = num2str(site_num);
% site_tag = num2str(site_label(find(site_label(:,1) == site_num),2));

%% Declare Paths

%%% Processed Met
load_path_metproc = ([data_loc 'MATLAB/Data/Met/Cleaned3/Met' site '/Met' site '_' yr '.']);  %/Column/30min/
hdr_path_metproc = ([data_loc 'MATLAB/Data/Met/Raw1/Docs/Met' site '_OutputTemplate.csv']);

%%% Master Flux and Master Met
load_path_master = ([data_loc 'MATLAB/Data/Flux/OPEC/Organized2/Met' site '/Column/Met' site '_' yr '.']);
hdr_path_master = ([data_loc 'MATLAB/Data/Flux/OPEC/Organized2/Docs/Met' site '_FluxColumns.csv']);

%%% Processed OPEC
hdr_path_OPECproc = ([data_loc 'MATLAB/Data/Flux/OPEC/Organized2/Docs/OPEC_header.csv']);
load_path_OPECproc = ([data_loc 'MATLAB/Data/Flux/OPEC/Cleaned3/Met' site '/Column/Met' site '_HHdata_' yr '.']);

%%% Processed CPEC
load_path_CPECproc = ([data_loc 'MATLAB/Data/Flux/CPEC/Met' site '/HH_fluxes/']);

%%% Calculated OPEC Variables path
calc_path = ([data_loc 'MATLAB/Data/Flux/OPEC/Calculated5/Met' site '/Met' site '_' yr '_']);
calc_path_met = ([data_loc 'MATLAB/Data/Met/Calculated4/Met' site '/Met' site '_' yr '_']);

%%% Cleaned OPEC Variables path
clean_path = ([data_loc 'MATLAB/Data/Flux/OPEC/Cleaned3/Met' site '/Met' site '_' yr '_']);

%%% Path for filled OPEC variables
filled_path = ([data_loc 'MATLAB/Data/Flux/OPEC/Filled4/Met' site '/Met' site '_' yr '_']);

%%%
flux_path = ([data_loc 'MATLAB/Data/Data_Analysis/M' site '_allyears/']);


%% Load Header Files
%%% Tracker for Processed Met Files
[hdr_cell_metproc] = jjb_hdr_read(hdr_path_metproc,',',3);
%%% Tracker for Master Flux and Master Met Files
[hdr_cell_flux]  = jjb_hdr_read(hdr_path_master,',',2);
%%% Tracker for Processed OPEC Files
[hdr_cell_OPEC] = jjb_hdr_read(hdr_path_OPECproc,',',2);

%% Sort out time variables:
%%% load timevector:
% tv = load([data_loc 'MATLAB/Data/Met/Organized2/Met' site '/Column/30min/Met' site '_' yr '.tv']);

[year JD HHMM dt]  = jjb_makedate(str2double(yr),30);

% dates = datevec(tv);    % Make datevec from TV
% dates(2:length(dates),2:3) = dates(1:length(dates)-1,2:3);  % Shift 1 spot to make 0030 first entry for each day
% 
% month = dates(:,2);       % Pick out Month Column
% day = dates(:,3);       % Pick out day column
% hour = dates(:,4);    
% minute = dates(:,5);    
% 



%% Make Blank Variables:
%%% Flux:
% FC(1:length(dt),1) = NaN; CO2_top(1:length(dt),1) = NaN; CO2_cpy(1:length(dt),1) = NaN; CO2_bot(1:length(dt),1) = NaN;
% % H(1:length(dt),1) = NaN; H_filled(1:length(dt),1) = NaN; LE(1:length(dt),1) = NaN; LE_filled(1:length(dt),1) = NaN;
% ustar(1:length(dt),1) = NaN; H2O(1:length(dt),1) = NaN; SFC(1:length(dt),1) = NaN; G0(1:length(dt),1) = NaN; Jt(1:length(dt),1) = NaN;
NEP(1:length(dt),1) = NaN; NEP_filled(1:length(dt),1) = NaN; GEP_filled(1:length(dt),1) = NaN; R_filled(1:length(dt),1) = NaN;
% APAR(1:length(dt),1) = NaN; FPAR(1:length(dt),1) = NaN; ZL(1:length(dt),1) = NaN;
%%% Met:
Rn(1:length(dt),1) = NaN; SW_down(1:length(dt),1) = NaN; SW_up(1:length(dt),1) = NaN; LW_down(1:length(dt),1) = NaN;
LW_up(1:length(dt),1) = NaN; PAR_down_top(1:length(dt),1) = NaN; PAR_reflected_top(1:length(dt),1) = NaN; PAR_down_bot(1:length(dt),1) = NaN;
Rn_bot(1:length(dt),1) = NaN; Tair_top(1:length(dt),1) = NaN; Tair_cpy(1:length(dt),1) = NaN; Tair_bot(1:length(dt),1) = NaN;
RH_top(1:length(dt),1) = NaN; RH_cpy(1:length(dt),1) = NaN; RH_bot(1:length(dt),1) = NaN;
WS(1:length(dt),1) = NaN; Wdir(1:length(dt),1) = NaN; APR(1:length(dt),1) = NaN; PPT(1:length(dt),1) = NaN;

% Ts2a(1:length(dt),1) = NaN; Ts2b(1:length(dt),1) = NaN; Ts5a(1:length(dt),1) = NaN; Ts5b(1:length(dt),1) = NaN;
% Ts10a(1:length(dt),1) = NaN; Ts10b(1:length(dt),1) = NaN; Ts20a(1:length(dt),1) = NaN; Ts20b(1:length(dt),1) = NaN;
% Ts50a(1:length(dt),1) = NaN; Ts50b(1:length(dt),1) = NaN; Ts100a(1:length(dt),1) = NaN; Ts100b(1:length(dt),1) = NaN;
% 
% SM5a(1:length(dt),1) = NaN; SM5b(1:length(dt),1) = NaN; SM10a(1:length(dt),1) = NaN; SM10b(1:length(dt),1) = NaN;
% SM20a(1:length(dt),1) = NaN; SM20b(1:length(dt),1) = NaN; SM50a(1:length(dt),1) = NaN; SM50b(1:length(dt),1) = NaN;
% SM100a(1:length(dt),1) = NaN; SM100b(1:length(dt),1) = NaN;
% 
% SHF1(1:length(dt),1) = NaN; SHF2(1:length(dt),1) = NaN;

% TC1(1:length(dt),1) = NaN; TC2(1:length(dt),1) = NaN; TC3(1:length(dt),1) = NaN; TC4(1:length(dt),1) = NaN; TC5(1:length(dt),1) = NaN; TC6(1:length(dt),1) = NaN;
%% Load Flux variables
% path 'M' site 'output_model' num2str(GEP_model)  '_' num2str(mm) '.dat'
flux_vars = load([flux_path 'M' site 'output_model3_' yr '.dat']);
NEP = flux_vars(:,2);
NEP_filled = flux_vars(:,3);
GEP_filled = flux_vars(:,5);
R_filled = flux_vars(:,4);
NEP_clean = flux_vars(:,10);
Tair_top = flux_vars(:,6);
PAR_down_top = flux_vars(:,9);

clear flux_vars;


% ET_vars = load([flux_path 'M' site '_ETEB_output_' yr '.dat']);
% LE_filled = ET_vars(:,1);
% H_filled = ET_vars(:,2);
% clear ET_vars;

switch flux_source

    %%%%%%%%%%% For case where flux files are to be loaded from the master files
    case 'master'
%         FC = jjb_load_var(hdr_cell_flux, load_path_master, 'CO2Flux_Top');
%         H = jjb_load_var(hdr_cell_flux, load_path_master, 'SensibleHeatFlux'); %%% Sensible Heat Flux
%         LE = jjb_load_var(hdr_cell_flux, load_path_master, 'LatentHeatFlux'); %%% Latent Heat Flux
%         ustar = jjb_load_var(hdr_cell_flux, load_path_master, 'UStar');
%         H2O = jjb_load_var(hdr_cell_flux, load_path_master,'H2O_AbvCnpy');

%         CO2_top = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_AbvCnpy');
%         CO2_cpy = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_Cnpy');
%         if site =='1';
%         CO2_bot = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_BlwCnpy');
%         end
%         SFC = load([calc_path 'dcdt_2h_cleaned.dat']); %% use filled or raw????
%         Jt = load([calc_path 'Jt.dat']);
%         G0 = load([calc_path_met 'g0.dat']);
        
%         APAR = 

        %         NEP = load(
        %         Pres = load([filled_path 'pres_cl.dat']);

        %%%%%%%%%%%% For case where flux files are to be loaded from the processed files
    case 'processed'

        if site == '1'
%             FC = load([load_path_CPECproc 'Fc' yr(3:4) '.dat']);
%             ustar = load([load_path_CPECproc 'ustr' yr(3:4) '.dat']);
%             H = load([load_path_CPECproc 'Hs' yr(3:4) '.dat']);
%             LE = load([load_path_CPECproc 'LE' yr(3:4) '.dat']);
%             H2O = load([load_path_CPECproc 'H2O' yr(3:4) '.dat']);

%             CO2_top = load([load_path_CPECproc 'CO2' yr(3:4) '.dat']);
%             CO2_cpy = jjb_load_var(hdr_cell_metproc, load_path_metproc,'CO2_Cnpy');
%             if site =='1';
%             CO2_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc,'CO2_BlwCnpy');
%             end
%             SFC = load([calc_path 'dcdt_2h_cleaned.dat']);
%             Jt = load([calc_path 'Jt.dat']);
%             G0 = load([calc_path_met 'g0.dat']);
%             %             Pres = load([filled_path 'pres_cl.dat']);
% 
        else
%             FC = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc, 'Fc_wpl');
%             ustar = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc, 'u_star');
%             H = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc, 'Hs'); %%% Sensible Heat Flux
%             LE = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc, 'LE_wpl'); %%% Latent Heat Flux
%             H2O = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc, 'h2o_Avg'); %%% Latent Heat Flux
% 
% 
%             CO2_top = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc,'co2_Avg');
%             CO2_cpy = jjb_load_var(hdr_cell_OPEC, load_path_OPECproc,'co2stor_Avg');
% 
%             SFC = load([calc_path 'dcdt_2h_cleaned.dat']);
%             Jt = load([calc_path 'Jt.dat']);
%             G0 = load([calc_path_met 'g0.dat']);
%             %             Pres = load([filled_path 'pres_cl.dat']);

        end


end


%% Load Met Variables
PPT(1:length(dt),1) = NaN;

switch met_source
    case 'master'
        Rn = jjb_load_var(hdr_cell_flux, load_path_master, 'NetRad_AbvCnpy');

%         PAR_down_top = jjb_load_var(hdr_cell_flux, load_path_master, 'DownPAR_AbvCnpy');
%         PAR_reflected_top = jjb_load_var(hdr_cell_flux, load_path_master, 'UpPAR_AbvCnpy');
%         PAR_down_bot = jjb_load_var(hdr_cell_flux, load_path_master, 'DownPAR_BlwCnpy');

%         Tair_top = jjb_load_var(hdr_cell_flux, load_path_master, 'AirTemp_AbvCnpy');

        
        RH_top = jjb_load_var(hdr_cell_flux, load_path_master, 'RelHum_AbvCnpy');
       
        WS = jjb_load_var(hdr_cell_flux, load_path_master, 'WindSpd');
%         Wdir = jjb_load_var(hdr_cell_flux, load_path_master, 'WindDir');
        APR = jjb_load_var(hdr_cell_flux, load_path_master, 'Pressure');
        PPT = jjb_load_var(hdr_cell_flux, load_path_master, 'Precipitation');

%         CO2_top = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_AbvCnpy');
%         CO2_cpy = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_Cnpy');
%         if site =='1';
%         CO2_bot = jjb_load_var(hdr_cell_flux, load_path_master,'CO2_BlwCnpy');
%         end
        
        if site == '1'
            
%         RH_cpy = jjb_load_var(hdr_cell_flux, load_path_master, 'RelHum_Cnpy');
%         RH_bot = jjb_load_var(hdr_cell_flux, load_path_master, 'RelHum_BlwCnpy');
%         Tair_bot = jjb_load_var(hdr_cell_flux, load_path_master, 'AirTemp_BlwCnpy');
%         Tair_cpy = jjb_load_var(hdr_cell_flux, load_path_master, 'AirTemp_Cnpy');
        SW_down = jjb_load_var(hdr_cell_flux, load_path_master, 'DownShortwaveRad');
%         SW_up = jjb_load_var(hdr_cell_flux, load_path_master, 'UpShortwaveRad');
if strcmp(yr,'2005') == 1
        LW_down = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownLongwaveRad_AbvCnpy');    
else
        LW_down = jjb_load_var(hdr_cell_flux, load_path_master, 'DownLongwaveRad');
end    
        LW_up = jjb_load_var(hdr_cell_flux, load_path_master, 'UpLongwaveRad');
%         Rn_bot = jjb_load_var(hdr_cell_flux, load_path_master, 'NetRad_BlwCnpy');
        end
        
        
        %         if site == '1'
        %         RHc = jjb_load_var(hdr_cell_flux, load_path_master, 'RelHum_Cnpy');
        % %         else
        % %             RHc(1:length(RH),1) = NaN;
        %         end
        %         if exist([calc_path_met 'Ts.dat'])
        %             Ts = load([calc_path_met 'Ts.dat']);
        %         end

%         Ts2a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_2cm');
%         Ts2b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_2cm');
%         Ts5a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_5cm');
%         Ts5b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_5cm');
%         Ts10a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_10cm');
%         Ts10b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_10cm');
%         Ts20a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_20cm');
%         Ts20b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_20cm');
%         Ts50a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_50cm');
%         Ts50b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_50cm');
%         Ts100a = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_A_100cm');
%         Ts100b = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilTemp_B_100cm');
% 
% 
%         SM5a = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_A_5cm');
%         SM5b = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_B_5cm');
%         SM10a = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_A_10cm');
%         SM10b = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_B_10cm');
%         SM20a = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_A_20cm');
%         SM20b = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_B_20cm');
%         SM50a = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_A_50cm');
%         SM50b = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_B_50cm');
%         SM100a = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_A_100cm');
%         SM100b = jjb_load_var(hdr_cell_flux, load_path_master, 'SM_B_100cm');
%         
%         if site == '1'
% try
%             SHF1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_HFT_1');
%             SHF2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_HFT_2');
% catch
% end
%         else
% 
%             SHF1 = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilHeatFlux_1');
%             SHF2 = jjb_load_var(hdr_cell_flux, load_path_master, 'SoilHeatFlux_2');
% 
%         end  
%         
%         
        
%         
% if site == '2'
%        %% Load Tree Thermocouple data for Met 2:
%        TC1 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree1_maxBN');
%        TC2 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree2_maxBC');
%        TC3 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree3_maxBS');
%        TC4 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree4_medBN');
%        TC5 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree5_medBQN');
%        TC6 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree6_medBC');
%        TC7 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree7_medBQS');
%        TC8 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree8_medBS');
%        TC9 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree9_minBN');
%        TC10 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree10_minBC');
%        TC11 = jjb_load_var(hdr_cell_flux, load_path_master, 'TreeTemp_Tree11_minBS');
%        
% elseif site =='1'
%     try
%             TC1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree1_20CmaxBN');
%     TC2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree2_20CmaxBC');
%     TC3 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree3_20CmaxBS');
%     TC4 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree4_30CmaxTN');
%     TC5 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree5_20CmaxTC');
%     TC6 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree6_30CmaxTS');
%     TC7 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree7_19BmedBN');
%     TC8 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree8_19Bmed');
%     TC9 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree9_19BmedBC');
%     TC10 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree10_19BmedBS');
%     TC11 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree11_19BmedBQS');
%     TC12 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree12_29BmedTN');
%     TC13 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree13_29BmedTQN');
%     TC14 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree14_29BmedTC');
%     TC15 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree15_29BmedTS');
%     TC16 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree16_29BmedTQS');
%     TC17 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree17_17minBH');
%     TC18 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree18_17minBC');
%     TC19 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree19_17minBS');
%     TC20 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree20_27AminTN');
%     TC21 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree21_27Amin');
%     TC22 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree22_27Amin');  
% 
%     catch
%         TC1(1:length(dt)) = NaN; TC2(1:length(dt)) = NaN; TC3(1:length(dt)) = NaN; TC4(1:length(dt)) = NaN;
%         TC5(1:length(dt)) = NaN; TC6(1:length(dt)) = NaN; TC7(1:length(dt)) = NaN; TC8(1:length(dt)) = NaN;
%         TC9(1:length(dt)) = NaN; TC10(1:length(dt)) = NaN; TC11(1:length(dt)) = NaN; TC12(1:length(dt)) = NaN;
%         TC13(1:length(dt)) = NaN; TC14(1:length(dt)) = NaN; TC15(1:length(dt)) = NaN; TC16(1:length(dt)) = NaN;
%         TC17(1:length(dt)) = NaN; TC18(1:length(dt)) = NaN; TC19(1:length(dt)) = NaN; TC20(1:length(dt)) = NaN;
%         TC21(1:length(dt)) = NaN; TC22(1:length(dt)) = NaN;
% 
%     end
% end   



        
    case 'processed'
%%%
        Rn = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'NetRad_AbvCnpy'); %%% Net Radiation
        
%         PAR_down_top = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownPAR_AbvCnpy');
%         PAR_reflected_top = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'UpPAR_AbvCnpy');
%         PAR_down_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownPAR_BlwCnpy');
% 
%         Tair_top = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'AirTemp_AbvCnpy');

        RH_top = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'RelHum_AbvCnpy');

        WS = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'WindSpd');
%         Wdir = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'WindDir');        
        
        if site == '1'
%         Tair_cpy = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'AirTemp_Cnpy');
%         Tair_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'AirTemp_BlwCnpy');            
%         RH_cpy = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'RelHum_Cnpy');
%         RH_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'RelHum_BlwCnpy');     
        SW_down = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownShortwaveRad');
%         SW_up = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'UpShortwaveRad');
% if strcmp(year,'2007') == 1;
   LW_down =  jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownLongwaveRad_AbvCnpy');
% else
%         LW_down = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'DownLongwaveRad');
% end
        LW_up = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'UpLongwaveRad_AbvCnpy');
%         Rn_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'NetRad_BlwCnpy');
        
%                     CO2_top = load([load_path_CPECproc 'CO2' yr(3:4) '.dat']);
%             CO2_cpy = jjb_load_var(hdr_cell_metproc, load_path_metproc,'CO2_Cnpy');
%             if site =='1';
%             CO2_bot = jjb_load_var(hdr_cell_metproc, load_path_metproc,'CO2_BlwCnpy');
%             end
%         
        
            if strcmp(yr, '2007') == 1; 
        PPT = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'CS_Rain'); % M1 - RMY_Rain, CS_Rain %M4 - Rain
            else
        PPT = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'RMY_Rain');
            end
        elseif site == '4'
             PPT = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'Rain');
        end
        
        if site == '1'
        APR = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'Pressure');
        else
        APR = load([filled_path 'pres_cl.dat']);
        end
% %% Soil Temp        
%         Ts2a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_2cm');
%         Ts2b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_2cm');
%         Ts5a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_5cm');
%         Ts5b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_5cm');
%         Ts10a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_10cm');
%         Ts10b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_10cm');
%         Ts20a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_20cm');
%         Ts20b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_20cm');
%         Ts50a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_50cm');
%         Ts50b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_50cm');
%         Ts100a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_A_100cm');
%         Ts100b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilTemp_B_100cm');
% %% Soil Moisture
%         SM5a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_A_5cm');
%         SM5b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_B_5cm');
%         SM10a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_A_10cm');
%         SM10b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_B_10cm');
%         SM20a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_A_20cm');
%         SM20b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_B_20cm');
%         SM50a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_A_50cm');
%         SM50b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_B_50cm');
%         SM100a = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_A_100cm');
%         SM100b = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SM_B_100cm');
% %% Soil Heat Flux Plates
%         if site == '1'
%         SHF1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_HFT_1');
%         SHF2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_HFT_2');
% 
%         else
%         SHF1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_1');
%         SHF2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'SoilHeatFlux_2');
%         end
% 
% %% Tree TCs        
%         if site == '2'
%        %% Load Tree Thermocouple data for Met 2:
%        TC1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree1_maxBN');
%        TC2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree2_maxBC');
%        TC3 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree3_maxBS');
%        TC4 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree4_medBN');
%        TC5 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree5_medBQN');
%        TC6 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree6_medBC');
%        TC7 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree7_medBQS');
%        TC8 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree8_medBS');
%        TC9 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree9_minBN');
%        TC10 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree10_minBC');
%        TC11 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree11_minBS');
%        
%        elseif site == '1'
%     TC1 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree1_20CmaxBN');
%     TC2 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree2_20CmaxBC');
%     TC3 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree3_20CmaxBS');
%     TC4 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree4_30CmaxTN');
%     TC5 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree5_20CmaxTC');
%     TC6 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree6_30CmaxTS');
%     TC7 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree7_19BmedBN');
%     TC8 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree8_19Bmed');
%     TC9 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree9_19BmedBC');
%     TC10 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree10_19BmedBS');
%     TC11 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree11_19BmedBQS');
%     TC12 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree12_29BmedTN');
%     TC13 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree13_29BmedTQN');
%     TC14 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree14_29BmedTC');
%     TC15 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree15_29BmedTS');
%     TC16 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree16_29BmedTQS');
%     TC17 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree17_17minBH');
%     TC18 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree18_17minBC');
%     TC19 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree19_17minBS');
%     TC20 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree20_27AminTN');
%     TC21 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree21_27Amin');
%     TC22 = jjb_load_var(hdr_cell_metproc, load_path_metproc, 'TreeTemp_Tree22_27Amin');  
%           
%         end
end   
     
%%
switch program
%     case 'SHF'
%         vars_out = [Ts2a Ts2b Ts5a Ts5b SHF1 SHF2];
%     case 'Storage'
%         vars_out = [T_air CO2_top CO2_cpy];
%     case 'Resp'
%         vars_out = [T_air PAR FC ustar];
%     case 'Photosynth'
%         vars_out = [T_air PAR SM5a SM5b SM10a SM10b SM20a SM20b ustar];
%     case 'Fluxes'
%         vars_out = [T_air PAR WS Rn SM5a SM5b SM10a SM10b SM20a SM20b ustar Hs_orig LE_orig];
%     case 'Analysis'
%         vars_out = [T_air PAR WS Rn SM5a SM5b SM10a SM10b SM20a SM20b ustar Hs_orig LE_orig Wdir RH RHc Ts5a Ts5b PAR_up];
% 
%     case 'HR'
%         vars_out = [SM10a SM10b SM20a SM20b SM50a SM50b SM100a SM100b];
%     case 'Fill' 
%         vars_out = [PAR PAR_up];
%     case 'EB'
%         vars_out = [Hs_orig LE_orig Jt G0 Rn];
%     case 'Ts'
%         vars_out = [Ts2a Ts2b Ts5a Ts5b Ts10a Ts10b Ts20a Ts20b Ts50a Ts50b Ts100a Ts100b];
        
    case 'Class'    %1     2         3       4       5       6     7   8   9       10     11    12
        vars_out = [NEP NEP_clean SW_down LW_down Tair_top RH_top APR PPT WS PAR_down_top Rn LW_up];
end





