for i=9:435
    RutaI =  '/home/luis/Desktop/MCI/Imagenes/Meibografias/MeiboImg_Escogidas/';
    RutaImg=strcat(RutaI,'lid_',sprintf('%d',i),'.BMP');
    Img=imread(RutaImg);
    %pathImg = input('File de Imagen: ');
    Imagen = mean(Img,3);
    [ImagenC1,ImagenN] = ContrasteYNormaliza(Imagen);
    [ImgLid] = SegmentaParpado(ImagenN);
    [ImgMeibo,~] = SeparaMeibomiosV21(ImgLid,ImagenN);
    [Rasgos] = RasgosGlandulasV4(ImagenN,ImgLid,ImgMeibo);

    if true
        ImagenRes(:,:,1) = ImagenN;
        ImagenRes(:,:,2) = ImagenN + imdilate(bwperim(ImgLid),ones(5));
        ImagenRes(:,:,3) = ImagenN + ImgMeibo;
        fig = figure(1);
        imagesc(ImagenRes),axis off-;
        saveas(fig,strcat('lid_',sprintf('%d',i),'.bmp'));
    end

end