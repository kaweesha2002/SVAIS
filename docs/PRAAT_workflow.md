# PRAAT Workflow for SVAIS Project

## Overview
This document outlines the workflow for utilizing the Praat software for audio analysis within the SVAIS (Smart Voice-based Acoustic Intelligent System) project. Praat is a powerful tool for phonetic analysis and can be used to extract various features from audio recordings, which are essential for our sound event detection tasks.

## Installation
1. Download Praat from the official website: [Praat Download](http://www.fon.hum.uva.nl/praat/download_win.html).
2. Install the software following the provided instructions for your operating system.

## Workflow Steps

### 1. Importing Audio Files
- Open Praat and select `Read` > `Read from file...` to import your audio files (e.g., from the `/data/raw/` directory).
- Choose the appropriate WAV file you wish to analyze.

### 2. Visualizing the Audio Signal
- Once the audio file is loaded, select it in the Objects window and click on `View & Edit`.
- This will open the waveform and spectrogram view, allowing you to visually inspect the audio signal.

### 3. Extracting Features
- To extract features such as pitch, intensity, and formants, use the following steps:
  - Select the audio object and navigate to `Analyze` > `Get pitch...` to obtain pitch values.
  - For intensity, select `Analyze` > `Get intensity...`.
  - To analyze formants, use `Analyze` > `Get formant...`.

### 4. Saving Extracted Data
- After extracting the desired features, you can save the results:
  - Select the relevant data in the output window and copy it.
  - Paste it into a text file or a CSV file for further analysis in Python.

### 5. Comparing Features
- Use the extracted features to compare different audio samples (e.g., claps vs. non-claps).
- Visualize the data using tools like Python's `matplotlib` for better insights.

### 6. Documenting Insights
- Keep a log of your findings and observations in the `/docs/insights.md` file.
- Note any patterns, anomalies, or interesting results that arise during your analysis.

## Conclusion
Using Praat effectively can significantly enhance the feature extraction process for the SVAIS project. By following this workflow, you can ensure that your audio analysis is systematic and well-documented, contributing to the overall goals of the project.