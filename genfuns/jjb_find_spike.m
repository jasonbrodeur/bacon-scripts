function [spike_tracker] = jjb_find_spike(data, z)
%% This function finds spikes in the input variable by comparing 


ind = (1:1:length(data))';
spike_tracker(1:length(data),1) = 0;

d_i(1:length(data),1) = NaN;
d_bef(1:length(data),1) = NaN;
d_aft(1:length(data),1) = NaN;


d_bef(2:length(data),1) = data(2:length(data)) - data(1:length(data)-1); 
d_aft(1:length(data)-1,1) = data(2:length(data)) - data(1:length(data)-1);
%%% First and last entries for each are calculated by wrapping around
d_bef(1,1) = data(1) - data(length(data));
d_aft(length(data),1) = data(1) - data(length(data));
%%% Calculate d_i
d_i = d_bef - d_aft;

Md = median(d_i(~isnan(d_i)));
MAD = median(abs(d_i(~isnan(d_i)) -Md));

up_thresh = Md + ((z.*MAD)./0.6745);
upspike_ind = d_i > up_thresh;
spike_tracker(d_i > up_thresh,1) = 1;

down_thresh = Md - ((z.*MAD)./0.6745);
downspike_ind = d_i < down_thresh;
spike_tracker(d_i < down_thresh,1) = 1;


% spike_tracker(spike,1) = 1;

%%
spike_ind = find(spike_tracker == 1);
for i = 1:1:length(spike_ind)
    pt = spike_ind(i);
    
    if pt == 1
        bef_ind = length(data);
        aft_ind = 2; 
    elseif pt ==length(data)
        bef_ind = length(data)-1;
        aft_ind = 1;
    else
        bef_ind = spike_ind(i)-1;
        aft_ind = spike_ind(i)+1;
    end
    
   if spike_tracker(spike_ind(i)) == 1 && ( (upspike_ind(bef_ind) == 1 && upspike_ind(aft_ind) == 1) || (downspike_ind(bef_ind) == 1 && downspike_ind(aft_ind) == 1) );
        spike_tracker(spike_ind(i)-1,1) = 2; spike_tracker(spike_ind(i)+1,1) = 2;
   else
   end
end

%%

figure(8)
plot(d_bef,'b'); hold on;
plot(d_aft,'r');
plot(d_i,'g');

spike_ind = find(spike_tracker == 1);
figure(6); clf
plot(data); hold on;
plot(ind(spike_ind),ones(length(ind(spike_ind))),'rx')