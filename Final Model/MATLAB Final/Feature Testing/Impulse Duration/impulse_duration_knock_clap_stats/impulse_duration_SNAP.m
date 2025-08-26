% Calculate impulse duration for snap audio samples

numFiles = 30;
impulseDurations = zeros(numFiles,1);

basePath = 'C:/Users/ACER/Documents/MATLAB/MATLAB Final/Feature Testing/Impulse Duration/Samples/';


for i = 1:numFiles
    fname = fullfile(basePath, sprintf('snap_%02d.wav', i));
    if exist(fname, 'file')
        [audio, Fs] = audioread(fname);
        audio = audio(:,1); % Use first channel if stereo

        peakAmp = max(abs(audio));
        thresh = 0.4 * peakAmp; % 40% of peak amplitude

        impulseSamples = find(abs(audio) > thresh);

        if ~isempty(impulseSamples)
            % Duration in seconds
            impulseDurations(i) = (impulseSamples(end) - impulseSamples(1)) / Fs;
        else
            impulseDurations(i) = NaN;
        end
    else
        warning('File %s not found.', fname);
        impulseDurations(i) = NaN;
    end
end

% Display results
disp('Impulse durations (seconds) for snap files:');
disp(impulseDurations);

% Summary statistics
fprintf('Min impulse duration: %.4f sec\n', min(impulseDurations));
fprintf('Max impulse duration: %.4f sec\n', max(impulseDurations));
fprintf('Mean impulse duration: %.4f sec\n', mean(impulseDurations, 'omitnan'));

% Optional: plot durations
figure; plot(impulseDurations, 'o-');
xlabel('Sample Index'); ylabel('Impulse Duration (sec)');
title('Impulse Duration of Snap Samples');