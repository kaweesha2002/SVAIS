# SVAIS Firmware Development

## Project Context
This document details the firmware development for the Smart Voice-based Acoustic Intelligent System (SVAIS), a project for the EE254 course. The objective is to design, implement, and test the embedded software for the ESP32 microcontroller, which serves as the core of the SVAIS hardware.

## Overview
The firmware is responsible for managing the system's hardware components, including microphones, speakers, and amplifiers. It processes acoustic data and executes the system's core logic. This directory contains all source code, libraries, and related development files.

## Directory Structure
- **SVAIS/**: Contains the main Arduino sketch.
   - `SVAIS.ino`: The primary application entry point.
- **lib/**: Reserved for custom libraries developed specifically for this project. External libraries are managed by the Arduino IDE.

## Development Environment Setup
To configure the development environment for the firmware, follow these steps:

1.  **Install Arduino IDE**:
      Ensure the latest version of the Arduino IDE is installed. It can be downloaded from the [official Arduino website](https://www.arduino.cc/en/software).

2.  **Install ESP32 Board Support**:
      - In the Arduino IDE, navigate to `File > Preferences`.
      - Add the following URL to the "Additional Boards Manager URLs" field: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
      - Open the Boards Manager via `Tools > Board > Boards Manager...`, search for "esp32", and install the package provided by Espressif Systems.

3.  **Install Required Libraries**:
      Install all necessary libraries using the Arduino Library Manager (`Sketch > Include Library > Manage Libraries...`). Refer to the project's dependency list for required libraries.

4.  **Open the Project**:
      Launch the Arduino IDE and open the `SVAIS.ino` file located in the `firmware/SVAIS/` directory.

5.  **Configure and Upload**:
      - Connect the ESP32 development board to the computer.
      - Select the correct board model (e.g., "ESP32 Dev Module") under `Tools > Board`.
      - Choose the appropriate COM port from `Tools > Port`.
      - Click the "Upload" button to compile the code and flash the firmware onto the ESP32.

## Development and Reporting Guidelines
- Adhere to established coding standards for clarity and consistency.
- Document code with comments explaining logic and functionality.
- Perform unit testing for individual modules before integration.
- Utilize version control (Git) for tracking changes and collaboration. All commits should have clear, descriptive messages.

## Project Documentation
For detailed project insights, experimental logs, and iteration findings, refer to the `docs/insights.md` file. This document serves as the primary log for project progress and decision-making.

## Project Milestones and Future Work
- **Current Status**: [Briefly describe the current state of the firmware]
- **Next Steps**:
   - Implement features based on the latest hardware testing results.
   - Optimize firmware for performance and memory efficiency.
   - Investigate the integration of machine learning models for advanced sound classification.
