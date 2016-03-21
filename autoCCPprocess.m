%%% first compile:
site_all = {'TP39';'TP74';'TP89';'TP02';'TPD';'TP_PPT'};
site_CPEC = {'TP39', 2002:2015;'TP74', 2008:2015;'TP02', 2008:2015;'TPD', 2012:2015};
site_CCP_output = {'TP39', 2002:2015;'TP74', 2008:2015;'TP02', 2008:2015;'TPD', 2012:2015;'TP_PPT', 2007:2015};

% site_short = {'TP39', 2003:2013;'TP74', 2003:2013;'TP02', 2003:2013;'TPD', 2012:2013};
site_short = {'TP39', 2002:2015, 'all';'TP74', 2002:2015, 'all';'TP02', 2002:2015, 'all'; ...
                'TPD', 2012:2015, 'all';'TP89',2002:2008, 'all';'TP_PPT', 2007:2015, 'all'; ...
                'TP39',2007:2015, 'sapflow'; 'MCM_WX', 2007:2015, 'all'};

            
%% 20150130 - recalculations
site_CPEC = {'TP39', 2002:2015;'TP74', 2008:2015;'TP02', 2008:2015;'TPD', 2012:2015};
site_short = {'TP39', 2002:2015, 'all';'TP74', 2002:2015, 'all';'TP02', 2002:2015, 'all'; ...
                'TPD', 2012:2015, 'all';'TP89',2002:2008, 'all';'TP_PPT', 2007:2015, 'all'; ...
                'TP39',2007:2015, 'sapflow'; 'MCM_WX', 2007:2015, 'all'};
site_output = {'TP39', 2002:2015;'TP74', 2002:2015;'TP02', 2002:2015;'TPD', 2012:2015;'TP_PPT', 2007:2015; 'TP89', 2002:2007};


%%% fill met variables
% for yr = 2014:1:2015
% mcm_metfill(yr,1);
% end
% 
% %%% SHF Calculation
% for i = 1:1:length(site_CPEC);
%     mcm_SHF(2015,site_CPEC{i,1});
% end

%%% Storage and NEE calc:
% for yr = 2013:1:2015 
%     for i = 1:1:length(site_CPEC);
%         mcm_CPEC_storage(yr,site_CPEC{i,1},1,1)
%     end
% end

%%% First compile, no prompts, CPEC sites - 2013-2015 only:            
% for i = 1:1:length(site_CPEC);
% mcm_data_compiler(2013:2015, site_CPEC{i,1}, 'all',-1)
% end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
% try

% % LE,H Gapfilling
% for i = 4:1:length(site_CPEC);
% mcm_Gapfill_LE_H_default(site_CPEC{i,1},site_CPEC{i,2},0);
% end

% %NEE Gapfilling
% for j = 1:1:length(site_CPEC);
% mcm_Gapfill_NEE_default(site_CPEC{j,1},[],0);
% end
% 
% %%% Full compile, no prompts, all sites:            
% for k = 1:1:length(site_short);
% mcm_data_compiler(site_short{k,2}, site_short{k,1}, site_short{k,3},-2)
% end
% sendmail('jason.brodeur@gmail.com','Done','Done');

% %%% CCP Output
% mcm_fluxnet_output(site_output{3,2}, site_output{3,1});
tic;
for i = 1:1:length(site_output);
%     mcm_CCP_output(site_output{i,2}, site_output{i,1},[],[]);
    try
        mcm_fluxnet_output(site_output{i,2}, site_output{i,1});
    catch
        disp(['Couldn''t do mcm_fluxnet_output for ' site_output{i,1}]);
    end
    disp(['Completed output for ' site_output{i,1}]);
end
t = toc;
sendmail({'jason.brodeur@gmail.com'; 'arainm@mcmaster.ca'},'Fluxnet data prepared.',['Done in ' num2str(t) 'seconds. Wait a few minutes for upload to Google Drive.']);


% mcm_CCP_output(year,site,CCP_out_path, master,ftypes_torun)

% sendmail('jason.brodeur@gmail.com','Error.','Error.');
% end
%%

%%% Storage and NEE calc:
for i = 1:1:length(site_CPEC);
    mcm_CPEC_storage(2015,site_CPEC{i,1},1)
end

%%% First compile, no prompts, all sites - 2015 only:            
for i = 1:1:length(site_short);
mcm_data_compiler(2015, site_short{i,1}, site_short{i,3},-1)
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

