function [Img_Paso8,ImgT] = ReconstruirImg(BW,ImDil_1d,XY_R,Imagen3)
ImgT= zeros(size(BW));
ImgT(XY_R(1):XY_R(1)+size(ImDil_1d,1)-1,XY_R(2):XY_R(2)+size(ImDil_1d,2)-1) = ImDil_1d;
Img_Paso8 = rescale(Imagen3);
Img_Paso8(:,:,1) = Img_Paso8 (:,:,1)+ImgT;
Img_Paso8 =rescale(Img_Paso8);
end

