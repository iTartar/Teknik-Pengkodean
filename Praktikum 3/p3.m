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
error([5],1)=1
code_error=xor(error,codeword')
code_noise=fix(code_error)
cek=[codeword' code_noise]

%proses decoding dari codeword bernoise
pesan_diterima=decode(code_noise,7,4,'cyclic')
cek_pesan=[pesan' pesan_diterima]

%plot
subplot(3,1,1)
stem(pesan,'b')
title('Pesan yang dikirim')
subplot(3,1,2)
stem(code_noise,'m')
ylabel('Codeword dengan 3 bit error')
subplot(3,1,3)
stem(code_diterima,'r')
xlabel('Pesan yang diterima')


