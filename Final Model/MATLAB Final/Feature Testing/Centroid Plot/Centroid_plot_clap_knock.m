% Hybrid Snap/Clap/Knock Classification and Snap Impulse Detection Demo
% - Classifies a sound as snap, clap, or knock using energy threshold and nearest centroid
% - Detects snap impulses and visualizes waveform and envelope

clear; clc;

%% === HYBRID SNAP/CLAP/KNOCK CLASSIFICATION ===

Fs = 44100;      % Sample rate
nBits = 16;      % Bit depth
nChannels = 1;   % Mono

SNAP_ENERGY_THRESHOLD = 0.00030; % Threshold for snap classification

% Load features and labels (snap_clap_knock_features.mat must exist)
if exist('snap_clap_knock_features.mat', 'file')
    load('snap_clap_knock_features.mat', 'featureMat', 'labels');
else
    error('snap_clap_knock_features.mat not found.');
end

unique_classes = unique(labels);
num_classes = numel(unique_classes);

% Centroids for all classes
centroids = zeros(num_classes, size(featureMat,2));
for k = 1:num_classes
    centroids(k,:) = mean(featureMat(strcmp(labels, unique_classes{k}), :), 1);
end

% Centroids for clap/knock only
clap_knock_classes = {'clap', 'knock'};
clap_knock_centroids = zeros(2, size(featureMat,2));
for k = 1:2
    clap_knock_centroids(k,:) = mean(featureMat(strcmp(labels, clap_knock_classes{k}), :), 1);
end

% PCA for visualization
[coeff,score,~,~,explained] = pca(featureMat);
labelsCat = categorical(labels, {'snap', 'clap', 'knock'});
centroid_scores = (centroids - mean(featureMat)) * coeff(:,1:2);

% Record test sample
disp('---- Hybrid Sound Classification Test ----');
disp('Get ready...');
pause(1);
recObj = audiorecorder(Fs, nBits, nChannels);
disp('Please make a sound (snap, clap, knock, etc) now!');
recordblocking(recObj, 2);
audioData = getaudiodata(recObj);

% Check amplitude
threshold = 0.02;
maxAmp = max(abs(audioData));

if maxAmp < threshold
    disp('No input detected.');
