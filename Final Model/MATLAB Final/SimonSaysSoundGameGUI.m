classdef SimonSaysSoundGameGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        
        % Main panels
        HeaderPanel         matlab.ui.container.Panel
        GamePanel           matlab.ui.container.Panel
        ControlPanel        matlab.ui.container.Panel
        StatusPanel         matlab.ui.container.Panel
        
        % Header components
        TitleLabel          matlab.ui.control.Label
        SubtitleLabel       matlab.ui.control.Label
        GameIcon            matlab.ui.control.Label
        
        % Game display components
        LevelDisplay        matlab.ui.control.Label
        LevelNumber         matlab.ui.control.Label
        
        % Sound visualization
        SoundVisPanel       matlab.ui.container.Panel
        SnapIndicator       matlab.ui.control.Label
        ClapIndicator       matlab.ui.control.Label
        KnockIndicator      matlab.ui.control.Label
        DetectedSound       matlab.ui.control.Label
        
        % Control components
        PlayButton          matlab.ui.control.Button
        SerialPortDropDown  matlab.ui.control.DropDown
        SerialStatusLamp    matlab.ui.control.Lamp
        SerialPortLabel     matlab.ui.control.Label
        
        % Status and feedback
        GameStatusLabel     matlab.ui.control.Label
        ProgressBar         matlab.ui.control.Slider
        InstructionLabel    matlab.ui.control.Label
        ScoreLabel          matlab.ui.control.Label
    end

    properties (Access = private)
        serialObj
        connected = false
        gameRunning = false
        maxLevel = 6
        ledCmds = {'SNAP','CLAP','KNOCK'}
        sounds = {'snap','clap','knock'}
        soundColors = {[255, 255, 0]/255, [255, 0, 0]/255, [0, 255, 0]/255} % Yellow for Snap, Red for Clap, Green for Knock
        Fs = 44100
        nBits = 16
        nChannels = 1
        SNAP_ENERGY_THRESHOLD = 0.0006
        IMPULSE_DURATION = 0.3
        classifier_loaded = false
        centroids
        clap_knock_centroids
        clap_knock_classes = {'clap','knock'}
        stopFlag = false
        currentLevel = 0
        currentSequence = {}
        animationTimer
        pulseState = false
    end

    methods (Access = private)
        function startupFcn(app)
            % Initialize serial ports
            app.SerialPortDropDown.Items = serialportlist("available");
            if ~isempty(app.SerialPortDropDown.Items)
                app.SerialPortDropDown.Value = app.SerialPortDropDown.Items{1};
            end
            
            % Setup initial state
            app.SerialStatusLamp.Color = [0.8 0.2 0.2];
            app.GameStatusLabel.Text = "Ready to Play Simon Says!";
            app.LevelNumber.Text = "0";
            app.DetectedSound.Text = "Press PLAY to start...";
            app.ScoreLabel.Text = "Score: 0";
            app.ProgressBar.Value = 0;
            app.InstructionLabel.Text = "Select COM port and click PLAY to begin the game!";
            
            % Auto-connect to ESP32
            autoConnectSerial(app);
            
            % Setup animations
            setupAnimations(app);
            
            % Apply modern styling
            applyModernStyling(app);
            
            % Load classifier on startup
            loadClassifier(app);
        end

        function autoConnectSerial(app)
            try
                if ~isempty(app.SerialPortDropDown.Items)
                    app.serialObj = serialport(app.SerialPortDropDown.Value, 115200);
                    configureTerminator(app.serialObj,"LF");
                    pause(2);
                    
                    app.connected = true;
                    app.SerialStatusLamp.Color = [0.2, 0.8, 0.2]; % green
                    app.GameStatusLabel.Text = sprintf('ESP32 Connected: %s', app.SerialPortDropDown.Value);
                    app.GameStatusLabel.FontColor = [0.2, 0.8, 0.2];
                    
                    % Quick LED test
                    sendSerial(app, 'SNAP');
                    pause(0.5);
                    sendSerial(app, 'OFF');
                end
            catch
                app.connected = false;
                app.SerialStatusLamp.Color = [0.8, 0.2, 0.2];
                app.GameStatusLabel.Text = 'ESP32 not connected - Check COM port';
                app.GameStatusLabel.FontColor = [0.8, 0.2, 0.2];
            end
        end

        function applyModernStyling(app)
            % Main figure
            app.UIFigure.Color = [0.05, 0.05, 0.1]; % Very dark blue
            
            % Header panel
            app.HeaderPanel.BackgroundColor = [0.1, 0.15, 0.25];
            app.TitleLabel.FontSize = 32;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [1, 1, 1];
            app.TitleLabel.FontName = 'Arial Black';
            
            app.SubtitleLabel.FontSize = 14;
            app.SubtitleLabel.FontColor = [0.7, 0.8, 1];
            app.SubtitleLabel.FontName = 'Arial';
            
            app.GameIcon.FontSize = 40;
            app.GameIcon.Text = '🎵';
            
            % Game panel
            app.GamePanel.BackgroundColor = [0.08, 0.12, 0.2];
            
            % Level display
            app.LevelDisplay.FontSize = 18;
            app.LevelDisplay.FontWeight = 'bold';
            app.LevelDisplay.FontColor = [0.3, 0.7, 1];
            app.LevelDisplay.FontName = 'Arial';
            
            app.LevelNumber.FontSize = 48;
            app.LevelNumber.FontWeight = 'bold';
            app.LevelNumber.FontColor = [1, 1, 1];
            app.LevelNumber.FontName = 'Arial Black';
            
            % Sound indicators
            setupSoundIndicators(app);
            
            % Control panel
            app.ControlPanel.BackgroundColor = [0.1, 0.14, 0.22];
            
            % Single PLAY button - Large and prominent
            app.PlayButton.BackgroundColor = [0.1, 0.8, 0.3]; % Bright green
            app.PlayButton.FontColor = [1, 1, 1];
            app.PlayButton.FontWeight = 'bold';
            app.PlayButton.FontName = 'Arial Black';
            app.PlayButton.FontSize = 18;
            app.PlayButton.Text = '▶️ PLAY SIMON SAYS';
            
            % Serial port label
            app.SerialPortLabel.FontSize = 12;
            app.SerialPortLabel.FontWeight = 'bold';
            app.SerialPortLabel.FontColor = [0.8, 0.9, 1];
            app.SerialPortLabel.FontName = 'Arial';
            app.SerialPortLabel.Text = 'COM Port:';
            
            % Status elements
            app.GameStatusLabel.FontSize = 16;
            app.GameStatusLabel.FontWeight = 'bold';
            app.GameStatusLabel.FontColor = [0.4, 0.9, 0.4];
            app.GameStatusLabel.FontName = 'Arial';
            
            app.InstructionLabel.FontSize = 14;
            app.InstructionLabel.FontColor = [0.8, 0.9, 1];
            app.InstructionLabel.FontName = 'Arial';
            
            app.ScoreLabel.FontSize = 16;
            app.ScoreLabel.FontWeight = 'bold';
            app.ScoreLabel.FontColor = [1, 0.8, 0.2];
            app.ScoreLabel.FontName = 'Arial';
            
            % Progress bar
            app.ProgressBar.FontColor = [1, 1, 1];
        end

        function setupSoundIndicators(app)
            % Snap indicator - Yellow
            app.SnapIndicator.BackgroundColor = app.soundColors{1};
            app.SnapIndicator.Text = 'SNAP';
            app.SnapIndicator.FontSize = 14;
            app.SnapIndicator.FontWeight = 'bold';
            app.SnapIndicator.FontColor = [0, 0, 0];
            app.SnapIndicator.HorizontalAlignment = 'center';
            
            % Clap indicator - Red
            app.ClapIndicator.BackgroundColor = app.soundColors{2};
            app.ClapIndicator.Text = 'CLAP';
            app.ClapIndicator.FontSize = 14;
            app.ClapIndicator.FontWeight = 'bold';
            app.ClapIndicator.FontColor = [1, 1, 1];
            app.ClapIndicator.HorizontalAlignment = 'center';
            
            % Knock indicator - Green
            app.KnockIndicator.BackgroundColor = app.soundColors{3};
            app.KnockIndicator.Text = 'KNOCK';
            app.KnockIndicator.FontSize = 14;
            app.KnockIndicator.FontWeight = 'bold';
            app.KnockIndicator.FontColor = [1, 1, 1];
            app.KnockIndicator.HorizontalAlignment = 'center';
            
            % Detected sound display
            app.DetectedSound.FontSize = 20;
            app.DetectedSound.FontWeight = 'bold';
            app.DetectedSound.FontColor = [1, 1, 1];
            app.DetectedSound.HorizontalAlignment = 'center';
        end

        function setupAnimations(app)
            app.animationTimer = timer('TimerFcn', @(~,~)pulseAnimation(app), ...
                                     'Period', 0.5, 'ExecutionMode', 'fixedRate');
        end

        function pulseAnimation(app)
            app.pulseState = ~app.pulseState;
            if app.pulseState
                app.LevelNumber.FontColor = [1, 1, 1];
            else
                app.LevelNumber.FontColor = [0.7, 0.7, 0.7];
            end
        end

        function highlightSoundIndicator(app, soundType, duration)
            indicators = {app.SnapIndicator, app.ClapIndicator, app.KnockIndicator};
            soundIdx = find(strcmp(app.sounds, soundType));
            
            if ~isempty(soundIdx)
                originalColor = indicators{soundIdx}.BackgroundColor;
                originalFontColor = indicators{soundIdx}.FontColor;
                
                indicators{soundIdx}.BackgroundColor = [1, 1, 1];
                indicators{soundIdx}.FontColor = [0, 0, 0];
                
                pause(duration);
                indicators{soundIdx}.BackgroundColor = originalColor;
                indicators{soundIdx}.FontColor = originalFontColor;
            end
        end

        function sendSerial(app, cmd)
            if app.connected && ~isempty(app.serialObj) && isvalid(app.serialObj)
                try
                    writeline(app.serialObj, string(cmd));
                    flush(app.serialObj);
                catch
                    app.connected = false;
                    app.SerialStatusLamp.Color = [0.8, 0.2, 0.2];
                end
            end
        end

        function loadClassifier(app)
            try
                S = load('snap_clap_knock_features.mat','featureMat','labels');
                featureMat = S.featureMat; 
                labels = S.labels;
                
                unique_classes = unique(labels);
                num_classes = numel(unique_classes);
                app.centroids = zeros(num_classes, size(featureMat,2));
                for k = 1:num_classes
                    app.centroids(k,:) = mean(featureMat(strcmp(labels, unique_classes{k}), :), 1);
                end
                
                app.clap_knock_centroids = zeros(2, size(featureMat,2));
                for k = 1:2
                    app.clap_knock_centroids(k,:) = mean(featureMat(strcmp(labels, app.clap_knock_classes{k}), :), 1);
                end
                
                app.classifier_loaded = true;
            catch
                app.classifier_loaded = false;
            end
        end

        function runGame(app)
            app.currentLevel = 1;
            app.LevelNumber.Text = '1';
            app.DetectedSound.Text = 'Starting...';
            app.ScoreLabel.Text = 'Score: 0';
            app.ProgressBar.Value = 0;
            app.GameStatusLabel.Text = 'Game in progress...';
            app.GameStatusLabel.FontColor = [0.2, 0.6, 1];
            app.stopFlag = false;
            app.gameRunning = true;
            app.PlayButton.Text = '⏹️ STOP GAME';
            app.PlayButton.BackgroundColor = [0.8, 0.2, 0.2]; % Red for stop

            start(app.animationTimer);

            level = 1;
            gameOver = false;
            score = 0;

            app.InstructionLabel.Text = 'Watch the LED sequence carefully and memorize it!';

            while ~gameOver && (level <= app.maxLevel) && ~app.stopFlag
                sequence = cell(1,level);
                for idx = 1:level
                    sequence{idx} = app.sounds{randi(3)};
                end
                
                app.currentSequence = sequence;
                app.LevelNumber.Text = num2str(level);
                app.InstructionLabel.Text = sprintf('Level %d: Watch the LED sequence!', level);
                app.ProgressBar.Value = ((level-1) / app.maxLevel) * 100;
                
                drawnow;
                pause(2); % Initial pause before showing sequence

                % Display sequence with ONLY LED feedback
                for i = 1:level
                    if app.stopFlag, break; end
                    
                    app.InstructionLabel.Text = sprintf('LED Pattern %d of %d', i, level);
                    
                    ledCmd = app.ledCmds{strcmp(app.sounds, sequence{i})};
                    sendSerial(app, ledCmd);
                    highlightSoundIndicator(app, sequence{i}, 1.5);
                    sendSerial(app, "OFF");
                    
                    if i < level
                        pause(1); % Pause between sequence items
                    end
                end
                
                if app.stopFlag, break; end

                app.InstructionLabel.Text = 'Now repeat the sequence with your sounds!';
                pause(1.5); % Pause before starting input phase

                i = 1;
                while i <= level && ~app.stopFlag
                    % Show "Get ready" message with delay for sequence > 2
                    if level > 2 && i > 1
                        app.InstructionLabel.Text = 'Get ready for next sound...';
                        app.DetectedSound.Text = 'Get ready...';
                        drawnow;
                        pause(2); % 2 second delay before next input
                    end
                    
                    app.InstructionLabel.Text = sprintf('Sound %d of %d - Make your sound now!', i, level);
                    app.DetectedSound.Text = 'Listening...';
                    drawnow;

                    % Classification logic
                    detectedValidInput = false;
                    while ~detectedValidInput && ~app.stopFlag
                        recObj = audiorecorder(app.Fs, app.nBits, app.nChannels);
                        recordblocking(recObj, 2.5);
                        testAudio = getaudiodata(recObj);

                        % Calculate features
                        zcrTest = sum(abs(diff(sign(testAudio)))) / max(numel(testAudio),1);
                        energyTest = sum(testAudio.^2) / max(numel(testAudio),1);

                        % Spectral features
                        win = hamming(512);
                        [S,F,~] = spectrogram(testAudio, win, 256, 512, app.Fs);
                        S = abs(S);
                        mS = mean(S,2);
                        if sum(mS)==0
                            mS = mS + eps;
                        end
                        centroidTest = sum(F .* mS) / sum(mS);
                        spreadTest = sqrt(sum(((F - centroidTest).^2) .* mS) / sum(mS));
                        psdTest = mS; 
                        psdTest_norm = psdTest / sum(psdTest);
                        entropyTest = -sum(psdTest_norm .* log2(psdTest_norm + eps));
                        testFeatures = [zcrTest, energyTest, centroidTest, spreadTest, entropyTest];

                        % Calculate impulse duration
                        peakAmp = max(abs(testAudio));
                        ampThresh = 0.4 * peakAmp;
                        impulseSamples = find(abs(testAudio) > ampThresh);
                        if ~isempty(impulseSamples)
                            impulseDuration = (impulseSamples(end) - impulseSamples(1)) / app.Fs;
                        else
                            impulseDuration = 0;
                        end

                        % Hybrid classification logic
                        if impulseDuration > app.IMPULSE_DURATION
                            disp('Invalid input detected (too long). Try again.');
                            continue;
                        end
                        
                        if energyTest < app.SNAP_ENERGY_THRESHOLD
                            predictedLabel = 'snap';
                            detectedValidInput = true;
                        else
                            clap_knock_distances = vecnorm(app.clap_knock_centroids - testFeatures, 2, 2);
                            [~, minIdx] = min(clap_knock_distances);
                            predictedLabel = app.clap_knock_classes{minIdx};
                            detectedValidInput = true;
                        end
                    end

                    if app.stopFlag, break; end

                    app.DetectedSound.Text = upper(predictedLabel);
                    app.DetectedSound.FontColor = [0.2, 0.8, 0.2];
                    
                    % LED feedback for detected sound
                    ledCmd = app.ledCmds{strcmp(app.sounds, predictedLabel)};
                    sendSerial(app, ledCmd);
                    highlightSoundIndicator(app, predictedLabel, 1.0);
                    sendSerial(app, "OFF");

                    if ~strcmp(predictedLabel, sequence{i})
                        app.InstructionLabel.Text = '❌ Incorrect sequence! Game Over.';
                        app.InstructionLabel.FontColor = [0.8, 0.2, 0.2];
                        app.GameStatusLabel.Text = sprintf('Game Over - Final Score: %d points', score);
                        app.GameStatusLabel.FontColor = [0.8, 0.2, 0.2];
                        gameOver = true;
                        break;
                    else
                        score = score + 10;
                        app.ScoreLabel.Text = sprintf('Score: %d', score);
                        
                        % Brief positive feedback
                        app.DetectedSound.Text = '✅ Correct!';
                        pause(1);
                    end
                    i = i + 1;
                end

                if ~gameOver && ~app.stopFlag
                    app.InstructionLabel.Text = '✅ Perfect! Moving to next level...';
                    app.InstructionLabel.FontColor = [0.2, 0.8, 0.2];
                    level = level + 1;
                    pause(2.5);
                    app.InstructionLabel.FontColor = [0.8, 0.9, 1];
                end
            end

            % Game end cleanup
            stop(app.animationTimer);
            app.LevelNumber.FontColor = [1, 1, 1];
            app.gameRunning = false;
            app.PlayButton.Text = '▶️ PLAY SIMON SAYS';
            app.PlayButton.BackgroundColor = [0.1, 0.8, 0.3]; % Back to green

            if ~gameOver && ~app.stopFlag
                app.InstructionLabel.Text = '🎉 CONGRATULATIONS! Perfect score achieved!';
                app.InstructionLabel.FontColor = [1, 0.8, 0.2];
                app.GameStatusLabel.Text = sprintf('🏆 CHAMPION! Final Score: %d points', score);
                app.GameStatusLabel.FontColor = [1, 0.8, 0.2];
                app.ProgressBar.Value = 100;
                
                sendSerial(app, "WIN");
                pause(5.5);
                sendSerial(app, "OFF");
            end

            if app.stopFlag
                app.InstructionLabel.Text = 'Game stopped by player.';
                app.GameStatusLabel.Text = 'Game stopped - Click PLAY to try again';
                app.GameStatusLabel.FontColor = [0.8, 0.8, 0.2];
                sendSerial(app, "OFF");
            end
        end
    end

    % Callbacks that handle component events
    methods (Access = private)
        function PlayButtonPushed(app, event)
            if ~app.gameRunning
                % Start game
                if ~app.classifier_loaded
                    loadClassifier(app);
                    if ~app.classifier_loaded
                        uialert(app.UIFigure, 'Audio classifier file "snap_clap_knock_features.mat" not found.', 'Classifier Error');
                        return;
                    end
                end
                
                if ~app.connected
                    % Try to reconnect
                    autoConnectSerial(app);
                    if ~app.connected
                        uialert(app.UIFigure, 'ESP32 not connected. Check COM port and try again.', 'Connection Required');
                        return;
                    end
                end
                
                runGame(app);
            else
                % Stop game
                app.stopFlag = true;
                if ~isempty(app.animationTimer) && isvalid(app.animationTimer)
                    stop(app.animationTimer);
                end
                sendSerial(app, "OFF");
            end
        end

        function SerialPortDropDownValueChanged(app, event)
            if ~app.gameRunning
                autoConnectSerial(app);
            end
        end
    end

    % Component initialization
    methods (Access = private)
        function createComponents(app)
            % Main figure
            app.UIFigure = uifigure('Position', [100 100 900 520], 'Name', 'Simon Says: Sound Edition - By Thaariq19 (August 2025)');

            % Header Panel
            app.HeaderPanel = uipanel(app.UIFigure, ...
                'Position', [0 430 900 90], ...
                'BorderType', 'none');
            
            app.GameIcon = uilabel(app.HeaderPanel, ...
                'Position', [20 20 60 50]);
            
            app.TitleLabel = uilabel(app.HeaderPanel, ...
                'Position', [90 35 500 40], ...
                'Text', 'SIMON SAYS: SOUND EDITION');
            
            app.SubtitleLabel = uilabel(app.HeaderPanel, ...
                'Position', [90 15 500 20], ...
                'Text', 'Watch LEDs, Listen, Repeat! - Created by Thaariq19 (August 25, 2025)');

            % Game Panel
            app.GamePanel = uipanel(app.UIFigure, ...
                'Position', [20 150 860 270], ...
                'BorderType', 'line');

            % Level Display
            app.LevelDisplay = uilabel(app.GamePanel, ...
                'Position', [30 220 100 30], ...
                'Text', 'LEVEL');
            
            app.LevelNumber = uilabel(app.GamePanel, ...
                'Position', [30 150 100 70], ...
                'Text', '0', ...
                'HorizontalAlignment', 'center');

            % Sound Visualization Panel
            app.SoundVisPanel = uipanel(app.GamePanel, ...
                'Position', [160 80 520 140], ...
                'BorderType', 'line');

            app.SnapIndicator = uilabel(app.SoundVisPanel, ...
                'Position', [60 70 120 50], ...
                'Text', 'SNAP');
            
            app.ClapIndicator = uilabel(app.SoundVisPanel, ...
                'Position', [200 70 120 50], ...
                'Text', 'CLAP');
            
            app.KnockIndicator = uilabel(app.SoundVisPanel, ...
                'Position', [340 70 120 50], ...
                'Text', 'KNOCK');
            
            app.DetectedSound = uilabel(app.SoundVisPanel, ...
                'Position', [20 20 480 40], ...
                'Text', 'Press PLAY to start the game');

            % Score and Progress
            app.ScoreLabel = uilabel(app.GamePanel, ...
                'Position', [720 220 120 30], ...
                'Text', 'Score: 0');
            
            app.ProgressBar = uislider(app.GamePanel, ...
                'Position', [720 170 120 3], ...
                'Limits', [0 100], ...
                'Value', 0);

            % Control Panel - Simplified with only one button
            app.ControlPanel = uipanel(app.UIFigure, ...
                'Position', [20 80 860 60], ...
                'BorderType', 'line');

            % Serial port controls (minimal)
            app.SerialPortLabel = uilabel(app.ControlPanel, ...
                'Position', [30 30 70 20]);
            
            app.SerialPortDropDown = uidropdown(app.ControlPanel, ...
                'Position', [100 25 120 25], ...
                'Items', {'COM3'}, 'Value', 'COM3', ...
                'ValueChangedFcn', @(src,event)SerialPortDropDownValueChanged(app, event));
            
            app.SerialStatusLamp = uilamp(app.ControlPanel, ...
                'Position', [230 32 12 12]);

            % Single large PLAY button
            app.PlayButton = uibutton(app.ControlPanel, 'push', ...
                'Position', [350 15 400 35], ...
                'ButtonPushedFcn', @(src,event)PlayButtonPushed(app, event));

            % Status Panel
            app.StatusPanel = uipanel(app.UIFigure, ...
                'Position', [20 20 860 50], ...
                'BorderType', 'none');

            app.GameStatusLabel = uilabel(app.StatusPanel, ...
                'Position', [20 25 400 20], ...
                'Text', 'Ready to Play Simon Says!');
            
            app.InstructionLabel = uilabel(app.StatusPanel, ...
                'Position', [20 5 700 20], ...
                'Text', 'Select COM port and click PLAY to begin the game!');
        end
    end

    methods (Access = public)
        function app = SimonSaysSoundGameGUI
            createComponents(app)
            startupFcn(app)
        end
        
        function delete(app)
            if ~isempty(app.animationTimer) && isvalid(app.animationTimer)
                stop(app.animationTimer);
                delete(app.animationTimer);
            end
            if ~isempty(app.serialObj) && isvalid(app.serialObj)
                delete(app.serialObj);
            end
        end
    end
end