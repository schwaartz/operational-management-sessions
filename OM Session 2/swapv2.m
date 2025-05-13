function [schedule, tt, ts] = swapv2(jobid, r, p, d, setup, familycode, schedule, pos1, pos2)
% Swapping two jobs in the sequence: 
% Suppose the sequence: 3 - 4 - 2 - 5 - 1 and two positions generated: 2 and 4
% The jobs at the second (4) and fourth position (5) are swapped.
% The new sequence: 3 - 5 - 2 - 4 - 1

%% Swap the jobs in these positions
temp = schedule(pos1, 1); 
schedule(pos1, 1) = schedule(pos2, 1); 
schedule(pos2, 1) = temp;

%% Evalaute the new schedule and criteria 
[schedule] = solnevaluationv2(jobid, r, p, d, setup, familycode, schedule(:, 1));
tt = sum(schedule(:, 5));
ts = sum(schedule(:, 2)); 


end