function [Resta,CentroSup,CentroInf] = DiferenciaMedianas(ImagenN)
%%Funcion utilizada para generar un razgo e identificar parpad
%parte del principio que la diferencia de las medianas de cada mascara de
%probabilidad ayuda a identificar si es un parpado superior o inferior
%hacemos load de las mascara, 
load('variablesP1_inferior');
load('variablesP1_superior');
%le ponemos un threshold, 
MatrizI=Matriz2D_inferior;
MatrizI(Matriz2D_inferior(:)<2/3)=0;
MatrizS=Matriz2D_Superior;
MatrizS(Matriz2D_Superior(:)<2/3)=0;
%multiplicamos por la imagen y sacamos medianas
Mascara=MatrizS.*ImagenN;
Mascara=Mascara(Mascara>0);
MedianaS = median(Mascara(:));
Mascara=MatrizI.*ImagenN;
Mascara=Mascara(Mascara>0);
MedianaI = median(Mascara(:));
%restamos las medianas de ambos vectores
Resta = MedianaS-MedianaI;
%Menor a cero es inferior

%% Busca Centros
MaxI = max(MatrizI(:));
[rowI,colI] = find(MatrizI==MaxI);
CentroInf = [round(mean(rowI)) round(mean(colI))];
MaxS = max(MatrizS(:));
[rowS,colS] = find(MatrizS==MaxS);
CentroSup = [round(mean(rowS)) round(mean(colS))];
end

