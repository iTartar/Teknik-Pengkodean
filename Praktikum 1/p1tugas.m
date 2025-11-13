%% PCM dengan Mid-Tread Quantization
% Tugas 1: n=3 bit (2^3 = 8 level)
% Tugas 2: n=4 bit (2^4 = 16 level)

clear all;
close all;
clc;

%% Parameter Sinyal Analog
f = 2;                          % Frekuensi sinyal informasi
fs = 40*f;                      % Frekuensi sampling
t = 0:1/fs:1;                   % Time vector
a = 2;                          % Amplitudo sinyal
x = a*sin(2*pi*f*t);            % Sinyal informasi

%% TUGAS 1: Mid-Tread Quantization dengan n=3 bit (8 level)
fprintf('=== TUGAS 1: n=3 bit (8 level quantization) ===\n');

n1 = 3;                         % Jumlah bit
L1 = 2^n1;                      % Jumlah level quantization = 8
x_max = max(x);                 % Nilai maksimum sinyal
x_min = min(x);                 % Nilai minimum sinyal
delta1 = (x_max - x_min)/(L1-1);% Step size quantization

% Mid-Tread Quantization untuk n=3
% Level quantization: -2, -1.43, -0.86, -0.29, 0.29, 0.86, 1.43, 2
quan_levels1 = x_min:delta1:x_max;
quan1 = zeros(size(x));

for i = 1:length(x)
    % Mencari level quantization terdekat (Mid-Tread)
    [~, idx] = min(abs(x(i) - quan_levels1));
    quan1(i) = quan_levels1(idx);
end

% Encoding untuk n=3 bit
quan1_shifted = quan1 - x_min;              % Shift ke nilai positif
quan1_index = round(quan1_shifted/delta1);  % Convert ke index 0-7
encode1 = de2bi(quan1_index, n1, 'left-msb'); % Binary encoding

% PCM Receiver untuk n=3 bit
decode1 = bi2de(encode1, 'left-msb');       % Decoding
xr1 = (decode1 * delta1) + x_min;          % Reconstruct signal
[num1, den1] = butter(5, 4*f/fs);          % Filter design
rec_op1 = filter(num1, den1, xr1);         % Filtering

%% TUGAS 2: Mid-Tread Quantization dengan n=4 bit (16 level)  
fprintf('\n=== TUGAS 2: n=4 bit (16 level quantization) ===\n');

n2 = 4;                         % Jumlah bit
L2 = 2^n2;                      % Jumlah level quantization = 16
delta2 = (x_max - x_min)/(L2-1);% Step size quantization

% Mid-Tread Quantization untuk n=4
quan_levels2 = x_min:delta2:x_max;
quan2 = zeros(size(x));

for i = 1:length(x)
    % Mencari level quantization terdekat (Mid-Tread)
    [~, idx] = min(abs(x(i) - quan_levels2));
    quan2(i) = quan_levels2(idx);
end

% Encoding untuk n=4 bit
quan2_shifted = quan2 - x_min;              % Shift ke nilai positif
quan2_index = round(quan2_shifted/delta2);  % Convert ke index 0-15
encode2 = de2bi(quan2_index, n2, 'left-msb'); % Binary encoding

% PCM Receiver untuk n=4 bit
decode2 = bi2de(encode2, 'left-msb');       % Decoding
xr2 = (decode2 * delta2) + x_min;          % Reconstruct signal
[num2, den2] = butter(5, 4*f/fs);          % Filter design  
rec_op2 = filter(num2, den2, xr2);         % Filtering

%% PLOTTING - Perbandingan n=3 vs n=4 bit
figure('Position', [100 100 1400 900]);

% Subplot 1: Sinyal Asli vs Quantized (n=3 bit)
subplot(2,3,1);
plot(t, x, 'r-', 'LineWidth', 2); hold on;
plot(t, quan1, 'b-', 'LineWidth', 2);
% Tampilkan quantization levels
for i = 1:length(quan_levels1)
    yline(quan_levels1(i), '--k', 'Alpha', 0.3);
end
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('n=3 bit: Sinyal Asli vs Mid-Tread Quantization');
legend('Sinyal Asli', 'Quantized (8 level)', 'Location', 'best');
xlim([0 1]);

% Subplot 2: Sinyal Asli vs Quantized (n=4 bit)
subplot(2,3,2);
plot(t, x, 'r-', 'LineWidth', 2); hold on;
plot(t, quan2, 'g-', 'LineWidth', 2);
% Tampilkan quantization levels
for i = 1:length(quan_levels2)
    yline(quan_levels2(i), '--k', 'Alpha', 0.2);
end
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('n=4 bit: Sinyal Asli vs Mid-Tread Quantization');
legend('Sinyal Asli', 'Quantized (16 level)', 'Location', 'best');
xlim([0 1]);

