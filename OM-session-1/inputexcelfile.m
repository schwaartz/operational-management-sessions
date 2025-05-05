function [r, p, d, setup, jobinfo, nbjobs, familycode] = inputexcelfile(inputfilename)
% release time array - r
% processing time array - p
% duedate array - d
% setup array - setup

releaseanddue = xlsread(inputfilename,'Release and Due date');
r = releaseanddue(~isnan(releaseanddue(:, 4)), 4);
d = releaseanddue(~isnan(releaseanddue(:, 5)), 5);
p = releaseanddue(~isnan(releaseanddue(:, 6)), 6);

jobinfo = xlsread(inputfilename,'Job types');
setup = xlsread(inputfilename,'Setup');

% The number of classes for jobs - like type, grade, product etc 
% the nb of features 
[nbjobs, nbclass] = size(jobinfo);
nbclass = nbclass - 1;
typeclass = zeros(nbclass, 1);

% The number of variaties in each dimension
for j = 1 : nbclass
    typeclass(j) = max(jobinfo(:, j+1));
end

% A family code (hash code) for each job is a number assigned based on all the dimensions (type, grade, product etc.)
% such that jobs that has the same in each dimension has the same
% family code.
familycode = zeros(nbjobs, 1);
for i = 1 : nbjobs
    for j = 1 : nbclass-1
        familycode(i, 1) = (jobinfo(i, 1+j) - 1)*(prod(typeclass(j+1:nbclass)));
    end
    familycode(i, 1) = familycode(i, 1) + jobinfo(i, nbclass+1); 
end

end