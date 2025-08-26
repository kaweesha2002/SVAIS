% Calculate impulse duration for knock and clap audio samples

Fs = 44100; % Or use audioread's output for each file
numKnock = 30;
numClap = 30; % For clap_31.wav to clap_60.wav

impulseDurationsKnock = zeros(numKnock,1);
impulseDurationsClap = zeros(numClap,1);

basePath = 'C:/Users/ACER/Documents/MATLAB/MATLAB Final/Feature Testing/Impulse Duration/Samples/';

% Knock files: knock_01.wav to knock_30.wav
for i = 1:numKnock
    fname = fullfile(basePath, sprintf('knock_%02d.wav', i));
    if exist(fname, 'file')
        [audio, Fs] = audioread(fname);
        audio = audio(:,1); % Use first channel if stereo
        peakAmp = max(abs(audio));
        thresh = 0.4 * peakAmp; % 40% of peak amplitude
        impulseSamples = find(abs(audio) > thresh);
        if ~isempty(impulseSamples)
            impulseDurationsKnock(i) = (impulseSamples(end) - impulseSamples(1)) / Fs;
        else
            impulseDurationsKnock(i) = NaN;
        end
    else
        warning('File %s not found.', fname);
        impulseDurationsKnock(i) = NaN;
    end
end

% Clap files: clap_31.wav to clap_60.wav
for i = 31:60
    fname = fullfile(basePath, sprintf('clap_%02d.wav', i));
    idx = i-30;
    if exist(fname, 'file')
        [audio, Fs] = audioread(fname);
        audio = audio(:,1); % Use first channel if stereo
        peakAmp = max(abs(audio));
        thresh = 0.4 * peakAmp; % 40% of peak amplitude
        impulseSamples = find(abs(audio) > thresh);
        if ~isempty(impulseSamples)
            impulseDurationsClap(idx) = (impulseSamples(end) - impulseSamples(1)) / Fs;
        else
            impulseDurationsClap(idx) = NaN;
        end
    else
        warning('File %s not found.', fname);
        impulseDurationsClap(idx) = NaN;
    end
end

disp('Impulse durations (seconds) for knock files:');
disp(impulseDurationsKnock);
fprintf('Knock: Min %.4f, Max %.4f, Mean %.4f\n', min(impulseDurationsKnock,[],'omitnan'), ...
        max(impulseDurationsKnock,[],'omitnan'), mean(impulseDurationsKnock,'omitnan'));

disp('Impulse durations (seconds) for clap files:');
disp(impulseDurationsClap);
fprintf('Clap: Min %.4f, Max %.4f, Mean %.4f\n', min(impulseDurationsClap,[],'omitnan'), ...
        max(impulseDurationsClap,[],'omitnan'), mean(impulseDurationsClap,'omitnan'));

% Optional plots
figure; plot(impulseDurationsKnock, 'o-'); xlabel('Knock Sample'); ylabel('Impulse Duration (sec)');
title('Impulse Duration of Knock Samples');

figure; plot(31:60, impulseDurationsClap, 'o-'); xlabel('Clap Sample'); ylabel('Impulse Duration (sec)');
title('Impulse Duration of Clap Samples (31-60)');