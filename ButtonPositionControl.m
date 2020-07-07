classdef ButtonPositionContor < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        SerialConfigurationPanel  matlab.ui.container.Panel
        PortsDropDownLabel        matlab.ui.control.Label
        PortsDropDown             matlab.ui.control.DropDown
        BaudRateDropDownLabel     matlab.ui.control.Label
        BaudRateDropDown          matlab.ui.control.DropDown
        ConnectButton             matlab.ui.control.StateButton
        Lamp                      matlab.ui.control.Lamp
        PositionsPanel            matlab.ui.container.Panel
        Label                     matlab.ui.control.Label
        Label_2                   matlab.ui.control.Label
        Label_3                   matlab.ui.control.Label
        XPositionEditFieldLabel   matlab.ui.control.Label
        XPositionEditField        matlab.ui.control.NumericEditField
        YPositionEditFieldLabel   matlab.ui.control.Label
        YPositionEditField        matlab.ui.control.NumericEditField
        ButtonEditFieldLabel      matlab.ui.control.Label
        ButtonEditField           matlab.ui.control.NumericEditField
        LEDsStatePanel            matlab.ui.container.Panel
        RedLedLabel               matlab.ui.control.Label
        BlueLedLabel              matlab.ui.control.Label
        GreenLedLabel             matlab.ui.control.Label
        Lamp_2                    matlab.ui.control.Lamp
        Lamp_3                    matlab.ui.control.Lamp
        Lamp_4                    matlab.ui.control.Lamp
        REDButton                 matlab.ui.control.Button
        BLUEButton                matlab.ui.control.Button
        GREENButton               matlab.ui.control.Button
        Panel                     matlab.ui.container.Panel
        UIAxes_6                  matlab.ui.control.UIAxes
        UIAxes2                   matlab.ui.control.UIAxes
        Label_4                   matlab.ui.control.Label
        Label_5                   matlab.ui.control.Label
        UIAxes4                   matlab.ui.control.UIAxes
        UIAxes3                   matlab.ui.control.UIAxes
        Label_6                   matlab.ui.control.Label
    end

    
    properties (Access = private)
        arduino;
        Stop = false;
        State = 0;
        h;  %Axes
        h2; %Animateline - 1
        h3; %Animateline - 2
        h4; %Animateline - 3
        port;
    end
    
    methods (Access = private)
        

        % Open serial communacation with arduino
        function open(app)
            app.Stop = false;
            if(strcmp(app.arduino.Status,'closed'))
                fopen(app.arduino);
            end            
        end
        
        function StartCom(app)             
                %Set the communicationn parameters
                app.arduino = serial(app.PortsDropDown.Value,"BaudRate",...
                    str2double(app.BaudRateDropDown.Value),"Terminator","LF");
                app.arduino.InputBufferSize = 30;
                app.arduino.OutputBufferSize = 20;
                app.arduino.TimeOut = 0.5;
                app.arduino.ReadAsyncMode = "Continuous";
        end
        
        % Close serial communacation
        function close(app)
            app.Stop = true;
            pause(1);
            if(strcmp(app.arduino,'open'))
                fclose(app.arduino);
            end
        end
        
        function Add_DropDown_Items(app, new)
            if ~any(ismember(app.PortsDropDown.Items, new))
                app.PortsDropDown.Items = [app.PortDropDown.Items new];
            end
            app.PortsDropDown.Value = new(1);
        end
        
        function Sellect_Led_State(app)
            switch(app.State)
                        case 0
                            fprintf(app.arduino,'%c','A');
                        case 1
                            fprintf(app.arduino,'%c','R');
                        case 2
                            fprintf(app.arduino,'%c','G');
                        case 3
                            fprintf(app.arduino,'%c','B');
                        otherwise
                            disp("Something wrong!!");                          
           end
        end
        
        function parse_Data(app,data)
            set(app.h,'XData',data(1),'YData',data(2));
           if(data(3) == 1)
              app.h.MarkerFaceColor = 'b';
           else
              app.h.MarkerFaceColor = 'w';
           end
           app.XPositionEditField.Value = data(1);
           app.YPositionEditField.Value = data(2);
           app.ButtonEditField.Value = data(3);
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            Ports = seriallist;
            info = instrhwinfo('serial');          %Find proper ports for communication
            app.port = info.AvailableSerialPorts;  %Find available serial port  
            col = size(Ports,2);
            if ~isempty(Ports) 
                for i=1:col
                    app.Add_DropDown_Items(Ports);
                end
            end
            % Create a marker to show position data
            app.h = plot(186,174,'o','MarkerSize', 20 ,'MarkerFaceColor', 'b','Parent',app.UIAxes_6);
            
            % Animated for sensor data
            app.h2 = animatedline(app.UIAxes3,0,0,'LineStyle','-.','Color','#7E2F8E','LineWidth',1);
            legend(app.UIAxes3,"X-POS");
            app.h3 = animatedline(app.UIAxes2,0,0,'LineStyle','-.','Color','b','LineWidth',1);
            legend(app.UIAxes2,"Y-POS");
            app.h4 = animatedline(app.UIAxes4,0,0,'LineStyle','-.','Color','g','LineWidth',2);
            legend(app.UIAxes4,"Button-State");
            
            %if serial port not connect,then app is deleted.
            if(isempty(app.port))
                uiwait(msgbox("Serial device not found. Please Control The Serial Port","replace",'warn'));
                app.delete();
            end
            
            %Start Communication with device
            app.StartCom();
            
            
        end

        % Button pushed function: REDButton
        function REDButtonPushed(app, event)
            app.Lamp_2.Color = 'r';
            app.Lamp_3.Color = 'w';
            app.Lamp_4.Color = 'w';
            app.State = 1;
        end

        % Button pushed function: BLUEButton
        function BLUEButtonPushed(app, event)
            app.Lamp_2.Color = 'w';
            app.Lamp_3.Color = 'b';
            app.Lamp_4.Color = 'w';
            app.State = 2;
        end

        % Button pushed function: GREENButton
        function GREENButtonPushed(app, event)
            app.Lamp_2.Color = 'w';
            app.Lamp_3.Color = 'w';
            app.Lamp_4.Color = 'g';
            app.State = 3;
        end

        % Value changed function: ConnectButton
        function ConnectButtonValueChanged(app, event)
            value = app.ConnectButton.Value;
            if(value==1)
                app.Lamp.Color = 'g';
                app.ConnectButton.Text = "Disconnect";
                if(~isempty(app.port))
                    app.open();
                    readasync(app.arduino);
                    byte = app.arduino.BytesAvailable;
                    while(byte <= 0)
                        byte = app.arduino.BytesAvailable;
                    end
                    data = fscanf(app.arduino,'%s',1);
                    while(strcmp(data(1),'A') && byte)
                        disp("aaa");
                        flushinput(app.arduino);
                        data = fscanf(app.arduino,'%s',1)';
                        byte = app.arduino.BytesAvailable;
                        fprintf(app.arduino,'%c','A');
                        pause(1);
                    end
                    
                    flushinput(app.arduino);
                    
                    i = 1;
                    j = 0;
                    
                    while(i<1000)
                        if(app.Stop)
                            break;
                        end
                        byte = app.arduino.BytesAvailable;
                        if(byte > 0)
                    %        data = char(fread(s,byte,'uint8')');
%                             data = str2num(data)
                            data = fscanf(app.arduino,'%i')';
                    %         drawCircle(data);   
                            addpoints(app.h2,j,data(1));
                            addpoints(app.h3,j,data(2));
                            addpoints(app.h4,j,data(3));
                            app.parse_Data(data);                                             
                            drawnow;
                            j = j+1;
                        end
                        app.Sellect_Led_State();
                        i = i+1;
                    end
                end
                
            else
                app.Lamp.Color = 'r';
                app.ConnectButton.Text = "Connect";
                app.close();
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 571];
            app.UIFigure.Name = 'UI Figure';

            % Create SerialConfigurationPanel
            app.SerialConfigurationPanel = uipanel(app.UIFigure);
            app.SerialConfigurationPanel.Title = 'Serial Configuration';
            app.SerialConfigurationPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.SerialConfigurationPanel.Position = [1 380 231 184];

            % Create PortsDropDownLabel
            app.PortsDropDownLabel = uilabel(app.SerialConfigurationPanel);
            app.PortsDropDownLabel.HorizontalAlignment = 'right';
            app.PortsDropDownLabel.FontSize = 15;
            app.PortsDropDownLabel.Position = [30 129 44 22];
            app.PortsDropDownLabel.Text = 'Ports:';

            % Create PortsDropDown
            app.PortsDropDown = uidropdown(app.SerialConfigurationPanel);
            app.PortsDropDown.Items = {'COM3', 'COM4', 'COM5', 'COM6'};
            app.PortsDropDown.FontSize = 15;
            app.PortsDropDown.Position = [89 129 132 22];
            app.PortsDropDown.Value = 'COM3';

            % Create BaudRateDropDownLabel
            app.BaudRateDropDownLabel = uilabel(app.SerialConfigurationPanel);
            app.BaudRateDropDownLabel.HorizontalAlignment = 'right';
            app.BaudRateDropDownLabel.FontSize = 15;
            app.BaudRateDropDownLabel.Position = [-3 100 77 22];
            app.BaudRateDropDownLabel.Text = 'BaudRate:';

            % Create BaudRateDropDown
            app.BaudRateDropDown = uidropdown(app.SerialConfigurationPanel);
            app.BaudRateDropDown.Items = {'9600', '19200', '38400', '57600', '1152000'};
            app.BaudRateDropDown.Position = [89 100 132 22];
            app.BaudRateDropDown.Value = '9600';

            % Create ConnectButton
            app.ConnectButton = uibutton(app.SerialConfigurationPanel, 'state');
            app.ConnectButton.ValueChangedFcn = createCallbackFcn(app, @ConnectButtonValueChanged, true);
            app.ConnectButton.Text = 'Connect';
            app.ConnectButton.Position = [7.5 36 196 30];

            % Create Lamp
            app.Lamp = uilamp(app.SerialConfigurationPanel);
            app.Lamp.Position = [207 40 20 20];
            app.Lamp.Color = [1 0 0];

            % Create PositionsPanel
            app.PositionsPanel = uipanel(app.UIFigure);
            app.PositionsPanel.Title = 'Positions';
            app.PositionsPanel.Position = [1 207 233 166];

            % Create Label
            app.Label = uilabel(app.PositionsPanel);
            app.Label.FontSize = 15;
            app.Label.Position = [170 102 25 22];
            app.Label.Text = '';

            % Create Label_2
            app.Label_2 = uilabel(app.PositionsPanel);
            app.Label_2.FontSize = 15;
            app.Label_2.Position = [170 72 25 22];
            app.Label_2.Text = '';

            % Create Label_3
            app.Label_3 = uilabel(app.PositionsPanel);
            app.Label_3.FontSize = 15;
            app.Label_3.Position = [170 36 25 22];
            app.Label_3.Text = '';

            % Create XPositionEditFieldLabel
            app.XPositionEditFieldLabel = uilabel(app.PositionsPanel);
            app.XPositionEditFieldLabel.HorizontalAlignment = 'right';
            app.XPositionEditFieldLabel.FontSize = 15;
            app.XPositionEditFieldLabel.Position = [5 102 78 22];
            app.XPositionEditFieldLabel.Text = 'X-Position:';

            % Create XPositionEditField
            app.XPositionEditField = uieditfield(app.PositionsPanel, 'numeric');
            app.XPositionEditField.Position = [95 102 100 22];

            % Create YPositionEditFieldLabel
            app.YPositionEditFieldLabel = uilabel(app.PositionsPanel);
            app.YPositionEditFieldLabel.HorizontalAlignment = 'right';
            app.YPositionEditFieldLabel.FontSize = 15;
            app.YPositionEditFieldLabel.Position = [8 72 76 22];
            app.YPositionEditFieldLabel.Text = 'Y-Position:';

            % Create YPositionEditField
            app.YPositionEditField = uieditfield(app.PositionsPanel, 'numeric');
            app.YPositionEditField.Position = [95 72 100 22];

            % Create ButtonEditFieldLabel
            app.ButtonEditFieldLabel = uilabel(app.PositionsPanel);
            app.ButtonEditFieldLabel.HorizontalAlignment = 'right';
            app.ButtonEditFieldLabel.FontSize = 15;
            app.ButtonEditFieldLabel.Position = [25 36 53 22];
            app.ButtonEditFieldLabel.Text = 'Button:';

            % Create ButtonEditField
            app.ButtonEditField = uieditfield(app.PositionsPanel, 'numeric');
            app.ButtonEditField.Position = [95 36 100 22];

            % Create LEDsStatePanel
            app.LEDsStatePanel = uipanel(app.UIFigure);
            app.LEDsStatePanel.Title = 'LEDs State';
            app.LEDsStatePanel.Position = [1 31 233 166];

            % Create RedLedLabel
            app.RedLedLabel = uilabel(app.LEDsStatePanel);
            app.RedLedLabel.FontSize = 15;
            app.RedLedLabel.Position = [23 99 67 22];
            app.RedLedLabel.Text = 'Red-Led:';

            % Create BlueLedLabel
            app.BlueLedLabel = uilabel(app.LEDsStatePanel);
            app.BlueLedLabel.FontSize = 15;
            app.BlueLedLabel.Position = [20 29 70 22];
            app.BlueLedLabel.Text = 'Blue-Led:';

            % Create GreenLedLabel
            app.GreenLedLabel = uilabel(app.LEDsStatePanel);
            app.GreenLedLabel.FontSize = 15;
            app.GreenLedLabel.Position = [9 63 81 22];
            app.GreenLedLabel.Text = 'Green-Led:';

            % Create Lamp_2
            app.Lamp_2 = uilamp(app.LEDsStatePanel);
            app.Lamp_2.Position = [96 100 20 20];
            app.Lamp_2.Color = [1 1 1];

            % Create Lamp_3
            app.Lamp_3 = uilamp(app.LEDsStatePanel);
            app.Lamp_3.Position = [96 30 20 20];
            app.Lamp_3.Color = [1 1 1];

            % Create Lamp_4
            app.Lamp_4 = uilamp(app.LEDsStatePanel);
            app.Lamp_4.Position = [96 64 20 20];
            app.Lamp_4.Color = [1 1 1];

            % Create REDButton
            app.REDButton = uibutton(app.LEDsStatePanel, 'push');
            app.REDButton.ButtonPushedFcn = createCallbackFcn(app, @REDButtonPushed, true);
            app.REDButton.Position = [127 99 100 22];
            app.REDButton.Text = 'RED';

            % Create BLUEButton
            app.BLUEButton = uibutton(app.LEDsStatePanel, 'push');
            app.BLUEButton.ButtonPushedFcn = createCallbackFcn(app, @BLUEButtonPushed, true);
            app.BLUEButton.Position = [127 29 100 22];
            app.BLUEButton.Text = 'BLUE';

            % Create GREENButton
            app.GREENButton = uibutton(app.LEDsStatePanel, 'push');
            app.GREENButton.ButtonPushedFcn = createCallbackFcn(app, @GREENButtonPushed, true);
            app.GREENButton.Position = [127 63 100 22];
            app.GREENButton.Text = 'GREEN';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BackgroundColor = [0 0 0];
            app.Panel.Position = [233 1 768 571];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.Panel);
            title(app.UIAxes_6, '')
            xlabel(app.UIAxes_6, '')
            ylabel(app.UIAxes_6, '')
            app.UIAxes_6.XLim = [0 362];
            app.UIAxes_6.YLim = [0 362];
            app.UIAxes_6.Box = 'on';
            app.UIAxes_6.Color = [0 0 0];
            app.UIAxes_6.CameraUpVector = [0 1 0];
            app.UIAxes_6.Visible = 'off';
            app.UIAxes_6.BackgroundColor = [0 0 0];
            app.UIAxes_6.Clipping = 'off';
            app.UIAxes_6.Position = [316 1 452 570];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.Panel);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, '')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.YLim = [0 360];
            app.UIAxes2.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes2.YColor = [0.9412 0.9412 0.9412];
            app.UIAxes2.Color = [0.149 0.149 0.149];
            app.UIAxes2.BackgroundColor = [0 0 0];
            app.UIAxes2.Position = [6 185 338 185];

            % Create Label_4
            app.Label_4 = uilabel(app.Panel);
            app.Label_4.FontColor = [1 1 1];
            app.Label_4.Position = [162 549 25 22];
            app.Label_4.Text = '';

            % Create Label_5
            app.Label_5 = uilabel(app.Panel);
            app.Label_5.FontColor = [1 1 1];
            app.Label_5.Position = [164 358 25 22];
            app.Label_5.Text = '';

            % Create Label_6
            app.Label_6 = uilabel(app.Panel);
            app.Label_6.FontColor = [1 1 1];
            app.Label_6.Position = [162 174 25 22];
            app.Label_6.Text = '';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.Panel);
            title(app.UIAxes3, '')
            xlabel(app.UIAxes3, '')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.YLim = [0 365];
            app.UIAxes3.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes3.YColor = [0.9412 0.9412 0.9412];
            app.UIAxes3.Color = [0.149 0.149 0.149];
            app.UIAxes3.BackgroundColor = [0 0 0];
            app.UIAxes3.Position = [4 371 335 193];

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.Panel);
            title(app.UIAxes4, '')
            xlabel(app.UIAxes4, '')
            ylabel(app.UIAxes4, 'Y')
            app.UIAxes4.YLim = [-0.5 1.5];
            app.UIAxes4.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes4.YColor = [0.9412 0.9412 0.9412];
            app.UIAxes4.Color = [0.149 0.149 0.149];
            app.UIAxes4.BackgroundColor = [0 0 0];
            app.UIAxes4.Position = [1 1 343 185];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ButtonPositionContor

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