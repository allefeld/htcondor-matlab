function out = condor_get_config(name)

% internal helper function
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld

% retrieve configuration parameters for htcondor-matlab
%
% out = condor_get_config(name)
%
% name:  name of configuration parameter
% out:   corresponding value


% run configuration script
try
    condorConfig
catch
    error('htcondor-matlab is not configured.\nsee README and condorConfig_template.m', [])      %#ok<CTPCT>
end

% return configuration parameter (after some error checking)
if ~exist(name, 'var')
    error('htcondor-matlab configuration parameter "%s" is not defined!', name)
end
switch name
    case 'conDir'
        % check whether conDir exists and is writable
        [success, message] = fileattrib(conDir);                            %#ok<NODEF>
        if ~(success && message.directory)
            error(['htcondor-matlab cluster directory\n  %s\ndoes not exist.\n' ...
                'create directory or edit configuration in condorConfig.m!'], conDir)
        end
        % check whether it's writable
        if ~message.UserWrite
            error('htcondor-matlab cluster directory\n  %s\nis not writable!', conDir)
        end
        % get absolute name
        conDir = message.Name;
        if conDir(end) ~= filesep
            conDir = [conDir filesep];
        end
        out = conDir;
    case 'submit'
        out = submit;
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
