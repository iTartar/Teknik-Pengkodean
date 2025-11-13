% Visualisasi Cara Kerja Viterbi Decoder
% Membandingkan error di bit 2&5 vs bit 5&12

clear all;
close all;
clc;

fprintf('============================================================\n');
fprintf('   VISUALISASI VITERBI ERROR CORRECTION\n');
fprintf('   Membandingkan: Error di bit 2&5 vs bit 5&12\n');
fprintf('============================================================\n\n');

%% Setup
t = poly2trellis(3, [6 7]);
pesan_asli = [1 0 1 1 0 1 0 0];

fprintf('Pesan Asli: [%s]\n\n', num2str(pesan_asli));

%% Encoding
codeword = convenc(pesan_asli, t);
fprintf('Codeword (16 bit):\n');
fprintf('[%s]\n', num2str(codeword));
fprintf(' ');
for i=1:length(codeword)
    fprintf('%d', mod(i,10));
    if i < length(codeword), fprintf(' '); end
end
fprintf('\n\n');

% Tampilkan dalam format pair
fprintf('Dalam format pair (setiap 2 bit = 1 symbol):\n');
for i=1:2:length(codeword)
    fprintf('[%d%d] ', codeword(i), codeword(i+1));
end
fprintf('\n');
fprintf(' 1   2   3   4   5   6   7   8  ← symbol index\n\n');

%% Case 1: Error di bit 2 dan 5

fprintf('============================================================\n');
fprintf('CASE 1: ERROR DI BIT 2 dan 5\n');
fprintf('============================================================\n\n');

received1 = codeword;
received1([2 5]) = ~received1([2 5]);

fprintf('Received:\n');
fprintf('[%s]\n', num2str(received1));
fprintf(' ');
for i=1:length(received1)
    if i==2 || i==5
        fprintf('↑');
    else
        fprintf(' ');
    end
    if i < length(received1), fprintf(' '); end
end
fprintf('\n');
fprintf(' error di sini!\n\n');

fprintf('Dalam format pair:\n');
for i=1:2:length(received1)
    if i==1 || i==5  % pair yang mengandung error
        fprintf('[%d%d]*', received1(i), received1(i+1));
    else
        fprintf('[%d%d] ', received1(i), received1(i+1));
    end
end
fprintf('\n');
fprintf(' ↑       ↑   ← pair dengan error (* = ada error)\n\n');

% Hitung Hamming distance per pair
fprintf('Hamming Distance per pair:\n');
total_distance1 = 0;
for i=1:2:length(codeword)
    pair_orig = codeword(i:i+1);
    pair_recv = received1(i:i+1);
    dist = sum(pair_orig ~= pair_recv);
    total_distance1 = total_distance1 + dist;
    
    if dist > 0
        fprintf('  Pair %d: [%d%d] vs [%d%d] → distance = %d ← ERROR\n', ...
            (i+1)/2, pair_orig(1), pair_orig(2), pair_recv(1), pair_recv(2), dist);
    else
        fprintf('  Pair %d: [%d%d] vs [%d%d] → distance = %d\n', ...
            (i+1)/2, pair_orig(1), pair_orig(2), pair_recv(1), pair_recv(2), dist);
    end
end
fprintf('  TOTAL Hamming Distance: %d\n\n', total_distance1);

% Decoding
tblen = min(5*2, floor(length(received1)/2));
decoded1 = vitdec(received1, t, tblen, 'trunc', 'hard');

fprintf('Decoding Result:\n');
fprintf('  Pesan Asli:  [%s]\n', num2str(pesan_asli));
fprintf('  Decoded:     [%s]\n', num2str(decoded1));

errors1 = sum(pesan_asli ~= decoded1);
if errors1 == 0
    fprintf('  Status: ✓ BERHASIL DIKOREKSI!\n\n');
else
    fprintf('  Status: ✗ GAGAL! (%d bit error)\n\n', errors1);
end

fprintf('Penjelasan:\n');
fprintf('  - Error hanya di PAIR 1 dan PAIR 3\n');
fprintf('  - Error terlokalisir di AWAL sequence\n');
fprintf('  - Viterbi bisa trace path yang benar dari 6 pair sisanya\n');
fprintf('  - Path asli tetap punya total distance terkecil\n\n');

%% Case 2: Error di bit 5 dan 12

fprintf('============================================================\n');
fprintf('CASE 2: ERROR DI BIT 5 dan 12\n');
fprintf('============================================================\n\n');

received2 = codeword;
received2([5 12]) = ~received2([5 12]);

fprintf('Received:\n');
fprintf('[%s]\n', num2str(received2));
fprintf(' ');
for i=1:length(received2)
    if i==5 || i==12
        fprintf('↑');
    else
        fprintf(' ');
    end
    if i < length(received2), fprintf(' '); end
end
fprintf('\n');
fprintf(' error di sini!\n\n');

