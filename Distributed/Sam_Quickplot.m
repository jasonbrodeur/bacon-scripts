path = '/1/fielddata/Matlab/Data/Met/Organized2/TP39_sapflow/HH_Files/'; % replace this with path to your file
load([path 'TP39_sapflow_HH_2011.mat']);

k = 5;

while k < length(master.labels)
            figure(1);clf;
            plot(master.data(:,k));
            tmp_title = master.labels{k,1};
            tmp_title(strfind(tmp_title,'_')) = '-';
            title(tmp_title);
            clear tmp_title
            grid on;
            
        response = input('Press enter to move forward, enter "1" to move backward, q to quit: ', 's');
    
    
        if isempty(response)==1
            k = k+1;
        elseif strcmp(response,'1')==1 && k > 1;
            k = k-1;
        elseif strcmp(response,'q')==1
           return;
        else
%             k = k;
        end
end

