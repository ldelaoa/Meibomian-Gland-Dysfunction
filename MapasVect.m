function [ImMapaVBA] = MapasVect(ImGray)
%% mapas vectoriales
[pxR,pyR] = gradient(ImGray.^2);
ImRelleno = (abs(pxR)+abs(pyR));
ImRelleno = rescale(ImRelleno);

ImHist = hist(ImRelleno(:));
TO = otsuthresh(ImHist);
ImMapaVB = imbinarize(ImRelleno,TO);
ImMapaVBA = imbinarize(ImRelleno,'global');
% figure,
% subplot(2,2,1),imagesc(ImRelleno),axis off,axis image
% subplot(2,2,2),imagesc(ImMapaVB),axis off,axis image
% subplot(2,2,3),imagesc(ImMapaVBA),axis off,axis image
% subplot(2,2,4),imagesc(or(ImMapaVBA,ImMapaVB)),axis off,axis image

%figure
%quiver(pxR,pyR)
end

