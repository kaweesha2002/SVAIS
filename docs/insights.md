# Insights Log for SVAIS Project

## Iteration 1: Initial Setup
- **Date:** YYYY-MM-DD
- **Hypothesis:** Using the ESP32 with the MAX4466 microphone will allow for effective sound event detection of claps.
- **Experiment:** Recorded various clap sounds in different environments (quiet room, noisy background).
- **Results:** Initial recordings were promising, but background noise affected detection accuracy.
- **Insights:** Need to implement noise reduction techniques in future iterations.

---

## Iteration 2: Feature Extraction
- **Date:** YYYY-MM-DD
- **Hypothesis:** Basic features like RMS and ZCR can help distinguish claps from other sounds.
- **Experiment:** Analyzed recorded audio using custom feature extraction scripts.
- **Results:** RMS values for claps were significantly higher than for non-clap sounds.
- **Insights:** RMS is a good initial feature; however, ZCR showed less distinction. Consider adding more features.

---

## Iteration 3: Testing Detection Logic
- **Date:** YYYY-MM-DD
- **Hypothesis:** A simple threshold-based detection logic can effectively identify claps.
- **Experiment:** Implemented a basic detection algorithm using RMS thresholds.
- **Results:** Detected claps with ~80% accuracy in controlled conditions.
- **Insights:** False positives occurred with loud non-clap sounds. Need to refine detection logic.

---

## Iteration 4: Utilizing External Tools
- **Date:** YYYY-MM-DD
- **Hypothesis:** Tools like Praat and Sonic Visualizer can enhance feature analysis.
- **Experiment:** Used Praat to visualize spectrograms of clap vs. non-clap sounds.
- **Results:** Spectrograms revealed distinct patterns for claps.
- **Insights:** Visual analysis is crucial for understanding feature differences. Documented workflows for both tools.
  
 --- 

## Hardware Development Insights

- **Schematic Design:** Ensure clear annotations and separation of analog and digital grounds.
- **PCB Layout:** Test points for power lines should be included for easy debugging.
- **Enclosure Design:** Consider thermal management and accessibility for USB and battery connections.
- **Assembly Guides:** Provide detailed instructions and visual aids for assembly to facilitate reproducibility.

--- 

## Future Directions
- Explore advanced features such as spectral centroid and envelope detection.
- Investigate machine learning approaches for improved detection, ensuring transparency in feature extraction.
- Continue logging insights and results to refine the detection system iteratively.
- Investigate machine learning approaches for improved detection, ensuring transparency in feature extraction.
- Continue logging insights and results to refine the detection system iteratively.

--- 

## Additional Notes
- Document all test results, including voltage readings and oscilloscope screenshots, to support future iterations and improvements.
  
- Maintain a comprehensive parts list and ensure all components are easily accessible for prototyping and testing.