classdef HybridPriority < int32 
% Enumeration class for behavior of solutions when the state is in the intersection of the flow and jump sets.
%
% See also: HyEQsolver, HybridSystem.
%
% Written by Paul K. Wintz, Hybrid Systems Laboratory, UC Santa Cruz. 
% © 2021. 

   enumeration
      JUMP(1) % Default
      FLOW(2)
   end
   
   methods(Static)
       function hp = default()
           % Get the default priority.
           hp = HybridPriority.JUMP;
       end
   end
end