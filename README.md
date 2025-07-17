<div align="center">

# SVAIS (Smart Voice-based Acoustic Intelligent System) 🤖🔊

**A research project focused on audio signal processing and sound event detection using the ESP32.**

</div>

<p align="center">
    <a href="https://github.com/Oshadha345/SVAIS/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
    </a>
    <img src="https://img.shields.io/badge/Status-In%20Progress-blue" alt="Project Status">
    <img src="https://img.shields.io/badge/Python-3.x-blue.svg" alt="Python">
    <img src="https://img.shields.io/badge/Arduino-IDE-00979D.svg" alt="Arduino IDE">
    <img src="https://img.shields.io/badge/Hardware-ESP32-orange" alt="Hardware: ESP32">
</p>

---

## 📝 Overview

SVAIS is a research-focused project aimed at implementing audio signal processing and sound event detection using low-cost hardware, specifically the ESP32 combined with the MAX4466 microphone. The project begins with the detection of basic sound events, such as claps, and emphasizes a fundamentals-first approach to learning and development.

---

## 💡 Motivation

The primary motivation behind SVAIS is to foster a deep understanding of audio signal processing techniques without relying heavily on external libraries or high-level machine learning frameworks. By focusing on the core principles of audio analysis, we aim to create a transparent and educational experience for researchers and developers alike.

---

## ⚙️ Project Workflow

The project follows a structured workflow:

1.  📥 **Data Collection**: Gather original audio recordings from various sources, including the ESP32 and PC microphones.
2.  🧹 **Processing**: Clean, normalize, and segment the audio files for analysis.
3.  🔬 **Feature Extraction**: Implement custom algorithms to extract relevant features from the audio signals.
4.  🧪 **Logic Testing**: Develop and test detection logic based on the extracted features.
5.  🔄 **Iteration**: Continuously refine the methods based on experimental results and insights.

---

## 🛠️ Hardware

The hardware design is modular and well-documented to ensure reproducibility and ease of testing.

<details>
<summary><strong>📂 File Structure</strong></summary>

-   **/schematics/**
        -   `svais_power_block.sch`: Schematic of the power supply and backup system.
        -   `svais_main_board.sch`: Main board schematic with ESP32, microphone, and speaker connections.
        -   `svais_firmware_io_map.md`: ESP32 pin mapping document.
-   **/pcb_layouts/**
        -   `svais_top_board.pcb`: Through-hole PCB layout for a DevKit-compatible board.
        -   `svais_audio_module.pcb`: Optional breakout PCB for the audio/speaker side.
        -   Gerber and `.step` files for manufacturing and 3D modeling.
-   **/simulations/**
        -   `power_switching.falstad.circuit`: Simulation of the power path switching.
        -   `voltage_divider_battery_ltspice.asc`: LTspice simulation for battery monitoring.
-   **/enclosure_design/**
        -   `svais_case_v1.step`: 3D model of the enclosure.
        -   `case_notes.md`: Mounting constraints and placement tips.
-   **/assembly_guides/**
        -   `breadboard_testing.md`: Step-by-step hardware verification guide.
        -   `pcb_assembly_notes.md`: Soldering techniques and considerations.
        -   `connection_diagram.png`: Visual wiring reference.

</details>

<details>
<summary><strong>📋 Parts List</strong></summary>

-   ESP32 DevKit V1 with female pin headers
-   MAX4466 microphone module (analog output)
-   PAM8403 speaker amplifier
-   3.7V 1200mAh LiPo battery
-   UPS Module (charging, protection, 5V boost)
-   HT7333 or AMS1117-3.3 for 3.3V supply
-   1N5819 diodes for power path switching
-   Tactile buttons for BOOT/RESET
-   JST connectors, headers, and 8Ω speaker

</details>

<details>
<summary><strong>📐 Design Principles</strong></summary>

-   Maintain separate analog and digital ground planes.
-   Include test points for 5V, 3.3V, GND, ADC, and DAC.
-   Position the microphone away from the speaker to minimize feedback.
-   Simulate power fallback behavior before finalizing PCB design.
-   Ensure all modules are swappable via headers.

</details>

<details>
<summary><strong> deliverables</strong></summary>

-   Schematics in EasyEDA/KiCad format.
-   Through-hole PCB layouts with Gerber files.
-   3D case design compatible with all components.
-   Wiring diagrams (Fritzing or PNG).
-   Documentation of hardware test results and logs.
-   Photos of breadboarding, voltage readings, and oscilloscope screenshots.

</details>

---

## 🔧 Tools & Technologies

-   **Audio Analysis**: Praat, Sonic Visualizer
-   **Audio Editing**: Audacity
-   **Firmware**: Arduino IDE
-   **Data Science**: Python

---

## 📁 Project Structure

```
SVAIS/
├── LICENSE
├── README.md
├── data/
│   ├── Clap Sounds/
│   ├── Non_Clap Sounds/
│   ├── Microphone Recordings/
│   └── Claps.md
├── docs/
│   ├── PRAAT_workflow.md
│   ├── insights.md
│   └── sonic_visualizer_workflow.md
├── firmware/
│   ├── src/
│   └── README.md
├── hardware/
│   ├── assembly/
│   ├── enclosure/
│   ├── pcb/
│   └── schematics/
├── analytics/
│   ├── feature_extraction.py
│   └── signal_tools.py
└── tests/
        ├── accuracy_report.md
        └── test_results_round1.csv
```

---

## 📜 License

This project is licensed under the **MIT License**. See the `LICENSE` file for more details.

---

## 🚀 Future Directions

-   Expand the range of detectable sound events.
-   Implement more advanced signal processing techniques.
-   Explore machine learning approaches with manually extracted features.
-   Enhance documentation and educational resources for users.

Thank you for your interest in SVAIS! We hope this project serves as a valuable resource for learning and experimentation in audio signal processing.

---

## 🧑‍💻 The Crew

| Name                  | E-Number |
| --------------------- | :------: |
| Movindu Dissanayake   | E/21/109 |
| Thaariq Firdous       | E/21/139 |
| Kaweesha Rathnayake   | E/21/334 |
| Oshdha Samarakoon     | E/21/345 |

---

<p align="center">
        A final project for <b>EE254 - Digital Instrumentation</b>
        <br>
        Department of Electrical and Electronic Engineering
        <br>
        University of Peradeniya
</p>
