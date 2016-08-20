function y = condorTestTask(x)

% test function to be used as an HTCondor task

% print primary message
fprintf('condorTestTask\n')

% print secondary message
fprintf(' processing\n')

% compute result
y = x ^ 2;
pause(10)   % act as if it's taking a while

% simulate error
if isprime(x)
    % print secondary message
    fprintf(' throwing error\n')
    % generate error
    error('bad things happen')
end

% print secondary message
fprintf(' finished\n')


