# Sonic Visualizer Workflow

## Overview
Sonic Visualizer is a powerful tool for visualizing and analyzing the contents of audio files. This document outlines the workflow for using Sonic Visualizer to extract features relevant to the SVAIS project, particularly focusing on sound event detection.

## Installation
1. Download and install Sonic Visualizer from the official website: [Sonic Visualizer](https://www.sonicvisualiser.org/).
2. Ensure that you have the necessary plugins for feature extraction. You may need to install additional plugins depending on your analysis needs.

## Workflow Steps

### 1. Load Audio File
- Open Sonic Visualizer.
- Use the "File" menu to select "Open" and choose the audio file you wish to analyze (e.g., from the `/data/raw/` directory).

### 2. Visualize Waveform
- Once the audio file is loaded, the waveform will be displayed in the main window.
- You can zoom in and out using the mouse wheel or the zoom controls to focus on specific sections of the audio.

### 3. Add Layers for Analysis
- Go to the "Layer" menu and select "Add Layer" to add different types of visualizations.
- Common layers to add include:
  - **Spectrogram**: Provides a visual representation of the frequency spectrum over time.
  - **Pitch Layer**: Displays the pitch contour of the audio.
  - **Note Layer**: Useful for identifying musical notes if applicable.

### 4. Feature Extraction
- Use the "Transform" menu to apply various analyses:
  - **FFT (Fast Fourier Transform)**: Analyze the frequency components of the audio.
  - **Zero-Crossing Rate**: Measure the rate at which the signal changes sign.
  - **Spectral Centroid**: Calculate the center of mass of the spectrum.

### 5. Exporting Data
- After analyzing the audio, you can export the visualizations and data:
  - Use the "File" menu and select "Export" to save the visualizations as images (e.g., PNG).
  - For numerical data, use the "Export" option to save the extracted features in CSV format.

### 6. Documentation of Findings
- Document your observations and insights in the `insights.md` file located in the `/docs/` directory.
- Include details about the features extracted, any anomalies observed, and how they relate to the sound events being detected.

## Tips
- Experiment with different audio files to understand how various sounds are represented visually.
- Use the zoom and selection tools to focus on specific events, such as claps, to better understand their characteristics.

## Conclusion
Sonic Visualizer is an essential tool for the SVAIS project, allowing for in-depth analysis of audio signals. By following this workflow, you can effectively extract and visualize features that will aid in the development of the sound event detection system.