%%% Full compile, no prompts, all sites:            
for i = 1:1:length(site_short);
mcm_data_compiler(site_short{i,2}, site_short{i,1}, site_short{i,3},-2)
end
%%% Full compile, no prompts, all sites - 2015 only:            
for i = 1:1:length(site_short);
mcm_data_compiler(2015, site_short{i,1}, site_short{i,3},-2)
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
% %%% FROM SCRATCH Full compile, no prompts, all sites:            
% for i = 1:1:length(site_short);
% mcm_data_compiler(site_short{i,2}, site_short{i,1}, site_short{i,3},-9)
% end

%%% Full compile, no prompts, CPEC sites:            
for i = 1:1:length(site_CPEC);
mcm_data_compiler(site_CPEC{i,2}, site_CPEC{i,1}, 'all',-2)
end

%%% CCP Output
for i = 1:1:length(site_CCP_output);
mcm_CCP_output(site_CCP_output{i,2}, site_CCP_output{i,1},[],[])
end


%%%
mcm_CCP_output(2015, 'TP39',[],[]);
mcm_CCP_output(2015, 'TPD',[],[]);



%%%

%%% CCP Output
for i = 1:1:length(site_CCP_output);
mcm_CCP_output(site_CCP_output{i,2}, site_CCP_output{i,1},[],[])
end


%%% LE Gap-filling:
for i = 4:1:length(site_short);
mcm_Gapfill_LE_H_default(site_short{i,1},site_short{i,2},0);
end

for i = 1:1:length(site_CPEC);
mcm_Gapfill_LE_H_default(site_CPEC{i,1},site_CPEC{i,2},0);
end

for i = 1:1:length(site_CPEC);
mcm_Gapfill_NEE_default(site_CPEC{i,1},[],0);
end

% mcm_CCP_output(2002:2013,'TP39',[],[]);
% mcm_CCP_output(2002:2013,'TP74',[],[]);
% mcm_CCP_output(2002:2013,'TP02',[],[]);
% mcm_CCP_output(2002:2008,'TP89',[],[]);
mcm_CCP_output(2012:2013,'TPD',[],[]);
mcm_CCP_output(2008:2013,'TP_PPT',[],[]);

mcm_CPEC_storage(2015,'TP39',1)
mcm_CPEC_storage(2015,'TP74')
mcm_CPEC_storage(2015,'TPD')

ind = [1,4]

%% Run footprints, gapfilling
for i = 1:1:length(site_CPEC)
run_mcm_footprint(site_CPEC{i},[],0);
end
run_mcm_footprint('TP02',2015,0);


%% Recalculating fluxes:
site_CPEC2 = {'TP39';'TP74';'TP02';'TPD'};
for i = 1:1:length(site_CPEC2)
% mcm_calc_fluxes(site_CPEC2{i,1},'CPEC',{'2015,01,01', '2016,01,01'});
% mcm_CPEC_mat2annual(2015, site_CPEC2{i,1}, -1);
% mcm_fluxclean(2015, site_CPEC2{i,1},1);
mcm_fluxfixer(2015,site_CPEC2{i,1},1);

end
sendmail('jason.brodeur@gmail.com','Done','Done');
%%
mcm_calc_fluxes('TP02', 'CPEC',{'2015,01,30', '2015,12,15'});
mcm_CPEC_mat2annual(2015, 'TP02', -1);
mcm_calc_fluxes('TPD', 'CPEC',{'2015,10,14', '2015,12,15'});
mcm_CPEC_mat2annual(2015, 'TPD', -1);



%% run stuff only for TP39, TPD:
ind = [1;4];
site_CPEC = {'TP39', 2003:2015;'TP74', 2008:2015;'TP02', 2008:2015;'TPD', 2012:2015};

for i = 1:1:1%length(ind)
tic;
%     run_mcm_footprint(site_CPEC{ind(i),1},[],0); % run footprint
    t(i,1) = toc;
try mcm_Gapfill_LE_H_default(site_CPEC{ind(i),1},site_CPEC{ind(i),2},0); % LE, H Gapfilling
catch; disp(['LE,H Gapfill failed for ' site_CPEC{ind(i),1}]); end
    
try mcm_Gapfill_NEE_default(site_CPEC{ind(i),1},[],0); % NEE Gapfilling
catch; disp(['NEE Gapfill failed for ' site_CPEC{ind(i),1}]); end
mcm_data_compiler(site_CPEC{ind(i),2}, site_CPEC{ind(i),1}, 'all',-2)
t(i,2) = toc;
end

sendmail('jason.brodeur@gmail.com','Done','Done.');

% mcm_CCP_output(2015,'TPD',[],[]);
% mcm_CCP_output(2015,'TP39',[],[]);
