% Simple Sound Classifier Test (Snap, Clap, Knock)
% No sequence, just one sound input and output check

clear; clc;

% --- Load classifier and features ---
load('snap_clap_knock_features.mat', 'featureMat', 'labels');
labelsCat = categorical(labels, {'snap','clap','knock'});
Mdl = fitcknn(featureMat, labelsCat);

Fs = 44100; nBits = 16; nChannels = 1;
threshold = 0.02; % Amplitude threshold to filter silence

disp('Sound Classifier Test');
disp('Perform one of: Snap, Clap, or Knock');
pause(1);

recObj = audiorecorder(Fs, nBits, nChannels);
disp('Perform your sound now!');
recordblocking(recObj, 2.0);
testAudio = getaudiodata(recObj);

maxAmp = max(abs(testAudio));
if maxAmp < threshold
    disp('No input detected or input too weak!');
    predictedLabel = 'none';
else
    % --- Feature extraction ---
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

    predictedLabel = predict(Mdl, testFeatures);
end

disp(['Classifier output: ', char(predictedLabel)]);