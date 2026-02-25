## Real-time Voice Changing

Real-time voice changing demo written in **Delphi for .NET** around **2007**. It records audio from the microphone, processes it in short windows using **FFT** (Fast Fourier Transform) with a Hanning window, applies simple spectral transformations, and plays the processed audio back in near real time. The application also provides basic visualization of the waveform / spectral data.

---

## Overview

- **Platform**: Delphi for .NET (Borland VCL assemblies)
- **Audio processing**:
  - Uses a fixed window length of `LenWindow = 1024` samples.
  - Each window is first passed through a **Hanning window**.
  - An **FFT** is applied to analyze the signal in the frequency domain.
  - Additional FFT passes on the real and imaginary parts are used to shape or redistribute spectral content.
  - The processed data is transformed back to a time-domain buffer and sent to the audio output.
- **Real-time loop**:
  - A custom `TRecorder` captures audio into an input buffer.
  - A custom `TPlayer` plays from an output buffer.
  - A timer periodically checks the recorder position; when a full window is ready, it calls `Change(t)` to process that block and fill the playback buffer.

This project serves as an experimental **FFT-based real-time voice changing** application, distinct from the matrix-precomputed Fourier-style approach used in the older “Real-time Voice Conversion” project.

---

## Project Structure

- `VoiceChanging.dpr` – Project entry point; references:
  - `Main.pas` – Main form, audio loop, and high-level signal processing.
  - `..\Units\Fourier.pas` – FFT, Hanning window, and related math routines (external).
  - `..\Units\MultiMedia.pas` – `TRecorder`, `TPlayer`, and audio I/O helpers (external).
  - `..\Units\Drawing.pas` – Drawing helper routines (external).
  - `..\Component\DrawLinePoint.pas` – UI frame for drawing / frequency mapping (external).
- `Main.pas` – Implements:
  - Setup of the FFT environment (`FFTInitial(LenWindow)`).
  - Buffers for time- and frequency-domain data (`X`, `Y`, `A`, `Data`, etc.).
  - The processing routine `Change(t)` that:
    - Copies a window from the input buffer.
    - Applies `HanningWindow`.
    - Runs FFT and additional transformations.
    - Writes the resulting samples into `BufferPlay`.
  - Visualization code (`ShowShapeWave`) for drawing simple waveform/analysis views.
- `Main.nfm` – Form definition (layout, images, panels, etc.).

---

## Building and Running

1. Open `VoiceChanging.dpr` in **Delphi for .NET** (e.g. Borland Developer Studio era with support for the `Borland.Vcl` assemblies).
2. Make sure the external units referenced in the project file exist and are in the expected relative paths:
   - `..\Units\Fourier.pas`
   - `..\Units\MultiMedia.pas`
   - `..\Units\Drawing.pas`
   - `..\Component\DrawLinePoint.pas`
3. Build the project.
4. Run the executable:
   - Ensure your **microphone** and audio output device are correctly configured in Windows.
   - Use the UI (e.g. clicking on the main image/button) to start and stop recording / playback.

Because the project targets an older **.NET 1.1 / Borland VCL** toolchain, you may need a compatible development environment or a legacy virtual machine to build and run it.

---

## Features

- **Real-time voice changing** using FFT-based processing.
- **Windowed processing** with a Hanning window to reduce artifacts at block boundaries.
- **Custom Recorder/Player classes** for audio capture and playback.
- **Simple visualization** of waveform / analysis data on the form.
- **Experimental spectral manipulation** via additional FFT passes on real and imaginary components.

---

## License

This codebase is shared **without a formal license**. It is intended for educational and personal use; you may use, study, and modify it as you wish. If you reuse or publish derivatives of this project, attributing the original Delphi/.NET “Voice Changing” demo is appreciated.

