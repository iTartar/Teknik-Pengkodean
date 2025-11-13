%% PCM Transmitter (Tx) - Program Sederhana
% Proses: Sinyal Analog → Sampling → Kuantisasi → Encoding

clear all;
close all;
clc;

%% Sinyal Analog (sinyal informasi)
f = 2;                          % Frekuensi sinyal informasi
fs = 40*f;                      % Frekuensi sampling t=0:1/fs:1; 
t = 0:1/fs:1;                   % Time
a = 2;                          % Amplitudo sinyal
x = a*sin(2*pi*f*t);            % Sinyal informasi

%% Shifting Amplitude (Level shifting)
x1 = x + a;

%% Proses Kuantisasi menggunakan fungsi "round"
quan = round(x1);
quan1 = quan - a;
encode = de2bi(quan, 'left-msb');
xe = encode;

%% PCM Receiver
decode = bi2de(encode, 'left-msb');

%% Shifting Level sinyal ke level sinyal asli
xr = decode - a;

%% Low Pass Filtering
[num, den] = butter(5, 4*f/fs);     % Butterworth LPF
rec_op = filter(num, den, xr);      % Smoothing

%% Plotting
figure(1)

subplot(211)
plot(t, x, 'r', 'linewidth', 2)
xlabel('Time')
ylabel('Amplitude')
title('Sinyal Sinus')
grid on

subplot(212)
stem(t, x, 'g', 'linewidth', 2)
xlabel('Time')
ylabel('Amplitude')
title('Sinyal Sampling')
grid on

figure(2)
plot(t, x, 'r', t, quan1, 'b', 'linewidth', 2)
xlabel('Time')
ylabel('Amplitude')
title('Sinyal Hasil Kuantisasi')
legend('Sinyal Asli', 'Sinyal Kuantisasi')
grid on

figure(3)
plot(t, x, 'r', t, xr, 'b', t, rec_op, 'g', 'linewidth', 2)
xlabel('Time')
ylabel('Amplitude')
title('Perbandingan Sinyal PCM')
legend('Sinyal Asli', 'Sinyal Decoded', 'Sinyal Filtered')
grid on

% Cara 1: Tampilkan sebagai tabel
fprintf('\n=== DATA ENCODED (5 sampel pertama) ===\n');
for i = 1:5
    fprintf('Sampel %d: %d → [%d %d %d]\n', i, quan(i), encode(i,1), encode(i,2), encode(i,3));
end

%% Informasi Parameter
fprintf('=== PARAMETER PCM SYSTEM ===\n');
fprintf('Frekuensi sinyal (f): %g Hz\n', f);
fprintf('Frekuensi sampling (fs): %g Hz\n', fs);
fprintf('Amplitudo sinyal (a): %g\n', a);
fprintf('Rasio sampling (fs/f): %g\n', fs/f);
fprintf('Jumlah bit per sampel: %d bit\n', size(encode, 2));
fprintf('Jumlah level kuantisasi: %d level\n', max(quan) + 1);

fprintf('\n=== CONTOH DATA ===\n');
fprintf('Sampel ke-1 sampai 5:\n');
for i = 1:5
    fprintf('t=%.3f: x=%.3f → x1=%.3f → quan=%d → decoded=%.3f\n', ...
        t(i), x(i), x1(i), quan(i), xr(i));
end