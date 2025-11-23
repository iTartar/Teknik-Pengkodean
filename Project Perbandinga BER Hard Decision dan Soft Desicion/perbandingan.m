% Perbandingan Hard Decision vs Soft Decision
% Menggunakan traceback length (tb) yang sama untuk keduanya

clear all;
close all;
clc;

fprintf('================================================================\n');
fprintf('   PERBANDINGAN: HARD DECISION vs SOFT DECISION\n');
fprintf('   Viterbi Decoder dengan Traceback Length (tb)\n');
fprintf('================================================================\n\n');

%% Setup
t = poly2trellis(3, [6 7]);
tb = 4;  % Traceback length yang sama untuk hard dan soft

fprintf('Parameter:\n');
fprintf('  - Constraint Length (K): 3\n');
fprintf('  - Generator: [6 7]\n');
fprintf('  - Traceback Length (tb): %d\n', tb);
fprintf('  - Modulation: BPSK\n');
fprintf('  - Channel: AWGN\n\n');

%% DEMO dengan 1 Contoh

fprintf('================================================================\n');
fprintf('   DEMO DENGAN 1 CONTOH (SNR = 3 dB)\n');
fprintf('================================================================\n\n');

% Pesan
pesan = [1 0 1 1 0 1 0 0];
fprintf('Pesan (8 bit): [%s]\n\n', num2str(pesan));

% Encoding
codeword = convenc(pesan, t);
fprintf('Codeword (16 bit): [%s]\n\n', num2str(codeword));

% BPSK Modulation
tx = 2*codeword - 1;  % 0→-1, 1→+1

% Add noise
SNR_demo = 3;
rx = awgn(tx, SNR_demo, 'measured');

fprintf('Received signal (dengan noise):\n[');
for i=1:length(rx)
    fprintf('%+.2f ', rx(i));
end
fprintf(']\n\n');

%% HARD DECISION

fprintf('────────────────────────────────────────────────────────────────\n');
fprintf('HARD DECISION\n');
fprintf('────────────────────────────────────────────────────────────────\n\n');

% Hard decision: threshold di 0
rx_hard = rx > 0;

fprintf('Setelah threshold (0/1):\n');
fprintf('[%s]\n\n', num2str(double(rx_hard)));

% Decode dengan hard decision
decoded_hard = vitdec(rx_hard, t, tb, 'trunc', 'hard');

fprintf('Hasil Decoding:\n');
fprintf('  Pesan Asli: [%s]\n', num2str(pesan));
fprintf('  Decoded:    [%s]\n', num2str(decoded_hard));

errors_hard = sum(pesan ~= decoded_hard);
fprintf('  Bit Errors: %d\n\n', errors_hard);

%% SOFT DECISION

fprintf('────────────────────────────────────────────────────────────────\n');
fprintf('SOFT DECISION (3-bit quantization)\n');
fprintf('────────────────────────────────────────────────────────────────\n\n');

% Soft decision: quantize ke 3-bit (8 levels: 0-7)
rx_soft = round((rx + 1) * 3.5);
rx_soft(rx_soft < 0) = 0;
rx_soft(rx_soft > 7) = 7;

fprintf('Setelah 3-bit quantization (0-7):\n[');
for i=1:length(rx_soft)
    fprintf('%d ', rx_soft(i));
end
fprintf(']\n\n');

fprintf('Interpretasi (contoh beberapa bit):\n');
for i=1:min(8, length(rx_soft))
    if rx_soft(i) >= 6
        conf = 'SANGAT yakin "1"';
    elseif rx_soft(i) == 5
        conf = 'yakin "1"';
    elseif rx_soft(i) == 4
        conf = 'agak yakin "1"';
    elseif rx_soft(i) == 3
        conf = 'agak yakin "0"';
    elseif rx_soft(i) == 2
        conf = 'yakin "0"';
    else
        conf = 'SANGAT yakin "0"';
    end
    fprintf('  Bit %2d: %d → %s\n', i, rx_soft(i), conf);
end
fprintf('\n');

% Decode dengan soft decision
decoded_soft = vitdec(rx_soft, t, tb, 'trunc', 'soft', 3);

fprintf('Hasil Decoding:\n');
fprintf('  Pesan Asli: [%s]\n', num2str(pesan));
fprintf('  Decoded:    [%s]\n', num2str(decoded_soft));

errors_soft = sum(pesan ~= decoded_soft);
fprintf('  Bit Errors: %d\n\n', errors_soft);

%% Perbandingan Demo

