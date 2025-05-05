function [schedule, tt, ts] = insert(jobid, p, d, setup, familycode, schedule, L, pos1, pos2)

% Inserting a part of the sequence into another place 
% Suppose the sequence: 3 - 4 - 2 - 5 - 1 - 6, pos1 = 3 and pos2 = 5, and L is 2. 
% 2 jobs starting from the job at the 3rd position pos1 (4 - 2) will be inserted just
% before the job at the 5th position (1) meaning that:
% There are four pieces of the sequence: 
% part0: 3
% part1: 4 - 2 (the 2 jobs from pos1 to the beginning) 
% part2: 5 (the jobs after pos1 until pos2), 
% part3: 1 - 6 (remaining jobs from pos2 to the end)
% 
% The new sequence: part0 - part2 - part1 - part3
% The new sequence: 3 - 5 - 4 - 2 - 1 - 6

%% Insert the part of the sequence to another position
% If it is not possible to include L jobs from pos1, then just take all
% possible. 
[nbjobs, ~] = size(jobid);
if pos1 <= L && pos2 > pos1 + 1
   % the part is taken and inserted at a later position, pos2
   part0 = [];
   part1 = schedule(1:pos1, 1); 
   part2 = schedule(pos1+1:pos2-1, 1);
   part3 = schedule(pos2:nbjobs, 1); 
  
   temp = vertcat(part0, part2); 
   temp2 = vertcat(temp, part1); 
   schedule(:, 1) = vertcat(temp2, part3); 
else
    % the part is taken and inserted at a later position, pos2 > pos1
    if pos1 < pos2
       part0 = schedule(1 : pos1-L, 1); 
       part1 = schedule(pos1-L+1:pos1, 1); 
       part2 = schedule(pos1+1:pos2-1, 1);
       
       if pos2 <= nbjobs
       part3 = schedule(pos2:nbjobs, 1); 
       else
       part3 = [];
       end
  
       temp = vertcat(part0, part2); 
       temp2 = vertcat(temp, part1); 
       schedule(:, 1) = vertcat(temp2, part3); 
       % the part is taken and inserted at an earlier position, pos1 > pos2
    elseif pos1 > pos2
          
          if pos2 == 1
             part0 = [];
          else
          part0 = schedule(1: pos2-1, 1); 
          end
          
          part1 = schedule(pos1-L+1:pos1, 1);
          part2 = schedule(pos2:pos1-L, 1); 
          
          if pos1 == nbjobs
             part3 = [];
          else
          part3 = schedule(pos1+1:nbjobs, 1);
          end
          temp = vertcat(part0, part1); 
          temp2 = vertcat(temp, part2); 
          schedule(:, 1) = vertcat(temp2, part3); 
          
    end
end
  
%% Evalaute the new schedule and criteria 
[schedule] = solnevaluation(jobid, p, d, setup, familycode, schedule(:, 1));
tt = sum(schedule(:, 5));
ts = sum(schedule(:, 2)); 

end