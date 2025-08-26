% Test Simon Says Algorithm Against Sample Audio Files
% Current Date: 2025-08-26 04:49:15 UTC
% User: Thaariq19

clear; clc;
disp('=== Testing Simon Says Algorithm Against Sample Audio Files ===');
disp('Current Date: 2025-08-26 04:49:15 UTC');
disp('User: Thaariq19');
disp('');

%% Load classifier features and setup parameters
try
    if exist('snap_clap_knock_features.mat', 'file')
        load('snap_clap_knock_features.mat', 'featureMat', 'labels');
        disp('✓ Classifier data loaded successfully');
    else
        error('snap_clap_knock_features.mat not found.');
    end
catch ME
    disp('✗ Failed to load classifier data');
    disp(ME.message);
    return;
end

% Algorithm parameters (same as main game)
Fs = 44100; 
nBits = 16; 
nChannels = 1;
SNAP_ENERGY_THRESHOLD = 0.0006;
IMPULSE_DURATION = 0.3;
sounds = {'snap', 'clap', 'knock'};

% Calculate centroids
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

disp('✓ Algorithm parameters setup complete');
disp('');

%% Define test file specifications
testSpecs = struct();

% Snap files: snap_01.wav to snap_30.wav
testSpecs(1).type = 'snap';
testSpecs(1).prefix = 'snap_';
testSpecs(1).startNum = 1;
testSpecs(1).endNum = 30;
testSpecs(1).format = '%02d'; % Two digit format (01, 02, etc.)

% Clap files: clap_31.wav to clap_61.wav
testSpecs(2).type = 'clap';
testSpecs(2).prefix = 'clap_';
testSpecs(2).startNum = 31;
testSpecs(2).endNum = 61;
testSpecs(2).format = '%02d'; % Two digit format

% Knock files: knock_01.wav to knock_30.wav
testSpecs(3).type = 'knock';
testSpecs(3).prefix = 'knock_';
testSpecs(3).startNum = 1;
testSpecs(3).endNum = 30;
testSpecs(3).format = '%02d'; % Two digit format

%% Set sample base path (EDITED)
baseSamplePath = 'C:/Users/ACER/Documents/MATLAB/MATLAB Final/Feature Testing/Samples Accuracy Test/samples';

%% Test each file type
allResults = {};
totalFiles = 0;
totalCorrect = 0;
totalValid = 0;

fprintf('Starting tests...\n\n');

for specIdx = 1:length(testSpecs)
    spec = testSpecs(specIdx);
    expectedLabel = spec.type;
    
    fprintf('=== Testing %s files ===\n', upper(expectedLabel));
    
    % Results for this sound type
    typeResults = struct();
    typeResults.type = expectedLabel;
    typeResults.files = {};
    typeResults.predictions = {};
    typeResults.isValid = [];
    typeResults.isCorrect = [];
    typeResults.metrics = {};
    
    fileCount = 0;
    correctCount = 0;
    validCount = 0;
    
    % Test each file in the range
    for fileNum = spec.startNum:spec.endNum
        filename = fullfile(baseSamplePath, sprintf('%s%s.wav', spec.prefix, sprintf(spec.format, fileNum)));
        
        % Check if file exists
        if exist(filename, 'file')
            try
                % Load audio file
                [testAudio, fs] = audioread(filename);
                
                % Resample if necessary
                if fs ~= Fs
                    testAudio = resample(testAudio, Fs, fs);
                end
                
                % Ensure mono
                if size(testAudio, 2) > 1
                    testAudio = mean(testAudio, 2);
                end
                
                % Apply the same algorithm as the main game
                [predicted, isValid, metrics] = classifyAudioSample(testAudio, SNAP_ENERGY_THRESHOLD, IMPULSE_DURATION, clap_knock_centroids, clap_knock_classes, Fs);
                
                % Check correctness
                isCorrect = strcmp(predicted, expectedLabel) && isValid;
                
                % Store results
                fileCount = fileCount + 1;
                if isValid
                    validCount = validCount + 1;
                end
                if isCorrect
                    correctCount = correctCount + 1;
                end
                
                % Store detailed results
                typeResults.files{end+1} = filename;
                typeResults.predictions{end+1} = predicted;
                typeResults.isValid(end+1) = isValid;
                typeResults.isCorrect(end+1) = isCorrect;
                typeResults.metrics{end+1} = metrics;
                
                % Display result
                status = '✗';
                if isCorrect
                    status = '✓';
                elseif ~isValid
                    status = '⚠';
                end
                
                fprintf('%s %s: %s -> %s (Valid: %s)\n', status, filename, expectedLabel, predicted, mat2str(isValid));
                
            catch ME
                fprintf('✗ %s: Failed to process - %s\n', filename, ME.message);
            end
        else
            fprintf('⚠ %s: File not found\n', filename);
        end
    end
    
    % Summary for this type
    if fileCount > 0
        accuracy = correctCount / fileCount * 100;
        validRate = validCount / fileCount * 100;
        fprintf('\n%s Summary:\n', upper(expectedLabel));
        fprintf('  Files tested: %d\n', fileCount);
        fprintf('  Correct: %d (%.1f%%)\n', correctCount, accuracy);
        fprintf('  Valid: %d (%.1f%%)\n', validCount, validRate);
    else
        fprintf('\nNo %s files found!\n', expectedLabel);
    end
    
    % Add to overall results
    allResults{end+1} = typeResults;
    totalFiles = totalFiles + fileCount;
    totalCorrect = totalCorrect + correctCount;
    totalValid = totalValid + validCount;
    
    fprintf('\n');
