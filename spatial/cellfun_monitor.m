% cellfun_monitor : apply a function to each element of a cell array
%   and monitor the estimated time left every second
%
% Usage :
%   cell_out = cellfun_monitor(fun, cell_in);
%
% Input :
%   fun (function_handle) : the function handle to be applied
%   cell_in (cell) : the cell whose element will be applied fun to
%
% Output :
%   cell_out (cell) : the transformed cell

function cell_out = cellfun_monitor(fun, cell_in)

K = numel(cell_in);
time_start = clock;
time_elapsed_at_last_print= 0;
time_between_each_print = 1;
for k = 1:K
    cell_out{k} = fun(cell_in{k});
    
    time_elapsed = etime(clock, time_start);
    if (time_elapsed - time_elapsed_at_last_print > time_between_each_print)
        time_elapsed_at_last_print =  time_elapsed;
        estimated_time_left = time_elapsed * (K-k) / k;
        fprintf('%d / %d : estimated time left %d seconds\n',...
            k,K,floor(estimated_time_left));
    end
    
end

end