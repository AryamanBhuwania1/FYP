classdef ANNPlotApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
        UIFigure         matlab.ui.Figure
        SurfaceRoughnessLabel  matlab.ui.control.Label
        SurfaceRoughnessEditField  matlab.ui.control.NumericEditField
        PredictButton    matlab.ui.control.Button
    end

    
    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: PredictButton
        function PredictButtonPushed(app, ~)
            hrms_value = app.SurfaceRoughnessEditField.Value;
            
            % Assume you have a trained neural network stored in 'Trained_Net.mat'
            load('Trained_Net.mat', 'net');

            % Create the input vector based on the provided surface roughness value
            input_value = [hrms_value; 0; 0];  % Assuming E and v are not considered for input
            
            % Predict using the trained neural network
            predicted_output = net(input_value);
            
            % Extract predicted values
            preD_pred = predicted_output(1, :);
            sepD_pred = predicted_output(2, :);
            Contact_ratio_pred = predicted_output(3, :);

            % Plot the load-separation curve
            figure;
            plot(sepD_pred, log(preD_pred), 'linestyle', '-', 'linewidth', 2, 'color', 'm', 'marker', 'none', ...
                'MarkerSize', 4, 'markerfacecolor', 'm', 'markeredgecolor', 'm');
            xlabel('u/rms');
            ylabel('log(p/E*)');
            set(gca, 'fontsize', 14, 'linewidth', 2);
            title('Load separation curve');

            % Plot the contact evolution curve
            figure;
            plot(preD_pred, Contact_ratio_pred, 'linestyle', '-', 'linewidth', 2, 'color', 'm', 'marker', 'none', ...
                'MarkerSize', 4, 'markerfacecolor', 'm', 'markeredgecolor', 'm');
            xlabel('p/E*');
            ylabel('A/A_0');
            set(gca, 'fontsize', 14, 'linewidth', 2);
            ylim([0 0.15]);
            title('Contact evolution curve');
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create SurfaceRoughnessLabel
            app.SurfaceRoughnessLabel = uilabel(app.UIFigure);
            app.SurfaceRoughnessLabel.HorizontalAlignment = 'right';
            app.SurfaceRoughnessLabel.Position = [146 362 103 22];
            app.SurfaceRoughnessLabel.Text = 'Surface Roughness';

            % Create SurfaceRoughnessEditField
            app.SurfaceRoughnessEditField = uieditfield(app.UIFigure, 'numeric');
            app.SurfaceRoughnessEditField.Limits = [0 Inf];
            app.SurfaceRoughnessEditField.Position = [264 362 100 22];

            % Create PredictButton
            app.PredictButton = uibutton(app.UIFigure, 'push');
            app.PredictButton.ButtonPushedFcn = createCallbackFcn(app, @PredictButtonPushed, true);
            app.PredictButton.Position = [264 317 100 22];
            app.PredictButton.Text = 'Predict';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ANNPlotApp
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
