function cluster = condor_get_cluster(clusterHandle)                            %#ok<STOUT>

% internal helper function
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld

% get cluster data structure
%
% cluster = condor_get_cluster(clusterHandle)
%
% clusterHandle:  handle of cluster to be submitted
% cluster:        cluster data structure


clusterDir = [condor_get_config('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
