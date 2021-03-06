master_path = '/1/fielddata/Matlab/Data/';

cd('/1/fielddata/Matlab/Data/Master_Files/TP39');
load([master_path 'Master_Files/TP39/TP39_data_master.mat']);

yr = master.data(:,1);
Ta_blw = master.data(:,52);
Ta_cpy = master.data(:,51);
Ta_abv = master.data(:,50);
RH_blw = master.data(:,55);
RH_cpy = master.data(:,54);
RH_abv = master.data(:,53);

WS = master.data(:,56);
PAR= master.data(:,47);

decyear = [];
ctr = 1;
for i = min(yr):1:max(yr)
    [tvec YYYY MM DD dt hhmm hh mm JD] = jjb_maketimes(i, 30);
    dt = dt-1;
    tmp = YYYY+dt./max(dt);
    decyear = [decyear; tmp];
ctr = ctr + 1;
end
[clrs, clr_list] = jjb_get_plot_colors;

%%% TP74 data:
% cd('Z:/Matlab/Data/Master_Files/TP74');
load([master_path 'Master_Files/TP74/TP74_data_master.mat']);
Ta_TP74 = master.data(:,42);                                                                                                      

figure(1);clf;
plot(decyear,(WS-nanmean(WS)).*10,'-','LineWidth',0.5,'Color',[0.6 0.6 0.6]);hold on;
plot(decyear,PAR./100,'y-','Marker','x','LineWidth',0.5);
h1(1)=plot(decyear,Ta_abv,'b-','Marker','x','LineWidth',2); hold on;
h1(2)=plot(decyear,Ta_cpy,'g-','Marker','x');
h1(3)=plot(decyear,Ta_blw,'r-','Marker','x');
% h1(4)=plot(decyear,Ta_TP74,'Color',clrs(13,:));
% legend(h1,{'above','canopy','below','TP74(above)'});
legend(h1,{'above','canopy','below'});
grid on;
%%% Load up TP39 data from 2016 -- let's investigate this:
load([master_path 'Met/Cleaned3/TP39/TP39_master_2016.mat']);

master.labels = cellstr(master.labels);
Ta_blw_2016 = master.data(:,3);
Ta_cpy_2016 = master.data(:,2);
Ta_abv_2016 = master.data(:,1);

figure(3);clf;
h1(1)=plot(Ta_abv_2016,'bx-','LineWidth',2); hold on;
h1(2)=plot(Ta_cpy_2016,'gx-');
h1(3)=plot(Ta_blw_2016,'rx-');
legend(h1,{'above','canopy','below'});
