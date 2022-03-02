% Postprocessing for Example 1.2: Bouncing Ball.

% Construct a HybridArc object from (t, j, x) computed by Simulink so that we
% can use the plotting tools associated with HybridArcs, namely
% HybridPlotBuilder.
sol = HybridArc(t, j, x); %#ok<IJCL> <- disable warning regarding using the variable name 'j'.

% Plot the solution vs. t.
figure(1)
clf
plotFlows(sol)

% Plot the solution in the phase plane.
figure(2)
clf
plotPhase(sol)
grid on

% Plot the first component of the solution vs. t and j.
figure(3)
clf
plotHybrid(sol.slice(1))     
grid on
view(37.5,30)