function solutioncheck(jobid, schedule)
% This function checks if the solution returned is feasible i.e. each job
% is included in the sequence exactly once.  

%% Checking if the sequence is a permutation of jobid
check = isequal(sortrows(schedule(:, 1)), jobid); 
if check == false
   fprintf('Something is wrong with your schedule.\nMaybe the same job is assigned to different positions, or a job is not assigned at all.')
end