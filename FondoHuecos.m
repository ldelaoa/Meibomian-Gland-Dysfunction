function [Imagen_Paso3,ImMeiboSinFondo] = FondoHuecos(ImZonaMeiboR,ZonaMeiboR_Index,BWR)
   %Quitar Luz de Fondo
   ImZonaMeiboR_LapL= locallapfilt(single(ImZonaMeiboR),.5,15);
   ImZonaMeiboR_SinFondo = rescale(ImZonaMeiboR- ImZonaMeiboR_LapL);
   ImMeiboSinFondo = zeros(size(ImZonaMeiboR));
   ImMeiboSinFondo(ZonaMeiboR_Index) = ImZonaMeiboR_SinFondo(ZonaMeiboR_Index);
   %Resaltar segmentos , no bordes
   %Z=MexicanHAtFunction(10,40,true);
   %ImMex = imfilter(ImMeiboSinFondo,Z,'conv');
   ImMeiboSinFondo = locallapfilt(single(ImMeiboSinFondo),5,.15);
   % Ajusta contraste de region de meibomios y hacemos huecos
   ImMeiboSinFondo =rescale(ImMeiboSinFondo);
   ImMeiboSinFondo2 = ImMeiboSinFondo;
   ImMeiboSinFondo2 (ImMeiboSinFondo2<.7) = 0;
   %ImMeiboSinFondo2 = medfilt2(ImMeiboSinFondo,[57,57]);
   ImMeiboSinFondo3 = ImMeiboSinFondo-ImMeiboSinFondo2;
   [ImagenC1,Imagen_Paso3] = Meibomios(BWR.*ImMeiboSinFondo3,ImMeiboSinFondo3); 
end