fprintf('Dalam format pair:\n');
for i=1:2:length(received2)
    if i==5 || i==11  % pair yang mengandung error
        fprintf('[%d%d]*', received2(i), received2(i+1));
    else
        fprintf('[%d%d] ', received2(i), received2(i+1));
    end
end
fprintf('\n');
fprintf('     ↑           ↑   ← pair dengan error (* = ada error)\n\n');

% Hitung Hamming distance per pair
fprintf('Hamming Distance per pair:\n');
total_distance2 = 0;
for i=1:2:length(codeword)
    pair_orig = codeword(i:i+1);
    pair_recv = received2(i:i+1);
    dist = sum(pair_orig ~= pair_recv);
    total_distance2 = total_distance2 + dist;
    
    if dist > 0
        fprintf('  Pair %d: [%d%d] vs [%d%d] → distance = %d ← ERROR\n', ...
            (i+1)/2, pair_orig(1), pair_orig(2), pair_recv(1), pair_recv(2), dist);
    else
        fprintf('  Pair %d: [%d%d] vs [%d%d] → distance = %d\n', ...
            (i+1)/2, pair_orig(1), pair_orig(2), pair_recv(1), pair_recv(2), dist);
    end
end
fprintf('  TOTAL Hamming Distance: %d\n\n', total_distance2);

% Decoding
decoded2 = vitdec(received2, t, tblen, 'trunc', 'hard');

fprintf('Decoding Result:\n');
fprintf('  Pesan Asli:  [%s]\n', num2str(pesan_asli));
fprintf('  Decoded:     [%s]\n', num2str(decoded2));

errors2 = sum(pesan_asli ~= decoded2);
if errors2 == 0
    fprintf('  Status: ✓ BERHASIL DIKOREKSI!\n\n');
else
    fprintf('  Status: ✗ GAGAL! (%d bit error)\n\n', errors2);
end

fprintf('Penjelasan:\n');
fprintf('  - Error di PAIR 3 dan PAIR 6\n');
fprintf('  - Error TERSEBAR (tengah dan hampir akhir)\n');
fprintf('  - Kombinasi ini membentuk pola mirip PATH LAIN\n');
fprintf('  - Viterbi SALAH PILIH path alternatif yang lebih cocok\n');
fprintf('  - Path alternatif punya distance lebih kecil ke received\n\n');

%% Visualisasi Grafik

figure('Name', 'Perbandingan Error Pattern', 'Position', [50 100 1400 800]);

% Subplot 1: Codeword Original
subplot(3,3,1);
stem(codeword, 'b', 'LineWidth', 2, 'MarkerSize', 8);
title('Codeword Asli');
xlabel('Bit Position');
ylabel('Value');
grid on;
axis([0 17 -0.2 1.2]);