% Subplot 3: Perbandingan Quantization Error
subplot(2,3,3);
error1 = x - quan1;
error2 = x - quan2;
plot(t, error1, 'b-', 'LineWidth', 2); hold on;
plot(t, error2, 'g-', 'LineWidth', 2);
grid on;
xlabel('Time (s)'); ylabel('Error');
title('Quantization Error Comparison');
legend('Error n=3 bit', 'Error n=4 bit', 'Location', 'best');
xlim([0 1]);

% Subplot 4: PCM Reconstruction (n=3 bit)
subplot(2,3,4);
plot(t, x, 'r-', 'LineWidth', 2); hold on;
plot(t, xr1, 'b--', 'LineWidth', 2);
plot(t, rec_op1, 'c-', 'LineWidth', 2);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('PCM Reconstruction n=3 bit');
legend('Original', 'Decoded', 'Filtered', 'Location', 'best');
xlim([0 1]);

% Subplot 5: PCM Reconstruction (n=4 bit)
subplot(2,3,5);
plot(t, x, 'r-', 'LineWidth', 2); hold on;
plot(t, xr2, 'g--', 'LineWidth', 2);
plot(t, rec_op2, 'm-', 'LineWidth', 2);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('PCM Reconstruction n=4 bit');
legend('Original', 'Decoded', 'Filtered', 'Location', 'best');
xlim([0 1]);

% Subplot 6: Final Comparison
subplot(2,3,6);
plot(t, x, 'r-', 'LineWidth', 3); hold on;
plot(t, rec_op1, 'b-', 'LineWidth', 2);
plot(t, rec_op2, 'g-', 'LineWidth', 2);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Final Output Comparison');
legend('Original', 'PCM n=3 bit', 'PCM n=4 bit', 'Location', 'best');
xlim([0 1]);

%% ANALISIS KINERJA
fprintf('\n=== ANALISIS KINERJA ===\n');

% Pastikan semua vector memiliki dimensi yang sama
x = x(:);           % Jadikan column vector
rec_op1 = rec_op1(:); % Jadikan column vector  
rec_op2 = rec_op2(:); % Jadikan column vector

% Mean Square Error (MSE)
mse1 = mean((x - rec_op1).^2);
mse2 = mean((x - rec_op2).^2);

% Signal-to-Noise Ratio (SNR) in dB
% Pastikan semua vector memiliki dimensi yang sama
x = x(:);           % Jadikan column vector
rec_op1 = rec_op1(:); % Jadikan column vector  
rec_op2 = rec_op2(:); % Jadikan column vector

% Recalculate MSE dengan dimensi yang benar
mse1 = mean((x - rec_op1).^2);
mse2 = mean((x - rec_op2).^2);

% Hitung SNR
snr1 = 10*log10(mean(x.^2)/mse1);
snr2 = 10*log10(mean(x.^2)/mse2);

fprintf('TUGAS 1 (n=3 bit, 8 level):\n');
fprintf('  Quantization levels: %d\n', L1);
fprintf('  Step size (delta): %.4f\n', delta1);
fprintf('  MSE: %.6f\n', mse1);
fprintf('  SNR: %.2f dB\n', snr1);

fprintf('\nTUGAS 2 (n=4 bit, 16 level):\n');
fprintf('  Quantization levels: %d\n', L2);
fprintf('  Step size (delta): %.4f\n', delta2);
fprintf('  MSE: %.6f\n', mse2);
fprintf('  SNR: %.2f dB\n', snr2);

fprintf('\nPERBANDINGAN:\n');
fprintf('  Improvement MSE: %.1fx better\n', mse1/mse2);
fprintf('  Improvement SNR: %.2f dB better\n', snr2-snr1);

%% TAMPILKAN QUANTIZATION LEVELS
fprintf('\n=== QUANTIZATION LEVELS ===\n');
fprintf('n=3 bit levels: ');
fprintf('%.3f ', quan_levels1);
fprintf('\nn=4 bit levels: ');
fprintf('%.3f ', quan_levels2(1:8)); % Tampilkan 8 pertama saja
fprintf('...');

%% CONTOH ENCODING
fprintf('\n\n=== CONTOH ENCODING (5 sampel pertama) ===\n');
fprintf('TUGAS 1 (n=3 bit):\n');
for i = 1:5
    bin_str = sprintf('%d', encode1(i,:));
    fprintf('  x(%.3f)=%.3f → quan=%.3f → idx=%d → binary=%s\n', ...
        t(i), x(i), quan1(i), quan1_index(i), bin_str);
end

fprintf('\nTUGAS 2 (n=4 bit):\n');
for i = 1:5
    bin_str = sprintf('%d', encode2(i,:));
    fprintf('  x(%.3f)=%.3f → quan=%.3f → idx=%d → binary=%s\n', ...
        t(i), x(i), quan2(i), quan2_index(i), bin_str);
end