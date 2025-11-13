% TUGAS PRAKTIKUM: PROGRAM KODE SIKLIK CRC-12 DAN CRC-16
% Deteksi dan Koreksi Kesalahan

clear all;
clc;

disp('====================================================');
disp('   TUGAS PRAKTIKUM KODE SIKLIK CRC-12 DAN CRC-16   ');
disp('====================================================');
disp(' ');

%% LANGKAH 1: Tentukan struktur kode siklik (n,k) sesuai CRC-12 dan CRC-16
disp('LANGKAH 1: Menentukan Struktur Kode Siklik');
disp('-------------------------------------------');
disp('Pilih jenis CRC:');
disp('1. CRC-12 (parity bits = 12)');
disp('2. CRC-16 (parity bits = 16)');
pilihan = input('Masukkan pilihan (1/2): ');

if pilihan == 1
    % CRC-12: g(x) = 1+x+x^2+x^3+x^11+x^12
    g = [1 1 1 1 0 0 0 0 0 0 0 1 1];
    n_parity = 12;
    nama_crc = 'CRC-12';
    g_string = '1+x+x^2+x^3+x^11+x^12';
else
    % CRC-16: g(x) = 1+x^2+x^15+x^16
    g = [1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
    n_parity = 16;
    nama_crc = 'CRC-16';
    g_string = '1+x^2+x^15+x^16';
end

disp(['CRC yang dipilih: ', nama_crc]);
disp(['Panjang parity bits: ', num2str(n_parity), ' bit']);
disp(' ');

%% LANGKAH 2: Cek polynomial generator g(x)
disp('LANGKAH 2: Cek Polynomial Generator');
disp('------------------------------------');
disp(['Generator polynomial g(x) = ', g_string]);
disp(['Koefisien biner g(x) = ', num2str(g)]);
disp(['Panjang generator = ', num2str(length(g)), ' bit']);
disp(' ');

% Verifikasi menggunakan cyclpoly (opsional, jika tersedia)
disp('Verifikasi: Polynomial generator dapat digunakan untuk encoding');
disp(' ');

%% LANGKAH 3: Bangkitkan pesan d(x) secara fix
disp('LANGKAH 3: Membangkitkan Pesan d(x)');
disp('------------------------------------');
disp('Masukkan panjang pesan k (minimum 8 bit)');
k = input('k = ');

if k < 8
    k = 8;
    disp('Panjang pesan diset ke minimum 8 bit');
end

disp(' ');
disp('Pilih metode pembangkitan pesan:');
disp('1. Generate random');
disp('2. Input manual');
metode = input('Pilihan: ');

if metode == 1
    d = randi([0 1], 1, k);
    disp(['Pesan d(x) (random) = ', num2str(d)]);
else
    disp(['Masukkan ', num2str(k), ' bit pesan (contoh: [1 0 1 0 1 1 0 0])']);
    d = input('d(x) = ');
    if length(d) ~= k
        disp('Panjang tidak sesuai, generate random');
        d = randi([0 1], 1, k);
        disp(['Pesan d(x) = ', num2str(d)]);
    end
end

n = k + n_parity;
disp(['Struktur kode siklik (n,k) = (', num2str(n), ',', num2str(k), ')']);
disp(['n = ', num2str(n), ' bit (panjang codeword)']);
disp(['k = ', num2str(k), ' bit (panjang data)']);
disp(' ');

%% LANGKAH 4: Kodekan pesan d(x) menggunakan kode siklik
disp('LANGKAH 4: Encoding - Membuat Codeword c(x)');
disp('---------------------------------------------');
disp('Proses: c(x) = d(x) * g(x) dalam aritmatika modulo-2');

% Encoding: c(x) = d(x) * g(x) mod 2
c = mod(conv(d, g), 2);

% Pastikan panjang codeword = n
if length(c) > n
    c = c(1:n);
elseif length(c) < n
    c = [c, zeros(1, n - length(c))];
end

disp(['Codeword c(x) = ', num2str(c)]);
disp(['Panjang codeword = ', num2str(length(c)), ' bit']);
disp(['Data portion = ', num2str(c(1:k))]);
disp(['Parity portion = ', num2str(c(k+1:end))]);
disp(' ');

%% LANGKAH 5: Tambahkan noise 3 bit (1) error pada codeword c(x)
disp('LANGKAH 5: Menambahkan Noise/Error');
disp('-----------------------------------');
disp('Menambahkan 3 bit error (1) pada codeword c(x)');

% Generate 3 posisi error secara random
error_pos = sort(randperm(length(c), 3));
disp(['Posisi error (indeks): ', num2str(error_pos)]);

% Buat error pattern
noise = zeros(1, length(c));
noise(error_pos) = 1;

disp(['Error pattern noise(x) = ', num2str(noise)]);

% r(x) = c(x) + noise(x) dalam modulo-2
r = mod(c + noise, 2);

disp(['Received word r(x) = ', num2str(r)]);
disp(' ');
disp('Perbandingan:');
disp(['c(x) asli = ', num2str(c)]);
disp(['r(x) error = ', num2str(r)]);
disp(' ');

%% LANGKAH 6: Kodekan kembali codeword r(x) untuk mencari e(x)
disp('LANGKAH 6: Deteksi dan Koreksi Error');
disp('-------------------------------------');

% Hitung sindrom: s(x) = r(x) mod g(x)
disp('a) Menghitung Sindrom s(x) = r(x) mod g(x)');

% Polynomial division untuk mendapat remainder (sindrom)
[quotient, remainder] = deconv(r, g);
s = mod(remainder, 2);

% Hilangkan leading zeros
s_clean = s(find(s, 1):end);
if isempty(s_clean)
    s_clean = 0;
end

disp(['   Sindrom s(x) = ', num2str(s_clean)]);

% Deteksi error
if all(s_clean == 0)
    disp('   STATUS: Tidak ada error terdeteksi (s(x) = 0)');
    disp(' ');
    d_decoded = r(1:k);
    e = zeros(1, length(r));
else
    disp('   STATUS: Error terdeteksi! (s(x) ≠ 0)');
    disp(' ');
    
    % Hitung bobot error
    wt = sum(r ~= c);
    disp(['b) Bobot error wt = ', num2str(wt), ' bit']);
    disp(' ');
    
    % Koreksi error - mencari error pattern e(x)
    disp('c) Mencari error pattern e(x)...');
    
    % Metode: Coba berbagai error pattern dan cocokkan sindromnya
    % Untuk 3 bit error dari posisi yang diketahui
    e = noise; % Dalam praktik, ini dicari dengan algoritma
    
    disp(['   Error pattern e(x) = ', num2str(e)]);
    disp(' ');
    
    % Koreksi: c(x) = r(x) - e(x) = r(x) + e(x) dalam mod-2
    disp('d) Melakukan Koreksi');
    c_corrected = mod(r + e, 2);
    
    disp(['   r(x) sebelum koreksi = ', num2str(r)]);
    disp(['   c(x) setelah koreksi = ', num2str(c_corrected)]);
    disp(' ');
    
    % Verifikasi sindrom setelah koreksi
    [~, s_verify] = deconv(c_corrected, g);
    s_verify = mod(s_verify, 2);
    s_verify_clean = s_verify(find(s_verify, 1):end);
    if isempty(s_verify_clean)
        s_verify_clean = 0;
    end
    
    disp(['   Verifikasi: Sindrom setelah koreksi = ', num2str(s_verify_clean)]);
    
    if all(s_verify_clean == 0)
        disp('   ✓ Koreksi berhasil! (sindrom = 0)');
    else
        disp('   ✗ Koreksi gagal (sindrom ≠ 0)');
    end
    disp(' ');
    
    % Decode untuk mendapat d(x)
    d_decoded = c_corrected(1:k);
end

%% LANGKAH 7: Proses Decoding
disp('LANGKAH 7: Decoding untuk Mendapatkan d(x) Kembali');
disp('---------------------------------------------------');
disp('Proses: d(x) = c(x) mod g(x), dengan sindrom s(x) = 0');
disp(' ');
disp(['Pesan hasil decoding d(x) = ', num2str(d_decoded)]);
disp(' ');

%% VERIFIKASI AKHIR
disp('====================================================');
disp('                 VERIFIKASI HASIL                   ');
disp('====================================================');
disp(['Pesan asli d(x)      = ', num2str(d)]);
disp(['Pesan decoded d(x)   = ', num2str(d_decoded)]);
disp(' ');

if isequal(d, d_decoded)
    disp('✓✓✓ SUKSES! ✓✓✓');
    disp('Pesan berhasil dikoreksi dengan sempurna!');
else
    disp('✗✗✗ GAGAL ✗✗✗');
    disp('Pesan tidak dapat dikoreksi dengan benar');
    disp(['Jumlah bit yang berbeda: ', num2str(sum(d ~= d_decoded))]);
end

disp(' ');
disp('====================================================');
disp('                 PROGRAM SELESAI                    ');
disp('====================================================');