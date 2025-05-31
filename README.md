# EST-SOP
Arduino and Python scripts for data collection and processing

## UltrasonicMeasureDist.ino
An Arduino sketch used to measure the water level in the tank using an ultrasonic sensor. It prints the measured distance to the Serial Monitor in real time. This is used to determine the tank height and initial water level for calibration purposes.

## ExperimentData.m
A MATLAB script that communicates with the Arduino over serial (e.g., COM3), reads sensor output in real time, and logs it to `flow_distance_data.txt`. It writes time, flow rates, pulse counts, and ultrasonic distance, with column headers. The script is terminated manually after the water tank is drained.

## Plots.m
This script loads the logged data from flow_distance_data.txt, computes flow rate and volume based on ultrasonic readings, and compares them with the values from the flow sensor. It also calculates instantaneous calibration factors, estimates total energy, and generates multiple plots, saving them as PNGs.

## CalFact.m
A MATLAB script similar to Plots.m, but with an emphasis on calibration. It calculates two calibration factors:

   - One from the ultrasonic sensor volume change

   - One from the flow sensor's reported flow rate. It then visualizes their distributions and variation with shaded ±1 standard deviation bands. This helps determine sensor consistency and which calibration factor to use.


## Instructions

1. **Download** the files in the Matlab and Arduino folders in a new a folder. After this, open the Arduino file.

2. **Connect the Arduino** to your computer.  Make sure the correct **board** and **COM port** are selected.then **compile and upload** the code.  
  
3. **Open** all the MATLAB files and continue with the step by step procedure.  