end

%% Overall Results Analysis
disp('=== OVERALL RESULTS ===');
if totalFiles > 0
    overallAccuracy = totalCorrect / totalFiles * 100;
    overallValidRate = totalValid / totalFiles * 100;
    
    fprintf('Total files tested: %d\n', totalFiles);
    fprintf('Overall accuracy: %.1f%% (%d/%d correct)\n', overallAccuracy, totalCorrect, totalFiles);
    fprintf('Overall valid rate: %.1f%% (%d/%d valid)\n', overallValidRate, totalValid, totalFiles);
    
    % Detailed analysis by type
    fprintf('\nDetailed Analysis:\n');
    for i = 1:length(allResults)
        result = allResults{i};
        if ~isempty(result.files)
            typeFiles = length(result.files);
            typeCorrect = sum(result.isCorrect);
            typeValid = sum(result.isValid);
            
            fprintf('  %s: %.1f%% accuracy (%d/%d), %.1f%% valid (%d/%d)\n', ...
                upper(result.type), typeCorrect/typeFiles*100, typeCorrect, typeFiles, ...
                typeValid/typeFiles*100, typeValid, typeFiles);
        end
    end
    
    % Error analysis
    fprintf('\nError Analysis:\n');
    for i = 1:length(allResults)
        result = allResults{i};
        if ~isempty(result.files)
            wrongPredictions = result.predictions(~result.isCorrect);
            if ~isempty(wrongPredictions)
                [uniqueErrors, ~, idx] = unique(wrongPredictions);
                errorCounts = accumarray(idx, 1);
                fprintf('  %s misclassified as:\n', upper(result.type));
                for j = 1:length(uniqueErrors)
                    fprintf('    %s: %d times\n', uniqueErrors{j}, errorCounts(j));
                end
            end
        end
    end
    
else
    fprintf('No files were tested!\n');
end

%% Save results
saveChoice = input('\nSave detailed results to file? (y/n): ', 's');
if strcmpi(saveChoice, 'y')
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    resultFilename = sprintf('sample_test_results_%s.mat', timestamp);
    save(resultFilename, 'allResults', 'testSpecs', 'SNAP_ENERGY_THRESHOLD', 'IMPULSE_DURATION');
    fprintf('Results saved to: %s\n', resultFilename);
end

disp('');
disp('Testing completed!');

%% Classification function (same as main algorithm)
function [predictedLabel, isValid, metrics] = classifyAudioSample(testAudio, SNAP_ENERGY_THRESHOLD, IMPULSE_DURATION, clap_knock_centroids, clap_knock_classes, Fs)
    % Feature extraction for test sample
    zcrTest = sum(abs(diff(sign(testAudio)))) / length(testAudio);
    energyTest = sum(testAudio.^2) / length(testAudio);

    win = hamming(512);
    [S,F,~] = spectrogram(testAudio, win, 256, 512, Fs);
    S = abs(S);
    meanS = mean(S,2);
    if sum(meanS) == 0
        meanS = meanS + eps;
    end
    
    centroidTest = sum(F .* meanS) / sum(meanS);
    spreadTest = sqrt(sum(((F - centroidTest).^2) .* meanS) / sum(meanS));
    psdTest = meanS;
    psdTest_norm = psdTest / sum(psdTest);
    entropyTest = -sum(psdTest_norm .* log2(psdTest_norm + eps));
    testFeatures = [zcrTest, energyTest, centroidTest, spreadTest, entropyTest];

    % Impulse duration calculation
    peakAmp = max(abs(testAudio));
    ampThresh = 0.4 * peakAmp; % 40% of peak amplitude
    impulseSamples = find(abs(testAudio) > ampThresh);
    if ~isempty(impulseSamples)
        impulseDuration = (impulseSamples(end) - impulseSamples(1)) / Fs; % seconds
    else
        impulseDuration = 0;
    end

    % Store metrics
    metrics = struct();
    metrics.energy = energyTest;
    metrics.zcr = zcrTest;
    metrics.centroid = centroidTest;
    metrics.spread = spreadTest;
    metrics.entropy = entropyTest;
    metrics.impulseDuration = impulseDuration;
    metrics.peakAmplitude = peakAmp;

    % HYBRID CLASSIFICATION LOGIC (same as main game)
    % First, check impulse duration for all sounds to filter noise
    if impulseDuration > IMPULSE_DURATION
        predictedLabel = 'rejected_long';
        isValid = false;
        return;
    end
    
    % If impulse duration is acceptable, proceed with classification
    if energyTest < SNAP_ENERGY_THRESHOLD
        predictedLabel = 'snap';
        isValid = true;
    else
        clap_knock_distances = vecnorm(clap_knock_centroids - testFeatures, 2, 2);
        [~, minIdx] = min(clap_knock_distances);
        predictedLabel = clap_knock_classes{minIdx};
        isValid = true;
    end
end