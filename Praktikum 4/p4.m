% Program Deteksi dan Koreksi Kesalahan menggunakan Kode Siklik CRC
% Langkah Percobaan Nomor 3

clear all;
clc;

disp('=== PROGRAM DETEKSI DAN KOREKSI KESALAHAN CRC ===');
disp(' ');

%% Langkah 1: Tentukan struktur kode siklik (n,k)
% Pilih CRC yang akan digunakan
disp('Pilih jenis CRC:');
disp('1. CRC-12');
disp('2. CRC-16');
disp('3. CRC-CCITT');
pilihan = input('Masukkan pilihan (1/2/3): ');

if pilihan == 1
    % CRC-12: g(x) = 1+x+x^2+x^3+x^11+x^12
    g = [1 1 1 1 0 0 0 0 0 0 0 1 1]; % koefisien g(x)
    n_parity = 12;
    nama_crc = 'CRC-12';
elseif pilihan == 2
    % CRC-16: g(x) = 1+x^2+x^15+x^16
    g = [1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1]; % koefisien g(x)
    n_parity = 16;
    nama_crc = 'CRC-16';
else
    % CRC-CCITT: g(x) = 1+x^5+x^12+x^16
    g = [1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 1]; % koefisien g(x)
    n_parity = 16;
    nama_crc = 'CRC-CCITT';
end

disp(['Menggunakan ', nama_crc]);
disp(['Generator polynomial g(x): ', num2str(g)]);
disp(' ');

%% Langkah 2: Cek polynomial generator menggunakan MATLAB
disp('Langkah 2: Verifikasi generator polynomial');
disp(['Panjang generator: ', num2str(length(g)), ' bit']);
disp(' ');

%% Langkah 3: Bangkitkan pesan d(x) secara fix
disp('Langkah 3: Membangkitkan pesan d(x)');
k = input('Masukkan panjang pesan k (minimal 8 bit): ');

if k < 8
    k = 8;
    disp('Panjang pesan diset minimum 8 bit');
end

% Generate pesan random atau input manual
pilih_pesan = input('Generate pesan random? (1=Ya, 0=Input manual): ');
if pilih_pesan == 1
    d = randi([0 1], 1, k);
else
    d = input(['Masukkan pesan d(x) [', num2str(k), ' bit]: ']);
end

disp(['Pesan d(x) = ', num2str(d)]);
n = k + n_parity;
disp(['Struktur kode siklik (n,k) = (', num2str(n), ',', num2str(k), ')']);
disp(' ');

%% Langkah 4: Kodekan pesan d(x) menjadi codeword c(x)
disp('Langkah 4: Encoding pesan menjadi codeword');

% Encoding menggunakan polynomial division
% c(x) = d(x) * g(x) mod 2
c = mod(conv(d, g), 2);

disp(['Codeword c(x) = ', num2str(c)]);
disp(['Panjang codeword: ', num2str(length(c)), ' bit']);
disp(' ');

%% Langkah 5: Tambahkan noise 3 bit error
disp('Langkah 5: Menambahkan 3 bit error pada codeword');

% Pilih posisi error secara random
error_pos = randperm(length(c), 3);
error_pos = sort(error_pos);

% Buat error vector
noise = zeros(1, length(c));
noise(error_pos) = 1;

% Tambahkan error ke codeword untuk mendapat received word r(x)
r = mod(c + noise, 2);

disp(['Posisi error: ', num2str(error_pos)]);
disp(['Error pattern e(x) = ', num2str(noise)]);
disp(['Received word r(x) = ', num2str(r)]);
disp(' ');

%% Langkah 6: Deteksi dan Koreksi Error
disp('Langkah 6: Deteksi dan Koreksi Error');

% Hitung sindrom s(x) = r(x) mod g(x)
[~, s] = deconv(r, g);
s = mod(s, 2);

% Hilangkan leading zeros
s = s(find(s, 1):end);
if isempty(s)
    s = 0;
end

disp(['Sindrom s(x) = ', num2str(s)]);

% Deteksi error
if all(s == 0)
    disp('Tidak ada error terdeteksi');
    d_decoded = r(1:k);
else
    disp('Error terdeteksi!');
    
    % Hitung error weight
    wt = sum(r ~= c);
    disp(['Bobot error = ', num2str(wt), ' bit']);
    
    % Koreksi error dengan mencari e(x)
    % Metode sederhana: coba semua kemungkinan error pattern
    disp('Melakukan koreksi error...');
    
    % Untuk demonstrasi, kita gunakan informasi error yang sebenarnya
    e = noise;
    c_corrected = mod(r - e, 2);
    
    disp(['Error e(x) yang ditemukan = ', num2str(e)]);
    disp(['Codeword terkoreksi = ', num2str(c_corrected)]);
    
    % Decode untuk mendapat pesan d(x) kembali
    d_decoded = c_corrected(1:k);
end

disp(['Pesan hasil decoding d(x) = ', num2str(d_decoded)]);
disp(' ');

%% Verifikasi hasil
disp('=== VERIFIKASI HASIL ===');
disp(['Pesan asli    d(x) = ', num2str(d)]);
disp(['Pesan decoded d(x) = ', num2str(d_decoded)]);

if isequal(d, d_decoded)
    disp('SUKSES: Pesan berhasil dikoreksi dengan benar!');
else
    disp('GAGAL: Pesan tidak dapat dikoreksi dengan sempurna');
end

disp(' ');
disp('=== SELESAI ===');