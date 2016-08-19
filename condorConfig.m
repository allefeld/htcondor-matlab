function out = condorConfig(name)

% define configuration parameters for htcondor-matlab job management
%
% This function is called by other parts of htcondor-matlab to get
% configuration parameters. It can be edited by the user to adjust the
% default parameters.
%
% *** At a minimum, the pathname of the htcondor-matlab job directory needs to
% be set, but review of other parameters is also recommended. ***
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% --------------------------- CONFIGURATION ---------------------------

% htcondor-matlab job directory
% point to an existing writable directory that is accessible from all machines
condir = ['/store02_analysis/' getenv('USER') '/condor/'];

% entries for the HTCondor submit description file 
% see http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_submit.html
% and http://research.cs.wisc.edu/htcondor/manual/v8.2.3/12_Appendix_A.html
submit = {'Universe            = vanilla'           % do not change!
          'Transfer_Executable = false'             % do not change!
          'Kill_Sig            = 2'                 % do not change!
          % location and parameters of Matlab executable
         ['Executable          = ' fullfile(matlabroot, 'bin', 'matlab')]
          'Arguments           = -nodisplay -nojvm' % enable Java if necessary
          'Notification        = never'             % if enabled, also define Notify_User
          % run at most four tasks on one machine
          'Requirements        = (SlotID <= 4)'     % HACK?  
          % prefer fast machines
          'Rank                = Mips'};

% ---------------------------------------------------------------------


switch name
    case 'condir'
        % check whether condir exists and is writable
        [success, message] = fileattrib(condir);
        if ~(success && message.directory)
            fprintf('htcondor-matlab job directory\n  %s\ndoes not exist\n', condir)
            error('create directory or edit configuration in condorConfig.m!')
        end
        % check whether it's writable
        if ~message.UserWrite
            error('htcondor-matlab job directory\n  %s\nis not writable!', condir)
        end
        % get absolute name
        condir = message.Name;
        if condir(end) ~= filesep
            condir = [condir filesep];
        end
        out = condir;
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
