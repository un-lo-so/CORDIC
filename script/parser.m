%script for generate results from the testbench output -for documentation purpose only

%calculate LSBs for modulus and phase 
LSB_modulo =1/(2^8);  
LSB_fase =2*pi/65536; 

moduli = zeros(100,1);
fasi = zeros(100,1);

moduli_giusti = zeros(100,1);
fasi_giuste = zeros(100,1);

%load data provided by testbench
a=fopen('output.txt','r');

for i = 1:100
    C=fgets(a);
    modulo=C(1:16);
    fase=C(18:33);
    
    moduli(i) = bin2dec(modulo)*LSB_modulo;
    fasi(i) = bin2dec(fase)*LSB_fase;
 end
fclose(a);

%The value provided by CORDIC is multiplied by factor, 1.647. So, a
%normalization is required 
moduli = moduli/1.647;

%Calculate the 

%Load data provided as input of CORDIC and calculate exact values
%of modulus and phase

a= fopen('input.txt');

for i = 1:100
    C=fgets(a);
    x=C(1:14);
    y=C(16:29);
    
    xdec=bin2dec(x)*2^-7;
    ydec=bin2dec(y)*2^-7;
%bin2dec takes as input only unsigned but we are interested to the
%signed value of X and Y coordinate, so if X and\or Y are negative
%numbers (according to MSB) a subtraction must be performed to obtain
%the real value

    if (y(1)=='1')
        ydec=ydec-(1/(2*LSB_modulo));      
    end
    
    if (x(1)=='1')
      xdec=xdec-128;
    end
    
    moduli_giusti(i)=sqrt(ydec*ydec+xdec*xdec);

%At this point we know X and Y, but atan return a value between -pi and pi
%but we must know the value between 0 and 2pi: 
    if (xdec>0) && (ydec>0)
        fasi_giuste(i)=atan(ydec/xdec);
    elseif (xdec>0) && (ydec<0)
        fasi_giuste(i)=2*pi+atan(ydec/xdec);
    elseif (xdec<0) && (ydec<0)
        fasi_giuste(i)=pi+atan(ydec/xdec);
    else
        fasi_giuste(i)=pi+atan(ydec/xdec);
    end
end

%data output 
figure('name','moduli');
stem(moduli);
hold on;
stem(moduli_giusti);
title ('moduli');
legend ('modulo calcolato','modulo atteso')

figure('name','fasi');
stem(fasi)
hold on;
stem(fasi_giuste);
ylabel('radianti')
title ('fasi');
legend ('fase calcolata', 'fase attesa');

%calculate the absolute and mean error related to modulus
Ea_moduli = 0;
for i = 1:100
    temp=moduli(i)-moduli_giusti(i);
    Ea_moduli = Ea_moduli + temp;
end

Ea_moduli=Ea_moduli/100;

fprintf('l''errore assoluto sui moduli è %f \n',Ea_moduli);

%calculate the absolute and mean error related to phase
Ea_fasi = 0;
for i = 1:100
    temp=fasi(i)-fasi_giuste(i);
    Ea_fasi = Ea_fasi + temp;
end

Ea_fasi = Ea_fasi/100;
fprintf('l''errore assoluto sulle fasi è %f\n',Ea_fasi);
