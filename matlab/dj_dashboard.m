function dj_dashboard()
% DJ_DASHBOARD - MATLAB GUI for the DJ Lightboard Arduino project
%
% Controls an Arduino Mega running the dj_lightboard firmware over serial.
% Features:
%   - 9 animation buttons + shuffle mode
%   - Speed slider (1-9)
%   - RGB color sliders
%   - Live 8x8 matrix visualization
%   - Power toggle
%   - IR remote activity log
%
% Usage:
%   dj_dashboard()    % Auto-detects Arduino port
%
% Requirements:
%   - MATLAB R2022a+ with Instrument Control Toolbox
%   - Arduino running dj_lightboard.ino firmware

    %% --- Find and Connect to Arduino ---
    port = setup_arduino();
    s = serialport(port, 9600);
    configureTerminator(s, "LF");
    pause(2); % Wait for Arduino to reset after serial connection

    %% --- Create Main Figure ---
    fig = uifigure('Name', 'DJ Lightboard Dashboard', ...
        'Position', [100 100 900 620], ...
        'Color', [0.15 0.15 0.2], ...
        'CloseRequestFcn', @(~,~) closeDashboard(fig, s));

    %% --- Animation Buttons Panel ---
    animPanel = uipanel(fig, 'Title', 'Animations', ...
        'Position', [20 280 300 320], ...
        'BackgroundColor', [0.2 0.2 0.25], ...
        'ForegroundColor', 'w', 'FontSize', 14);

    animNames = {'Smiley', 'Heart', 'Rain', 'HI!', 'Star', ...
                 'Snake', 'Fireworks', 'Spinner', 'Arrows'};
    animEmojis = {':)', '<3', '~~', 'HI', '*', '~s~', '**', '(O)', '>>>'};
    animColors = {[1 0.8 0], [1 0 0], [0 0.3 1], [0 1 0], [1 1 1], ...
                  [0.7 0 1], [1 0.4 0], [0 1 1], [1 0 0.8]};

    for i = 1:9
        row = floor((i-1) / 3);
        col = mod((i-1), 3);
        btn = uibutton(animPanel, 'push', ...
            'Text', sprintf('%d: %s', i, animNames{i}), ...
            'Position', [10+col*95, 230-row*70, 88, 55], ...
            'BackgroundColor', animColors{i}, ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~) sendCommand(s, sprintf('A%d', i), logArea));
    end

    % Shuffle button
    uibutton(animPanel, 'push', ...
        'Text', '0: SHUFFLE', ...
        'Position', [10, 230-3*70, 280, 45], ...
        'BackgroundColor', [0.5 0.2 0.8], ...
        'FontColor', 'w', 'FontSize', 13, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(~,~) sendCommand(s, 'A10', logArea));

    %% --- Speed Control ---
    speedPanel = uipanel(fig, 'Title', 'Speed', ...
        'Position', [340 480 240 120], ...
        'BackgroundColor', [0.2 0.2 0.25], ...
        'ForegroundColor', 'w', 'FontSize', 14);

    speedLabel = uilabel(speedPanel, 'Text', 'Speed: 5', ...
        'Position', [80, 60, 80, 25], ...
        'FontColor', 'w', 'FontSize', 14, 'FontWeight', 'bold');

    uislider(speedPanel, ...
        'Position', [20 35 200 3], ...
        'Limits', [1 9], 'Value', 5, ...
        'MajorTicks', 1:9, ...
        'ValueChangedFcn', @(sld,~) speedChanged(s, sld, speedLabel, logArea));

    %% --- RGB Color Control ---
    rgbPanel = uipanel(fig, 'Title', 'RGB Color', ...
        'Position', [340 280 240 190], ...
        'BackgroundColor', [0.2 0.2 0.25], ...
        'ForegroundColor', 'w', 'FontSize', 14);

    colorPreview = uilamp(rgbPanel, 'Position', [170, 120, 50, 50], 'Color', 'k');

    sliderR = createColorSlider(rgbPanel, 'R', [1 0.3 0.3], 120);
    sliderG = createColorSlider(rgbPanel, 'G', [0.3 1 0.3], 75);
    sliderB = createColorSlider(rgbPanel, 'B', [0.3 0.3 1], 30);

    uibutton(rgbPanel, 'push', 'Text', 'Send Color', ...
        'Position', [20 0 200 28], ...
        'BackgroundColor', [0.4 0.4 0.5], 'FontColor', 'w', ...
        'ButtonPushedFcn', @(~,~) sendColor(s, sliderR, sliderG, sliderB, colorPreview, logArea));

    %% --- Power Button ---
    uibutton(fig, 'push', ...
        'Text', 'POWER', ...
        'Position', [340 230 240 40], ...
        'BackgroundColor', [0.8 0.1 0.1], ...
        'FontColor', 'w', 'FontSize', 14, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(~,~) sendCommand(s, 'P', logArea));

    %% --- 8x8 Matrix Visualization ---
    matrixPanel = uipanel(fig, 'Title', 'LED Matrix (Live)', ...
        'Position', [600 280 280 320], ...
        'BackgroundColor', [0.1 0.1 0.15], ...
        'ForegroundColor', 'w', 'FontSize', 14);

    matrixAx = uiaxes(matrixPanel, 'Position', [15 15 250 270]);
    matrixAx.Color = [0.05 0.05 0.08];
    matrixAx.XLim = [0.5 8.5]; matrixAx.YLim = [0.5 8.5];
    matrixAx.XTick = []; matrixAx.YTick = [];
    matrixAx.XColor = 'none'; matrixAx.YColor = 'none';
    hold(matrixAx, 'on');

    % Create 8x8 grid of patch objects for the LED visualization
    ledPatches = gobjects(8, 8);
    for r = 1:8
        for c = 1:8
            ledPatches(r,c) = rectangle(matrixAx, ...
                'Position', [c-0.4, 9-r-0.4, 0.8, 0.8], ...
                'Curvature', [0.3 0.3], ...
                'FaceColor', [0.1 0.1 0.1], ...
                'EdgeColor', [0.2 0.2 0.2]);
        end
    end

    %% --- Activity Log ---
    logPanel = uipanel(fig, 'Title', 'Activity Log', ...
        'Position', [20 20 860 200], ...
        'BackgroundColor', [0.2 0.2 0.25], ...
        'ForegroundColor', 'w', 'FontSize', 14);

    logArea = uitextarea(logPanel, ...
        'Position', [10 10 840 160], ...
        'BackgroundColor', [0.1 0.1 0.12], ...
        'FontColor', [0 1 0], 'FontSize', 11, ...
        'FontName', 'Courier New', ...
        'Editable', 'off', ...
        'Value', {'[Dashboard] Connected to Arduino on ' + string(port), ...
                  '[Dashboard] Ready! Press IR remote buttons or use the controls above.'});

    %% --- Serial Read Callback for Arduino Status Updates ---
    configureCallback(s, "terminator", ...
        @(src, ~) processArduinoStatus(src, logArea, ledPatches, ...
            speedLabel, colorPreview, animNames));

    % Query initial state
    writeline(s, '?');
