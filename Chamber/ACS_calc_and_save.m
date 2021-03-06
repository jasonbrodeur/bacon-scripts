function [HHour] = ACS_calc_and_save(dateRange,SysNbr,metdataPath,recalcFlag, plotFlag)
%[HHour] = ACS_calc_and_save(dateRange,SysNbr)
%
%
% (c) David Gaumont-Guay & Zoran Nesic           File created:             , 2005
%                                                Last modification   Feb 10, 2008

%Revisions:
%
% Mar 25, 2008
%   - moved the stuff below from an orphan version of
%   acs_calc_and_save_20080312a.m
%   - added a call to fr_moveHFtoDailyFolders to put all data files into
%   the right locations
%   - fixed a few editor warnings (&& and || instead of & and |)
% Feb 10, 2008
%   - Had to fix another special case (multiple Timer points that are the same
%   and at the end of the trace [... 1798 1799 1.5 1.5].  Added the fudge
%   factor 0.99 * size(...)
% Feb 8, 2008
%   - Corrected the data processing for occasional HHours when the Timer
%   (DataHF(:,6)) goes from 1800 to 0. Data comes like this from UBC_GII.
%    This solution will prevent any case (even multiple points) where
%    Timer(end) < Timer(end-1) 
% Aug 6, 2007
%   - added plotFlag
% July 21, 2007
%   - added TimeVector field to HHour
%   - removed "+VB2MatlabDateOffset" from datestr calculation to get
%     correct date (year 2007 instead of 3907)
% Mar 20, 2007
%   - added an option for plotting (plotFlag = 1)
% Mar 13, 2007
%   - implemented delay time to improve data processing by including the
%   time delay between the chamber is selected and the time air sample
%   arrives to the IRGA
% Jun 8, 2009 -- JJB
%   - added a line to change the number of chambers based on the date of
%   interest % ( 4 chambers before 08 May 2009, 6 chambers after that )
% Jan 15, 2010 - JJB
%   - edited subfunction acs_read_init_all so that it looks for
%   'ACS_init_all.txt' and not for 'acs_init_all.txt' -- Linux has trouble
%   with case missmatches.


% example of extracting data
% x = get_Stats_field(HHour,'Chamber(1).Sampe(3).airTemperature')

if ischar(dateRange)
    dateRange = eval(dateRange);
end
if ischar(SysNbr)
    SysNbr = eval(SysNbr);
end

if ischar(recalcFlag)
    recalcFlag = eval(recalcFlag);
end

if metdataPath(end) ~= '/' % Changed direction of slashes to work in linux/Windows
    metdataPath = [metdataPath '/'];
end

numOfErrors = 0;
numOfFiles = 0;

warning ('off', 'MATLAB:divideByZero');
warning('off','MATLAB:dispatcher:InexactMatch');
VB2MatlabDateOffset = 693960;
delete(fullfile(metdataPath,'log','ACS_calc_and_save.log'));
diary(fullfile(metdataPath,'log','ACS_calc_and_save.log'));
disp('=============================================')
disp(['Calculations started: ' datestr(now)])
disp('   ');

tic;    
% First move files from the ...\data folder into the yymmdd folders
% (configIn.path point to the data folder)
configIn  = acs_read_init_all(floor(dateRange(end)), SysNbr, metdataPath);
[numFiles] = fr_moveHFtoDailyFolders(configIn.path,6);
disp(sprintf('%d files moved from %s folder into %s\yymmdd folders.',numFiles,configIn.path,configIn.path))

    % Added by JB and RT (22-Jan-2014): modifying the chamber volume usign
    % the file: /1/fielddata/Matlab/ubc_PC_setup/Site_Specific/TP39_chamber/ACS_Volume.csv
    ls = addpath_loadstart;
    ch_vol = csvread([ls 'Matlab/ubc_PC_setup/Site_Specific/TP39_chamber/ACS_Volume.csv']);
    ch_vol_dn = datenum(ch_vol(:,1:3));


for dateRangeCurrent = dateRange

    HHour = [];
    
    %Get inifile information
    configIn  = acs_read_init_all(floor(dateRangeCurrent), SysNbr, metdataPath);

    % Added by JB and RT (22-Jan-2014): modifying the chamber volume usign
    % the file: /1/fielddata/Matlab/ubc_PC_setup/Site_Specific/TP39_chamber/ACS_Volume.csv
%     ch_vol_day = ch_vol
try
    ch_vol_day = ch_vol(ch_vol_dn == dateRangeCurrent,4:11);
catch
    ch_vol_day = 0.069*ones(1,8);
    disp('Could not establish chamber volumes, using defaults');
end
    
    %Create filename for input and output files
    FileName_p = datestr(datestr(dateRangeCurrent),30);
    FileName_p = FileName_p(3:8);

    disp(sprintf('Processing data in folder: %s',[configIn.path num2str(FileName_p(1:6))]))
    
    % Check if recalculation is needed
    if recalcFlag ~= 1 & ~isempty (dir([configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext]));
        disp(['('  FileName_p(1:6) ') ' 'Skipped. HHour data already calculated.']);
    else
        %Find all the files in the current directory that are associated with ACS
        dirInfo = dir([configIn.path num2str(FileName_p(1:6)) '/*' configIn.HF_ext num2str(SysNbr)]);
        numOfFiles = numOfFiles + length(dirInfo);
        
        %Loop through files available in current directory and compute fluxes
        for g = 1:length(dirInfo)    

            hhourNbr = str2num(dirInfo(g).name(7:8))/2;

            %import high frequency data (DataHF)
            fullFileName = [configIn.path num2str(FileName_p(1:6)) '/' dirInfo(g).name];
            [DataHF,header] = fr_read_Digital2_file(fullFileName);

            % find out if the file contains at least a hundred points.
            % There was 
            
            % check if the data has the last point in the next half hour
            % (happens sometimes with UBC_GII program)
            while size(DataHF,1) > 1 & (DataHF(end,6)< DataHF(end-1,6) | ...
                DataHF(end,6) < 0.99 * size(DataHF,1))% If the last Timer value less than previous
                % remove the last sample
                DataHF = DataHF(1:end-1,:);
            end
            
            %Store filename, time stamp (end of hhour) and configuration info in HHour
            HHour(hhourNbr).HhourFileName = dirInfo(g).name;
            HHour(hhourNbr).TimeVector    = header.hhourStartTime;
            HHour(hhourNbr).HhourEndTime  = datestr(header.hhourStartTime);
            HHour(hhourNbr).Configuration = configIn;

            %Store diagnostic results for full halfhour (from DataHF) in HHour
            [m,n] = size(DataHF);
            for j=1:n
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).avg = mean(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).min = min(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).max = max(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).std = std(DataHF(:,j));
            end

            %Store DataHF in HHour
            HHour(hhourNbr).DataHF.co2 = DataHF(:,configIn.chanMeasured.co2);
            HHour(hhourNbr).DataHF.h2o = DataHF(:,configIn.chanMeasured.h2o);
            HHour(hhourNbr).DataHF.timer = DataHF(:,configIn.chanMeasured.timer);

            %loop through each chamber and each slope and compute fluxes (and associated variables)
            indSlope_all = [];                      % clear the matrix
            indChamber_all = [];                    % clear the matrix
