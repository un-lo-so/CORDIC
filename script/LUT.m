%script that create entries of the LUT (atan values)

%Lut dimesion is 16x16

LSB = 2*pi/(2^16);
%angle values (in radiants)
arg = [1:16];

%generate the argumet of atan
for i = 1:16
       arg(i) = [2^(-(i-1))];
end

y = atan(arg);   %value of atan 

y_q = round(y/LSB)  %quantization on 16 bit

%data are printed in command window, a manual copy and paste in
%VHDL source code is required