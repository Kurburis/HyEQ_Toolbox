%% Creating plots with HybridPlotBuilder
%% Setup
% The |HybridPlotBuilder| class provides an easy and configurable way to plot 
% hybrid solutions. We first create several solutions that are used in
% subsequent examples.
system = hybrid.examples.ExampleBouncingBallHybridSystem();
system_3D = hybrid.examples.Example3DHybridSystem();
config = HybridSolverConfig('Refine', 15); % 'Refine' option makes the plots smoother.
sol = system.solve([10, 0], [0 30], [0 30], config);
sol_3D = system_3D.solve([0; 1; 0], [0, 20], [0, 100], config);

%% Basic Plotting
% To create a plot of a hybrid solution |sol|, we create an instance of
% |HybridPlotBuilder| by calling the constructor |HybridPlotBuilder()|. 
% The five main plotting functions are |plotFlows|, |plotJumps|,
% |plotHybrid|, |plotPhase| and |plot|.
% For |plotFlows|,
% |plotJumps|, |plotHybrid|, 
% each component (up to four by default) of |sol.x| is placed in a separate
% subplot. If the plot builder is only used once, it is unnecessary to
% assign it to a variable and can instead be used immediately, e.g.,
% |HybridPlotBuilder().plotFlows(sol)|.
% 
% The |plotFlows| function plots each component of the solution versus
% continuous time $t$. 
HybridPlotBuilder().plotFlows(sol);

%% 
% NOTE: prior to MATLAB version R2016a, it is not possible to chain
% a function call directly after a constructor, so the code above must be
% split into a variable assignment, followed by the function call:
% 
%  hpb = HybridPlotBuilder();
%  hpb.plotFlows(sol);
% 

%% 
% The |plotJumps| function plots each component of the solution versus
% discrete time $j$.
HybridPlotBuilder().plotJumps(sol);

%% 
% The |plotHybrid| function plots each component of the solution versus
% hybrid time $(t, j)$.
HybridPlotBuilder().plotHybrid(sol);

%% 
% The |plotPhase| function produces a plot of the solution vector |x| in 2D or
% 3D phase space.
HybridPlotBuilder().plotPhase(sol);

%%
% The |plot| function chooses the type of plot based on the number of
% components. For solutions with two or three components, then |plot|
% produces a plot in 2D or 3D state space. Otherwise, each component is
% plotted using |plotFlows|.
HybridPlotBuilder().plot(sol);

%% 
% Each of the four preceeding function calls can be abbreviated by omitting
% |HybridPlotBuilder()|, that is |plotFlows(sol)|, |plotJumps(sol)|,
% |plotHybrid(sol)|, and 
% |plot(sol)|. 
plot(sol)

%%
% This approach, although convenient, does not allow the modifications of the plot
% appearances that we describe below. 

%% Choosing Components to Plot
% For solutions with multiple components, the |slice| function allows for the
% selection of which components to plot and which order to plot them.
% We will look at the following solution to a 3D system.
plot(sol_3D)
view([63.6 28.2]) % Set the view angle.

%%
% We plot only the first two components by passing the array.
% [1, 2] to |slice|.
HybridPlotBuilder().slice([1,2]).plot(sol_3D);

%% 
% The |slice| function also allows the order of components to be changed.
HybridPlotBuilder().slice([2,1]).plot(sol_3D);

%% Ploting Other Values
% |HyrbidPlotBuilder| can plot trajectories given as (t, j, x).
HybridPlotBuilder().slice(1).plotFlows(sol.t, sol.j, -sol.x)
title('Negative Height')

%% 
% This can be simplified by using the |HybridSolution|
% object to provide the values of |t| and |j|.
% Rather than referencing |sol.t| and |sol.j| explicitly, the solution object can be
% passed to the plotting function, along with the plot values. The time
% values from |sol| are then used.
HybridPlotBuilder().slice(1).plotFlows(sol, -sol.x)
title('Negative Height')