%            try        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Added in by JJB to vary the number of chambers depending on the date
% ( 4 chambers before 08 May 2009, 6 chambers after that )
% if dateRangeCurrent < 733902; configIn.chNbr = 4; else configIn.chNbr =
% 8; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for chNbr = 1:configIn.chNbr
                    %Get index for each chamber
                    indSingleChamber = find(ceil(DataHF(:,configIn.chanMeasured.chNbr))==chNbr);
                    indChamber_all(chNbr).indSingleChamber = indSingleChamber;
                    % Find where the border is beteween different slopes
                    indDiff = find(diff(indSingleChamber)>1);
                    
                    % find starting point for each slope
                    indStartPoints = [1 ; indDiff+1];
                                        
                    %Get data for each slope for each chamber based on index
                    %Delay co2 and h2o signals
                    indSingleChamberDelayed = indSingleChamber + configIn.slopeDelay;

                    % Make sure you don't go beyond the last sample
                    indSingleChamberDelayed = indSingleChamberDelayed(find(indSingleChamberDelayed <= m));
                    indChamber_all(chNbr).indSingleChamberDelayed = indSingleChamberDelayed;
                    indChamber_all(chNbr).indSingleChamber = indSingleChamber;
                    
                    % Extract HF data for the delayed signals
                    co2 = DataHF(indSingleChamberDelayed,configIn.chanMeasured.co2);
                    h2o = DataHF(indSingleChamberDelayed,configIn.chanMeasured.h2o);
                    
                    % Extract HF data for non delayed signals
                    airT = DataHF(indSingleChamber,configIn.chanMeasured.airT(chNbr));
                    tTimer = DataHF(indSingleChamber,configIn.chanMeasured.timer);
                    
                    % Get the average air pressure
                    if isempty(configIn.chanMeasured.airP)
                        airP = ones(size(co2))*configIn.pBar;
                    else
                        airP = DataHF(indSingleChamber,configIn.chanMeasured.airP);
                    end

                    %Calculate regression for each slope for each chamber
                    for slopeNbr = 1:length(indStartPoints)
                        if slopeNbr ~= length(indStartPoints)
                            % pick all points between this start point and
                            % one point before the next start point
                            indSlope = indStartPoints(slopeNbr):indStartPoints(slopeNbr+1)-1;
                        else
                            % if processing the last start point pick all
                            % data from the last start point until the last
                            % sample for this chamber
                            indSlope = indStartPoints(slopeNbr):length(indSingleChamber);
                        end
                        if ~isempty(indSlope)
                            indSlope = [indSlope(1)+configIn.slopeSkipStart:indSlope(end)-configIn.slopeSkipEnd];
                        end
                        % find the valid indexes 
                        indValid = find(indSlope <= length(indSingleChamber) & indSlope <=length(indSingleChamberDelayed));
                        indSlope = indSlope(indValid);
                        
                        % store the indexing info for the plotting                         
                        indSlope_all(chNbr,slopeNbr).indSlope = indSingleChamber(indSlope);
                        indSlope_all(chNbr,slopeNbr).indSingleChamberDelayed = indSingleChamberDelayed(indSlope);
                        % Store slope related stats
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airTemperature = mean(airT(indSlope));
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airPressure    = mean(airP(indSlope));

                        %Compute regression for each slope
                       try
                        [p,r2,sigma,s,fval,regHHour] = polyfit1([1:length(indSlope)]',co2(indSlope),1);
                        
                       catch
                           warning('Error running polyfit1 for co2 - data for slopes seem to be empty')
                           p = [0 0];
                           r2 = NaN;
                       end
                        % Added Sep 7, 2010 by EDN and JJB -- Going to try
                        % and calculate a slope for h20
                       try
                       [p_h2o,r2_h2o,sigma_h2o,s_h2o,fval_h2o,regHHour_h2o] = ...
                           polyfit1([1:length(indSlope)]',h2o(indSlope),1);
                       catch
                           warning('Error running polyfit1 for h2o - data for slopes seem to be empty')
                           p_h2o = [0 0];
                           r2_h2o = NaN;
                       end
                        
                        %Store regression results in HHour
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt = p(1);
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rsquare = r2;
                        slopeLength = length(indSlope);
                        
                        % Store h2o regression results in HHour
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt_h2o = p_h2o(1);
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rsquare_h2o = r2_h2o;
%                         slopeLength_h2o = length(indSlope);
                        
                      
if p(1) == 0 && p(2) == 0
    HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse  = NaN;
else
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse = sqrt( sum( (co2(indSlope)'-polyval(p,1:slopeLength)).^2 ) / slopeLength );
end

%%%% Added Sep 7, 2010 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if p_h2o(1) == 0 && p_h2o(2) == 0
    HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse_h2o  = NaN;
else
    HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse_h2o = sqrt( sum( (h2o(indSlope)'-polyval(p_h2o,1:slopeLength)).^2 ) / slopeLength );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        %Compute and store effluxes in HHour
                        dcdt = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt;
                        dcdt_h2o = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt_h2o;
                        airTemperature = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airTemperature;
                        airPressure = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airPressure;
                        %%%%%%%%%%%% Modified by Rob and Jay, 22-Jan-2014 %%
                        %chVolume = configIn.chVolume(chNbr); %%% Commented 22-Jan-2014 by Rob and Jay 
                        chVolume = ch_vol_day(chNbr);
                        %disp(['Chamber volume is: ' num2str(chVolume)]);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        chArea = configIn.chArea(chNbr);

                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).efflux = airPressure .* chVolume .* dcdt ...
                            ./ (8.3144.*(airTemperature+273.15).*chArea.*(1 +(mean(h2o(indSlope)./1000))));                
%%%% Added Sep 7, 2010 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Not 100% sure that the calculation for LE is correct, so if it's not, feel free to fix it. 
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).LE = ...
                        (airPressure .* chVolume .* dcdt_h2o ./ (8.3144.*(airTemperature+273.15).*chArea)) ...
                        .*(18.*(2.501 - 0.002361.*(airTemperature+273.15)));                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        %Store diagnostic variables for each slope
                        [m1,n1] = size(DataHF(indSingleChamber(indSlope),:));
                        for h=1:n1
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).avg ...
                                                            = mean(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).min ...
                                                            = min(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).max ...
                                                            = max(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).std ...
                                                            = std(DataHF(indSingleChamber(indSlope),h));
                        end % next h
                    end % next slopeNbr
                end % next chNbr
                if plotFlag == 1
                    test_plot(DataHF,indSlope_all,indChamber_all,HHour,hhourNbr, dirInfo(g).name)
                end 
                disp(sprintf('Processed file: %s.',dirInfo(g).name))
%            catch
%                numOfErrors = numOfErrors + 1; 
%                disp(sprintf('**** Error in file: %s. Error: [%s]',fullFileName,lasterr))
%             end % of try-catch
         end % next HF file

        %Export output file
        if ~isempty(dirInfo)
            if ~isempty(HHour)
                FileName = [configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext]; 
                save(FileName,'HHour');
            else
                disp('Files exist but data processing failed');
            end
        else
            disp('Files do not exist and data processing failed');
        end
    end
end
disp(sprintf('%0.0f of %0.0f hhour files processed in %4.2f seconds',numOfFiles-numOfErrors,numOfFiles,toc));
disp('   ');
disp('   ');
diary off

function c = acs_read_init_all(dateRange, SysNbr, metdataPath)

c =[];
fid = fopen('ACS_init_all.txt');  % Modified by JJB - changed ACS from 'acs' to uppercase to match case in /Site_Specific/
if fid < 0
    error('Init file: ACS_init_all.txt not found! - Make sure your ACS_init_all file has the exact same cases as shown here.')
end

while 1
    s = fgetl(fid);
    if ~ischar(s),break,end
    eval(s)
end

fclose(fid);

function test_plot(DataHF,indSlope_all,indChamber_all,HHour,hhourNbr,fileName)
    figure(1);
%    ha1=subplot(1,2,1);
%    set(ha1,'position',[0.07 0.11 0.3 0.815]);
    indSlope = indSlope_all(1,1).indSlope;
    co2 = DataHF(:,1);
    tTimer = DataHF(:,6);
    if ~isempty(indSlope)
        for chNbr=1:size(indSlope_all,1)
            plot(tTimer,co2,'.',tTimer(indChamber_all(chNbr).indSingleChamberDelayed),co2(indChamber_all(chNbr).indSingleChamberDelayed),'r.')
            title(sprintf('Chamber = %d, hhour = %d, Data file: %s',chNbr,hhourNbr,fileName))
            indSingleChamber = indChamber_all(chNbr).indSingleChamber;
            line(tTimer(indSingleChamber),co2(indSingleChamber),'marker','o','markeredgecolor','k','linestyle','none');

            for slopeNbr = 1:size(indSlope_all,2)
                indSlope = indSlope_all(chNbr,slopeNbr).indSlope;
                indSlopeDelayed = indSlope_all(chNbr,slopeNbr).indSingleChamberDelayed;
                
                try
%                    disp(sprintf('%d %d %8.4f %8.4f %8.4f',[hhourNbr chNbr
%                    slopeNbr HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse]));
                    line(tTimer(indSlopeDelayed),co2(indSlopeDelayed),'marker','o','markeredgecolor','g','linestyle','none');
                    line(tTimer(indSlopeDelayed),mean(co2(indSlopeDelayed))+detrend((0:length(indSlopeDelayed)-1)*HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt,0));
%                    line(tTimer(indSlopeDelayed),mean(co2(indSlopeDelayed(1:5)))+(0:length(indSlopeDelayed)-1)*HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt);
                    xTxt = tTimer(indSlopeDelayed(round(1)));
                    yTxt = ( min(co2(indSlopeDelayed)) + max(co2(indSlopeDelayed)) )/2;
                    dcdtC = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt;
                    rmseC = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse;
                    text(xTxt,yTxt+3,sprintf( '%5.2f' ,dcdtC),'fontsize',10,'fontwe','bold')
                    text(xTxt,yTxt+0,sprintf('(%5.2f)',rmseC),'fontsize',10,'fontwe','bold')
                    zoom on
                catch
%                    disp(sprintf('%d %d %d',[hhourNbr chNbr slopeNbr]))
                end
            end
            pause
        end
%        ha2=subplot(1,2,2);
%        set(ha2,'position',[0.44 0.11 0.3 0.815])
    end