else
    % Feature extraction
    zcrTest = sum(abs(diff(sign(audioData)))) / length(audioData);
    energyTest = sum(audioData.^2) / length(audioData);
    win = hamming(512);
    [S,F,~] = spectrogram(audioData, win, 256, 512, Fs);
    S = abs(S);
    centroidTest = sum(F .* mean(S,2)) / sum(mean(S,2));
    spreadTest = sqrt(sum(((F - centroidTest).^2) .* mean(S,2)) / sum(mean(S,2)));
    psdTest = mean(S,2);
    psdTest_norm = psdTest / sum(psdTest);
    entropyTest = -sum(psdTest_norm .* log2(psdTest_norm + eps));
    testFeatures = [zcrTest, energyTest, centroidTest, spreadTest, entropyTest];

    % Hybrid classification
    if energyTest < SNAP_ENERGY_THRESHOLD
        predictedLabel = 'snap';
        classificationMethod = 'Energy threshold';
        disp(['Energy: ', num2str(energyTest), ' (below threshold ', num2str(SNAP_ENERGY_THRESHOLD), ')']);
        disp(['Classified as: snap (using energy threshold)']);
    else
        clap_knock_distances = vecnorm(clap_knock_centroids - testFeatures, 2, 2);
        [~, minIdx] = min(clap_knock_distances);
        predictedLabel = clap_knock_classes{minIdx};
        classificationMethod = 'Centroid classifier';
        disp(['Energy: ', num2str(energyTest), ' (above threshold ', num2str(SNAP_ENERGY_THRESHOLD), ')']);
        disp(['Classified as: ', predictedLabel, ' (using centroid classifier)']);
    end

    % PCA Visualization
    testScore = (testFeatures - mean(featureMat)) * coeff(:,1:2);
    figure('Name','Hybrid Classification PCA Visualization');
    if strcmp(predictedLabel, 'snap')
        subplot(2,1,1);
        gscatter(score(:,1), score(:,2), labelsCat, 'rgb', 'xo');
        hold on;
        plot(testScore(1), testScore(2), 'ks', 'MarkerSize', 14, 'LineWidth', 3, 'DisplayName', 'Test Sample');
        plot(centroid_scores(:,1), centroid_scores(:,2), 'p', 'MarkerSize', 18, 'LineWidth', 3, ...
            'MarkerFaceColor','yellow', 'MarkerEdgeColor','k', 'DisplayName', 'Centroids');
        xlabel(['PC1 (' num2str(explained(1),'%.1f') '%)']);
        ylabel(['PC2 (' num2str(explained(2),'%.1f') '%)']);
        legend('Snap', 'Clap', 'Knock', 'Test Sample', 'Centroids');
        title(['PCA Space - Classified as: ' predictedLabel ' (energy threshold)']);
        grid on;

        subplot(2,1,2);
        bar(1, energyTest, 'FaceColor', 'b');
        hold on;
        line([0.5, 1.5], [SNAP_ENERGY_THRESHOLD, SNAP_ENERGY_THRESHOLD], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
        hold off;
        ylabel('Energy');
        title(['Energy: ' num2str(energyTest) ' (Threshold: ' num2str(SNAP_ENERGY_THRESHOLD) ')']);
        set(gca, 'XTick', []);
        legend('Sound Energy', 'Snap Threshold');
        grid on;
    else
        gscatter(score(:,1), score(:,2), labelsCat, 'rgb', 'xo');
        hold on;
        plot(testScore(1), testScore(2), 'ks', 'MarkerSize', 14, 'LineWidth', 3, 'DisplayName', 'Test Sample');
        plot(centroid_scores(:,1), centroid_scores(:,2), 'p', 'MarkerSize', 18, 'LineWidth', 3, ...
            'MarkerFaceColor','yellow', 'MarkerEdgeColor','k', 'DisplayName', 'Centroids');
        clap_idx = find(strcmp(unique_classes, 'clap'));
        knock_idx = find(strcmp(unique_classes, 'knock'));
        plot([testScore(1), centroid_scores(clap_idx,1)], [testScore(2), centroid_scores(clap_idx,2)], ...
            'g--', 'LineWidth', 1.5, 'DisplayName', 'Distance to Clap');
        plot([testScore(1), centroid_scores(knock_idx,1)], [testScore(2), centroid_scores(knock_idx,2)], ...
            'b--', 'LineWidth', 1.5, 'DisplayName', 'Distance to Knock');
        clap_dist = norm(testScore - centroid_scores(clap_idx,:));
        knock_dist = norm(testScore - centroid_scores(knock_idx,:));
        xlabel(['PC1 (' num2str(explained(1),'%.1f') '%)']);
        ylabel(['PC2 (' num2str(explained(2),'%.1f') '%)']);
        legend('Snap', 'Clap', 'Knock', 'Test Sample', 'Centroids', 'Distance to Clap', 'Distance to Knock');
        title({['Hybrid Classification: ' predictedLabel ' (energy > threshold, centroid)'], ...
               ['Distances in PCA space - Clap: ' num2str(clap_dist,'%.2f') ', Knock: ' num2str(knock_dist,'%.2f')]});
        grid on;
        annotation('textbox', [0.15, 0.01, 0.7, 0.05], 'String', ...
            ['Energy: ' num2str(energyTest) ', Threshold: ' num2str(SNAP_ENERGY_THRESHOLD) ...
             ' (Not a snap - using centroid classifier)'], ...
            'HorizontalAlignment', 'center', 'BackgroundColor', 'white');
    end
end

%% === SNAP IMPULSE DETECTION DEMO ===

% Parameters
useAudioFile = false;
audioFile = 'test.wav';
recDur = 2.0;

% Acquire audio
if useAudioFile
    if ~exist(audioFile, 'file')
        error('Audio file %s not found.', audioFile);
    end
    [x, f0] = audioread(audioFile);
    if size(x,2) > 1, x = mean(x,2); end
    if f0 ~= Fs, x = resample(x, Fs, f0); end
else
    recObj = audiorecorder(Fs, 16, 1);
    disp('Recording... Make a snap.');
    recordblocking(recObj, recDur);
    x = getaudiodata(recObj);
end

% Snap impulse detection function
[isSnap, onsetTime, peakTime, idxOnset, idxPeak, env, t] = detect_snap_impulse( ...
    x, Fs, 'Band', [1000 7000], 'SmoothMs', 8, 'K', 10, ...
    'MinPeakDistance', 0.05, 'MinPeakProm', 0.02, 'AmpGate', 0.01);

% Report
if isSnap
    fprintf('Impulse detected. Onset: %.4f s, Peak: %.4f s\n', onsetTime, peakTime);
else
    fprintf('No snap impulse detected above threshold.\n');
end

% Plot waveform and envelope
figure('Name','Snap Impulse Detection');
t = (0:numel(x)-1)/Fs;

subplot(2,1,1);
plot(t, x, 'b-'); grid on; xlim([0 max(t)+eps]);
ylabel('Amplitude'); title('Waveform');
if isSnap
    yl = ylim;
    line([onsetTime onsetTime], yl, 'Color','m', 'LineStyle','--', 'LineWidth',1.5);
    line([peakTime peakTime], yl, 'Color','r', 'LineStyle','--', 'LineWidth',1.5);
    legend('x(t)','Onset','Peak');
end

subplot(2,1,2);
plot(t, env, 'k-'); grid on; xlim([0 max(t)+eps]);
xlabel('Time (s)'); ylabel('Envelope');
title('Smoothed Envelope');
if isSnap
    yl = ylim;
    line([onsetTime onsetTime], yl, 'Color','m', 'LineStyle','--', 'LineWidth',1.5);
    line([peakTime peakTime], yl, 'Color','r', 'LineStyle','--', 'LineWidth',1.5);
    legend('env(t)','Onset','Peak');
end

%% === DETECT_SNAP_IMPULSE FUNCTION ===
function [isSnap, onsetTime, peakTime, idxOnset, idxPeak, env, t] = detect_snap_impulse(x, Fs, varargin)
% Detects impulse (snap) in an audio signal and returns onset/peak times and envelope.
% Optional name-value args:
%  'Band' [low high], 'SmoothMs', 'K', 'MinPeakDistance', 'MinPeakProm', 'AmpGate'

% Parse args
p = inputParser;
addParameter(p, 'Band', [1000 7000]);
addParameter(p, 'SmoothMs', 8);
addParameter(p, 'K', 10);
addParameter(p, 'MinPeakDistance', 0.05);
addParameter(p, 'MinPeakProm', 0.02);
addParameter(p, 'AmpGate', 0.01);
parse(p, varargin{:});
Band = p.Results.Band;
SmoothMs = p.Results.SmoothMs;
K = p.Results.K;
MinPeakDistance = p.Results.MinPeakDistance;
MinPeakProm = p.Results.MinPeakProm;
AmpGate = p.Results.AmpGate;

% Bandpass filter
if ~isempty(Band)
    d = designfilt('bandpassiir','FilterOrder',4,...
        'HalfPowerFrequency1',Band(1),'HalfPowerFrequency2',Band(2),...
        'SampleRate',Fs);
    x = filtfilt(d, x);
end

% Envelope calculation
xAbs = abs(x);
envWin = round(Fs*SmoothMs/1000);
env = movmean(xAbs, envWin);

% Normalize envelope
env = env / max(env + eps);

% Find peaks in envelope above AmpGate
[pk, locs, w, p] = findpeaks(env, 'MinPeakDistance', round(MinPeakDistance*Fs), ...
    'MinPeakProminence', MinPeakProm);

validIdx = find(pk > AmpGate);
isSnap = ~isempty(validIdx);

if isSnap
    idxPeak = locs(validIdx(1));
    peakTime = idxPeak / Fs;
    % Onset: find where envelope rises above 10% of peak before peak
    onsetIdxCandidates = find(env(1:idxPeak) > 0.1*pk(validIdx(1)));
    if ~isempty(onsetIdxCandidates)
        idxOnset = onsetIdxCandidates(1);
    else
        idxOnset = max(1, idxPeak-10);
    end
    onsetTime = idxOnset / Fs;
else
    onsetTime = NaN;
    peakTime = NaN;
    idxOnset = NaN;
    idxPeak = NaN;
end

t = (0:numel(x)-1)/Fs;
end