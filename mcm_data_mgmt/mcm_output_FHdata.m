function [] = mcm_output_FHdata(year,data_level)
%%% mcm_output_FHdata.m
% This function is used to output TP_PPT data into a yearly file in a format 
% that can be easily shared with others (e.g. Fish Hatchery people).
% usage: mcm_output_FHdata(year,data_level), where
% data_level = 1 denotes cleaned data, and data_level = 2 denotes filled.

if ischar(year)==1
    yr_str = year;
else
    yr_str = num2str(year);
end
year = str2double(yr_str);

if nargin == 1
    commandwindow;
    data_level = input('Enter 1 for cleaned data; enter 2 for filled data: ');
end

ls = addpath_loadstart;
met_cleaned_path = [ls 'Matlab/Data/Met/Final_Cleaned/TP39/'];
met_filled_path = [ls 'Matlab/Data/Met/Final_Filled/TP39/'];

ppt_cleaned_path = [ls 'Matlab/Data/Met/Final_Cleaned/TP_PPT/'];
ppt_filled_path = [ls 'Matlab/Data/Met/Final_Filled/TP_PPT/'];

%%% Time data:
[tvec YYYY Mon Day dt hhmm hh mm JD] = jjb_maketimes(year, 30);
%    [YYYY, JD, HHMM, dt] = jjb_makedate(year, 30);
%    [Mon Day] = make_Mon_Day(year, 30);
    
   %%% Load Data:
    if data_level == 1; % Cleaned Data:
        tag = 'Cleaned';
        % Get PPT data:
%         load([ppt_cleaned_path 'TP_PPT_met_cleaned_' yr_str '.mat']);
%         PPT = loadvar(master,'GN_Precip');
        PPT = load([ppt_cleaned_path 'TP_PPT_' yr_str '.GN_Precip']);
        clear master;
        % Get Met data:
        load([met_cleaned_path 'TP39_met_cleaned_' yr_str '.mat']);
        PAR = loadvar(master,'DownPAR_AbvCnpy');
        Ta = loadvar(master,'AirTemp_AbvCnpy');
        RH = loadvar(master,'RelHum_AbvCnpy');
        WS =  loadvar(master,'WindSpd');
        
    else % Filled Data:
        tag = 'Filled';
        % Get PPT data:
        load([ppt_filled_path 'TP_PPT_filled_' yr_str '.mat']);
        PPT = loadvar(master,'GEO_PPT');
        clear master;
        % Get Met data:
        load([met_filled_path 'TP39_met_filled_' yr_str '.mat']);
        PAR = loadvar(master,'DownPAR_AbvCnpy');
        Ta = loadvar(master,'AirTemp_AbvCnpy');
        RH = loadvar(master,'RelHum_AbvCnpy');
        WS =  loadvar(master,'WindSpd');
    end

       
%%% Converts all to EST (from UTC):
Final = [YYYY JD Mon Day hhmm PPT Ta RH PAR WS];
% [rows cols] = size(Final);
% Final_EST = [Final(1:end,1:5) [Final(11:end,6:cols); NaN.*ones(10,cols-6+1)]];

A(1,1)  = cellstr('Year'); A(2,1)  = cellstr('JD'); A(3,1)  = cellstr('Month'); 
A(4,1)  = cellstr('Day'); A(5,1)  = cellstr('HHMM'); A(6,1)  = cellstr('PPT'); 
A(7,1)  = cellstr('Ta'); A(8,1)  = cellstr('RH'); A(9,1)  = cellstr('PAR'); 
A(10,1)  = cellstr('WS'); 
AA = char(A);
format_code = '\n %4.0f\t %3.0f\t %2.0f\t %2.0f\t %4.0f\t %4.2f\t %3.1f\t %4.1f\t %5.1f\t %4.2f\t';

Preamble(1,1) =cellstr(['Fish Hatchery and TP39 half-hourly data for year: ' yr_str]);
Preamble(2,1) =cellstr('All variables are listed in UTC timecode (EST+5)');
Preamble(3,1) =cellstr('Variable Explanation: ');
Preamble(4,1) =cellstr('col 1: Year ');
Preamble(5,1) =cellstr('col 2: JD ');
Preamble(6,1) =cellstr('col 3: Month ');
Preamble(7,1) =cellstr('col 4: Day ');
Preamble(8,1) =cellstr('col 5: HHMM - 24hr daily clock');
Preamble(9,1) =cellstr('col 6: PPT - half hourly precipitation accumulation (mm) at Fish Hatchery');
Preamble(10,1) =cellstr('col 7: Ta - 1/2 hour average air temperature at 28m height at TP39 station');
Preamble(11,1) =cellstr('col 8: RH - 1/2 hour average relative humidity at 28m height at TP39 station');
Preamble(12,1) =cellstr('col 9: PAR - 1/2 hour average downwelling photosyntheically active radiation (sunshine) at 28m height at TP39 station');
Preamble(13,1) =cellstr('col 10: WS - 1/2 hour Windspeed at 28m height at TP39 station');
Preamble(14,1) =cellstr('Data is property of McMaster University, Climate Change Research Group');
Preamble(15,1) =cellstr('For further inquiries, please contact Dr. Altaf Arain: 905-525-9140 ext. 27941');
Preamble(16,1) = cellstr(' ');

Pre_char = char(Preamble);



fid = fopen([ls 'Matlab/Data/Distributed/For_FH_' tag '_' yr_str '_prepared-' datestr(now,29) '.dat'],'w');


for i = 1:1:length(Preamble)
    h3 = fprintf(fid,'%117s\n',Pre_char(i,:));
end


for j = 1:1:length(A)
h = fprintf(fid, '%6s\t' , AA(j,:) );
end


for j = 1:1:length(YYYY)
    h2 = fprintf(fid,format_code,Final(j,:));
end

fclose(fid);

disp(['You can find your data at: ' ls 'Matlab/Data/Distributed/For_FH_' tag '_' yr_str '_prepared-' datestr(now,29) '.dat' ])
end

function [var_out] = loadvar(master,var_name)

        if ~iscell(master.labels)
            labels = cellstr(master.labels);
        else
            labels = master.labels;
        end
        
  right_col = find(strcmp(labels(:,1),var_name)==1,1,'first');
  var_out = master.data(:,right_col);
  
end

        
