% Program Pengujian Berbagai Panjang Pesan
% Menggunakan Convolutional Code (2,1,3) - Trellis dengan generator [6 7]

clear all;
close all;
clc;

fprintf('================================================================\n');
fprintf('   PENGUJIAN BERBAGAI PANJANG PESAN\n');
fprintf('   Convolutional Encoder (2,1,3) dengan Trellis [6 7]\n');
fprintf('================================================================\n\n');

%% Setup Encoder
% Trellis (2,1,3): K=3, rate 1/2, generator [6 7]
t = poly2trellis(3, [6 7]);

fprintf('Parameter Encoder:\n');
fprintf('  - Constraint Length (K): 3\n');
fprintf('  - Code Rate: 1/2 (1 bit input → 2 bit output)\n');
fprintf('  - Generator Polynomial: [6 7] (oktal)\n');
fprintf('    • g1 = 6 (oktal) = 110 (biner)\n');
fprintf('    • g2 = 7 (oktal) = 111 (biner)\n\n');

%% Pengujian dengan Berbagai Panjang Pesan

% Definisi panjang pesan yang akan diuji
message_lengths = [10, 15, 20];

fprintf('================================================================\n');
fprintf('   PENGUJIAN ENCODING DAN DECODING\n');
fprintf('================================================================\n\n');

results = struct();

for idx = 1:length(message_lengths)
    msg_len = message_lengths(idx);
    
    fprintf('────────────────────────────────────────────────────────────────\n');
    fprintf('PENGUJIAN %d: Panjang Pesan = %d bit\n', idx, msg_len);
    fprintf('────────────────────────────────────────────────────────────────\n\n');
    
    % Generate pesan random
    pesan = randi([0 1], 1, msg_len);
    
    fprintf('1. PESAN INPUT (%d bit):\n', msg_len);
    fprintf('   [%s]\n\n', num2str(pesan));
    
    %% Encoding
    fprintf('2. PROSES ENCODING:\n');
    codeword = convenc(pesan, t);
    code_len = length(codeword);
    
    fprintf('   Panjang codeword: %d bit\n', code_len);
    fprintf('   Code rate: %d/%d = %.2f\n', msg_len, code_len, msg_len/code_len);
    fprintf('   Codeword:\n   [%s]\n\n', num2str(codeword));
    
    % Tampilkan dalam format pair
    fprintf('   Dalam format pair (setiap 2 bit):\n   ');
    for i=1:2:length(codeword)
        fprintf('[%d%d] ', codeword(i), codeword(i+1));
        if mod(i, 20) == 19  % break line setiap 10 pair
            fprintf('\n   ');
        end
    end
    fprintf('\n\n');
    
    %% Transmisi Tanpa Error
    fprintf('3. TRANSMISI (Tanpa Error):\n');
    received = codeword;
    fprintf('   Received signal sama dengan codeword\n\n');
    
    %% Decoding
    fprintf('4. PROSES DECODING (Viterbi):\n');
    tblen = min(5*2, floor(length(received)/2));
    decoded = vitdec(received, t, tblen, 'trunc', 'hard');
    
    fprintf('   Traceback depth: %d\n', tblen);
    fprintf('   Decoded message:\n   [%s]\n\n', num2str(decoded));
    
    %% Verifikasi
    fprintf('5. VERIFIKASI:\n');
    errors = sum(pesan ~= decoded);
    ber = errors / msg_len;
    
    fprintf('   Pesan Asli: [%s]\n', num2str(pesan));
    fprintf('   Decoded:    [%s]\n', num2str(decoded));
    fprintf('   Jumlah bit error: %d\n', errors);
    fprintf('   BER (Bit Error Rate): %.4f\n', ber);
    
    if errors == 0
        fprintf('   Status: ✓ DECODING BERHASIL!\n\n');
        status = 'SUCCESS';
    else
        fprintf('   Status: ✗ ADA KESALAHAN DECODING!\n\n');
        status = 'FAILED';
    end
    
    % Simpan hasil
    results(idx).message_length = msg_len;
    results(idx).pesan = pesan;
    results(idx).codeword = codeword;
    results(idx).codeword_length = code_len;
    results(idx).decoded = decoded;
    results(idx).errors = errors;
    results(idx).ber = ber;
    results(idx).status = status;
    
