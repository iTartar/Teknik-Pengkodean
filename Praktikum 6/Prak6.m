% =========================================================================
% PERCOBAAN 6: KODE KONVOLUSI HARD DAN SOFT DECISION
% Nama File : Prak6.m
% =========================================================================

clear all; clc;
close all;

disp('===========================================================');
disp(' BAGIAN A: PENGKODEAN TANPA ERROR (VERIFIKASI SISTEM) ');
disp('===========================================================');

% 1. Membangkitkan Sinyal Informasi
len_msg_A = 20;
pesan_A = randi([0 1], len_msg_A, 1);
disp('1. Pesan Asli (20 bit):');
disp(pesan_A');

% 2. Mendefinisikan Encoder Rate 2/3
trellis_A = poly2trellis([3 3], [5 4 0; 0 4 5]);
disp('2. Struktur Trellis Rate 2/3 berhasil didefinisikan.');

% 3. Proses Encoding
codeword_A = convenc(pesan_A, trellis_A);
disp(['3. Panjang Codeword (Rate 2/3): ', num2str(length(codeword_A)), ' bit']);

% 4. Proses Decoding (Hard Decision)
tb_A = 10;
decoded_A = vitdec(codeword_A, trellis_A, tb_A, 'trunc', 'hard');

% 5. Verifikasi Hasil
[num_err_A, ~] = biterr(pesan_A, decoded_A);
disp('5. Hasil Decoding:');
if num_err_A == 0
    disp('   STATUS: BERHASIL (Pesan diterima sama persis dengan dikirim).');
else
    disp(['   STATUS: GAGAL (Terdapat ', num2str(num_err_A), ' bit error).']);
end
disp(' ');


disp('===========================================================');
disp(' BAGIAN B: PENGKODEAN DENGAN ERROR (HARD VS SOFT)');
disp('===========================================================');

% 1. Membangkitkan Sinyal Informasi
len_msg_B = 20;
pesan_B = randi([0 1], len_msg_B, 1);
disp('1. Pesan Asli (20 bit):');
disp(pesan_B');

% 2. Encoder Rate 1/2
trellis_B = poly2trellis(4, [11 15]);
disp('2. Struktur Trellis Rate 1/2 berhasil didefinisikan.');

% Encoding
codeword_B = convenc(pesan_B, trellis_B);
disp(['   Panjang Codeword (Rate 1/2): ', num2str(length(codeword_B)), ' bit']);

% 3. Simulasi Kanal: Menambahkan ERROR
posisi_error = [5, 11, 13];
rx_hard = codeword_B;          % Hard decision input
rx_soft = codeword_B * 7;      % Soft decision input (0→0, 1→7)

% Terapkan error
rx_hard(posisi_error) = ~rx_hard(posisi_error); % Flip bit
rx_soft(posisi_error) = 3;                      % Nilai ambigu untuk soft

disp(['3. Error/Noise ditambahkan pada bit ke: ', num2str(posisi_error)]);

% 4. Decoding
tb_B = 15;

decoded_hard = vitdec(rx_hard, trellis_B, tb_B, 'trunc', 'hard');
decoded_soft = vitdec(rx_soft, trellis_B, tb_B, 'trunc', 'soft', 3);

% 5. Analisa & Perbandingan
[err_hard, ~] = biterr(pesan_B, decoded_hard);
[err_soft, ~] = biterr(pesan_B, decoded_soft);

disp(' ');
disp('--- HASIL PERBANDINGAN ---');
disp(['Jumlah Error Awal (Kanal): ', num2str(length(posisi_error)), ' bit']);
disp(['Sisa Error (Hard Decision): ', num2str(err_hard), ' bit']);
disp(['Sisa Error (Soft Decision): ', num2str(err_soft), ' bit']);
disp(' ');

if err_soft < err_hard
    disp('KESIMPULAN: Metode Soft Decision LEBIH UNGGUL.');
elseif err_soft == err_hard
    disp('KESIMPULAN: Performa kedua metode SAMA pada pola error ini.');
else
    disp('KESIMPULAN: Hard Decision lebih unggul (jarang terjadi).');
end

% 6. Visualisasi
figure('Name', 'Perbandingan Hard vs Soft Decision');

subplot(3,1,1);
stem(pesan_B, 'b', 'filled');
title('Pesan Asli Dikirim');
axis([0 21 0 1.2]);

subplot(3,1,2);
stem(decoded_hard, 'r', 'filled');
title(['Hasil Decode Hard (Error: ', num2str(err_hard), ')']);
axis([0 21 0 1.2]);

subplot(3,1,3);
stem(decoded_soft, 'g', 'filled');
title(['Hasil Decode Soft (Error: ', num2str(err_soft), ')']);
axis([0 21 0 1.2]);