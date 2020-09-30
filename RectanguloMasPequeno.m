function [BWR,ZonaMeiboIndex,ImZonaMeiboR,ZonaMeiboR_Index,XY_R] = RectanguloMasPequeno(ImagenN,BW)
%Sacas la zona de parpado y mejoras el histograma, con el histograma guardado
   ZonaMeibo = ImagenN.*BW;
   ZonaMeiboVectorZ = ZonaMeibo(ZonaMeibo>0);
   ZonaMeiboIndex = find(ZonaMeibo(:));
   ImZonaMeibo = zeros(size(ImagenN));
   ImZonaMeibo(ZonaMeiboIndex) = ZonaMeiboVectorZ;
   
   [ZonaMeiboX,ZonaMeiboY] = find(ZonaMeibo);
   ImZonaMeiboR = ImZonaMeibo(min(ZonaMeiboX):max(ZonaMeiboX),min(ZonaMeiboY):max(ZonaMeiboY));
   ZonaMeiboR_Index = find(ImZonaMeiboR(:));
   ZonaMeiboR_Vector = ImZonaMeiboR(ZonaMeiboR_Index);
   BWR = BW(min(ZonaMeiboX):max(ZonaMeiboX),min(ZonaMeiboY):max(ZonaMeiboY));
   %figure(1),imagesc(ImagenN+BW),axis image
   %close(1) 
   XY_R = [min(ZonaMeiboX) min(ZonaMeiboY)];
end