% Subplot 2: Case 1 - Received
subplot(3,3,2);
stem(received1, 'r', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
stem([2 5], received1([2 5]), 'ko', 'MarkerSize', 12, 'LineWidth', 2);
title('Case 1: Error di bit 2 & 5');
xlabel('Bit Position');
ylabel('Value');
grid on;
axis([0 17 -0.2 1.2]);
legend('Received', 'Error Position');

% Subplot 3: Case 1 - Result
subplot(3,3,3);
bar([pesan_asli; decoded1]');
title(sprintf('Case 1 Result: %d errors', errors1));
xlabel('Bit Position');
ylabel('Value');
legend('Original', 'Decoded');
grid on;
if errors1 == 0
    text(4, 0.5, '✓ BERHASIL', 'FontSize', 14, 'Color', 'g', 'FontWeight', 'bold');
else
    text(4, 0.5, '✗ GAGAL', 'FontSize', 14, 'Color', 'r', 'FontWeight', 'bold');
end

% Subplot 4: Hamming Distance Case 1 (per pair)
subplot(3,3,4);
dist_vec1 = zeros(1,8);
for i=1:2:length(codeword)
    dist_vec1((i+1)/2) = sum(codeword(i:i+1) ~= received1(i:i+1));
end
bar(dist_vec1, 'b');
title('Case 1: Distance per Pair');
xlabel('Pair Index');
ylabel('Hamming Distance');
grid on;
ylim([0 2.5]);

% Subplot 5: Case 2 - Received
subplot(3,3,5);
stem(received2, 'r', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
stem([5 12], received2([5 12]), 'ko', 'MarkerSize', 12, 'LineWidth', 2);
title('Case 2: Error di bit 5 & 12');
xlabel('Bit Position');
ylabel('Value');
grid on;
axis([0 17 -0.2 1.2]);
legend('Received', 'Error Position');

% Subplot 6: Case 2 - Result
subplot(3,3,6);
bar([pesan_asli; decoded2]');
title(sprintf('Case 2 Result: %d errors', errors2));
xlabel('Bit Position');
ylabel('Value');
legend('Original', 'Decoded');
grid on;
if errors2 == 0
    text(4, 0.5, '✓ BERHASIL', 'FontSize', 14, 'Color', 'g', 'FontWeight', 'bold');
else
    text(4, 0.5, '✗ GAGAL', 'FontSize', 14, 'Color', 'r', 'FontWeight', 'bold');
end

% Subplot 7: Hamming Distance Case 2 (per pair)
subplot(3,3,7);
dist_vec2 = zeros(1,8);
for i=1:2:length(codeword)
    dist_vec2((i+1)/2) = sum(codeword(i:i+1) ~= received2(i:i+1));
end
bar(dist_vec2, 'r');
title('Case 2: Distance per Pair');
xlabel('Pair Index');
ylabel('Hamming Distance');
grid on;
ylim([0 2.5]);

% Subplot 8: Error Pattern Comparison
subplot(3,3,8);
plot(1:16, zeros(1,16), 'k--', 'LineWidth', 1);
hold on;
stem([2 5], [1 1], 'bo', 'MarkerSize', 10, 'LineWidth', 2);
stem([5 12], [2 2], 'rs', 'MarkerSize', 10, 'LineWidth', 2);
title('Pola Error');
xlabel('Bit Position');
ylabel('Case');
yticks([1 2]);
yticklabels({'Case 1 (2&5)', 'Case 2 (5&12)'});
grid on;
axis([0 17 0.5 2.5]);
legend('Baseline', 'Error bit 2&5', 'Error bit 5&12');

% Subplot 9: Summary
subplot(3,3,9);
axis off;
text(0.1, 0.9, 'KESIMPULAN:', 'FontWeight', 'bold', 'FontSize', 12);
text(0.1, 0.75, sprintf('Case 1 (bit 2&5): %s', ...
    iif(errors1==0, '✓ BERHASIL', '✗ GAGAL')), 'FontSize', 10);
text(0.1, 0.65, '  • Error terlokalisir di awal', 'FontSize', 9);
text(0.1, 0.58, '  • Pair 1 & 3 terkena', 'FontSize', 9);
text(0.1, 0.51, '  • Viterbi bisa self-correct', 'FontSize', 9);

text(0.1, 0.35, sprintf('Case 2 (bit 5&12): %s', ...
    iif(errors2==0, '✓ BERHASIL', '✗ GAGAL')), 'FontSize', 10);
text(0.1, 0.25, '  • Error tersebar jauh', 'FontSize', 9);
text(0.1, 0.18, '  • Pair 3 & 6 terkena', 'FontSize', 9);
text(0.1, 0.11, '  • Membentuk pola mirip path lain', 'FontSize', 9);

%% Kesimpulan Akhir

fprintf('============================================================\n');
fprintf('   KESIMPULAN AKHIR\n');
fprintf('============================================================\n\n');

fprintf('MENGAPA POSISI ERROR SANGAT PENTING?\n\n');

fprintf('1. VITERBI BEKERJA DENGAN PAIR (2 bit):\n');
fprintf('   - Codeword 16 bit = 8 pair\n');
fprintf('   - Setiap pair = hasil 1 kali transisi state\n');
fprintf('   - Error dalam 1 pair = 1 transisi salah\n\n');

fprintf('2. ERROR TERLOKALISIR (bit 2&5) = MUDAH DIKOREKSI:\n');
fprintf('   - Hanya mempengaruhi 2 pair di awal\n');
fprintf('   - 6 pair sisanya masih benar\n');
fprintf('   - Path asli tetap punya distance minimum\n');
fprintf('   - Viterbi bisa "self-correct" dari context\n\n');

fprintf('3. ERROR TERSEBAR (bit 5&12) = SULIT DIKOREKSI:\n');
fprintf('   - Mempengaruhi pair di tengah dan hampir akhir\n');
fprintf('   - Kombinasi error membuat pola AMBIGUOUS\n');
fprintf('   - Ada path alternatif dengan distance lebih kecil\n');
fprintf('   - Viterbi SALAH PILIH path alternatif\n\n');

fprintf('4. ANALOGI:\n');
fprintf('   Seperti menebak kata dengan huruf hilang:\n');
fprintf('   - "H_L_O" (error di awal) → mudah: HALO ✓\n');
fprintf('   - "HA_O_" (error tersebar) → bingung: HALO? HASO? HAPO? ✗\n\n');

fprintf('5. FREE DISTANCE:\n');
fprintf('   - Free distance (d_free) = 5\n');
fprintf('   - Bisa koreksi maksimal 2 bit error\n');
fprintf('   - TAPI posisi error juga mempengaruhi!\n');
fprintf('   - 2 error di posisi "buruk" bisa gagal!\n\n');

fprintf('============================================================\n');

function out = iif(condition, true_val, false_val)
    if condition
        out = true_val;
    else
        out = false_val;
    end
end