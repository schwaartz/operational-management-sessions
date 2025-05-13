function [schedule, tt, ts] = exchangeseq(jobid, p, d, setup, familycode, schedule)

% Exchanging a part of the sequence with another piece of sequence 
% Suppose the sequence: 3 - 4 - 2 - 5 - 1 and two distinct random numbers generated: 2 and 4
% The first piece of sequence: The jobs until (inclusive) the first random
% number (2nd) position -> (3 - 4)
% The second piece of sequence: The jobs from after first random number (2nd) position until (inclusive) the
% the second random number (4th) position -> (2 - 5)
% Exchange the sequences
% The new sequence: 2 - 5 - 3 - 4 - 1

%% Randomly generate two positions to exchange the sequence
[nbjobs, ~] = size(jobid);
positions = randperm(nbjobs, 2); 
positions = sort(positions); 
pos1 = positions(1); 
pos2 = positions(2); 

%% Exchange the part of the sequence with the other position
part1 = schedule(1:pos1, 1); 
part2 = schedule(pos1+1:pos2, 1);

if pos2 == nbjobs
   part3 = [];
else
    part3 = schedule(pos2+1:nbjobs, 1); 
end

temp = vertcat(part2, part1); 
schedule(:, 1) = vertcat(temp, part3); 

%% Evaluate the new schedule and criteria
[schedule] = solnevaluation(jobid, p, d, setup, familycode, schedule(:, 1));
 tt = sum(schedule(:, 4));
 ts = sum(schedule(:, 2));

end