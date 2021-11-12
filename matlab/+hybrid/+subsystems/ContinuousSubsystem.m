classdef (Abstract) ContinuousSubsystem < HybridSubsystem
% Hybrid subsystems that do not have discrete dynamics.
    
    methods(Abstract) 
        xdot = flowMap(this, x, u, t, j)  
    end
    
    methods(Sealed)
        % The system does not jump.
        function xplus = jumpMap(this, x, u, t, j)   %#ok<INUSD,INUSL>
           xplus = x; 
        end

        % The system always flows.
        function C = flowSetIndicator(this, x, u, t, j)  %#ok<INUSD>
            C = 1;
        end

        % The system does not jump.
        function D = jumpSetIndicator(this, x, u, t, j) %#ok<INUSD>
           D = 0; 
        end
    end    
end