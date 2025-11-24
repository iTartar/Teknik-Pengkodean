% =========================================================================
% TUGAS B: PERBANDINGAN HARD VS SOFT DECISION (DENGAN ERROR)
% =========================================================================
clear all; clc; close all;
disp('=== TUGAS B: HARD vs SOFT DECISION ===');

% 1. Bangkitkan Informasi 
len_msg = 20;
msg = randi([0 1], len_msg, 1);
disp('Pesan Asli:');
disp(msg');

% 2. Encoder Rate 1/2 (Sesuai Modul: poly2trellis(4, [11 15]))
trellis = poly2trellis(4, [11 15]);

codeword = convenc(msg, trellis);
N = length(codeword);
disp(['Panjang Codeword: ', num2str(N)]);

% 3. Menambahkan Error pada posisi tertentu
error_pos = [3, 7, 12];   % Posisi error sesuai perintah
noise = zeros(N,1);
noise(error_pos) = 1;

% HARD DECISION (bit dibalik)
rx_hard_code = xor(codeword, noise);

% SOFT DECISION (0→0 yakin, 1→7 yakin, error→nilai tengah 3)
rx_soft_code = zeros(N,1);

for i = 1:N
    if codeword(i) == 0
        rx_soft_code(i) = 1;      % yakin 0
    else
        rx_soft_code(i) = 6;      % yakin 1
    end
    
    if ismember(i, error_pos)
        rx_soft_code(i) = 3;      % ragu² untuk soft decision
    end
end

% 4. Decoding
tb = 10;

decoded_hard = vitdec(rx_hard_code, trellis, tb, 'trunc', 'hard');
decoded_soft = vitdec(rx_soft_code, trellis, tb, 'trunc', 'soft', 3);

% 5. Analisa Hasil
[err_hard, ~] = biterr(msg, decoded_hard);
[err_soft, ~] = biterr(msg, decoded_soft);

fprintf('\n--- HASIL PERBANDINGAN ---\n');
fprintf('Jumlah bit error pada kanal     : %d\n', sum(noise));
fprintf('Error setelah HARD Decision     : %d\n', err_hard);
fprintf('Error setelah SOFT Decision     : %d\n', err_soft);

if err_soft < err_hard
    disp('Kesimpulan: Soft Decision lebih baik.');
elseif err_soft == err_hard
    disp('Kesimpulan: Keduanya memiliki performa sama.');
else
    disp('Kesimpulan: Anomali (Hard lebih baik, jarang terjadi).');
end

% 6. Plotting
figure('Name','Tugas B: Hard vs Soft Decision');

subplot(4,1,1);
stem(msg,'b','filled');
title('Pesan Asli');
axis([0 len_msg 0 1.2]);

subplot(4,1,2);
stem(rx_hard_code,'k','filled');
title('Codeword diterima (Hard + Noise)');

subplot(4,1,3);
stem(decoded_hard,'r','filled');
title(['Decode Hard Error = ' num2str(err_hard)]);
axis([0 len_msg 0 1.2]);

subplot(4,1,4);
stem(decoded_soft,'g','filled');
title(['Decode Soft Error = ' num2str(err_soft)]);
axis([0 len_msg 0 1.2]);