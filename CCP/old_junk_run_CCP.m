% run_mcm_footprint('TP39')
% run_mcm_footprint('TP74')
% run_mcm_footprint('TP89')
% run_mcm_footprint('TP02')
%%%%%%%%%%%%%% Run CPEC site-spec gapfill for each site with footprint
%%%%%%%%%%%%%% filter
site_list = ['TP39';'TP74';'TP89'; 'TP02'];
Ustar_list = [0.35; 0.2; 0.3; 0.15];
yr_list = [2003 2009; 2003 2009; 2003 2007; 2003 2009];
fptypes = {'Schuepp';'Hsieh'};
XCrit_list = [0.6 0.7 0.8]';

for ctr = 1:1:4

site = site_list(ctr,:)
Ustar_th = Ustar_list(ctr,1);

for i = 1:1:length(XCrit_list)
    for j = 1:1:length(fptypes)

options.fpname = fptypes{j,1}
options.XCrit = XCrit_list(i,1)
[sums] = mcm_SiteSpec_Gapfill(site, yr_list(ctr,1), yr_list(ctr,2), Ustar_th, options);
    end
end
clear Ustar_th site;
end
%%%%%%%%%%%%%% Run CPEC FCRN gapfill for each site with footprint
%%%%%%%%%%%%%% filter
site_list = ['TP39';'TP74';'TP89'; 'TP02'];
Ustar_list = [0.35; 0.2; 0.3; 0.15];
yr_list = [2003 2009; 2003 2009; 2003 2007; 2003 2009];
fptypes = {'Schuepp';'Hsieh'};
XCrit_list = [0.6 0.7 0.8]';

for ctr = 1:1:4

site = site_list(ctr,:)
Ustar_th = Ustar_list(ctr,1);

for i = 1:1:length(XCrit_list)
    for j = 1:1:length(fptypes)

options.fpname = fptypes{j,1}
options.XCrit = XCrit_list(i,1)
[sums] = mcm_FCRN_Gapfill(site, yr_list(ctr,1), yr_list(ctr,2), Ustar_th, options);
    end
end
clear Ustar_th site;
end

%%%%%%%%%%%%%% And once with no footprint filter:
site_list = ['TP39';'TP74';'TP89'; 'TP02'];
Ustar_list = [0.35; 0.2; 0.3; 0.15];
yr_list = [2003 2009; 2003 2009; 2003 2007; 2003 2009];
fptypes = {'Schuepp';'Hsieh'};
XCrit_list = [0.6 0.7 0.8]';

for ctr = 1:1:4

site = site_list(ctr,:)
Ustar_th = Ustar_list(ctr,1);

[sumsSS] = mcm_SiteSpec_Gapfill(site, yr_list(ctr,1), yr_list(ctr,2), Ustar_th);

[sumsFCRN] = mcm_FCRN_Gapfill(site, yr_list(ctr,1), yr_list(ctr,2), Ustar_th);
clear Ustar_th site;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Compile_2003_2007('TP39')
Compile_2003_2007('TP74')
Compile_2003_2007('TP89')
Compile_2003_2007('TP02')
Align_Master_Files


mcm_data_compiler(2003:2009,'TP39')
mcm_data_compiler(2003:2009,'TP74')
mcm_data_compiler(2003:2009,'TP89')
mcm_data_compiler(2003:2009,'TP02')


