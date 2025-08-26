% --- Simon Says Game Using Hybrid Sound Classification (Snap, Clap, Knock) ---
clear; clc;

% --- Serial Port Settings ---
serialPort = "COM3"; % Change to your ESP32 port
baudRate = 115200;
try
    s = serialport(serialPort, baudRate);
    pause(1); % Longer settle time
catch
    error('Could not connect to ESP32. Check serial port.');
end

% --- Game settings ---
maxLevel = 6; % Maximum sequence length
ledCmds = {'SNAP', 'CLAP', 'KNOCK'};
sounds = {'snap', 'clap', 'knock'}; % classifier output labels

% --- Load classifier features and calculate centroids ---
if exist('snap_clap_knock_features.mat', 'file')
    load('snap_clap_knock_features.mat', 'featureMat', 'labels');
else
    error('snap_clap_knock_features.mat not found.');
end

Fs = 44100; nBits = 16; nChannels = 1;

% --- Hybrid classification setup ---
SNAP_ENERGY_THRESHOLD = 0.0006;       % Snap energy threshold
IMPULSE_DURATION = 0.3;               % Impulse duration threshold (seconds)
unique_classes = unique(labels);
num_classes = numel(unique_classes);

centroids = zeros(num_classes, size(featureMat,2));
for k = 1:num_classes
    centroids(k,:) = mean(featureMat(strcmp(labels, unique_classes{k}), :), 1);
end

clap_knock_classes = {'clap', 'knock'};
clap_knock_centroids = zeros(2, size(featureMat,2));
for k = 1:2
    clap_knock_centroids(k,:) = mean(featureMat(strcmp(labels, clap_knock_classes{k}), :), 1);
end

% --- Amplitude threshold to avoid noise/silence ---
threshold = 0.02;

disp('=== Simon Says: Sound Edition (Hybrid Classifier with Impulse) ===');
disp('Replicate the LED sequence using your sounds!');
disp('Snap, Clap, or Knock');

level = 1;
gameOver = false;

while ~gameOver && level <= maxLevel
    % Generate a new random pattern of length 'level' for this round
    sequence = cell(1,level);
    for idx = 1:level
        sequence{idx} = sounds{randi(3)};
    end

    disp(['Level ', num2str(level), ': Watch the LED sequence!']);
    pause(1.5);

    % Show the sequence on ESP32 LEDs
    for i = 1:level
        writeline(s, ledCmds{strcmp(sounds, sequence{i})});
        pause(2.0);
        writeline(s, "OFF");
        pause(1.5);
    end

    disp('Now repeat the sequence with your sounds.');

    i = 1;
    while i <= level
        disp(['Sound ', num2str(i), ' of ', num2str(level)]);
        pause(2.0);

        % Keep asking for input until a valid one is detected
        detectedValidInput = false;
        while ~detectedValidInput
            recObj = audiorecorder(Fs, nBits, nChannels);
            disp('Perform your sound now!');
            recordblocking(recObj, 2.5);
            testAudio = getaudiodata(recObj);

         
            % --- Feature extraction for test sample ---
            zcrTest = sum(abs(diff(sign(testAudio)))) / length(testAudio);
            energyTest = sum(testAudio.^2) / length(testAudio);

            win = hamming(512);
            [S,F,~] = spectrogram(testAudio, win, 256, 512, Fs);
            S = abs(S);
            centroidTest = sum(F .* mean(S,2)) / sum(mean(S,2));
            spreadTest = sqrt(sum(((F - centroidTest).^2) .* mean(S,2)) / sum(mean(S,2)));
            psdTest = mean(S,2);
            psdTest_norm = psdTest / sum(psdTest);
            entropyTest = -sum(psdTest_norm .* log2(psdTest_norm + eps));
            testFeatures = [zcrTest, energyTest, centroidTest, spreadTest, entropyTest];

            % --- Impulse duration calculation ---
            peakAmp = max(abs(testAudio));
            ampThresh = 0.4 * peakAmp; % 40% of peak amplitude
            impulseSamples = find(abs(testAudio) > ampThresh);
            if ~isempty(impulseSamples)
                impulseDuration = (impulseSamples(end) - impulseSamples(1)) / Fs; % seconds
            else
                impulseDuration = 0;
            end

            % ===== HYBRID CLASSIFICATION LOGIC WITH INITIAL IMPULSE CHECK =====
            % First, check impulse duration for all sounds to filter noise
            if impulseDuration > IMPULSE_DURATION
                disp('Invalid input detected (too long). Try again.');
                continue; % Loop again for new input
            end
            
            % If impulse duration is acceptable, proceed with classification
            if energyTest < SNAP_ENERGY_THRESHOLD
                predictedLabel = 'snap';
                detectedValidInput = true;
            else
                clap_knock_distances = vecnorm(clap_knock_centroids - testFeatures, 2, 2);
                [~, minIdx] = min(clap_knock_distances);
                predictedLabel = clap_knock_classes{minIdx};
                detectedValidInput = true;
            end
        end

        disp(['Detected: ', char(predictedLabel)]);

        % Feedback LED on ESP32
        if strcmp(char(predictedLabel), 'snap')
            writeline(s, "SNAP");
        elseif strcmp(char(predictedLabel), 'clap')
            writeline(s, "CLAP");
        elseif strcmp(char(predictedLabel), 'knock')
            writeline(s, "KNOCK");
        else
            writeline(s, "OFF");
        end
        pause(1.0);
        writeline(s, "OFF");

        % Check correctness
        if ~strcmp(char(predictedLabel), sequence{i})
            disp('Incorrect! Game Over.');
            gameOver = true;
            break;
        end
        i = i + 1; % Only increment if input was valid
    end

    if ~gameOver
        disp('Correct sequence! Level up!');
        level = level + 1;
        pause(2.0);
    end
end

if ~gameOver
    disp('CONGRATULATIONS! ALL LEVELS ARE COMPLETED!');
    writeline(s, "WIN");
    pause(5.5);
    writeline(s, "OFF");
end

clear s % close serial port
disp('Game ended.');