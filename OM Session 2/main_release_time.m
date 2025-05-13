clc
clear

%% Input datafile and parameters
 inputfilename = sprintf('Consumergoods3.xlsx'); 

% The function reads the necessary info on the data, see inside the function
% inputexcelfile.m
[r, p, d, setup, jobinfo, nbjobs, familycode] = inputexcelfile(inputfilename);
jobid = jobinfo(:, 1); 
% Set the seed
rng(nbjobs); 

%% Initial Solution Generation
% The order of the sequence can be based on EDD, SPT, Random, In-order
jobseqEDD = sortrows((horzcat(jobid(:, 1), d)), 2);  % EDD
jobseqSPT = sortrows((horzcat(jobid(:, 1), p)), 2);  % SPT
jobseqRAND = transpose(randperm(nbjobs, nbjobs));    % Random permutation
jobseqINORDER = jobid;                               % 1 - 2 - 3 ...
jobseqINIT = findValidJobSequence(jobid(:, 1));

% Set the initial sequence
jobseqinit = jobseqINIT(:, 1); 

%% Evaluation of a job sequence
% Objective is to minimize z = lambda*total tardiness(TT) + sigma*total setup time(TS)
% Note that in the input files, everything is in terms of seconds. 
% To convert TT and TS into asked units:
factorweek = 60*60*24*7; % seconds in a week  
factorhour = 60*60;      % seconds in an hour
factorday = 60*60*24;    % seconds in a day

% Function handle to convert seconds into asked units:
sec2week = @(secs) secs/factorweek; 
sec2hour = @(secs) secs/factorhour;
sec2day = @(secs) secs/factorday; 

% Different production environments might have different weights (lambda and sigma) on total tardiness and setup time. 
lambda = 1;    sigma = 1;

% Function handle to convert and calculate weighted sum
% !!! Do not forget to update this according to the dataset !!!
f = @(tt, ts) (lambda*sec2week(tt)+sigma*sec2hour(ts)); % for chemicals
%f = @(tt, ts) (lambda*sec2day(tt)+sigma*sec2hour(ts)); % for consumer goods

%% Evaluation of the initial job sequence
% SCHEDULE array includes the job sequence, setup
% time required for the job, starting time of the job, completion time of
% the job, and the tardiness of the job: see inside the function solnevalution.m
[scheduleinit] = solnevaluationv2(jobid, r, p, d, setup, familycode, jobseqinit);

% Total tardiness and total setup time in seconds
ttinit = sum(scheduleinit(:, 5)); 
tsinit = sum(scheduleinit(:, 2)); 

% Objective Function Value
objinit = f(ttinit, tsinit); 

%% Metaheuristic Algorithm
% Variable Neighbourhood Search algorithm 
% Parameters
% Set the clock
tic
comptime = 0; 
% Set the cut and insert length
L = 4; 
% Set the allowed computation time and/or iteration limit
comptimelimit = 180; % in seconds
iterlim = 10000; 

% Initialize the incumbent and the best solution
schedule = scheduleinit; 
schedulebest = scheduleinit; 
tt = ttinit; 
ts = tsinit; 
obj = objinit;
objbest = objinit; 
ttbest = ttinit; 
tsbest = tsinit; 