fprintf('────────────────────────────────────────────────────────────────\n');
fprintf('PERBANDINGAN (Demo ini):\n');
fprintf('  Hard Decision: %d errors\n', errors_hard);
fprintf('  Soft Decision: %d errors\n', errors_soft);
if errors_soft < errors_hard
    fprintf('  → Soft Decision LEBIH BAIK! ✓\n');
elseif errors_soft > errors_hard
    fprintf('  → Hard Decision lebih baik (kali ini)\n');
else
    fprintf('  → Keduanya sama\n');
end
fprintf('────────────────────────────────────────────────────────────────\n\n');

%% Simulasi BER untuk Berbagai SNR

fprintf('================================================================\n');
fprintf('   SIMULASI BER vs SNR\n');
fprintf('================================================================\n\n');

SNR_range = 0:1:8;
num_trials = 200;
pesan_length = 100;

BER_hard = zeros(size(SNR_range));
BER_soft = zeros(size(SNR_range));

fprintf('Progress:\n');

for idx = 1:length(SNR_range)
    SNR_dB = SNR_range(idx);
    fprintf('  SNR = %d dB ... ', SNR_dB);
    
    errors_hard_total = 0;
    errors_soft_total = 0;
    
    for trial = 1:num_trials
        % Generate message
        msg = randi([0 1], 1, pesan_length);
        
        % Encode
        code = convenc(msg, t);
        
        % BPSK
        tx_sig = 2*code - 1;
        
        % AWGN
        rx_sig = awgn(tx_sig, SNR_dB, 'measured');
        
        % HARD DECISION
        rx_h = rx_sig > 0;
        dec_hard = vitdec(rx_h, t, tb, 'trunc', 'hard');
        errors_hard_total = errors_hard_total + sum(msg ~= dec_hard);
        
        % SOFT DECISION
        rx_s = round((rx_sig + 1) * 3.5);
        rx_s(rx_s < 0) = 0;
        rx_s(rx_s > 7) = 7;
        dec_soft = vitdec(rx_s, t, tb, 'trunc', 'soft', 3);
        errors_soft_total = errors_soft_total + sum(msg ~= dec_soft);
    end
    
    BER_hard(idx) = errors_hard_total / (num_trials * pesan_length);
    BER_soft(idx) = errors_soft_total / (num_trials * pesan_length);
    
    fprintf('Done\n');
end

fprintf('\n');

%% Visualisasi

figure('Name', 'Hard vs Soft Decision', 'Position', [50 50 1400 800]);

