 function [real_spikes] = jjb_find_spike2(array_in, z,sdev,start, real_z)
%% This function finds spikes in the input variable by comparing 


if nargin == 3 || isempty(start)
 figure(99); clf; plot(array_in,'k.-')   
 start = input('please pick a good array_inpoint to start at:');

end
if nargin == 4
    real_z = [];
end



%% Establish stats for array_inset:
d_bef(2:length(array_in),1) = array_in(2:length(array_in)) - array_in(1:length(array_in)-1); 
d_aft(1:length(array_in)-1,1) = array_in(2:length(array_in)) - array_in(1:length(array_in)-1);
%%% First and last entries for each are calculated by wrapping around
d_bef(1,1) = array_in(1) - array_in(length(array_in));
d_aft(length(array_in),1) = array_in(1) - array_in(length(array_in));
%%% Calculate d_i
d_i = d_bef - d_aft;
% MAD(1:length(array_in),1) = NaN;

if isempty(real_z)==1
Md = median(d_i(~isnan(d_i)));
MAD = median(abs(d_i(~isnan(d_i)) -Md));    
up_thresh(1:length(array_in),1) = z; %15;    %Md + ((z.*MAD)./0.6745)
down_thresh(1:length(array_in),1) = -z; %= -15; %Md - ((z.*MAD)./0.6745)
else
    d_ix = (1:1:length(d_i))';
    ctr = 1;
    for i = 0:624:length(array_in)-624
        ind_good = find(~isnan(d_i) & d_ix <= i+624 & d_ix >= i+1);
        
        Md(ctr,1) = median(d_i(ind_good),1);
        
        MAD(ctr,1) = median(abs(d_i(ind_good,1) - Md(ctr,1)));
   up_thresh(i+1:i+624,1) = Md(ctr,1) + ((real_z.*MAD(ctr,1))./0.6745);
   down_thresh(i+1:i+624,1) = Md(ctr,1) - ((real_z.*MAD(ctr,1))./0.6745);

   
        ctr = ctr+1;
        clear ind_good;
    end

    %%% do last little bit of data:
    if length(array_in) - i(end) > 624;
      ind_good = find(~isnan(d_i) & d_ix >= i+624+1 & d_ix <= length(array_in));
       Md(ctr+1,1) = median(d_i(ind_good),1);
       MAD(ctr+1,1) = median(abs(d_i(ind_good,1) - Md(ctr+1,1)));
      up_thresh(i+1+624:i+624+624,1) = Md(ctr+1,1) + ((real_z.*MAD(ctr+1,1))./0.6745);
   down_thresh(i+1+624:i+624+624,1) = Md(ctr+1,1) - ((real_z.*MAD(ctr+1,1))./0.6745);
     
    end
   
% up_thresh(:,1) = Md + ((real_z.*MAD)./0.6745);
% down_thresh(:,1) = Md - ((real_z.*MAD)./0.6745);

end
%%
ind = (1:1:length(array_in))';
good_ind = find(~isnan(array_in));
spike_tracker1(1:1:length(array_in),1) = 0;
spike_tracker2(1:1:length(array_in),1) = 0;
spike_tracker3(1:1:length(array_in),1) = 0;

real_spikes(1:1:length(array_in),1) = 0;

%% Let's try using ensemble averages
ww = 624;
for p = 0:ww:length(array_in)-ww
    en_temp = ensemble_avg(array_in(p+1:p+ww,1));
    en_avg(1:48,(p./ww)+1) = en_temp(1:48,1);
    en_std(1:48,(p./ww)+1) = en_temp(1:48,2);
    en_medd(1:48,(p./ww)+1) = en_temp(1:48,3);    
clear en_temp
end

%%% Do the last little bit of array_in
leftover = length(array_in) - p(end)-ww;
en_temp = ensemble_avg(array_in(p(end)+1:length(array_in),1));

en_avg(1:48,(p./ww)+2) = en_temp(1:48,1);
en_std(1:48,(p./ww)+2) = en_temp(1:48,2);
en_med(1:48,(p./ww)+2) = en_temp(1:48,3);

[rows cols] = size(en_avg);

% for k = 1:1:48
%     en_stdall(k,1) = nanstd(array_in(k:48:length(array_in)));
% end
% 