end

%% --- Helper Functions ---

function sld = createColorSlider(parent, label, color, yPos)
    uilabel(parent, 'Text', label, ...
        'Position', [5, yPos, 20, 22], ...
        'FontColor', color, 'FontSize', 13, 'FontWeight', 'bold');
    sld = uislider(parent, ...
        'Position', [30 yPos+12 130 3], ...
        'Limits', [0 255], 'Value', 0, ...
        'MajorTicks', [0 128 255]);
end

function sendCommand(s, cmd, logArea)
    try
        writeline(s, cmd);
        appendLog(logArea, sprintf('[MATLAB -> Arduino] %s', cmd));
    catch e
        appendLog(logArea, sprintf('[ERROR] %s', e.message));
    end
end

function speedChanged(s, sld, speedLabel, logArea)
    spd = round(sld.Value);
    sld.Value = spd;
    speedLabel.Text = sprintf('Speed: %d', spd);
    sendCommand(s, sprintf('S%d', spd), logArea);
end

function sendColor(s, sliderR, sliderG, sliderB, colorPreview, logArea)
    r = round(sliderR.Value);
    g = round(sliderG.Value);
    b = round(sliderB.Value);
    colorPreview.Color = [r/255, g/255, b/255];
    sendCommand(s, sprintf('C%d,%d,%d', r, g, b), logArea);
end

function processArduinoStatus(src, logArea, ledPatches, speedLabel, colorPreview, animNames)
    try
        data = readline(src);
        if strlength(data) == 0 || ~startsWith(data, 'S')
            return;
        end

        % Parse: S<anim>,<r>:<g>:<b>,<speed>,<power>
        parts = split(extractAfter(data, 1), ',');
        if length(parts) < 4
            return;
        end

        anim = str2double(parts{1});
        rgbParts = split(parts{2}, ':');
        r = str2double(rgbParts{1});
        g = str2double(rgbParts{2});
        b = str2double(rgbParts{3});
        spd = str2double(parts{3});
        pwr = str2double(parts{4});

        % Update speed label
        speedLabel.Text = sprintf('Speed: %d', spd);

        % Update color preview
        colorPreview.Color = [r/255, g/255, b/255];

        % Build log message
        if pwr == 0
            msg = '[Arduino] Power OFF';
        elseif anim == 0
            msg = '[Arduino] Idle';
        elseif anim == 10
            msg = sprintf('[Arduino] Shuffle mode | RGB(%d,%d,%d) | Speed %d', r, g, b, spd);
        elseif anim >= 1 && anim <= 9
            msg = sprintf('[Arduino] %s | RGB(%d,%d,%d) | Speed %d', animNames{anim}, r, g, b, spd);
        else
            msg = sprintf('[Arduino] Unknown anim %d', anim);
        end
        appendLog(logArea, msg);

        % Update matrix visualization with a simple preview pattern
        updateMatrixPreview(ledPatches, anim, pwr, r, g, b);

    catch e
        appendLog(logArea, sprintf('[ERROR] %s', e.message));
    end
