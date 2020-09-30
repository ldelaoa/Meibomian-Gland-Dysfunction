clear
clc
Indices = [1 2 6 7 11 12 14 17 24 29 32 34 36 37 48 61 71 72 83 99 ...
 100 161 162 168 213 221 233 7+235 9+235 11+235 13+235 14+235 16+235 18+235 ...
 22+235 25+235 27+235 28+235 29+235 32+235 38+235 39+235 41+235 44+235 ...
 45+235 49+235 50+235 53+235 55+235  58+235  73+235  86+235  97+235  116+235  117+235 ];
RutaI = '/home/luis/Desktop/MCI/Imagenes/Meibografias/MeiboImg_Escogidas/';
RutaMAT = '/home/luis/Desktop/MCI/Resultados/ResSeparaParpados/Indices_SinDiv/V2/';
%load('MatSegManual.mat');%MatManual
MatDif = zeros(length(Indices),2);
toci = zeros(length(Indices),1);
%%% parte ciclica 
for i = 1:length(Indices)
    i
  RutaImg=strcat(RutaI,'lid_',sprintf('%d',Indices(i)),'.BMP');
  Imagen3=imread(RutaImg);
  Imagen = mean(Imagen3,3);
  [ImagenC1,ImagenN] = ContrasteYNormaliza(Imagen);
 
  %% Paso 0 -Segmenta Párpado
  load(strcat(RutaMAT,'LidSeg_V1_',sprintf('%d',i),'.mat'));
  %[BW] = SegmentaParpado (ImagenN);
  [BW] = Res_SVM;
  %% Paso 1 - Mejoramos contraste 
  if sum(BW(:))~=0
      tic
      [ImagenC1,ImagenSVM_Meibo] = Meibomios(BW.*ImagenN,ImagenN); % Ajusta contraste de meibomios
      %% Paso 2  Nos quedamos con el rectangulo más pequeño posible
      [BWR,ZonaMeiboIndex,ImZonaMeiboR,ZonaMeiboR_Index,XY_R] = RectanguloMasPequeno(ImagenN,BW);
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
       %% Paso 5 - Dos Modas 
       Vent1 = Vent(:,1);
       Vent2 = Vent(:,2);
       Vent1(Vent1>size(BWR2,1)) = size(BWR2,2-1);
       Vent2(Vent2>size(BWR2,2)) = size(BWR2,2);
       Vent(:,1)=Vent1;
       Vent(:,2)=Vent2;
        tic
       [ImPaso5_1d] = DosModas(BWR2,ImPaso4N,Vent);
        toc
       %% Morfologia
       ImMapaV2 = MapasVect(ImPaso4N);
       ImMorfoS = FiltroMorfoMeiboV3(or(ImMapaV2,ImPaso5_1d));
       toci(i) = toc;
       %% Visual
       %[Img_Paso8,~] = ReconstruirImg(BW,ImPaso5_1d,XY_R,Imagen3);
       %ImPaso8 = squeeze(mean(Img_Paso8,3));
       [Img_Paso9,ImgT] = ReconstruirImg(BW,ImMorfoS,XY_R,Imagen3);
       [~,ImgParaRasgos] = ReconstruirImg(BW,ImPaso4N,XY_R,Imagen3);
       %GeneraImgV3(true,1,2,cat(3,ImagenN),Img_Paso9,i,true);
        
       %% Stats
       if true
        % figure(10),imagesc(ImPaso4N),title('4N');
        pathSegManual = '/home/luis/Desktop/MCI/Resultados/ResSeparaGlandulas/Manual/';
        [BW_manual2d] = GlandSegmentaManualV2(ImMorfoS,Indices(i),isfile(strcat(pathSegManual,'MeiboBwmanual_V2(',sprintf('%d',(Indices(i))),').mat')));
        [~,ImgT_Real] = ReconstruirImg(BW,ImMorfoS,XY_R,Imagen3);
        [~,ImgT_Manual] = ReconstruirImg(BW,BW_manual2d,XY_R,Imagen3);
        % Diferencias
        ImMorfoV = double(ImgT_Real(:));
        ImMorfoV(ImMorfoV==0)=-1;
        BW_manual2dV = double(ImgT_Manual(:));
        BW_manual2dV(BW_manual2dV==0)=-1;
        Tani = Tanimoto(ImMorfoV(1:100:end),BW_manual2dV(1:100:end));
        Auci(:) = area_roc(ImMorfoV(1:100:end),BW_manual2dV(1:100:end));
        MatDif(i,:) = [Tani Auci(1)];
       end
       %% Guardar Mat      
       if false
        name = strcat('/home/luis/Desktop/MCI/Resultados/ResSeparaGlandulas/v22_mat/',...
           'MAT_SegGland_',sprintf('%d',Indices(i)),'_V10.mat');
        saveIMG = cat(3,ImgT,ImgParaRasgos,mean(Img_Paso9,3),BW);
        save(name,'saveIMG')
        close all
       end
  end
end
%% final stats
%save('SegMeiboStats_Real_V0','MatDif');
AvgDif = mean(MatDif);
StdDif = std(MatDif);
tocim = mean(toci);
tocis = std(toci);

AvgDifInf = mean(MatDif(1:27,:));
AvgDifSup = mean(MatDif(28:55,:))
StdDifInf = std(MatDif(1:27,:));
StdDifSup = std(MatDif(28:55,:))


%% stats de enfermos y sanos
%Load vect
%load('/home/luis/Desktop/MCI/Resultados/ResRasgosGlandulas/MatResv8/MAT_FeatureGland_V8.mat')
%load('/home/luis/Desktop/MCI/AlgoritmoLocal/SegMeiboStats.mat')
%load('/home/luis/Desktop/MCI/AlgoritmoLocal/SegMeiboStats_Real_V0.mat')
SanosVal= mean(Vect(:,1))+var(Vect(:,1));
EnfVal = mean(Vect(:,1))-var(Vect(:,1));
SanosInx =  find(Vect(:,1)>SanosVal);
EnfInx =  find(Vect(:,1)<SanosVal);

AvgDifSano = mean(MatDif(SanosInx,:));
AvgDifEnf = mean(MatDif(EnfInx,:));
StdDifSano = std(MatDif(SanosInx,:));
StdDifEnf = std(MatDif(EnfInx,:));

% x=linspace(1,size(MatDif,2),size(MatDif,2));
% figure,plot(x,MatDif(1,:),'bx'),hold on
% plot(x,MatDif(2,:),'ro'),legend('1D','r1d','2D','r2d'),hold off
% 
% figure
% stem(MatDif(2,:)-MatDif(1,:)),hold on
% plot(zeros(size(MatDif,2)),'k'),hold off,title(TotDif)
