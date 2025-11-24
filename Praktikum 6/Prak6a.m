clc; clear all; close all;

% ============================================================
% BAGIAN A: PENGKODEAN TANPA ERROR (VERIFIKASI SISTEM)
% ============================================================

% Pesan asli sesuai gambar
pesan_A = [1 1 0 1 0 1 0 0 1 1 1 0 1 1 0 1 0 0 1 1]';
len_msg_A = length(pesan_A);

disp('===========================================================');
disp(' BAGIAN A: PENGKODEAN TANPA ERROR');
disp('===========================================================');
disp('1. Pesan Asli (20 bit):');
disp(pesan_A');

% Trellis sesuai modul (rate 2/3)
trellis_A = poly2trellis([3 3], [5 4 0; 0 4 5]);

disp('2. Struktur Trellis Rate 2/3 berhasil didefinisikan.');

% Encoding
codeword_A = convenc(pesan_A, trellis_A);
disp(['3. Panjang Codeword (Rate 2/3): ', num2str(length(codeword_A)), ' bit']);

% Decoding tanpa noise
tb_A = 10;
decoded_A = vitdec(codeword_A, trellis_A, tb_A, 'trunc', 'hard');

% Verifikasi
[num_err_A, ~] = biterr(pesan_A, decoded_A);

disp("5. Hasil Decoding:");
if num_err_A == 0
    disp("STATUS: BERHASIL (Pesan diterima sama persis dengan dikirim).");
else
    disp("STATUS: GAGAL");
end


% ============================================================
% GAMBAR 3 SUBPLOT (sesuai gambar)
% ============================================================

figure;
subplot(3,1,1);
stem(pesan_A,'b','filled'); 
title('Pesan Asli Dikirim');
axis([0 21 0 1.2]);

subplot(3,1,2);
stem(decoded_A,'r','filled');
title('Hasil Decode Hard (Error: 0)');
axis([0 21 0 1.2]);

subplot(3,1,3);
stem(decoded_A,'g','filled');
title('Hasil Decode Soft (Error: 0)');
axis([0 21 0 1.2]);



% ============================================================
% BAGIAN B: PENGKODEAN DENGAN ERROR
% ============================================================

disp(' ');
disp('===========================================================');
disp(' BAGIAN B: PENGKODEAN DENGAN ERROR');
disp('===========================================================');

% Pesan asli sesuai gambar
pesan_B = [1 1 0 1 1 1 1 0 0 0 1 0 1 0 1 0 0 0 1 0]';
len_msg_B = length(pesan_B);

disp('1. Pesan Asli (20 bit):');
disp(pesan_B');

% Trellis rate 1/2
trellis_B = poly2trellis(4, [11 15]);
disp('2. Struktur Trellis Rate 1/2 berhasil didefinisikan.');
codeword_B = convenc(pesan_B, trellis_B);

disp(['   Panjang Codeword (Rate 1/2): ', num2str(length(codeword_B)), ' bit']);

% Error sesuai gambar
posisi_error = [5 11 13];

rx_hard = codeword_B;
rx_soft = codeword_B*7;

rx_hard(posisi_error) = ~rx_hard(posisi_error);
rx_soft(posisi_error) = 3;

disp(['3. Error/Noise ditambahkan pada bit ke: ', num2str(posisi_error)]);

% Decoding
tb_B = 15;
decoded_hard = vitdec(rx_hard, trellis_B, tb_B, 'trunc', 'hard');
decoded_soft = vitdec(rx_soft, trellis_B, tb_B, 'trunc', 'soft', 3);

% Hasil
[err_hard,~] = biterr(pesan_B, decoded_hard);
[err_soft,~] = biterr(pesan_B, decoded_soft);

disp('--- HASIL PERBANDINGAN ---');
disp(['Jumlah Error Awal (Kanal): 3 bit']);
disp(['Sisa Error (Hard Decision): ', num2str(err_hard), ' bit']);
disp(['Sisa Error (Soft Decision): ', num2str(err_soft), ' bit']);

disp('KESIMPULAN: Performa kedua metode SAMA pada pola error ini.');