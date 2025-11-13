clear
clc
p=cyclpoly(7,4);
[h,g]=cyclgen(7,p);
pesan=[0 0 1 1]
codeword=encode(pesan,7,4,'cyclic')
pesan_diterima=decode(codeword,7,4,'cyclic')
cek=[pesan pesan_diterima]
cek=[pesan' pesan_diterima']
[number,ratio]=biterr(pesan',pesan_diterima')

%Mengeplot pesan tanda noise
subplot(3,1,1)
stem(pesan,'b')
title('Pesan Yang Dikirim')
subplot(3,1,2)
stem(codeword,'m')
ylabel('Codeword Tanpa Error')
subplot(3,1,3)
stem(pesan_diterima,'r')
xlabel('Pesan Yang Diterima')

%Untuk mempermudah pengamatan
error=zeros(7,1);
error(5,1)=1
code_error=xor(error,codeword')
code_noise=fix(code_error)
cek=[codeword' code_noise]

%proses decoding dari codeword bernoise
pesan_terima=decode(code_noise,7,4,'cyclic')
cek_pesan=[pesan' pesan_terima]

%plot
figure
subplot(3,1,1)
stem(pesan,'b')
title('Pesan yang dikirim')
subplot(3,1,2)
stem(code_noise,'m')
ylabel('Codeword dengan 1 bit error')
subplot(3,1,3)
stem(pesan_terima,'r')
xlabel('Pesan yang diterima')

%% ===== TUGAS 2: TEST VARIASI ERROR =====
fprintf('\n=== TUGAS 2: VARIASI JUMLAH DAN POSISI ERROR ===\n\n')

% Test 1: Error di berbagai posisi (1 bit)
fprintf('TEST 1 BIT ERROR:\n')
for pos = 1:7
    err = zeros(7,1);
    err(pos) = 1;
    noise = xor(codeword', err);
    terima = decode(noise, 7, 4, 'cyclic');
    if isequal(pesan', terima)
        fprintf('Posisi %d: BERHASIL\n', pos);
    else
        fprintf('Posisi %d: GAGAL\n', pos);
    end
end

% Test 2: Error 2 bit (contoh beberapa kombinasi)
fprintf('\nTEST 2 BIT ERROR:\n')
kombinasi2 = [1 2; 1 5; 3 6; 2 7; 4 5];
for i = 1:size(kombinasi2,1)
    err = zeros(7,1);
    err(kombinasi2(i,1)) = 1;
    err(kombinasi2(i,2)) = 1;
    noise = xor(codeword', err);
    terima = decode(noise, 7, 4, 'cyclic');
    if isequal(pesan', terima)
        fprintf('Posisi %d & %d: BERHASIL\n', kombinasi2(i,1), kombinasi2(i,2));
    else
        fprintf('Posisi %d & %d: GAGAL\n', kombinasi2(i,1), kombinasi2(i,2));
    end
end

% Test 3: Error 3 bit (contoh beberapa kombinasi)
fprintf('\nTEST 3 BIT ERROR:\n')
kombinasi3 = [1 2 3; 1 3 5; 2 4 6; 3 5 7; 1 4 7];
for i = 1:size(kombinasi3,1)
    err = zeros(7,1);
    err(kombinasi3(i,1)) = 1;
    err(kombinasi3(i,2)) = 1;
    err(kombinasi3(i,3)) = 1;
    noise = xor(codeword', err);
    terima = decode(noise, 7, 4, 'cyclic');
    if isequal(pesan', terima)
        fprintf('Posisi %d, %d & %d: BERHASIL\n', kombinasi3(i,1), kombinasi3(i,2), kombinasi3(i,3));
    else
        fprintf('Posisi %d, %d & %d: GAGAL\n', kombinasi3(i,1), kombinasi3(i,2), kombinasi3(i,3));
    end
end

fprintf('\nKESIMPULAN: Kode (7,4) hanya dapat mengoreksi 1 bit error!\n')