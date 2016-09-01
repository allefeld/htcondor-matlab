function condorInspect(clusterHandle, jobNumber)

% inspect a job's output, error, and HTCondor log
%
% condorInspect(clusterHandle, jobNumber)
%
% clusterHandle:  handle of cluster
% jobNumber:      job(s) to be inspected
%                 an array of integers, or a string of the form 'job###'
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% determine job number(s)
if ischar(jobNumber)
    jobNumber = sscanf(jobNumber, 'job%d');
    if isempty(jobNumber)
        error('unrecognized argument')
    end
end

% load cluster data structure
cluster = condor_get_cluster(clusterHandle);

% panel labels
labels = {'job output', 'job error', 'HTCondor log'};

% one window per job
for jn = jobNumber(:)'
    % figure name
    name = [clusterHandle ': ' sprintf('job%03d', jn)];
    % read files
    texts = {strsplit(fileread(cluster.job(jn).out), '\n'), ...
        strsplit(fileread(cluster.job(jn).err), '\n'), ...
        strsplit(fileread(cluster.job(jn).log), '\n')};
    % generic code to display text(s) in uicontrols
    f = figure('Units', 'normalized', 'OuterPosition', [0.25 0 0.5 1], ...
        'ToolBar', 'none', 'MenuBar', 'none', 'Color', [0.8 0.8 0.8], ...
        'Name', name, 'NumberTitle', 'off');
    np = numel(labels);
    for i = 1 : np
        up = uipanel(f, 'Title', labels{i}, 'FontSize', 14, ...
            'BorderType', 'line', ...
            'BackgroundColor', [0.8 0.8 0.8], ...
            'HighlightColor', [0.4 0.4 0.4], ...
            'Units', 'normalized', 'Position', [0, (np - i) / np, 1, 1 / np]);
        uc = uicontrol(up, 'Style', 'edit', ...
            'Units', 'normalized', 'Position', [0 0 1 1], ...
            'Enable', 'inactive', 'Max', 2, ...
            'BackgroundColor', 'white', ...
            'HorizontalAlignment', 'left', ...
            'FontName', 'FixedWidth', 'FontSize', 12, ...
            'String', texts{i});
    end
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
