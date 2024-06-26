# SemiModularSynth

This project is a digital, modular, patchable electronic music synthesizer designed for use on an Intel DE-10 LITE FPGA, equipped with MCP-3001 ADCs and MCP-4031 DACs.

![Synthesizer+Plant](Faceplate.jpg)

## Features
The synthesizer includes the following features:

### Voltage Controlled Oscillator (VCO)
Offers rough and fine frequency controls, with the ability to toggle between square, triangle, sawtooth, and sine waves.
### Low-pass Voltage Controlled Filter (VCF)
Allows adjustable frequency cutoff.
### Voltage Controlled Amplifier (VCA)
Controls the volume of the signal.
### Envelope Generator (EG)
Utilizes ADSR controls. When used in conjunction with the VCA, emulates the sound of a piano key being struck.
### Low Frequency Oscillator (LFO) x2
Generates low-frequency (0.1-10 Hz) signals for controlling other modules. Togglable between square, triangle, sawtooth, and sine waves.

##Pictures

###Output of the low-pass VCF with a triangle input and changing cutoff frequency

| High Cutoff | Medium Cutoff | Low Cutoff |
|---------|---------|---------|
| <img src="VCF_demo_1.jpg" width="400" /> | <img src="VCF_demo_2.jpg" width="400" /> | <img src="VCF_demo_3.jpg" width="400" /> |

### Enclosure with PCB

![PCB](PCB_Wiring.jpg)

## Demo
Check out the YouTube demo showcasing the functionality of the VCO, VFC, and LFOs:
https://www.youtube.com/shorts/WItJAyof4KM
