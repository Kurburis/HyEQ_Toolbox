classdef SilentProgressUpdater < hybrid.ProgressUpdater
% Defines a no-op progress updater for the hybrid equations solver.
%
% See also: HybridSolverConfig, hybrid.ProgressUpdater, hybrid.PopupProgressUpdater.

% Written by Paul K. Wintz, Hybrid Systems Laboratory, UC Santa Cruz. 
% © 2021. 
        
    methods 
        function update(this) %#ok<MANU>
            % Do nothing
        end
    end
    
end