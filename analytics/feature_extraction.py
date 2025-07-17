import os
import numpy as np
import wave
import csv
from signal_tools import compute_fft, compute_rms, compute_zcr, compute_spectral_centroid

def extract_features(audio_file):
    """Extract features from an audio file."""
    with wave.open(audio_file, 'rb') as wf:
        n_channels = wf.getnchannels()
        sample_rate = wf.getframerate()
        n_frames = wf.getnframes()
        audio_data = wf.readframes(n_frames)
        audio_signal = np.frombuffer(audio_data, dtype=np.int16)

        if n_channels > 1:
            audio_signal = audio_signal[::n_channels]  # Convert to mono

        # Compute features
        fft_result = compute_fft(audio_signal)
        rms_value = compute_rms(audio_signal)
        zcr_value = compute_zcr(audio_signal)
        spectral_centroid_value = compute_spectral_centroid(audio_signal, sample_rate)

        return {
            'fft': fft_result,
            'rms': rms_value,
            'zcr': zcr_value,
            'spectral_centroid': spectral_centroid_value
        }

def log_features_to_csv(features, output_csv):
    """Log extracted features to a CSV file."""
    with open(output_csv, mode='a', newline='') as csvfile:
        fieldnames = ['fft', 'rms', 'zcr', 'spectral_centroid']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write header only if the file is empty
        if os.stat(output_csv).st_size == 0:
            writer.writeheader()

        writer.writerow(features)

def process_audio_directory(input_dir, output_csv):
    """Process all audio files in a directory and log features."""
    for filename in os.listdir(input_dir):
        if filename.endswith('.wav'):
            audio_file = os.path.join(input_dir, filename)
            features = extract_features(audio_file)
            log_features_to_csv(features, output_csv)

if __name__ == "__main__":
    input_directory = 'SVAIS\data\Clap Sounds'  # Adjust path as necessary
    output_csv_file = 'SVAIS\tests\test_results_round1.csv'  # Adjust path as necessary
    process_audio_directory(input_directory, output_csv_file)