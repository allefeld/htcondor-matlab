function condorTest
jobHandle = condorCreateJob;
for i = 1 : 10
   condorCreateTask(jobHandle, @condorTestFunction, {i}, 1)
end
condorSubmitJob(jobHandle)
condorMonitorJob(jobHandle)
results = condorGetResults(jobHandle);
cell2mat([results{:}])

function y = condorTestFunction(x)
y = 2 * x;
