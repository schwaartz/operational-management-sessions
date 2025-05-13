function jobseq = findValidJobSequence(jobid, r)
    % Finds a valid job sequence to start the search
    % jobid - a column vector of all the job ids
    % r - a column vector of realease times
    
    % Sort jobs based on release times
    [~, idx] = sort(r);       % idx gives the indices that would sort r
    jobseq = jobid(idx);      % reorder jobid according to the sorted release times

    if ~solutioncheck(jobid, jobseq)
        disp('Could not find a feasibl solution');
        jobseq = zeros(len(jobid),1);
    end
end