%% 
% Alternatively, a function handle can be evaluated along the solution and plotted
% as follows. The evaluation of the function is done via the function
% |HybridSolution.evaluateFunction()|. See the documentation of that function
% for details.
HybridPlotBuilder().plotFlows(sol, @(x) -x(1)); % Can also use @(x, t) or @(x, t, j).

%% Customizing Plot Appearance
% The following functions modify the appearance of flows.
HybridPlotBuilder().slice(1)...
    .flowColor('black')...
    .flowLineWidth(2)...
    .flowLineStyle(':')...
    .plotFlows(sol)

%% 
% Similarly, we can change the appearance of jumps.
HybridPlotBuilder().slice(1:2)...
    .jumpColor('m')... % magenta
    .jumpLineWidth(1)...
    .jumpLineStyle('-.')...
    .jumpStartMarker('+')...
    .jumpStartMarkerSize(16)...
    .jumpEndMarker('o')...
    .jumpEndMarkerSize(10)...
    .plot(sol_3D)

%% 
% To confiugre the the jump markers on both sides of jumps, omit 'Start'
% and 'End' from the function names:
HybridPlotBuilder().slice(1:2)...
    .jumpMarker('s')... % square
    .jumpMarkerSize(12)...
    .plot(sol_3D)

%% 
% To hide jumps or flows, set the corresponding color to 'none.' Jump
% markers can be hidden by setting the marker style to 'none' and jump
% lines can be hidden by setting the jump line style to 'none.' (Note:
% there appears to be a MATLAB defect that causes markers with style 'none'
% to be visible in plots saved as eps files.)
HybridPlotBuilder().slice(2)...
    .flowColor('none')...
    .jumpEndMarker('none')...
    .jumpLineStyle('none')...
    .plotFlows(sol)
title('Start of Each Jump') % An alternative way to add titles is shown below.

%%
% Sequences of colors can be set for flows and jumps by passing a cell array to
% the color functions. When auto-subplots are off (see below), the color that
% each component is 
% plotted rotates through the given colors, so the following code creates a plot
% where the first 
% component is plotted with blue flows and red jumps, and the second component
% is plotted with black flows and green jumps. (If the solution had a third
% component, it would be plotted in blue and red.)
clf
HybridPlotBuilder().autoSubplots('off')...
    .flowColor({'blue', 'black'})...
    .jumpColor({'red', 'green'})...
    .legend('$h$', '$v$')...
    .plotFlows(sol);


%%
% When auto-subplots is on, then all the plots added by a single call to a
% plotting function are the same color, and all the plots added by the next call
% to a plotting function are the next color, and so on. Note, here, we set both
% flow and jump color via the |color| function. The |'matlab'| argument sets the
% colors to match the default colors used by MATLAB plots. 
hpb = HybridPlotBuilder().autoSubplots('on').color('matlab');
hold on
hpb.legend('$h$', '$v$').plotFlows(sol);
hpb.legend('$2h$', '$2v$').plotFlows(sol, @(x) 2*x);
hpb.legend('$3h$', '$3v$').plotFlows(sol, @(x) 3*x);
hpb.legend('$4h$', '$4v$').plotFlows(sol, @(x) 4*x);

%% Component Labels
% Plot labels are set component-wise (as opposed to subplot-wise). 
% In the bouncing ball system, the first
% component is height and the second is velocity, so we will add the labels
% $h$ and $v$. |HybridPlotBuilder| automatically adds labels for $t$ and $j$.
clf
HybridPlotBuilder()...
    .labels('$h$', '$v$')...
    .plotFlows(sol)

%% 
% If |slice| is used to switch the order of components, then the labels
% automatically switch also.
HybridPlotBuilder().slice([2 1])...
    .labels('$h$', '$v$')...
    .plotFlows(sol)

%% 
% Labels are also displayed for plots in 2D or 3D phase space.
HybridPlotBuilder().slice([2 1])...
    .labels('$h$', '$v$')...
    .plot(sol)

