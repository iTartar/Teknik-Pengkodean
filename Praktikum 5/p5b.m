% Program Simulasi Channel Coding - Convolutional Code
% Encoder (2,1,3) dengan Viterbi Decoder

clear all;
close all;
clc;

%% 1. INPUT - Pesan/Informasi
% Masukan pesan 8 bit
pesan_kirim = [1 0 1 1 0 1 0 0];

% Masukan pesan 10 bit
% pesan_kirim = [0  0  1  0  1  1  0  0  1  1];

% Masukan pesan 15 bit
% pesan_kirim = [1  1  1  0  0  0  1  0  1  1  0  0  0  0  1];

% Masukan pesan 20 bit
% pesan_kirim = [0  1  0  1  0  0  0  1  1  1  0  0  1  0  0  1  0  0  0  1];

fprintf('=== CHANNEL CODING SIMULATION ===\n\n');
fprintf('1. Pesan Asli (8 bit):\n');
fprintf('   [%s]\n\n', num2str(pesan_kirim));

%% 2. ENCODER - Proses Pengkodean
% Struktur trellis dengan rate 1/2, constraint length 3
% Polynomial generator: [6 7] dalam oktal
t = poly2trellis(3, [6 7]);

fprintf('Trellis Structure: (2,1,3)\n');
fprintf('Constraint Length: 3\n');
fprintf('Generator Polynomial: [6 7] (oktal)\n');
fprintf('Code Rate: 1/2\n\n');

%% ENCODING
fprintf('2. Proses Encoding:\n');
codeword = convenc(pesan_kirim, t);

fprintf('   Hasil Encoding (Codeword):\n');
fprintf('   [%s]\n', num2str(codeword));
fprintf('   Panjang codeword: %d bit\n\n', length(codeword));

%% 3. TRANSMISI MELALUI CHANNEL
% Simulasi transmisi dengan kemungkinan error
fprintf('3. Transmisi melalui Channel:\n');

% Tanpa error (ideal)
received_signal = codeword;
fprintf('   Sinyal diterima (tanpa noise):\n');
fprintf('   [%s]\n\n', num2str(received_signal));

% Jika ingin simulasi dengan error, uncomment baris berikut:
%error_pos = [2 5]; % posisi bit yang error
%received_signal(error_pos) = ~received_signal(error_pos);
%fprintf('   Sinyal diterima (dengan error di posisi %s):\n', num2str(error_pos));
%fprintf('   [%s]\n\n', num2str(received_signal));

%% DECODER - Viterbi Decoding dengan tb
fprintf('4. Proses Decoding (Viterbi):\n');

% Menggunakan tb = 2 seperti pada contoh gambar
tb = 2;
pesan_terima = vitdec(codeword, t, tb, 'trunc', 'hard');

fprintf('   Traceback depth (tb): %d\n', tb);
fprintf('   Hasil Decoding:\n');
fprintf('   [%s]\n\n', num2str(pesan_terima));

%% VERIFIKASI
fprintf('5. Verifikasi:\n');
fprintf('   Pesan Asli    : [%s]\n', num2str(pesan_kirim));
fprintf('   Pesan Diterima: [%s]\n', num2str(pesan_terima));

% Cek bit error - DIMODIFIKASI: tampil per baris secara horizontal
fprintf('\n   Perbandingan bit (format horizontal):\n');
fprintf('   Bit ke- : ');
for i = 1:length(pesan_kirim)
    fprintf('%2d ', i);
end
fprintf('\n   Kirim   : ');
for i = 1:length(pesan_kirim)
    fprintf(' %d ', pesan_kirim(i));
end
fprintf('\n   Terima  : ');
for i = 1:length(pesan_kirim)
    fprintf(' %d ', pesan_terima(i));
end
fprintf('\n   Status  : ');
for i = 1:length(pesan_kirim)
    if pesan_kirim(i) == pesan_terima(i)
        fprintf(' ✓ ');
    else
        fprintf(' ✗ ');
    end
end
fprintf('\n');

% Hitung BER
[jml_biterr, ratio_biterr] = biterr(pesan_terima, pesan_kirim);

fprintf('\n   Jumlah Bit Error: %d\n', jml_biterr);
fprintf('   Bit Error Rate (BER): %.4f\n', ratio_biterr);

if jml_biterr == 0
    fprintf('   Status: ✓ DECODING BERHASIL!\n\n');
else
    fprintf('   Status: ✗ Ada kesalahan decoding\n\n');
end

%% 6. VISUALISASI
figure('Name', 'Bit Pesan Yang Dikirim', 'Position', [100 500 800 400]);
stem(pesan_kirim, 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Jumlah Bit Pesan');
ylabel('Amplitudo Bit Pesan');
title('Bit Pesan Yang Dikirim');
grid on;
axis([0 9 -0.2 1.2]);

figure('Name', 'Bit Hasil Pengkodean', 'Position', [100 50 800 400]);
stem(codeword, 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Jumlah Bit Codeword');
ylabel('Amplitudo Codeword');
title('Bit Hasil Pengkodean');
grid on;
axis([0 length(codeword)+1 -0.2 1.2]);

%% 7. DIAGRAM ENCODER
figure('Name', 'Struktur Encoder', 'Position', [920 300 600 400]);
subplot(2,1,1);
text(0.5, 0.7, 'CONVOLUTIONAL ENCODER (2,1,3)', ...
    'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
text(0.5, 0.5, sprintf('Generator Polynomial: g1 = 6 (110), g2 = 7 (111)'), ...
    'HorizontalAlignment', 'center', 'FontSize', 11);
text(0.5, 0.3, sprintf('Input: %d bit → Output: %d bit', ...
    length(pesan_kirim), length(codeword)), ...
    'HorizontalAlignment', 'center', 'FontSize', 11);
text(0.5, 0.1, sprintf('Code Rate: 1/2 (setiap 1 bit input → 2 bit output)'), ...
    'HorizontalAlignment', 'center', 'FontSize', 11);
axis off;

subplot(2,1,2);
bar([length(pesan_kirim), length(codeword), length(pesan_terima)]);
set(gca, 'XTickLabel', {'Input', 'Encoded', 'Decoded'});
ylabel('Jumlah Bit');
title('Perbandingan Jumlah Bit');
grid on;