# Accuracy Report for SVAIS Project

## Overview
This document summarizes the detection logic and observations from the experiments conducted in the SVAIS (Smart Voice-based Acoustic Intelligent System) project. The focus of these experiments is on sound event detection, specifically targeting the identification of clap sounds using low-cost hardware.

## Detection Logic
The detection logic is based on the following steps:
1. **Audio Signal Acquisition**: Audio signals are captured using the ESP32 and MAX4466 microphone.
2. **Feature Extraction**: Key features such as RMS (Root Mean Square), ZCR (Zero-Crossing Rate), and spectral centroid are extracted from the audio signals.
3. **Thresholding**: A threshold is set for each feature to determine the presence of a clap sound.
4. **Classification**: Based on the extracted features and their respective thresholds, the audio segments are classified as either "clap" or "non-clap".

## Experiment Results
### Round 1
- **Test Conditions**: 
  - Environment: Quiet room
  - Number of claps: 50
  - Number of non-clap sounds: 50 (taps, speech, noise)
- **Accuracy**: 85%
- **Observations**: 
  - The system performed well in a controlled environment.
  - False positives were observed with certain non-clap sounds that had similar acoustic features.

### Round 2
- **Test Conditions**: 
  - Environment: Noisy room
  - Number of claps: 50
  - Number of non-clap sounds: 50 (taps, speech, noise)
- **Accuracy**: 70%
- **Observations**: 
  - The accuracy dropped significantly in a noisy environment.
  - Background noise interfered with the detection logic, leading to increased false negatives.

## Insights
- **Feature Importance**: RMS and ZCR were found to be the most significant features for clap detection.
- **Environmental Factors**: The performance of the detection system is highly dependent on the acoustic environment.
- **Future Improvements**: 
  - Implementing adaptive thresholding based on ambient noise levels.
  - Exploring additional features for improved classification accuracy.

## Conclusion
The experiments conducted in the SVAIS project have provided valuable insights into the challenges and opportunities in sound event detection. Continued iterations and refinements of the detection logic will be essential for enhancing the system's robustness and accuracy in diverse environments.