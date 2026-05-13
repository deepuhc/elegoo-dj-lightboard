function proximity_direct()
% PROXIMITY_DIRECT - MATLAB directly controls the Arduino hardware
%
% This uses the MATLAB Support Package for Arduino to read the sensor
% and control the LED/buzzer directly from MATLAB — no custom Arduino
% firmware needed! MATLAB becomes the brain.
%
% This demonstrates a different architecture:
%   Option A (proximity_dashboard.m): Arduino firmware does the logic,
%            MATLAB just visualizes over serial
%   Option B (this file): MATLAB does ALL the logic, Arduino is just I/O
%
% Requirements:
%   - MATLAB Support Package for Arduino (install via Add-Ons)
%   - HC-SR04 on Trig=D9, Echo=D4
%   - RGB LED on R=D6, G=D5, B=D3
%   - Buzzer on D8
%
% Usage:
%   proximity_direct()

    %% Connect to Arduino
    fprintf('Connecting to Arduino...\n');
    a = arduino();  % Auto-detect port and board
    fprintf('Connected: %s on %s\n', a.Board, a.Port);

    % Configure pins
    configurePin(a, 'D9', 'DigitalOutput');  % Trig
    configurePin(a, 'D4', 'DigitalInput');   % Echo
    configurePin(a, 'D6', 'PWM');            % Red
    configurePin(a, 'D5', 'PWM');            % Green
    configurePin(a, 'D3', 'PWM');            % Blue
    configurePin(a, 'D8', 'DigitalOutput');  % Buzzer

    % Thresholds
    VERY_CLOSE = 5;
    CLOSE = 15;
    MEDIUM = 30;

    %% Create live figure
    fig = figure('Name', 'Proximity Direct Control', ...
        'NumberTitle', 'off', ...
        'Position', [200, 200, 800, 400]);

    subplot(1, 2, 1);
    distBar = bar(0, 'FaceColor', 'g');
    ylim([0, 60]);
    ylabel('Distance (cm)');
    title('Current Distance');
    hold on;
    yline(VERY_CLOSE, 'r--', 'Very Close');
    yline(CLOSE, 'Color', [1, 0.5, 0], 'LineStyle', '--', 'Label', 'Close');
    yline(MEDIUM, 'g--', 'Medium');

    subplot(1, 2, 2);
    histData = [];
    histPlot = histogram(0, 'BinWidth', 2, 'FaceColor', [0.3, 0.6, 1]);
    xlabel('Distance (cm)');
    ylabel('Frequency');
    title('Distance Distribution');
    xlim([0, 60]);

    fprintf('Running! Wave your hand in front of the sensor. Close figure to stop.\n');

    %% Main loop - MATLAB controls everything
    while ishandle(fig)
        % Read distance using ultrasonic trigger/echo
        dist = readUltrasonic(a);

        % Decide zone and set outputs
        if dist == 0
            setRGB(a, 0, 0, 0);
        elseif dist < VERY_CLOSE
            setRGB(a, 1, 0, 0);           % Red
            playTone(a, 'D8', 1000, 0.05);
        elseif dist < CLOSE
            setRGB(a, 1, 0, 0);           % Red
            playTone(a, 'D8', 800, 0.05);
            pause(0.1);
        elseif dist < MEDIUM
            setRGB(a, 1, 0.7, 0);         % Yellow
            playTone(a, 'D8', 400, 0.05);
            pause(0.3);
        else
            setRGB(a, 0, 1, 0);           % Green
        end

        % Update plot
        if ishandle(fig)
            distBar.YData = dist;
            if dist < VERY_CLOSE
                distBar.FaceColor = [1, 0, 0];
            elseif dist < CLOSE
                distBar.FaceColor = [1, 0.5, 0];
            elseif dist < MEDIUM
                distBar.FaceColor = [1, 1, 0];
            else
                distBar.FaceColor = [0, 1, 0];
            end

            histData(end+1) = dist; %#ok<AGROW>
            subplot(1, 2, 2);
            histogram(histData, 'BinWidth', 2, 'FaceColor', [0.3, 0.6, 1]);
            xlim([0, 60]);
            xlabel('Distance (cm)');
            ylabel('Frequency');
            title(sprintf('Distribution (%d samples)', length(histData)));

            drawnow;
        end

        pause(0.05);
    end

    % Cleanup
    setRGB(a, 0, 0, 0);
    writeDigitalPin(a, 'D8', 0);
    clear a;
    fprintf('Done. Arduino disconnected.\n');
end

%% Read ultrasonic distance
function dist = readUltrasonic(a)
    % Send 10us trigger pulse
    writeDigitalPin(a, 'D9', 0);
    pause(0.000002);
    writeDigitalPin(a, 'D9', 1);
    pause(0.00001);
    writeDigitalPin(a, 'D9', 0);

    % Measure echo (simplified - may need pulseIn equivalent)
    % Note: MATLAB Support Package has limited pulse timing accuracy.
    % For production, use the Ultrasonic add-on library or serial approach.
    tic;
    timeout = 0.03;  % 30ms max
    while readDigitalPin(a, 'D4') == 0
        if toc > timeout
            dist = 0;
            return;
        end
    end
    pulseStart = toc;
    while readDigitalPin(a, 'D4') == 1
        if toc > timeout
            dist = 0;
            return;
        end
    end
    pulseEnd = toc;

    duration = pulseEnd - pulseStart;
    dist = round(duration * 34300 / 2);  % cm
end

%% Set RGB LED color (0-1 range for PWM)
function setRGB(a, r, g, b)
    writePWMDutyCycle(a, 'D6', r);
    writePWMDutyCycle(a, 'D5', g);
    writePWMDutyCycle(a, 'D3', b);
end

%% Play tone (simplified - toggles pin)
function playTone(a, pin, ~, duration)
    writeDigitalPin(a, pin, 1);
    pause(duration);
    writeDigitalPin(a, pin, 0);
end
