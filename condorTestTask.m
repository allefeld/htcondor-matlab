function y = condorTestTask(x)

% test function to be used as an HTCondor task

% print primary output message
fprintf('condorTestTask\n')

% print secondary output message
fprintf(' processing\n')

% compute result
y = x ^ 2;
pause(10)   % act as if its taking a while

% simulate error
if isprime(x)
    % print secondary output message
    fprintf(' throwing error\n')
    % generate error
    error('bad things happen')
end

% print secondary output message
fprintf(' finished\n')


