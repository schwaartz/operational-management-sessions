function solutioncheck(jobid, schedule, r)
% This function checks if the solution returned is feasible i.e. each job
% is included in the sequence exactly once.  

%% Checking if the sequence is a permutation of jobid
check = isequal(sortrows(schedule(:, 1)), jobid); 
if check == false
   fprintf('Something is wrong with your schedule.\nMaybe the same job is assigned to different positions, or a job is not assigned at all.')
end

[nbjobs, ~] = size(jobid); 

%% Checking if setup starts after release time and setup and processing of a job is within weekdays
for i = 1 : nbjobs
    startsetup = schedule(i, 3) -  schedule(i, 2); 
    if startsetup < r(schedule(i, 1)) 
       fprintf('Something is wrong with your schedule.\nSetup started before job release time for position %i\n', i)
    end
    if mod((startsetup/(24*3600)), 7) == 5 || mod((startsetup/(24*3600)), 7) == 6 % 
       fprintf('Something is wrong with your schedule.\nSetup started during downtime for position %i\n', i) 
    end
    if mod((schedule(i, 4)/(24*3600)), 7) == 5 || mod((schedule(i, 4)/(24*3600)), 7) == 6
       fprintf('Something is wrong with your schedule.\position %i completed during downtime\n', i) 
    end        
    if floor((startsetup/(7*24*3600))) ~= floor((schedule(i, 4)/(7*24*3600)))
       fprintf('Something is wrong with your schedule.\n Position %i is split between downtime\n', i) 
    end
end