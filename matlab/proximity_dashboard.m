function proximity_dashboard()
% PROXIMITY_DASHBOARD - Live MATLAB dashboard for the Proximity Alert project
%
% Connects to the Arduino over serial and displays:
%   - Real-time scrolling distance plot
%   - Zone indicator (green/yellow/red) with current distance
%   - Distance gauge visualization
%   - Adjustable threshold sliders
%   - Data logging with CSV export
%
% Usage:
%   1. Upload proximity_alert.ino to your Arduino
%   2. Close VS Code Serial Monitor (only one app can use the port)
%   3. Run: proximity_dashboard()
%
% Requirements: MATLAB R2022a+ with Instrument Control Toolbox (serialport)

    %% Find Arduino port
    port = find_arduino_port();
    if isempty(port)
        error('Arduino not found. Check USB connection and close any Serial Monitors.');
    end
    fprintf('Found Arduino on: %s\n', port);

    %% Configuration
    BAUD_RATE = 9600;
    MAX_POINTS = 200;       % Number of points to show on plot
    UPDATE_RATE = 0.05;     % Seconds between reads

    % Default thresholds (matching Arduino firmware)
    thresholds.veryClose = 5;
    thresholds.close = 15;
    thresholds.medium = 30;

    %% Data storage
    distances = nan(1, MAX_POINTS);
    timestamps = nan(1, MAX_POINTS);
    logData = [];       % For CSV export
    startTime = tic;
    isRunning = true;

    %% Create figure
    fig = uifigure('Name', 'Proximity Alert Dashboard', ...
        'Position', [100, 100, 1000, 650], ...
        'CloseRequestFcn', @onClose);

    % Main grid layout
    mainGrid = uigridlayout(fig, [3, 3]);
    mainGrid.RowHeight = {'2x', '1x', 'fit'};
    mainGrid.ColumnWidth = {'3x', '1x', '1x'};

    %% Panel 1: Live distance plot (top-left, spans 2 columns)
    plotPanel = uipanel(mainGrid, 'Title', 'Live Distance (cm)');
    plotPanel.Layout.Row = 1;
    plotPanel.Layout.Column = [1, 2];
    ax = uiaxes(plotPanel, 'Position', [10, 10, 580, 200]);
    ax.YLim = [0, 60];
    ax.XLim = [0, MAX_POINTS];
    ax.YLabel.String = 'Distance (cm)';
    ax.XLabel.String = 'Samples';
    ax.Title.String = 'Ultrasonic Sensor Reading';
    hold(ax, 'on');
    ax.XGrid = 'on';
    ax.YGrid = 'on';

    % Threshold lines on plot
    yline(ax, thresholds.veryClose, 'r--', 'Very Close', 'LineWidth', 1.5);
    yline(ax, thresholds.close, 'Color', [1, 0.5, 0], 'LineStyle', '--', ...
        'Label', 'Close', 'LineWidth', 1.5);
    yline(ax, thresholds.medium, 'g--', 'Medium', 'LineWidth', 1.5);

    % Plot line
    distLine = plot(ax, 1:MAX_POINTS, distances, 'b-', 'LineWidth', 2);

    %% Panel 2: Zone indicator (top-right)
    zonePanel = uipanel(mainGrid, 'Title', 'Current Zone');
    zonePanel.Layout.Row = 1;
    zonePanel.Layout.Column = 3;

    zoneGrid = uigridlayout(zonePanel, [3, 1]);
    zoneGrid.RowHeight = {'1x', 'fit', 'fit'};

    % Large distance number
    distLabel = uilabel(zoneGrid, 'Text', '-- cm', ...
        'FontSize', 36, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % Zone name
    zoneLabel = uilabel(zoneGrid, 'Text', 'Waiting...', ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % Zone description
    zoneDesc = uilabel(zoneGrid, 'Text', 'Point sensor at an object', ...
        'FontSize', 12, ...
        'HorizontalAlignment', 'center');

    %% Panel 3: Gauge (middle-left)
    gaugePanel = uipanel(mainGrid, 'Title', 'Distance Gauge');
    gaugePanel.Layout.Row = 2;
    gaugePanel.Layout.Column = 1;

    gaugeAx = uiaxes(gaugePanel, 'Position', [10, 5, 400, 120]);
    gaugeAx.XLim = [0, 60];
    gaugeAx.YLim = [0, 1];
    gaugeAx.YTick = [];
    gaugeAx.XLabel.String = 'Distance (cm)';
    gaugeAx.Title.String = '';
    hold(gaugeAx, 'on');

    % Colored zones on gauge
    fill(gaugeAx, [0, thresholds.veryClose, thresholds.veryClose, 0], ...
        [0, 0, 1, 1], [1, 0, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    fill(gaugeAx, [thresholds.veryClose, thresholds.close, thresholds.close, thresholds.veryClose], ...
        [0, 0, 1, 1], [1, 0.5, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    fill(gaugeAx, [thresholds.close, thresholds.medium, thresholds.medium, thresholds.close], ...
        [0, 0, 1, 1], [1, 1, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    fill(gaugeAx, [thresholds.medium, 60, 60, thresholds.medium], ...
        [0, 0, 1, 1], [0, 1, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    % Gauge needle
    gaugeNeedle = plot(gaugeAx, [0, 0], [0, 1], 'k-', 'LineWidth', 3);

    %% Panel 4: Stats (middle-center)
    statsPanel = uipanel(mainGrid, 'Title', 'Statistics');
    statsPanel.Layout.Row = 2;
    statsPanel.Layout.Column = 2;

    statsGrid = uigridlayout(statsPanel, [5, 1]);
    statsGrid.RowHeight = repmat({'fit'}, 1, 5);

    statMin = uilabel(statsGrid, 'Text', 'Min: --', 'FontSize', 12);
    statMax = uilabel(statsGrid, 'Text', 'Max: --', 'FontSize', 12);
    statAvg = uilabel(statsGrid, 'Text', 'Avg: --', 'FontSize', 12);
    statSamples = uilabel(statsGrid, 'Text', 'Samples: 0', 'FontSize', 12);
    statRate = uilabel(statsGrid, 'Text', 'Rate: -- Hz', 'FontSize', 12);

    %% Panel 5: Controls (middle-right)
    ctrlPanel = uipanel(mainGrid, 'Title', 'Controls');
    ctrlPanel.Layout.Row = 2;
    ctrlPanel.Layout.Column = 3;

    ctrlGrid = uigridlayout(ctrlPanel, [4, 1]);
    ctrlGrid.RowHeight = repmat({'fit'}, 1, 4);

    % Export button
    exportBtn = uibutton(ctrlGrid, 'Text', 'Export CSV', ...
        'ButtonPushedFcn', @onExport);

    % Clear button
    clearBtn = uibutton(ctrlGrid, 'Text', 'Clear Plot', ...
        'ButtonPushedFcn', @onClear);

    % Pause/Resume button
    pauseBtn = uibutton(ctrlGrid, 'Text', 'Pause', ...
        'ButtonPushedFcn', @onPause);

    % Status
    statusLabel = uilabel(ctrlGrid, 'Text', 'Connecting...', ...
        'FontSize', 10, 'FontColor', [0.5, 0.5, 0.5]);

    %% Bottom status bar
    statusBar = uilabel(mainGrid, 'Text', 'Initializing...', ...
        'FontSize', 11);
    statusBar.Layout.Row = 3;
    statusBar.Layout.Column = [1, 3];

    %% Connect to Arduino
    try
        s = serialport(port, BAUD_RATE);
        configureTerminator(s, "LF");
        flush(s);
        statusLabel.Text = 'Connected';
        statusLabel.FontColor = [0, 0.6, 0];
        statusBar.Text = sprintf('Connected to %s @ %d baud | Dashboard running', port, BAUD_RATE);
    catch e
        statusLabel.Text = 'Error';
        statusLabel.FontColor = [1, 0, 0];
        statusBar.Text = sprintf('Connection failed: %s', e.message);
        return;
    end

    % Wait for Arduino startup message
    pause(2);
    flush(s);

    %% Main loop using timer
    sampleCount = 0;
    isPaused = false;

    t = timer('ExecutionMode', 'fixedRate', ...
        'Period', UPDATE_RATE, ...
        'TimerFcn', @readSerial);
    start(t);

    %% Nested functions

    function readSerial(~, ~)
        if ~isRunning || isPaused
            return;
        end

        try
            while s.NumBytesAvailable > 0
                line = readline(s);
                line = char(line);

                % Parse "Distance: XX cm"
                tokens = regexp(line, 'Distance:\s*(\d+)\s*cm', 'tokens');
                if ~isempty(tokens)
                    dist = str2double(tokens{1}{1});
                    sampleCount = sampleCount + 1;

                    % Update rolling buffer
                    distances = [distances(2:end), dist];
                    timestamps = [timestamps(2:end), toc(startTime)];

                    % Log for export
                    logData(end+1, :) = [toc(startTime), dist]; %#ok<AGROW>

                    % Update plot
                    distLine.YData = distances;

                    % Update zone indicator
                    updateZone(dist);

                    % Update gauge
                    gaugeNeedle.XData = [dist, dist];

                    % Update stats
                    validDist = distances(~isnan(distances));
                    if ~isempty(validDist)
                        statMin.Text = sprintf('Min: %.0f cm', min(validDist));
                        statMax.Text = sprintf('Max: %.0f cm', max(validDist));
                        statAvg.Text = sprintf('Avg: %.1f cm', mean(validDist));
                    end
                    statSamples.Text = sprintf('Samples: %d', sampleCount);
                    elapsed = toc(startTime);
                    if elapsed > 0
                        statRate.Text = sprintf('Rate: %.1f Hz', sampleCount / elapsed);
                    end
                end
            end
        catch
            % Serial read error - ignore (port may have disconnected)
        end
    end

    function updateZone(dist)
        if dist == 0
            distLabel.Text = '-- cm';
            zoneLabel.Text = 'No Reading';
            zoneLabel.FontColor = [0.5, 0.5, 0.5];
            zoneDesc.Text = 'Sensor out of range';
            zonePanel.BackgroundColor = [0.94, 0.94, 0.94];
        elseif dist < thresholds.veryClose
            distLabel.Text = sprintf('%d cm', dist);
            zoneLabel.Text = 'VERY CLOSE';
            zoneLabel.FontColor = [1, 0, 0];
            zoneDesc.Text = 'Red LED + Continuous tone';
            zonePanel.BackgroundColor = [1, 0.8, 0.8];
        elseif dist < thresholds.close
            distLabel.Text = sprintf('%d cm', dist);
            zoneLabel.Text = 'CLOSE';
            zoneLabel.FontColor = [0.8, 0.2, 0];
            zoneDesc.Text = 'Red LED + Fast beep';
            zonePanel.BackgroundColor = [1, 0.9, 0.8];
        elseif dist < thresholds.medium
            distLabel.Text = sprintf('%d cm', dist);
            zoneLabel.Text = 'MEDIUM';
            zoneLabel.FontColor = [0.8, 0.6, 0];
            zoneDesc.Text = 'Yellow LED + Slow beep';
            zonePanel.BackgroundColor = [1, 1, 0.8];
        else
            distLabel.Text = sprintf('%d cm', dist);
            zoneLabel.Text = 'SAFE';
            zoneLabel.FontColor = [0, 0.6, 0];
            zoneDesc.Text = 'Green LED + Silent';
            zonePanel.BackgroundColor = [0.8, 1, 0.8];
        end
    end

    function onExport(~, ~)
        if isempty(logData)
            uialert(fig, 'No data to export yet.', 'Export');
            return;
        end
        [file, path] = uiputfile('proximity_log.csv', 'Save Data');
        if file ~= 0
            T = array2table(logData, 'VariableNames', {'Time_s', 'Distance_cm'});
            writetable(T, fullfile(path, file));
            statusBar.Text = sprintf('Exported %d samples to %s', size(logData, 1), file);
        end
    end

    function onClear(~, ~)
        distances = nan(1, MAX_POINTS);
        timestamps = nan(1, MAX_POINTS);
        distLine.YData = distances;
        sampleCount = 0;
        logData = [];
        startTime = tic;
        statusBar.Text = 'Plot cleared';
    end

    function onPause(~, ~)
        isPaused = ~isPaused;
        if isPaused
            pauseBtn.Text = 'Resume';
            statusBar.Text = 'Paused - data not being recorded';
        else
            pauseBtn.Text = 'Pause';
            statusBar.Text = 'Resumed';
        end
    end

    function onClose(~, ~)
        isRunning = false;
        try
            stop(t);
            delete(t);
        catch
        end
        try
            clear s;
        catch
        end
        delete(fig);
    end
end

%% Helper: find Arduino port
function port = find_arduino_port()
    port = '';
    if ismac
        ports = serialportlist("available");
        idx = contains(ports, 'usbmodem');
        if any(idx)
            port = ports(find(idx, 1));
            return;
        end
    elseif ispc
        ports = serialportlist("available");
        idx = contains(ports, 'COM');
        if any(idx)
            port = ports(find(idx, 1));
            return;
        end
    else
        ports = serialportlist("available");
        idx = contains(ports, {'ttyACM', 'ttyUSB'});
        if any(idx)
            port = ports(find(idx, 1));
            return;
        end
    end
end
