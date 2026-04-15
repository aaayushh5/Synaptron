clear; clc; close all;

%% ---------- LOAD DATA ----------
dataStruct = load('Amaan_rawdata.mat');

emg = dataStruct.EMG_RAW.ADC;   % ✅ RAW ADC COUNTS
t   = dataStruct.EMG_RAW.t;     % real timestamps (s)

fs = 1000;                      % nominal sampling frequency
N = length(emg);

%% ---------- FFT OF RAW EMG (ADC) ----------
emg_fft = emg - mean(emg);          % remove DC
emg_win = emg_fft .* hamming(N);    % windowing

X = fft(emg_win);
P2 = abs(X / N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2 * P1(2:end-1);

f = fs * (0:(N/2)) / N;

figure;
plot(f, P1, 'LineWidth', 1.2)
xlim([0 500])
xlabel('Frequency (Hz)')
ylabel('Magnitude (ADC)')
title('FFT of Raw EMG (ADC)')
grid on

%% ---------- RAW EMG (TIME DOMAIN) ----------
figure;
plot(t, emg)
xlabel('Time (s)')
ylabel('ADC Value')
title('Raw EMG Signal (ADC)')
grid on

%% ---------- PREPROCESSING ----------
% DC removal
emg_dc = emg - mean(emg);

% Band-pass filter (FFT justified)
[b,a] = butter(4, [30 300]/(fs/2), 'bandpass');
emg_filt = filtfilt(b, a, emg_dc);

% Full-wave rectification
emg_rect = abs(emg_filt);

% RMS envelope (50 ms window)
win = round(0.05 * fs);
emg_env = sqrt(movmean(emg_rect.^2, win));

%% ---------- FINAL VISUALIZATION ----------
figure;

subplot(4,1,1)
plot(t, emg)
title('Raw EMG (ADC)')
ylabel('ADC')
grid on

subplot(4,1,2)
plot(t, emg_filt)
title('Band-Passed EMG (30–300 Hz)')
ylabel('ADC')
grid on

subplot(4,1,3)
plot(t, emg_rect)
title('Rectified EMG')
ylabel('ADC')
grid on

subplot(4,1,4)
plot(t, emg_env)
title('RMS Envelope (50 ms)')
xlabel('Time (s)')
ylabel('ADC')
grid on