iter = 1; 
while iter <= iterlim && comptime < comptimelimit + 0.001
      %% Local search INSERT + ADJACENT SWAP
      %% Insert move with FIRST improvement
      % Randomly select a position to take a part of the sequence with
      % length L
      pos1 = randi([1, nbjobs]);
      updated = 0; 
             % Try inserting from the beginning
             pos2 = 1; 
             while pos2 <= pos1-L + 1 && updated < 1 && comptime < comptimelimit + 0.001
                  [scheduletemp, tttemp, tstemp] = insertv2(jobid, p, d, setup, familycode, schedule, L, pos1, pos2);
                  objtemp =  f(tttemp, tstemp); 
                  if  objtemp < obj
                  % If the solution is better than the incumbent solution, 
                  % Update the incumbent solution and enter the next iteration
                  % with that. 
                  tt = tttemp; 
                  ts = tstemp; 
                  schedule = scheduletemp; 
                  obj = objtemp;
                  pos2 = nbjobs + 1;
                  updated = updated + 1;
                          if obj < objbest
                             % Check if the solution is better than the best solution
                             % found so far, or not.
                             schedulebest = schedule; 
                             ttbest = tt;
                             tsbest = ts;
                             objbest = obj;
                          end
                  else 
                  % If not, then update the next position to be inserted. Enter the
                  % next iteration with the current incumbent solution. 
                  pos2 = pos2 + 1;
                  end
                  % Update the clock
                  comptime = toc;
             end
             % If no improvement achieved before, now try after. 
                pos2 = pos1 + 2;
                while pos2 <= nbjobs + 1 && updated < 1 && comptime < comptimelimit + 0.001
                      [scheduletemp, tttemp, tstemp] = insert(jobid, p, d, setup, familycode, schedule, L, pos1, pos2);
                      objtemp =  f(tttemp, tstemp); 
                         if  objtemp < obj
                          % If the solution is better than the incumbent solution, 
                          % Update the incumbent solution and enter the next iteration
                          % with that. 
                          tt = tttemp; 
                          ts = tstemp; 
                          schedule = scheduletemp; 
                          obj = objtemp;
                          pos2 = nbjobs + 1;
                          updated = updated + 1; 
                                  if obj < objbest
                                     % Check if the solution is better than the best solution
                                     % found so far, or not.
                                     schedulebest = schedule; 
                                     ttbest = tt;
                                     tsbest = ts;
                                     objbest = obj;
                                  end
                          else 
                          % If not, then update the next position to be inserted. Enter the
                          % next iteration with the current incumbent solution. 
                          pos2 = pos2 + 1;
                         end
                         % Update the clock
                         comptime = toc;
                end
      %% Adjacent swap move with FIRST improvement
      % Swap the job on pos1 with the job on the right, pos2 = pos1 + 1
      pos1 = 1;
      pos2 = pos1 + 1; 
      adjswapz = zeros(nbjobs-1, 1);
      updated2 = false;
      while pos1 <= nbjobs - 1 && comptime < comptimelimit + 0.001
          [scheduletemp, tttemp, tstemp] = swapv2(jobid, r, p, d, setup, familycode, schedule, pos1, pos2); 
          objtemp =  f(tttemp, tstemp); 
          adjswapz(pos1) = objtemp;
          pos1 = pos1 + 1;
          pos2 = pos1 + 1;
      end
      [objtemp, pos1] = min(adjswapz);
      pos2 = pos1 + 1;
      if objtemp < obj
          % If the solution is better than the incumbent solution, 
          % Update the incumbent solution and enter the next iteration
          % with that. 
          [scheduletemp, tttemp, tstemp] = swap(jobid, r, p, d, setup, familycode, schedule, pos1, pos2); 
          objtemp =  f(tttemp, tstemp);
          tt = tttemp;
          ts = tstemp;
          schedule = scheduletemp;
          obj = objtemp;
          updated2 = true;
              if obj < objbest
                 % Check if the solution is better than the best solution
                 % found so far, or not.
                 schedulebest = schedule;
                 ttbest = tt;
                 tsbest = ts;
                 objbest = obj;
              end
      else
      pos1 = pos1 + 1;
      pos2 = pos1 + 1;
      end
      %% Diversification: Exchange sequence move 
      % After the local search, if the incumbent solution is not updated
      if updated == 0 
      % Randomly generate two positions to exchange the two part of the
      % sequence, you update the incumbent solution REGARDLESS of the new
      % obj value
      [schedule, tt, ts] = exchangeseq(jobid, r, p, d, setup, familycode, schedulebest); 
      obj =  f(tt, ts);
               if obj < objbest
                 % Check if the solution is better than the best solution
                 % found so far, or not.
                 schedulebest = schedule; 
                 ttbest = tt;
                 tsbest = ts;
                 objbest = obj;
               end
      end
      % Update the clock
      comptime = toc;
      iter = iter + 1;
end

comptime = toc;
solutioncheck(jobid, schedulebest);
fprintf('Best solution found in %i iterations and %.2f seconds, TT:%.2f, TS:%.2f, OBJ:%.2f\n', iter-1, comptime, sec2week(ttbest), sec2hour(tsbest), objbest); 
%fprintf('Best solution found in %i iterations and %.2f seconds, TT:%.2f, TS:%.2f, OBJ:%.2f\n', iter-1, comptime, sec2day(ttbest), sec2hour(tsbest), objbest); 



