%% Example 1.4: Modeling Hybrid System Data with Simulink Blocks
% This example continues the discussion of the system presented in 
% <matlab:hybrid.internal.openHelp('Example_1_3') Example 1.3>, namely a ball bouncing on a
% moving platform is modeled in Simulink. We show here that a MATLAB function
% block can be replaced with operational blocks in Simulink. 


%%
% The Simulink model, below, shows the jump set |D| modeled in Simulink using
% operational blocks instead of a MATLAB function block. The other functions for
% $f$, $C$, and $g$ are the same as in  
% <matlab:hybrid.internal.openHelp('Example_1_3') Example 1.3>.

% Open subsystem "HS" in Example1_4.slx. A screenshot of the subsystem will be
% automatically included in the published document.
warning('off','Simulink:Commands:LoadingOlderModel')
model_path = 'hybrid.examples.bouncing_ball_with_input.bouncing_ball_with_input_alternative';
block_path = 'bouncing_ball_with_input_alternative/HS';
load_system(which(model_path))
open_system(block_path)
snapnow();

%%
% Solutions computed by this model are identical to those in
% <matlab:hybrid.internal.openHelp('Example_1_3') Example 1.3>.

% Clean up. It's important to include an empty line before this comment so it's
% not included in the HTML. 

% Close the Simulink file.
close_system 
warning('on','Simulink:Commands:LoadingOlderModel') % Renable warning.

% Navigate to the doc/ directory so that code is correctly included with
% "<include>src/...</include>" commands.
cd(hybrid.getFolderLocation('doc')) 
