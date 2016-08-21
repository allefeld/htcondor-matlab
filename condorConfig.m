% htcondor-matlab configuration parameters
%
% Edit this file to adapt htcondor-matlab to your local system, or put an
% edited version in a directory with higher preference on the path, or the
% local directory of a project.
%
% *** At a minimum, the pathname of the htcondor-matlab job directory needs
% to be set, but review of other parameters is also recommended. ***
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


%% htcondor-matlab job directory
%   point to an existing writable directory that is accessible from all machines
conDir = ['/store02_analysis/' getenv('USER') '/condor/'];


%% general entries for the HTCondor submit description file 
%   see http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_submit.html
%   and http://research.cs.wisc.edu/htcondor/manual/v8.2.3/12_Appendix_A.html
submit = {'Universe            = vanilla'           % do not change!
          'Transfer_Executable = false'             % do not change!
          'Kill_Sig            = 2'                 % do not change!
          % location and parameters of Matlab executable
         ['Executable          = ' fullfile(matlabroot, 'bin', 'matlab')]
          'Arguments           = -nodisplay -nojvm' % enable Java if necessary
          };