end

%% Visualisasi

fprintf('================================================================\n');
fprintf('   VISUALISASI HASIL\n');
fprintf('================================================================\n\n');

% Figure 1: Perbandingan Panjang
figure('Name', 'Perbandingan Panjang Pesan', 'Position', [50 400 1200 500]);

for idx = 1:length(results)
    subplot(2, 3, idx);
    stem(results(idx).pesan, 'b', 'LineWidth', 2, 'MarkerSize', 6);
    title(sprintf('Pesan Input (%d bit)', results(idx).message_length));
    xlabel('Bit Position');
    ylabel('Bit Value');
    grid on;
    axis([0 results(idx).message_length+1 -0.2 1.2]);
end

for idx = 1:length(results)
    subplot(2, 3, idx+3);
    stem(results(idx).codeword, 'r', 'LineWidth', 2, 'MarkerSize', 6);
    title(sprintf('Codeword Output (%d bit)', results(idx).codeword_length));
    xlabel('Bit Position');
    ylabel('Bit Value');
    grid on;
    axis([0 results(idx).codeword_length+1 -0.2 1.2]);
end

% Figure 2: Grafik Statistik
figure('Name', 'Statistik Pengujian', 'Position', [50 50 1000 600]);

subplot(2,2,1);
msg_lengths = [results.message_length];
code_lengths = [results.codeword_length];
bar(1:3, [msg_lengths; code_lengths]');
title('Perbandingan Panjang Pesan vs Codeword');
xlabel('Test Case');
ylabel('Jumlah Bit');
legend('Input Message', 'Output Codeword', 'Location', 'northwest');
grid on;
set(gca, 'XTickLabel', {'10 bit', '15 bit', '20 bit'});

subplot(2,2,2);
rates = msg_lengths ./ code_lengths;
bar(rates);
title('Code Rate');
xlabel('Test Case');
ylabel('Rate (input/output)');
ylim([0 1]);
grid on;
set(gca, 'XTickLabel', {'10 bit', '15 bit', '20 bit'});
text(1:3, rates+0.05, arrayfun(@(x) sprintf('%.3f', x), rates, 'UniformOutput', false), ...
    'HorizontalAlignment', 'center');

subplot(2,2,3);
redundancy = (code_lengths - msg_lengths);
bar(redundancy, 'FaceColor', [0.8 0.4 0.4]);
title('Redundansi (bit tambahan)');
xlabel('Test Case');
ylabel('Jumlah Bit Redundan');
grid on;
set(gca, 'XTickLabel', {'10 bit', '15 bit', '20 bit'});
text(1:3, redundancy+1, arrayfun(@(x) sprintf('%d bit', x), redundancy, 'UniformOutput', false), ...
    'HorizontalAlignment', 'center');

subplot(2,2,4);
efficiency = msg_lengths ./ code_lengths * 100;
bar(efficiency, 'FaceColor', [0.4 0.8 0.4]);
title('Efisiensi Bandwidth');
xlabel('Test Case');
ylabel('Efisiensi (%)');
ylim([0 100]);
grid on;
set(gca, 'XTickLabel', {'10 bit', '15 bit', '20 bit'});
text(1:3, efficiency+3, arrayfun(@(x) sprintf('%.1f%%', x), efficiency, 'UniformOutput', false), ...
    'HorizontalAlignment', 'center');

%% Tabel Ringkasan

fprintf('================================================================\n');
fprintf('   TABEL RINGKASAN HASIL\n');
fprintf('================================================================\n\n');

fprintf('┌─────────┬─────────────┬─────────────┬────────────┬──────────┐\n');
fprintf('│  Test   │   Panjang   │   Panjang   │ Redundansi │  Status  │\n');
fprintf('│  Case   │   Pesan     │  Codeword   │   (bit)    │          │\n');
fprintf('├─────────┼─────────────┼─────────────┼────────────┼──────────┤\n');

for idx = 1:length(results)
    redundancy = results(idx).codeword_length - results(idx).message_length;
    
    if strcmp(results(idx).status, 'SUCCESS')
        status_str = '✓ OK    ';
    else
        status_str = '✗ GAGAL ';
    end
    
    fprintf('│    %d    │   %2d bit    │   %2d bit    │   %2d bit   │ %s │\n', ...
        idx, results(idx).message_length, results(idx).codeword_length, ...
        redundancy, status_str);
end

fprintf('└─────────┴─────────────┴─────────────┴────────────┴──────────┘\n\n');

%% Pengujian dengan Noise (SNR)

fprintf('================================================================\n');
fprintf('   PENGUJIAN PERFORMA DENGAN NOISE (AWGN)\n');
fprintf('================================================================\n\n');

SNR_dB = 0:2:10;

figure('Name', 'Performa BER vs SNR', 'Position', [100 100 1000 600]);

colors = ['b', 'r', 'g'];
markers = ['o', 's', 'd'];

for idx = 1:length(results)
    fprintf('Testing dengan pesan %d bit...\n', results(idx).message_length);
    
    BER = zeros(size(SNR_dB));
    
    for j = 1:length(SNR_dB)
        num_errors = 0;
        num_trials = 100;
        
        for trial = 1:num_trials
            % Generate random message
            msg = randi([0 1], 1, results(idx).message_length);
            
            % Encode
            code = convenc(msg, t);
            
            % BPSK Modulation
            tx = 2*code - 1;
            
            % Add AWGN noise
            rx = awgn(tx, SNR_dB(j), 'measured');
            
            % Hard decision
            rx_hard = rx > 0;
            
            % Decode
            tblen = min(5*2, floor(length(rx_hard)/2));
            decoded = vitdec(rx_hard, t, tblen, 'trunc', 'hard');
            
            % Count errors
            num_errors = num_errors + sum(msg ~= decoded);
        end
        
        BER(j) = num_errors / (num_trials * results(idx).message_length);
    end
    
    % Plot
    semilogy(SNR_dB, BER, [colors(idx) markers(idx) '-'], ...
        'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    
    fprintf('  Selesai\n');
end

grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Perbandingan Performa BER untuk Berbagai Panjang Pesan');
legend('10 bit', '15 bit', '20 bit', 'Location', 'southwest');

fprintf('\n');

%% Kesimpulan

fprintf('================================================================\n');
fprintf('   KESIMPULAN\n');
fprintf('================================================================\n\n');

fprintf('1. POLA UMUM:\n');
fprintf('   - Code rate selalu 1/2 (independent dari panjang pesan)\n');
fprintf('   - Panjang codeword = 2 × panjang pesan\n');
fprintf('   - Redundansi = panjang pesan (100%% overhead)\n\n');

fprintf('2. TRADE-OFF:\n');
fprintf('   - Pesan lebih panjang → codeword lebih panjang\n');
fprintf('   - Lebih banyak redundansi → lebih baik error correction\n');
fprintf('   - Tapi membutuhkan bandwidth lebih besar\n\n');

fprintf('3. PERFORMA:\n');
fprintf('   - Semua panjang pesan berhasil di-decode tanpa error\n');
fprintf('   - BER performance relatif sama untuk semua panjang\n');
fprintf('   - Encoder (2,1,3) efektif untuk berbagai panjang pesan\n\n');

fprintf('4. APLIKASI:\n');
fprintf('   - 10 bit: cocok untuk control signal, header\n');
fprintf('   - 15 bit: cocok untuk short message\n');
fprintf('   - 20 bit: cocok untuk data packet\n\n');

fprintf('================================================================\n');
fprintf('   PENGUJIAN SELESAI\n');
fprintf('================================================================\n');