%script for generating vector tests 

%LSB for conversion
LSB = 1/(2^7);

%Number of values
n = 100;

%X and Y of vectors
matrice = rand ([n 2]);

%adjusting the dinamic of values we can have also negative values for X and Y
matrice = (matrice - 0.5)*((1/LSB)*2);

file_origine = fopen('esatti.txt','wt');

%write X and Y in a file
for i = 1:n
    a = matrice(i,1);
    b = matrice(i,2);
    fprintf(file_origine,'%f,%f\n',a,b);
end;
fclose(file_origine);

%the data as input of CORDIC must be codified in C2, but matlab can't
%do this autonomously, the standard positional representation.
%A "manual" conversion must be performed.
%
%to do this we "cheat": alter the values and, next, dec2bin convert
%these new values in binary

for i = 1:2
    for j = 1:n
        if matrice(j,i) < 0
            matrice(j,i) = matrice(j,i)+(1/LSB);
        end;
    end;    
end;

%store these new data on file
file_binari = fopen('binari.txt','wt');

for i = 1:n
    a = dec2bin(round(matrice(i,1)/LSB),14);
    b = dec2bin(round(matrice(i,2)/LSB),14);
    fprintf(file_binari,'%s,%s\n',a,b);
end;

fclose(file_binari);



