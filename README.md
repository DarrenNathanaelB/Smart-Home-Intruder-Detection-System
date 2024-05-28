# 🏡 Smart Home Intruder Detection System 🏡

Made By Group 13

1. Darren Nathanael Boentara (2206059490)
2. Emir Fateen Haqqi (2206059465)
3. Fabsesya Muhammad (2206829433)
4. Stefanus Simon Rilando (2206830422)

## Introduction

### Problem

Many homes are vulnerable to intrusion or theft, especially when the owners are away, making home security a top priority. Traditional security systems often fall short for several reasons. They typically lack early warning capabilities, detecting intrusions only after they have started, leading to delayed responses. False alarms are another common issue, often triggered by small animals or environmental disturbances, causing unnecessary inconvenience. Additionally, many traditional systems lack effective visualization and monitoring, failing to provide clear information about the intruder's distance or location. This makes it difficult for homeowners to quickly assess threats and take appropriate action.

### Solution

To address these problem, we developed the Smart Home Intruder Detection System. This device helps users detect movement or objects approaching their homes, notifying homeowners when something nears critical areas like doors or windows. If an object gets close, the system issues audible and visual alerts, displaying the object's distance. If the object comes very near, it escalates the warnings and takes further security measures. The system aims to enhance home security by providing early notifications and preventive actions against potential intrusions.

### Features

- **Motion Detection**: Detects movement near critical areas of the home.
- **Distance Measurement**: Displays the distance of the detected object from the critical areas.
- **Alerts**: Provides audible and visual alerts when an object is detected within a predefined proximity.
- **Preventive Actions**: Implements additional security measures if the object reaches a very close distance.
- **Object Verification**: Ensure object is near the sensor for 5 seconds before alerting.

## Hardware Design and Implementation

### Hardware Specification
The Smart Home Intruder Detection System enhances home security using various components and modules. It employs the HC-SR04 sensor to measure the distance between an object and a home's door or window. The system provides auditory and visual alerts when an object approaches. If the object is over 75 cm away, a green LED indicates safety. If the object is between 40 cm and 75 cm away, a yellow LED and buzzer signal a warning. If the object is within 40 cm, a red LED, buzzer, and automatic door/window locking indicate an emergency. An 8-digit 7-segment display (MAX7219) shows the distance, with a 5-second delay ensuring the object's presence before alerting. The system uses I2C/SPI for communication between master and slave devices and additional sensor modules to aid the ultrasonic sensor in distance measurement.

### Component 
- Arduino Uno
- 8-digit 7-Segment Display
- HC-SR04
- IC MAX7219
- DC Motor
- LED (Red, Yellow, Green)
- Buzzer

### Hardware Schematics
![Hardware_Schematic](https://github.com/DarrenNathanaelB/Smart-Home-Intruder-Detection-System/assets/144119254/1109904e-4636-4786-81a0-771c86bbdad8)

## Software Implementation

This assembly code for an AVR microcontroller implements a Smart Home Intruder Detection System using the HC-SR04 ultrasonic sensor to detect nearby objects and alert users inside the home. The initial setup and initialization define various I/O pin configurations and initialize the necessary components for this project.

In the main function, several pins are set as outputs to control devices like motors, LEDs, buzzers, and external communication components. The SPI_MAX7219_init function initializes the SPI (Serial Peripheral Interface) and sets up communication with the MAX7219 display. The MAX7219_display function, called subsequently, uses send_bytes to transmit data to the MAX7219, displaying information on the LED display.

The program then enters its main loop, continuously calling the HC_SR04_sensor subroutine. This subroutine starts by sending a 10µs high pulse to the HC-SR04 sensor via the trigger pin (PB1) and waits for the echo pulse width using the echo_PW subroutine. The compare subroutine determines the appropriate mode based on the echo_PW data, converting it to decimal with byte_to_decimal before displaying it on the MAX7219.

Based on the data, the compare subroutine triggers specific modes. In Normal Mode, if the sensor measures a distance of 75 cm or more, a green LED lights up, and the buzzer is turned off. In Emergency Lock Mode, if an object remains within 40 cm for more than 5 seconds (verified by delay_5s), the motor locks the emergency door , the buzzer sounds, and the red LED lights up. In Warning Mode, if an object stays between 40 cm and 75 cm for more than 5 seconds (checked by delay_5s), the buzzer and yellow LED are activated.

Additional delay subroutines like delay_timer0 for 10 microseconds, delay_ms for milliseconds, and a specific 5-second delay are used to ensure accurate timing and verification before triggering alerts.

### Flowchart
![Screenshot 2024-05-28 002558](https://github.com/DarrenNathanaelB/Smart-Home-Intruder-Detection-System/assets/144119254/b8bbebb6-d094-4d34-89ae-e5fd0babde71)

## Test Result and Performance Evaluation

| Parameter                                                    | Status  |
| ------------------------------------------------------------ | ------- |
| Object detection using sensor HC-SR04     | SUCCESS |
| Showing object distance from the sensor using MAX 7219     | SUCCESS |
| Audio and visual alert with LED and Buzzer         | SUCCESS |
| Auto-lock door when emergency mode triggered | SUCCESS |
| Ensure the object is near the sensor for 5 seconds before the alert | SUCCESS |