end

function updateMatrixPreview(ledPatches, anim, pwr, r, g, b)
    % Show a static preview of the current animation on the GUI matrix
    onColor = [r/255, g/255, b/255];
    offColor = [0.08 0.08 0.08];

    if pwr == 0 || anim == 0
        for row = 1:8
            for col = 1:8
                ledPatches(row, col).FaceColor = offColor;
            end
        end
        return;
    end

    % Simple static preview patterns for each animation
    patterns = {
        % 1: Smiley
        [0 0 1 1 1 1 0 0; 0 1 0 0 0 0 1 0; 1 0 1 0 0 1 0 1;
         1 0 0 0 0 0 0 1; 1 0 1 0 0 1 0 1; 1 0 0 1 1 0 0 1;
         0 1 0 0 0 0 1 0; 0 0 1 1 1 1 0 0];
        % 2: Heart
        [0 1 1 0 0 1 1 0; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1;
         1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 0 1 1 1 1 1 1 0;
         0 0 1 1 1 1 0 0; 0 0 0 1 1 0 0 0];
        % 3: Rain
        [1 0 0 1 0 0 0 0; 0 0 0 0 0 1 0 0; 0 1 0 0 0 0 0 1;
         0 0 0 1 0 0 0 0; 1 0 0 0 0 0 1 0; 0 0 1 0 0 0 0 0;
         0 0 0 0 1 0 0 0; 0 1 0 0 0 1 0 0];
        % 4: HI
        [1 0 0 0 0 1 0 0; 1 0 0 0 0 1 0 0; 1 0 0 0 0 1 0 0;
         1 1 1 1 1 1 0 0; 1 0 0 0 0 1 0 0; 1 0 0 0 0 1 0 0;
         1 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0];
        % 5: Star
        [1 0 0 1 0 0 1 0; 0 1 0 1 0 1 0 0; 0 0 1 1 1 0 0 0;
         1 1 1 1 1 1 1 0; 0 0 1 1 1 0 0 0; 0 1 0 1 0 1 0 0;
         1 0 0 1 0 0 1 0; 0 0 0 0 0 0 0 0];
        % 6: Snake
        [1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 1;
         0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0;
         0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0];
        % 7: Fireworks
        [1 0 0 0 0 0 0 1; 0 1 0 0 0 0 1 0; 0 0 1 0 0 1 0 0;
         0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0; 0 0 1 0 0 1 0 0;
         0 1 0 0 0 0 1 0; 1 0 0 0 0 0 0 1];
        % 8: Spinner
        [0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0;
         1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0;
         0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0];
        % 9: Arrows (up)
        [0 0 0 1 1 0 0 0; 0 0 1 1 1 1 0 0; 0 1 1 1 1 1 1 0;
         1 1 0 1 1 0 1 1; 0 0 0 1 1 0 0 0; 0 0 0 1 1 0 0 0;
         0 0 0 1 1 0 0 0; 0 0 0 1 1 0 0 0];
    };

    if anim == 10
        anim = mod(floor(now * 86400), 9) + 1; % rotating preview
    end

    if anim >= 1 && anim <= 9
        pat = patterns{anim};
        for row = 1:8
            for col = 1:8
                if pat(row, col) == 1
                    ledPatches(row, col).FaceColor = onColor;
                else
                    ledPatches(row, col).FaceColor = offColor;
                end
            end
        end
    end
end

function appendLog(logArea, msg)
    timestamp = datestr(now, 'HH:MM:SS');
    newLine = sprintf('[%s] %s', timestamp, msg);
    currentLog = logArea.Value;
    logArea.Value = [currentLog; {newLine}];
    scroll(logArea, 'bottom');
end

function closeDashboard(fig, s)
    try
        writeline(s, 'P'); % Power off on close
        pause(0.5);
        clear s;
    catch
    end
    delete(fig);
end
