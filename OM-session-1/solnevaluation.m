function [schedule] = solnevaluation(jobid, p, d, setup, familycode, jobseq)
% The only output of this function is the array schedule that stores in the
% First column: jobid of the job at the kth position,
% Second column: setup time required for the job at the kth position, 
% Third column: starting time of the job at the kth position,
% Fourth column: completion time of the job at the kth position,
% Fifth column: tardiness of the job at the kth position.

[nbjobs, ~] = size(jobid);
schedule(:, 1) = jobseq; 

for i = 1 : nbjobs
    if i == 1
       startsetup = 0;                 % There is no job before the first job
       schedule(i, 2) = 0;             % No setup required for the first job
    else
       startsetup = schedule(i - 1, 4);  % Setup can start immediately after the completion time of the previous job
       schedule(i, 2) = setup(familycode(schedule(i-1, 1)), familycode(schedule(i, 1))); % Setup time required
    end
    schedule(i, 3) = startsetup + schedule(i, 2); % Start time of processing the job
    schedule(i, 4) = schedule(i, 3) + p(schedule(i, 1)); % Completion time
    schedule(i, 5) = max(0, schedule(i, 4) - d(schedule(i, 1))); % Tardiness  
end


end