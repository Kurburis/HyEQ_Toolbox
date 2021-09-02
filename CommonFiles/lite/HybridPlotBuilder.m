classdef HybridPlotBuilder < handle

    properties(Constant, Hidden)
        INTERPRETERS = ["none", "tex", "latex"];
    end
    
    properties(Constant)
        % To reset the defaults, clear all instances of HybridPlotBuilder,
        % then call "clear HybridPlotBuilder". (To do both at once, "clear all", 
        % if you don't mind deleting all other variables)
        default_values = hybrid.internal.HybridPlotBuilderDefaults()
    end

    methods(Static)
        function d = defaults()
            d = HybridPlotBuilder.default_values;
        end
    end
    
    properties(SetAccess = private)
        % Text
        component_titles;
        component_labels; 
        title_interpreter;
        label_interpreter;
        title_size;
        label_size;

        % Plots
        flow_color = "b";
        flow_line_style string = "-";
        flow_line_width double = NaN;
        jump_color = "r";
        jump_line_style string = "--";
        jump_line_width double = NaN;
        jump_start_marker string = ".";
        jump_start_marker_size double = 6;
        jump_end_marker string = "*";
        jump_end_marker_size double = 6;
        
        % Subplots
        auto_subplots logical = true;
        subplots_callback function_handle = @(component) disp('');
        
        % Extra label config
        t_label % Defaults to value of 'default_t_label'
        j_label % Defaults to value of 'default_j_label'
        label_format % Defaults to value of 'default_label_format'
    end
    
    properties(Access = private)
        plots_for_legend = [];
        axes_for_legend = [];
        component_indices uint32 = [];
        timestepsFilter = [];
        max_subplots = 4;
    end
    
    properties(Dependent, Access = private)
        % Labels that correctly adjust to different text interpreters.
        default_t_label
        default_j_label
        default_label_format
    end
    
    methods
        function value = get.default_t_label(this)
            if strcmp(this.label_interpreter, "none")
                value = "t"; % No formatting
            elseif strcmp(this.label_interpreter, "tex")
                value = "t";
            elseif strcmp(this.label_interpreter, "latex")
                value = "$t$";
            else
                error("text interpreter '%s' unrecognized",... 
                            this.label_interpreter);
            end
        end

        function value = get.default_j_label(this)
            if strcmp(this.label_interpreter, "none")
                value = "j"; % No formatting
            elseif strcmp(this.label_interpreter, "tex")
                value = "j";
            elseif strcmp(this.label_interpreter, "latex")
                value = "$j$";
            else
                error("text interpreter '%s' unrecognized",... 
                            this.label_interpreter);
            end
        end
        
        function fmt = get.default_label_format(this)
            if strcmp(this.label_interpreter, "none")
                fmt = "x_%d"; % No formatting
            elseif strcmp(this.label_interpreter, "tex")
                fmt = "x_{%d}";
            elseif strcmp(this.label_interpreter, "latex")
                fmt = "$x_{%d}$";
            else
                error("text interpreter '%s' unrecognized",...
                    this.label_interpreter);
            end
        end
    end

    methods

        function this = title(this, title)
            assert(length(title) == 1, "For setting multiple titles, use titles()")
            this.component_titles = title;
        end
        
        function this = titles(this, varargin)
            this.component_titles = varargin;
        end

        function this = labels(this, varargin)
            this.component_labels = varargin;
        end

        function this = xLabelFormat(this, label_format)
            this.label_format = label_format;
        end

        function this = tLabel(this, t_label)
            this.t_label = t_label;
        end

        function this = jLabel(this, j_label)
            this.j_label = j_label;
        end

        function this = flowColor(this, color)
            % FLOWCOLOR Set the color of flow lines.
            this.flow_color = color;
        end

        function this = flowLineStyle(this, style)
            % FLOWLINESTYLE Set the style of flow lines.  If 'style'
            % is an empty string or empty array, then flow lines are hidden. 
            if style == "" || isempty(style)
                this.flow_line_style = "none";
            else
                this.flow_line_style = style;
            end
        end

        function this = flowLineWidth(this, width)
            % FLOWLINEWIDTH Set the width of flow lines.
            assert(width > 0, "Line width must be positive")
            this.flow_line_width = width;
        end

        function this = jumpColor(this, color)
            % JUMPCOLOR Set the color of jump lines and jump markers.
            % at each end.
            this.jump_color = color;
        end

        function this = jumpLineStyle(this, style)
            % JUMPLINESTYLE Set the style of lines along jumps. If 'style'
            % is an empty string or empty array, then jump lines are hidden. 
            if style == "" || isempty(style)
                this.jump_line_style = "none";
            else
                this.jump_line_style = style;
            end
        end

        function this = jumpLineWidth(this, width)
            % JUMPLINEWIDTH Set the width of jump lines.
            assert(width > 0, "Line width must be positive")
            this.jump_line_width = width;
        end

        function this = jumpMarker(this, marker)
            % JUMPMARKER Set the marker for both sides of jumps.
            this.jumpStartMarker(marker);
            this.jumpEndMarker(marker);
        end

        function this = jumpMarkerSize(this, size)
            % JUMPMARKERSIZE Set the marker size for both sides of jumps.
            this.jumpStartMarkerSize(size);
            this.jumpEndMarkerSize(size);
        end

        function this = jumpStartMarker(this, marker)
            % JUMPSTARTMARKER Set the marker for the starting point of each
            % jump.
            if marker == "" || isempty(marker)
                this.jump_start_marker = "none";
            else
                this.jump_start_marker = marker;
            end
        end

        function this = jumpStartMarkerSize(this, size)
            % JUMPSTARTMARKERSIZE Set the marker size for the starting 
            % point of each jump.
            assert(size > 0, "Size must be positive")
            this.jump_start_marker_size = size;
        end

        function this = jumpEndMarker(this, marker)
            % JUMPENDMARKER Set the marker for the end point of each
            % jump.
            if marker == "" || isempty(marker)
                this.jump_end_marker = "none";
            else
                this.jump_end_marker  = marker;
            end
        end

        function this = jumpEndMarkerSize(this, size)
            % JUMPENDMARKERSIZE Set the marker size for the end 
            % point of each jump.
            assert(size > 0, "Size must be positive")
            this.jump_end_marker_size = size;
        end

        function this = slice(this, component_indices)
            % SLICE Pick the state components to plot by providing the
            % corresponding indices. 
            
            if size(component_indices, 1) > 1
                % We need component_indices to be a row vector so that when
                % we use it to create a for-loop (i.e., "for
                % i=component_indices"), every entry is used for 
                % one iteration each. If component_indices is a column
                % vector, instead, then the entire column is used as the
                % value of 'i' for only a single iteration.
                assert(size(component_indices, 2) == 1)
                component_indices = component_indices';
            end
            
            this.component_indices = component_indices;
        end

        function this = filter(this, timesteps_filter)
            % FILTER Pick the timesteps to display. All others are hidden
            % from plots. 
            this.timestepsFilter = timesteps_filter;
        end
        
        function this = autoSubplots(this, auto_subplots)
            % AUTOSUBPLOTS Configure whether to automatically create subplots for each component.
            if strcmp("on", auto_subplots)
                auto_subplots = true;
            elseif strcmp("off", auto_subplots)
                auto_subplots = false;
            end
            assert(isscalar(auto_subplots), "Argument 'auto_subplots' was an array")
            this.auto_subplots = logical(auto_subplots);
        end
        
        function this = configureSubplots(this, callback)
           this.subplots_callback = callback;
        end
        
        function this = textInterpreter(this, interpreter)
            is_valid = ismember(interpreter,HybridPlotBuilder.INTERPRETERS);
            assert(is_valid, "'%s' is not a valid value. Use one of these values: 'none' | 'tex' | 'latex'.", interpreter)
            this.title_interpreter = interpreter;
        end

        function this = plotFlows(this, varargin)
            % Plot values vs. continuous time.
            hybrid_sol = hybrid.internal.convert_varargin_to_solution_obj(varargin);
            
            indices_to_plot = indicesToPlot(this, hybrid_sol);
                        
            nplot = length(indices_to_plot);
            axis1_ids = repmat("t", nplot, 1);
             
            this.plot_from_ids(hybrid_sol, axis1_ids, indices_to_plot);
            
            if nargout == 0
                % Prevent output if function is not terminated with a
                % semicolon.
                clear this
            end
        end

        function this = plotJumps(this, varargin)
            hybrid_sol = hybrid.internal.convert_varargin_to_solution_obj(varargin);
            indices_to_plot = indicesToPlot(this, hybrid_sol);
                        
            nplot = length(indices_to_plot);
            axis1_ids = repmat("j", nplot, 1);
             
            this.plot_from_ids(hybrid_sol, axis1_ids, indices_to_plot);
            
            if nargout == 0
                % Prevent output if function is not terminated with a
                % semicolon.
                clear this
            end
        end

        function this = plotHybrid(this, varargin)
            hybrid_sol = hybrid.internal.convert_varargin_to_solution_obj(varargin);
            indices_to_plot = indicesToPlot(this, hybrid_sol);

            nplot = length(indices_to_plot);
            axis1_ids = repmat("t", nplot, 1);
            axis2_ids = repmat("j", nplot, 1);
            axis3_ids = indices_to_plot;
            this.plot_from_ids(hybrid_sol, axis1_ids, axis2_ids, axis3_ids)
            
            if nargout == 0
                % Prevent output if function is not terminated with a
                % semicolon.
                clear this
            end
        end

        function this = plot(this, varargin)
            % PLOT Plot the hybrid solution in an intelligent way.
            % The output of depends on the dimension of the system 
            % (or the number of components selected with 'slice()'). 
            % The output is as follows: 
            % - 1D: a 1D plot generated using plotFlows
            % - 2D: a 2D phase plot
            % - 3D: a 3D phase plot
            % - 4D+: a set of 1D subplots generated using plotFlows.
            hybrid_sol = hybrid.internal.convert_varargin_to_solution_obj(varargin);
            sliced_indices = indicesToPlot(this, hybrid_sol);
            dimensions = length(sliced_indices);
            
            if dimensions ~= 2 && dimensions ~= 3
                this.plotFlows(hybrid_sol)
                return
            end
            if this.auto_subplots
                subplot(1, 1, 1) % Reset to only one subplot
            end
            sliced_x = hybrid_sol.x(:, sliced_indices);
            this.plot_sliced(hybrid_sol, sliced_x)

            if dimensions == 2
                configureAxes(this, sliced_indices(1), sliced_indices(2))
            else % dimensions == 3
                configureAxes(this, sliced_indices(1), sliced_indices(2), sliced_indices(3))
            end    
            
            if nargout == 0
                % Prevent output if function is not terminated with a
                % semicolon.
                clear this
            end          
        end

        function lgd = legend(this, varargin)
            % LEGEND Add a legend for each call to builder.plots() while 
            % in the current figure. (Plots in other figures will be
            % skipped).
            lgd_labels = varargin;
            
            % For the current figure, get all the line plots. 
            plots_in_figure = findall(gcf,'Type','Line');
            
            % For each plot saved in this.plots_for_legend, check whether
            % it is a plot in the current figure.
            plots_for_legend_indices ...
                = ismember(this.plots_for_legend,  plots_in_figure);
            plots_for_this_legend ...
                = this.plots_for_legend(plots_for_legend_indices);
            axes_for_this_legend = this.axes_for_legend(plots_for_legend_indices);
            
            for ax = unique(axes_for_this_legend)
                % Add the legend entries for each plot. We truncate the lengths
                % of the arrays to match so that Matlab does not print a
                % (rather unhelpful) warning.
                plots_in_axes = plots_for_this_legend(axes_for_this_legend == ax);
                m = min(length(plots_in_axes), length(lgd_labels));
                
                % Show a warning if the number of plots don't
                % match the number of labels provided.
                check_legend_count(plots_in_axes, lgd_labels);
                
                if isvalid(ax)
                    lgd = legend(ax, plots_in_axes(1:m), lgd_labels(1:m), ...
                        "interpreter", this.label_interpreter, ...
                        "FontSize", this.label_size, ...
                        'AutoUpdate','off');
                end
                
                if nargout == 0
                    % We clear 'lgd' if the output of the
                    % function is unused. This prevents the value 
                    % from being printed out if the function call was not
                    % terminated with a semi-colon.
                    clear lgd;
                end
            end
        end

        function addLegendEntry(this, plt)
            % Add an object to include in the legend. 
            % This function MUST be called while the axes where the object
            % was plotted is still active.
            this.plots_for_legend = [this.plots_for_legend, plt];
            this.axes_for_legend = [this.axes_for_legend, gca()];
        end
    end

    methods(Hidden)
        % The following functions are provided to help users transition
        % from v2.04 to v3.0.
        
        function plotflows(this, varargin)            
            warning("Please use the plotFlows function instead of plotflows.")
            this.plotFlows(varargin{:});
        end

        function plotjumps(this, varargin)
            warning("Please use the plotJumps function instead of plotjumps.")
            this.plotJumps(varargin{:});
        end

        function plotHybridArc(this, varargin)
            warning("Please use the plotHybrid function instead of plotHybridArc.")
            this.plotHybrid(varargin{:});
        end 
    end
    
    methods(Access = private)

        function configureAxes(this, xaxis_id, yaxis_id, zaxis_id)
            narginchk(3, 4)
            %is2D = nargin == 4;
            is3D = nargin == 4;
            is_x_a_time_axis = any(strcmp(xaxis_id, ["t", "j"]));
            is_y_a_time_axis = strcmp(yaxis_id, "j");            
            first_nontime_axis = 1 + is_x_a_time_axis + is_y_a_time_axis;
            
            % Apply labels
            this.xlabel(xaxis_id)
            this.ylabel(yaxis_id)
            if is3D
                this.zlabel(zaxis_id)
            end
            
            switch first_nontime_axis
                case 1
                    this.applyTitle(xaxis_id)
                case 2
                    this.applyTitle(yaxis_id)
                case 3
                    this.applyTitle(zaxis_id)
            end
            
            % Adjust padding.
            if is_x_a_time_axis
               set(gca, 'XLimSpec', 'Tight');
            else
                set(gca, 'XLimSpec', 'Padded');
            end
            
            if is_y_a_time_axis
               set(gca, 'YLimSpec', 'Tight');
            else
                set(gca, 'YLimSpec', 'Padded');
            end
            
            % The z-axis never contains t or j, so we don't make it
            % "tight". Conversely, making it "padded" doesn't improve the
            % appearance of a 3D plot, so we don't modify the default
            % behavior.            
        end
        
        function plot_from_ids(this, hybrid_sol, axis1_ids, axis2_ids, axis3_ids)
            narginchk(4, 5)
            is2D = nargin == 4;
            
            nplot = length(axis1_ids);
             
            if ~this.auto_subplots
                was_hold_on = ishold();
                if ~was_hold_on
                    % Clear the plot to emulate "hold off" behavior.
                    plot(nan, nan);
                end
                % Turn on hold so that we can plot multiple components.
                hold on
            end
            
            for sp = 1:nplot
                if this.auto_subplots
                    subplots(sp) = open_subplot(nplot, sp); %#ok<AGROW>
                    was_subplot_hold_on = ishold();
                    if ~was_subplot_hold_on
                        % Clear the plot to emulate "hold off" behavior.
                        plot(nan, nan);
                    end
                    hold on
                end
                
                if is2D
                    axis3_id = [];
                    last_id = axis2_ids(sp);
                else
                    axis3_id = axis3_ids(sp);
                    last_id = axis3_ids(sp);
                end
                
                plot_values = create_plot_values(hybrid_sol, axis1_ids(sp), axis2_ids(sp), axis3_id);
                this.plot_sliced(hybrid_sol, plot_values)
                
                if this.auto_subplots
                    this.configureAxes(axis1_ids(sp), axis2_ids(sp), axis3_id);
                    this.subplots_callback(last_id);
                    if ~was_subplot_hold_on
                        hold off
                    end
                else
                    this.configureAxes(axis1_ids(sp), axis2_ids(sp), axis3_id);
                end
            end
            
            if this.auto_subplots
                % Link the subplot axes.
                if is2D
                    % Link the x-axes of the subplots so zooming and panning
                    % one subplot effects the others.
                    linkaxes(subplots,'x')
                else
                    if this.auto_subplots
                        % Link the subplot axes so that the views are sync'ed.
                        link = linkprop(subplots, {'View', 'XLim', 'YLim'});
                        setappdata(gcf, 'StoreTheLink', link);
                    end
                end
            else
                if ~was_hold_on
                    hold off
                end
            end
        end

        function plot_sliced(this, hybrid_sol, sliced_plot_values)

            if ~isempty(this.timestepsFilter)
                assert(length(this.timestepsFilter) == size(sliced_plot_values, 1), ...
                    "The length(filter)=%d does not match the timesteps=%d in the HybridSolution.", ...
                    length(this.timestepsFilter), size(sliced_plot_values, 1))
                % Set entries that don't match the filter to NaN so they are not plotted.
                sliced_plot_values(~this.timestepsFilter) = NaN;
            end
            
            flows_x = hybrid.internal.separateFlowsWithNaN(...
                                    hybrid_sol.t, hybrid_sol.j, sliced_plot_values);
            [jumps_x, jumps_befores, jumps_afters] ...
                = hybrid.internal.separateJumpsWithNaN(hybrid_sol.t, hybrid_sol.j, sliced_plot_values);
            
            % We 'plot' a invisible dummy point (NaN values are not
            % visible in plots), which provides the line and marker
            % appearance for the corresponding legend entry.
            % Drawing this point will also clear the plot if 'hold' is off.
            plt = plot(nan, nan, "Color", this.flow_color, ...
                "LineStyle", this.flow_line_style, ...
                "LineWidth", this.flow_line_width, ...
                "Marker", this.jump_start_marker, ...
                "MarkerSize", this.jump_start_marker_size, ...
                "MarkerEdgeColor", this.jump_color);
            this.addLegendEntry(plt)
            
            % We have to turn on hold while plotting the hybrid arc, so 
            % we save the current hold state and restore it at the end.
            was_hold_on = ishold();
            hold on

            switch size(sliced_plot_values, 2)
                case 2
                    this.plotFlow2D(flows_x)
                    this.plotJump2D(jumps_x, jumps_befores, jumps_afters)
                case 3
                    this.plotFlow3D(flows_x)
                    this.plotJump3D(jumps_x, jumps_befores, jumps_afters)
                    view(34.8,16.8)
                otherwise
                    error("HybridPlotBuilder:WrongNumberOfComponents", ...
                        "The plot_sliced method can only plot in 2D and 3D.")
            end
            
            % Turn off 'hold' if it was off at the beginning of this
            % function.
            if ~was_hold_on
                hold off
            end
        end
        
        function indices_to_plot = indicesToPlot(this, hybrid_sol)
            n = size(hybrid_sol.x, 2);
            if isempty(this.component_indices)
                if this.auto_subplots
                    last_index = min(n, this.max_subplots);
                else
                    last_index = n;
                end
                indices_to_plot = 1:last_index;
            else
                indices_to_plot = this.component_indices;
            end
            assert(min(indices_to_plot) >= 1)
            assert(max(indices_to_plot) <= n, ...
                "max(indices_to_plot)=%d is greater than n=%d", ...
                max(indices_to_plot), n)
        end

        function plotFlow2D(this, x)
            if isempty(x)
               return 
            end
            plot(x(:,1), x(:,2), 'Color', this.flow_color, ...
                            'LineStyle', this.flow_line_style, ...
                            'LineWidth', this.flow_line_width)
        end

        function plotFlow3D(this, x)
            if isempty(x)
               return 
            end
            plot3(x(:,1), x(:,2), x(:,3), ...
                            'Color', this.flow_color, ...
                            'LineStyle', this.flow_line_style, ...
                            'LineWidth', this.flow_line_width)
        end

        function plotJump2D(this, x_jump, x_start, x_end)
            % Plot the line from start to end.
            plot(x_jump(:,1), x_jump(:,2), ...
                'Color', this.jump_color, ...
                'LineStyle', this.jump_line_style, ...
                'LineWidth', this.jump_line_width)
            % Plot the start of the jump
            plot(x_start(:,1), x_start(:,2), ...
                'Color', this.jump_color, ...
                'Marker', this.jump_start_marker, ...
                'MarkerSize', this.jump_start_marker_size)
            % Plot the end of the jump
            plot(x_end(:,1), x_end(:,2), ...
                'Color', this.jump_color, ...
                'Marker', this.jump_end_marker, ...
                'MarkerSize', this.jump_end_marker_size)
        end

        function plotJump3D(this, x_jump, x_before, x_after)
            if isempty(x_before)
                return % Not a jump
            end
            % Plot jump line
            plot3(x_jump(:,1), x_jump(:, 2), x_jump(:, 3), ...
                'Color', this.jump_color, ...
                'LineStyle', this.jump_line_style, ...
                'LineWidth', this.jump_line_width)
            % Plot the start of the jump
            plot3(x_before(:,1), x_before(:,2), x_before(:,3), ...
                'Color', this.jump_color, ...
                'Marker', this.jump_start_marker, ...
                'MarkerSize', this.jump_start_marker_size)
            % Plot the end of the jump
            plot3(x_after(:,1), x_after(:,2), x_after(:,3), ...
                'Color', this.jump_color, ...
                'Marker', this.jump_end_marker, ...
                'MarkerSize', this.jump_end_marker_size)
        end
        
        function label = createLabel(this, index)
            if strcmp("t", index)
                label = this.t_label;
                return
            end
            
            if strcmp("j", index)
                label = this.j_label;
                return
            end
            
            if index <= length(this.component_labels)
                label = this.component_labels(index);  
            else
                fmt = this.label_format;
                label = sprintf(fmt, index);
            end
        end
        
        function xlabel(this, index)
            % xlabel Add a label to the x-axis for the component at 'index'.
            label = this.createLabel(index);
            xlabel(label, "interpreter", this.label_interpreter, "FontSize", this.label_size)
        end

        function ylabel(this, index)
            % ylabel Add a label to the y-axis for the component at 'index'.
            label = this.createLabel(index);
            ylabel(label, "interpreter", this.label_interpreter, "FontSize", this.label_size)
        end

        function zlabel(this, index)
            % zlabel Add a label to the z-axis for the component at 'index'.
            label = this.createLabel(index);
            zlabel(label, "interpreter", this.label_interpreter, "FontSize", this.label_size)
        end

        function applyTitle(this, index)
            if index <= length(this.component_titles)
                title(this.component_titles(index), ...
                    "interpreter", this.title_interpreter, ...
                    "FontSize", this.title_size)
            end
        end         
    end
    
    methods
        function val = get.t_label(this)
            if isempty(this.t_label)
                val = this.default_t_label;
            else
                val = this.t_label;
            end
        end
        
        function val = get.j_label(this)
            if isempty(this.j_label)
                val = this.default_j_label;
            else
                val = this.j_label;
            end
        end
        
        function val = get.label_format(this)
            if isempty(this.label_format)
                val = this.default_label_format;
            else
                val = this.label_format;
            end
        end
        
        function val = get.label_size(this)
           if isempty(this.label_size)
               val = this.defaults.label_size;
           else
               val = this.label_size;
           end
        end
        
        function val = get.title_size(this)
           if isempty(this.title_size)
               val = this.defaults.title_size;
           else
               val = this.title_size;
           end
        end
        
        function val = get.label_interpreter(this)
           if isempty(this.label_interpreter)
               val = this.defaults.label_interpreter;
           else
               val = this.label_interpreter;
           end
        end
        
        function val = get.title_interpreter(this)
           if isempty(this.title_interpreter)
               val = this.defaults.title_interpreter;
           else
               val = this.title_interpreter;
           end
        end
        
        function val = get.flow_line_width(this)
           if isnan(this.flow_line_width)
               val = this.defaults.flow_line_width;
           else
               val = this.flow_line_width;
           end
        end
        
        function val = get.jump_line_width(this)
           if isnan(this.jump_line_width)
               val = this.defaults.jump_line_width;
           else
               val = this.jump_line_width;
           end
        end
    end
end
        
%%% Local functions %%%

function sp = open_subplot(subplots_count, index)
    is_hold_on = ishold(); % Save the hold status to apply in subplots.
    sp = subplot(subplots_count, 1, index);
    if is_hold_on
        % Subplots default to hold off, so we modify the hold
        % status to match what was met before 
        hold on
    end
end


function plot_values = create_plot_values(sol, xaxis_id, yaxis_id, zaxis_id)
% CREATE_PLOT_VALUES Create an array containing the values from the corresponding id in each column.
% xaxis_id can take values "t", "j" or an integer.
% yaxis_id can take values "j" or an integer.
% zaxis_id can take value of an integer or an empty set.
narginchk(4, 4)

    function values = values_from_id(id)
        if strcmp(id, "t")
            values = sol.t;
        elseif strcmp(id, "j")
            values = sol.j;
        else
            values = sol.x(:, id);
        end
    end

    xvalues = values_from_id(xaxis_id);
    yvalues = values_from_id(yaxis_id);
    % If zaxis_id is empty, then zvalues will be as well, which means the
    % the plot will be only 2D.
    zvalues = values_from_id(zaxis_id);
    plot_values = [xvalues, yvalues, zvalues];

end

function checkColorArg(color_arg)
    if ~verLessThan('matlab', '9.9')
        % The validatecolor function was added in R2020b (v9.9), so we
        % first check the version to make sure we can call it.
        if ~validatecolor(color_arg)
            error("HybridPlotBuilder:InvalidColor", ...
                "The argument is not recognized as a color.")
        end
    end
    
end
       
function check_legend_count(plots_in_axes, lgd_labels)
% Print a warning if the number of plots and labels do not
% match.
warning_msg = "The number of plots (%d) added to the current axes" + ...
    " by this HybridPlotBuilder is %s than the number of legend labels provided (%d).";
if length(plots_in_axes) < length(lgd_labels)
    warning(warning_msg, length(plots_in_axes), "less", length(lgd_labels))
elseif length(plots_in_axes) > length(lgd_labels)
    warning(warning_msg, length(plots_in_axes), "more", length(lgd_labels))
end
end
