%Cambios de corregir r7, que tenia un r4 en lugar de r3
function [Matriz] = MandasRowsColsRegresaMatrizV2(rows,cols,ImagenN,Label)
        ImagenEQ = histeq(ImagenN);
        rT = ones(length(rows),1)*Label;
        r1 = rows;
        r2 = cols;
        r3 = ImagenEQ((((cols-1)*size(ImagenEQ,1))+rows)); %valor de gris
        
        [Resta,CentroSup,CentroInf] = DiferenciaMedianas(ImagenN);
        r4 = ImagenN((((cols-1)*size(ImagenN,1))+rows)); 
        r4  = r4*Resta; %Gris * Diferencia de medianas
        Imagen256 = uint16(ImagenN*256);
        ImagenLocalLap = locallapfilt (Imagen256,.6,.7);
        r5 = double(ImagenLocalLap((((cols-1)*size(ImagenLocalLap,1))+rows))); %Local Lap
        k = ones(9);
        k(5,5)= 0;
        ImagenE = rescale(entropyfilt(ImagenEQ,k));
        r6 = ImagenE((((cols-1)*size(ImagenN,1))+rows)); % Entrop�a reescalada
        r7 = r3 -conv2(ImagenN((((cols-1)*size(ImagenN,1))+rows)),k,'same'); %Laplaciano de 9x9
        [PupilaRow,PupilaCol] = BuscaPupila(ImagenN,false);
        r8 = PupilaRow-rows;
        r9 = PupilaCol-cols;
        r10 = pdist2(CentroSup,[rows cols],'euclidean');
        r11 = pdist2(CentroInf,[rows cols],'euclidean');
        
        [PestanaRow,PestanaCol] = BuscaPestanas(ImagenN);
        r12 = PestanaRow - rows;
        r13 = PestanaCol - cols;


        Matriz = [rT r1 r2 r3 r4 r5 r6 r7 r8 r9 r10' r11' r12 r13]'; 
    end
% rT  - Target 1 si es Parpado  -1 si es fuera de parpado
% r1 - Valores row
% r2 - Valores col
% r3  -Valor de Gris
% r4 - Valor de Gris * Diferencia de Medianas         
% r5 - Valor de Gris de Laplaciano local 
% r6 - Valor de Entrop�a reescalada de Mascara de 9x9         
% r7 - Valor de Laplaciano de Mascara de 9x9                  
% r8 - Distancia PupilaRow-row                                
% r9 - Distancia PupilaCol-col                               
% r10 - Distancia pixel a centro de masa de Matriz Sup
% r11 - Distancia pixel a centro de masa de Matriz Inf
% r12 - Distancia Pesta�aRow - row
% r13 - Distancia Pesta�aCol - col
