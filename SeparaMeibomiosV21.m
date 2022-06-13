function [ImgT,ImgParaRasgos] = SeparaMeibomiosV21 (BwParpado,ImagenN)
  if sum(BwParpado(:))~=0
      [ImagenC1,ImagenSVM_Meibo] = Meibomios(BwParpado.*ImagenN,ImagenN); % Ajusta contraste de meibomios
      %% Paso 2  Nos quedamos con el rectangulo más pequeño posible
      [BWR,ZonaMeiboIndex,ImZonaMeiboR,ZonaMeiboR_Index,XY_R] = RectanguloMasPequeno(ImagenN,BwParpado);
      %% Paso 3 Quitar Luz de fondo y ajuste de contraste y hacemos huecos
      [Imagen_Paso3,ImMeiboSinFondo] = FondoHuecos(ImZonaMeiboR,ZonaMeiboR_Index,BWR);
       %% Numero de Meibomios en Renglón - Barrido
       [NumMeibos,RenMasLargo,GlandU4,Ventanas,VentanaProm] = NumMeibosxRenglon(rescale(ImMeiboSinFondo),false);
       Vent=[];
       Vent(1,:) = [1 Ventanas(1)];
       for j=1:numel(Ventanas)-1
           Vent(j+1,:) = [Ventanas(j)+1 Ventanas(j+1)];
       end
       %Vent(j+2,:) = [Ventanas(j+1)+1 size(GlandU4,2)];
       ImMeiboSinFondoX = ImMeiboSinFondo;
       ImMeiboSinFondoX(ZonaMeiboR_Index) = 1;

       % Llenamos huecos 
       ImMeiboSinHuecos = ImMeiboSinFondoX;
       ImMeiboSinHuecos(ImMeiboSinHuecos~=1) = -1;
       ImMeiboSinHuecos(ZonaMeiboR_Index) = Imagen_Paso3(ZonaMeiboR_Index);
       ImMeiboSinHuecos= imfill(ImMeiboSinHuecos);
       ImMeiboSinHuecos(ImMeiboSinHuecos==-1) = 0;
       %% PCA / Direccionalidad de Meibomios
       [v1,v2,MeiboDeg] = DireccionMeibos(ImMeiboSinHuecos);
       %% Filtrado segun orientación
       [ImPaso4N,BWR2] = FiltroDireccionMeibos6(v1,v2,VentanaProm,ImMeiboSinHuecos);
       %% Paso 5 - Dos Medias 
       Vent1 = Vent(:,1);
       Vent2 = Vent(:,2);
       Vent1(Vent1>size(BWR2,1)) = size(BWR2,2-1);
       Vent2(Vent2>size(BWR2,2)) = size(BWR2,2);
       Vent(:,1)=Vent1;
       Vent(:,2)=Vent2;

       [ImPaso5_1d] = DosModas(BWR2,ImPaso4N,Vent);

       %% Morfologia
       ImMapaV2 = MapasVect(ImPaso4N);
       ImMorfoS = FiltroMorfoMeiboV3(or(ImMapaV2,ImPaso5_1d));
       %% Visual
       [ImgMeibo,ImgT] = ReconstruirImg(BwParpado,ImMorfoS,XY_R,ImagenN);
       [~,ImgParaRasgos] = ReconstruirImg(BwParpado,ImPaso4N,XY_R,ImagenN);
       if false
        figure,imagesc(ImZonaMeiboR),title('Rect Más pequeño'),colormap gray,axis off, axis image;
        figure,imagesc(or(ImMapaV2,ImPaso5_1d)),title('antes Morfo'),colormap gray,axis off, axis image;
        figure,imagesc(ImMorfoS),title('despues Morfo'),colormap gray,axis off, axis image;
        figure,imagesc(ImPaso4N),title('Después de filtrado'),colormap gray,axis off, axis image;
       end
  end
end