for i = 1:1:cols-1
    for j = 0:48:(ww-48)
        avg_full((i*ww)-ww+j+1 :(i*ww)-ww+j+48,1) = en_avg(:,i);
        std_full((i*ww)-ww+j+1 :(i*ww)-ww+j+48,1) = en_std(:,i);
        med_full((i*ww)-ww+j+1 :(i*ww)-ww+j+48,1) = en_med(:,i);        
    end
end
for j = 0:48:leftover-48
avg_full(((i+1)*ww)-ww+j+1 : ((i+1)*ww)-ww+j+48,1) = en_avg(:,i+1);
std_full(((i+1)*ww)-ww+j+1 : ((i+1)*ww)-ww+j+48,1) = en_std(:,i+1);
med_full(((i+1)*ww)-ww+j+1 : ((i+1)*ww)-ww+j+48,1) = en_med(:,i+1);
end

%% Rearrange so we can start from the chosen start point:
array_in_rearrange(:,1) = [array_in(start:length(array_in)) ; array_in(1:start-1)];
array_in = array_in_rearrange;
clear array_in_rearrange;
down_thresh_re(:,1) = [down_thresh(start:length(array_in)) ; down_thresh(1:start-1)];
up_thresh_re(:,1) = [up_thresh(start:length(array_in)) ; up_thresh(1:start-1)];
%%
di(1:length(array_in),1) = NaN;
for i = 1:1:length(array_in)
    if ~isnan(array_in(i))
     if i == 1 || i == length(array_in)
     else
     [bef_ind aft_ind] = jjb_find_befaft(array_in, i);
         
     di(i) = ( array_in(i) - array_in(bef_ind) )  - ( array_in(aft_ind) - array_in(i) );

      %%% Downspikes
      if di(i) < down_thresh_re(i);
%           array_in(i) = NaN; 
          spike_tracker1(i,1) = -1;   
      elseif di(i) > up_thresh_re(i);
%           array_in(i) = NaN; 
          spike_tracker1(i,1) = 1;
      end
          
         
     end
    else
    end
      
end
    
%% Re-arrange array_in back:
array_in_rearrange = [array_in(length(array_in)-start+2:length(array_in),1) ; array_in(1:length(array_in)-start+1,1)];
array_in = array_in_rearrange;
clear array_in_rearrange;
spike_tracker_re = [spike_tracker1(length(spike_tracker1)-start+2:length(spike_tracker1),1) ; spike_tracker1(1:length(spike_tracker1)-start+1,1)];
spike_tracker1 = spike_tracker_re;
clear spike_tracker_re;  
%%% do same for di
di_re = [di(length(di)-start+2:length(di),1) ; di(1:length(di)-start+1,1)];
di = di_re;
clear di_re;  



%% Find true spikes

spike_tracker2(array_in(:,1) > avg_full + sdev.*std_full,1) = 1;
spike_tracker2(array_in(:,1) < avg_full - sdev.*std_full,1) = -1;
% spike_tracker3(array_in(:,1) > med_full + 2.*std_full,1) = 1;
% spike_tracker3(array_in(:,1) < med_full - 2.*std_full,1) = -1;
% if isempty(real_z)==1
real_spikes(spike_tracker1 == 1 & spike_tracker2 == 1,1) = 1;
real_spikes(spike_tracker1 == -1 & spike_tracker2 == -1,1) = -1;
% else
% real_spikes(spike_tracker1 == 1) = 1;
% real_spikes(spike_tracker1 == -1) = -1;
% end
    
    
spike_ind = find(abs(real_spikes) == 1);

figure(96); clf;
plot(array_in,'b'); hold on;
plot(ind(spike_ind),ones(length(ind(spike_ind))),'rx')

figure(95); clf
plot(di(1:17568,1),'b'); hold on;
plot(down_thresh(1:17568),'r--')
plot(up_thresh(1:17568),'r--')

figure(97);clf
plot(array_in,'b'); hold on;
plot(ind, avg_full+std_full.*sdev,'r')
plot(ind, avg_full-std_full.*sdev,'r')

figure(99);clf
plot(array_in,'k');hold on;
test = array_in; test(abs(real_spikes) ==1,1) = NaN;
plot(test,'go');
