mcm_Gapfill_NEE_default('TP39',[],0);
mcm_Gapfill_NEE_default('TP74',[],0);
mcm_Gapfill_NEE_default('TP02',[],0);
mcm_Gapfill_NEE_default('TPD',[],0);
mcm_Gapfill_NEE_default('TP89',[],0);

mcm_data_compiler(2002:2014, 'TP39', 'general',-9);
mcm_data_compiler(2002:2014, 'TP74', 'general',-9);
mcm_data_compiler(2002:2014, 'TP02', 'general',-9);
mcm_data_compiler(2012:2014, 'TPD', 'general',-9);
mcm_data_compiler(2002:2008, 'TP89', 'general',0);



% mcm_CCP_output(2002:2010,'TP39',[],[]);
% mcm_CCP_output(2002:2008,'TP89',[],[]);
% mcm_CCP_output(2002:2010,'TP74',[],[]);
% mcm_CCP_output(2002:2010,'TP02',[],[]);