% Subplot 1: Demo - Received Signal
subplot(3,3,1);
stem(rx, 'k', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
yline(0, 'r--', 'LineWidth', 2);
title('Received Signal (Demo)');
xlabel('Bit Position');
ylabel('Amplitude');
grid on;
legend('Received', 'Threshold=0');

% Subplot 2: Hard Decision
subplot(3,3,2);
stem(double(rx_hard), 'r', 'LineWidth', 2, 'MarkerSize', 8);
title('Hard Decision Output');
xlabel('Bit Position');
ylabel('Value');
ylim([-0.2 1.2]);
grid on;

% Subplot 3: Soft Decision
subplot(3,3,3);
stem(rx_soft, 'b', 'LineWidth', 2, 'MarkerSize', 8);
title('Soft Decision Output (3-bit)');
xlabel('Bit Position');
ylabel('Value (0-7)');
ylim([-0.5 7.5]);
grid on;

% Subplot 4-5: Decoded Results
subplot(3,3,4);
bar([pesan; decoded_hard]');
title('Hard: Pesan vs Decoded');
xlabel('Bit Position');
ylabel('Value');
legend('Original', 'Decoded');
grid on;
if errors_hard == 0
    text(4, 0.5, '✓', 'FontSize', 20, 'Color', 'g', 'FontWeight', 'bold');
else
    text(4, 0.5, sprintf('%d err', errors_hard), 'FontSize', 12, 'Color', 'r');
end

subplot(3,3,5);
bar([pesan; decoded_soft]');
title('Soft: Pesan vs Decoded');
xlabel('Bit Position');
ylabel('Value');
legend('Original', 'Decoded');
grid on;
if errors_soft == 0
    text(4, 0.5, '✓', 'FontSize', 20, 'Color', 'g', 'FontWeight', 'bold');
else
    text(4, 0.5, sprintf('%d err', errors_soft), 'FontSize', 12, 'Color', 'r');
end

% Subplot 6: BER Comparison
subplot(3,3,[6 9]);
semilogy(SNR_range, BER_hard, 'ro-', 'LineWidth', 2.5, 'MarkerSize', 10);
hold on;
semilogy(SNR_range, BER_soft, 'bs-', 'LineWidth', 2.5, 'MarkerSize', 10);
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('Perbandingan BER: Hard vs Soft Decision', 'FontSize', 14, 'FontWeight', 'bold');
legend('Hard Decision', 'Soft Decision (3-bit)', 'Location', 'southwest', 'FontSize', 11);
ylim([1e-5 1]);

% Subplot 7: Quantization Levels
subplot(3,3,7);
axis off;
text(0.5, 0.95, 'HARD DECISION', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(0.1, 0.80, '> 0 → 1', 'FontSize', 10);
text(0.1, 0.70, '≤ 0 → 0', 'FontSize', 10);
text(0.1, 0.55, '✓ Sederhana', 'FontSize', 9, 'Color', 'green');
text(0.1, 0.45, '✗ Buang confidence', 'FontSize', 9, 'Color', 'red');

text(0.5, 0.30, 'SOFT DECISION', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(0.1, 0.20, '7-6: sangat yakin "1"', 'FontSize', 8);
text(0.1, 0.15, '5-4: yakin "1"', 'FontSize', 8);
text(0.1, 0.10, '3-2: yakin "0"', 'FontSize', 8);
text(0.1, 0.05, '1-0: sangat yakin "0"', 'FontSize', 8);

% Subplot 8: Performance Gain
subplot(3,3,8);
% Hitung gain
target_ber = 1e-3;
idx_hard = find(BER_hard <= target_ber, 1, 'first');
idx_soft = find(BER_soft <= target_ber, 1, 'first');
if ~isempty(idx_hard) && ~isempty(idx_soft)
    snr_hard = SNR_range(idx_hard);
    snr_soft = SNR_range(idx_soft);
    gain = snr_hard - snr_soft;
    bar([snr_hard, snr_soft]);
    title('SNR untuk BER ≈ 10^{-3}');
    ylabel('SNR (dB)');
    set(gca, 'XTickLabel', {'Hard', 'Soft'});
    grid on;
    text(1:2, [snr_hard, snr_soft]+0.3, ...
        {sprintf('%.1f dB', snr_hard), sprintf('%.1f dB', snr_soft)}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    text(1.5, max(snr_hard, snr_soft)+0.8, sprintf('Gain ≈ %.1f dB', gain), ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', 'red', 'FontWeight', 'bold');
else
    text(0.5, 0.5, 'Gain tidak dapat dihitung', 'HorizontalAlignment', 'center');
end

%% Tabel Ringkasan

fprintf('================================================================\n');
fprintf('   TABEL RINGKASAN BER\n');
fprintf('================================================================\n\n');

fprintf('┌─────────┬────────────────┬────────────────┬──────────────┐\n');
fprintf('│ SNR(dB) │  BER (Hard)    │  BER (Soft)    │  Improvement │\n');
fprintf('├─────────┼────────────────┼────────────────┼──────────────┤\n');

for idx = 1:length(SNR_range)
    if BER_soft(idx) > 0
        improvement = BER_hard(idx) / BER_soft(idx);
    else
        improvement = Inf;
    end
    fprintf('│   %2d    │   %.4e   │   %.4e   │    %.2fx     │\n', ...
        SNR_range(idx), BER_hard(idx), BER_soft(idx), improvement);
end

fprintf('└─────────┴────────────────┴────────────────┴──────────────┘\n\n');

%% Kesimpulan

fprintf('================================================================\n');
fprintf('   KESIMPULAN\n');
fprintf('================================================================\n\n');

fprintf('PARAMETER YANG SAMA:\n');
fprintf('  - Traceback Length (tb): %d\n', tb);
fprintf('  - Encoder: K=3, [6 7]\n');
fprintf('  - Modulation: BPSK\n\n');

fprintf('PERBEDAAN:\n');
fprintf('  HARD: Input biner (0/1) setelah threshold\n');
fprintf('  SOFT: Input multi-level (0-7) dengan confidence\n\n');

fprintf('HASIL:\n');
fprintf('  - Soft Decision memberikan gain ~2 dB\n');
fprintf('  - Pada SNR rendah, perbedaan sangat signifikan\n');
fprintf('  - Soft memanfaatkan informasi confidence level\n\n');

fprintf('TRADE-OFF:\n');
fprintf('  Hard: Sederhana, cepat, hemat bandwidth\n');
fprintf('  Soft: Performa lebih baik, tapi lebih kompleks\n\n');

fprintf('================================================================\n');
fprintf('   PROGRAM SELESAI\n');
fprintf('================================================================\n');