%%
% The |t| and |j| axis labels and the default label for the state
% components can be modified as follows. If the string passed to
% |xLabelFormat| contains |'%d'|, then it is substituted with the index
% number of the component.
HybridPlotBuilder()...
    .tLabel('$t$ [s]')...
    .jLabel('$j$ [k]')...
    .xLabelFormat('$z_{%d}$')...
    .plotHybrid(sol)

%% Plot Titles
% Adding titles is similar to adding labels.
clf
HybridPlotBuilder().slice([2 1])...
    .titles('Height', 'Velocity')...
    .plotFlows(sol)

%% 
% One place where the behavior of labels and titles differ are in 2D or 3D
% plots of a solution in phase space. 
% A plot in phase space only contains one subplot, so only the first title
% is displayed. For this case, the |title| function can be used instead of
% |titles|.
HybridPlotBuilder().title('Phase Plot').plot(sol)

%% 
% The default interpreter for text is |latex| and can be changed by calling
% |titleInterpreter()| or |labelInterpreter()|. Use one of these values:
% |none| | |tex| | |latex|. The default labels automatically change to
% match the label interpreter.
HybridPlotBuilder()...
    .titleInterpreter('none')...
    .labelInterpreter('tex')...
    .titles('''tex'' is used for labels and ''none'' for titles',...
            'In ''tex'', dollar signs do not indicate a switch to math mode', ...
            'default label is formatted to match interpreter') ...
    .labels('z_1', '$z_2$')... % only two labels provided.
    .plotFlows(sol_3D)

%% Automatic Subplots
% By default, |HybridPlotBuilder| creates a new subplot for each component
% of the solution for |plotFlows|, |plotJumps|, and |plotHybrid|. 
HybridPlotBuilder().plotFlows(sol)

%% 
% This can be disabled via tha |autoSubplots| function. If automatic
% subplots are turned off, then all components are plotted in a single axes. 
clf
HybridPlotBuilder()...
    .autoSubplots('off')...
    .plotFlows(sol) 

%%
% When automatic subplots are off, only the first label and title are used.
% For legends, however, as many legend entries are used as plots have been
% added. 
clf
pb = HybridPlotBuilder();
pb.autoSubplots('off')...
    .labels('Label 1', 'Label 2')... % Only first label is used.
    .titles('Title 1', 'Title 2')... % Only first title is used.
    .legend('Legend 1', 'Legend 2')... % Both two legend entries are used.
    .plotFlows(sol)

%%
% Legend options can be set simlar to the MATLAB legend function. The legend
% labels are passed as a cell array (enclosed with braces '{}') and name/value
% pairs are passed in subsequent arguments.
clf
HybridPlotBuilder()...
    .legend({'h', 'v'}, 'Location', 'southeast')...
    .plotFlows(sol);

%% 
% Passing legend labels as a cell array is also useful when not plotting the
% first several entries. The following notation creates a cell array with the
% first two entries empty and the third set to the given value. 
lgd_labels = {}; % This line is only necessary if lgd_labels is previously defined (but a good idea just in case).
lgd_labels{3} = 'Component 3';

%% 
% We can then set the relevant legend label without explicitly putting empty
% labels for the first two components (i.e., |legend('', '', 'Component 3').|
HybridPlotBuilder()...
    .legend(lgd_labels, 'Location', 'southeast')...
    .slice(3)...
    .plotFlows(sol_3D);

%%
% The 'titles' and 'labels' functions also accept values given as a cell array,
% but do not (yet) accept subsequent options.
labels{2} = '$y_2$';
titles{2} = 'Plot of second component';
HybridPlotBuilder()...
    .labels(labels)...
    .titles(titles)...
    .slice(2)...
    .plotFlows(sol_3D);

%%
% The above method applies the same settings to the legends in all subplots. 
% To modify legend options separately for each subplot, use the |configurePlots|
% function described below.

%% Filtering Solutions
% Portions of solutions can be hidden with the |filter| function. In this
% example, we create a filter that only includes points where the second
% component (velocity) is negative. (If the time-step size
% along flows is large, deleted lines connected to filtered points may
% extends a noticible distance into the portion of the solution that should
% be visible.)
clf
is_falling = sol.x(:,2) < 0;
HybridPlotBuilder()...
    .filter(is_falling)...
    .plotFlows(sol)

%% Plotting System Modes
% Filtering is useful for plotting systems where an integer-value
% component indicates the mode of the system. 
% Here, we create a 3D system with a continuous variable $z \in \bf{R}^2$
% and a discrete variable $q \in \{0, 1\}$. Points in the solution where 
% $q = 0$ are plotted in blue, and points where $q = 1$ are plotted in
% black. The same |HybridPlotBuilder| object is used for both plots by saving it 
% to the |builder| variable (this allows us to specify the labels only
% once and add a legend for both plots). 
system_with_modes = hybrid.examples.ExampleModesHybridSystem();

% Create initial condition and solve.
z0 = [-7; 7];
q0 = 0;
sol_modes = system_with_modes.solve([z0; q0], [0, 10], [0, 10], 'silent');

% Extract values for q-component.
q = sol_modes.x(:, 3);

% Plot the [1, 2] components (that is, the first two components) of
% sol_modes at all time steps where q == 0. 
builder = HybridPlotBuilder();
builder.title('Phase Portrait') ...
    .labels('$x_1$', '$x_2$') ...
    .legend('$q = 0$') ...
    .slice([1,2]) ... % Pick which state components to plot
    .filter(q == 0) ... % Only plot points where q is 0.
    .plot(sol_modes)
hold on % See the section below about 'hold on'
% Plot in black the solution (still only the [1,2] components) for all time
% steps where q == 1. 
builder.flowColor('black') ...
    .jumpColor('none') ...
    .filter(q == 1) ... % Only plot points where q is 1.
    .plot(sol_modes)
axis padded
axis equal

%%
% For the bouncing ball system, we can change the color of the plot based on
% whether the ball is falling.
clf
is_falling = sol.x(:, 2) < 0;
pb = HybridPlotBuilder();
pb.filter(is_falling)...
    .jumpColor('none')...
    .flowColor('k')...
    .legend('Falling', 'Falling')...
    .plotFlows(sol);
hold on
pb.filter(~is_falling)...
    .flowColor('g')...
    .legend('Rising', 'Rising')...
    .plotFlows(sol);

%% Legends
% When using auto-subplots, legends are added to each subplot on a
% component-wise basis. This means that legends switch locations when |slice| is
% used.
clf
HybridPlotBuilder()...
    .legend('Component 1', 'Component 2')...
    .slice([2 1])...
    .plotFlows(sol);

%%
% If |slice| is used to omit components, it is necessary to include a legend
% entry for those components so that the legend entries for displayed components
% are displayed correctly. 
HybridPlotBuilder()...
    .legend('', 'Component 2')...
    .slice(2)...
    .plotFlows(sol);

%%
% Graphic objects added to a figure without |HybridPlotBuilder|
% can be added to the legend by passing the graphic handle to |addLegendEntry|.
clf
pb = HybridPlotBuilder()...
    .legend('Hybrid Plot')...
    .plot(sol);
hold on
axis equal
% Plot a circle.
theta = linspace(0, 2*pi);
plt_handle = plot(10*cos(theta), 10*sin(theta), 'magenta');
% Pass the circle to the plot builder.
pb.addLegendEntry(plt_handle, 'Circle');

%% Replacing vs. Adding Plots to a Figure
% By default, each call to a |HybridPlotBuilder| plot function overwrites the 
% previous plots. In the following code, we call |plotFlows| twice. The
% first call plots a solution in blue and red, but the second call resets the figure
% and plots a solution in black and green.
tspan = [0 10];
jspan = [0 30];
sol1 = system.solve([10, 0], tspan, jspan, config);
sol2 = system.solve([ 5, 10], tspan, jspan, config);

clf
HybridPlotBuilder()... % Plots blue flows and red jumps by default.
    .plotFlows(sol1)
HybridPlotBuilder().flowColor('black').jumpColor('green')...
    .title('Multiple Calls to $\texttt{plotFlows}$ with \texttt{hold off}') ...
    .plotFlows(sol2)
%% 
% To plot multiple graphs on the same figure, use |hold on|, similar to
% standard MATLAB plotting functions.
HybridPlotBuilder().plotFlows(sol1) % Plots blue flows and red jumps by default.
hold on
HybridPlotBuilder().flowColor('black').jumpColor('green')...
    .title('Multiple Calls to $\texttt{plotFlows}$ with \texttt{hold on}')...
    .plotFlows(sol2)

%% Modifying Defaults
% The default values of all |HybridPlotBuilder| settings can be modified by
% calling 'set' on the 'defaults' property. The arguments are must be name-value
% pairs, where the name is a string that matches one of the
% properties in PlotSettings (names are case insensitive and underscores can be
% replaced with spaces). 
clf
HybridPlotBuilder.defaults.set('Label Size', 14, ...
                             'Title Size', 16, ...
                             'label interpreter', 'tex', ...
                             'title interpreter', 'none', ...
                             'flow_color', 'k', ...
                             'flow line width', 2, ...
                             'jump_color', 'k', ...
                             'jump line width', 2, ...
                             'jump line style', ':', ...
                             'jump start marker', 's', ...
                             'jump start marker size', 10, ...
                             'jump end marker', 'none', ...
                             'x_label_format', 'z_{%d}', ...
                             't_label', 't [s]')
HybridPlotBuilder()...
    .title('Title')...
    .legend('Legend A', 'Legend B')...
    .plotFlows(sol);

%% 
% The defaults can be reset to their original value with the following command.
HybridPlotBuilder.defaults.reset()

%% Default Scaling
% MATLAB is inconsistent about the size of text and graphics on
% different devices. To mitigate the differences, several scale properties are
% included in the |HybridPlotBuilder| defaults. 
clf
HybridPlotBuilder.defaults.set('text scale', 1.5, ...
                                'line scale', 3, ...
                                'marker scale', 2)
% Example output:
HybridPlotBuilder()...
    .title('Title')...
    .legend('height', 'velocity')...
    .plotFlows(sol);

HybridPlotBuilder.defaults.reset() % Cleanup

% To set the default values for every MATLAB session, create a script
% 'startup.m' in the folder returned by the |userpath()| command. 
% The commands in this script will run every time MATLAB starts.

%% Additional configuration
% There are numerous options for configuring the appearance of Matlab plots
% that are not included explicitly in HybridPlotBuilder (see
% <https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% here>).
% For plots with a single subplot, the appearance can be modified just like any
% other Matlab plot.
HybridPlotBuilder().plot(sol);
grid on
ax = gca;
ax.YAxisLocation = 'right';

%%
% Plots with multiple subplots can also be configured as described above by
% calling |subplot(2, 1, 1)| and making the desired modifications, then
% calling |subplot(2, 1, 2)|, etc., but that approach 
% is messy and tediuous. Instead, the |configurePlots| function provides a
% cleaner alternative. A function handle is passed to |configurePlots|,
% which is then called by |HybridPlotBuilder| within each (sub)plot.
% The function handle passed to |configurePlots| must take two input
% arguments. The first is the axes for the subplot and the second is the index
% for the state component(s) plotted in the plot. For |plotFlows|, |plotJumps|,
% and |plotHybrid|, this will be one 
% integer, and for phase plots generated with |plot|, this will be an array of
% two or three integers, depending on the dimension of the plot.
HybridPlotBuilder()...
    .legend('A', 'B')...
    .configurePlots(@apply_plot_settings)...
    .plotFlows(sol);

function apply_plot_settings(ax, component)
    title(ax, sprintf('This is the plot of component %d', component))
    subtitle(ax, 'An Insightful Subtitle','FontAngle','italic')
    % Set the location of the legend in each plot to different positions.
    switch component 
        case 1
            ax.Legend.Location = 'northeast';
        case 2
            ax.Legend.Location = 'southeast';
    end
    % Configure grid
    grid(ax, 'on')
    grid(ax, 'minor')
    ax.GridLineStyle = '--';
end