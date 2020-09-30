function [ImPaso4H,BW3] = FiltroDireccionMeibos6(v1,v2,VentanaProm,ImMeiboSinHuecos)

   %Primero sacamos pendiente de vector resultante y segun lo sea sacamos
   %su angulo respecto a X positiva 
   m = (v1(2,2)-v1(1,2))/(v1(2,1)-v1(1,1));   
   MeiboDeg = (atan(m) * 180 / pi);
   %Hacemos un filtro de 0 grados
   LargMasc = 4; %siempre par
   VentanaProm=round(VentanaProm);
   filtv =2;
   h0 =[ones(LargMasc,round(VentanaProm/2))*-filtv,ones(LargMasc,VentanaProm)*filtv,ones(LargMasc,round(VentanaProm/2))*-filtv]';
   %Mexihat - This function is proportional to the second derivative function of the Gaussian probability density function.
   mexival = 5;%round(VentanaProm/10);
   [psi,~] = mexihat(-mexival,mexival,size(h0,1));
   h = h0.*psi';
   
   %Giramos la imagen
   [rowI,colI,NG] = find(ImMeiboSinHuecos);
   V1_mat = repmat([v1(2,1) v1(2,2)],size(rowI));
   V2_mat = repmat([v2(2,1) v2(2,2)],size(rowI));
   MatProy1 = dot([rowI colI],V1_mat,2);%Renglones
   MatProy2 = dot([rowI colI],V2_mat,2);%columnas
   MatProy1 = round(MatProy1+abs(min(MatProy1))+1);
   MatProy2 = round(MatProy2+abs(min(MatProy2))+1);
   
   %Generamos indices [(columna-1) * largo de renglon ] + renglon
   An2= round(((MatProy1 -1).* max(MatProy2))+MatProy2);
   
   %Redondeo
   ImRot  = zeros(max(MatProy2),max(MatProy1));
   ImRot(An2) =  NG;
   ImRot_I = imfill(ImRot);
    
   %ahora si hacemos el filtrado 1D
   ImPaso3 = rescale(imfilter(ImRot_I,h'));
   ImPaso31 = ImPaso3.*ImRot_I;
   
   %Regresar a su orientación original
   [rowI2,colI2,NGI] = find(ImPaso31);
   IV1_mat = repmat([-v1(2,1) v1(2,2)],size(rowI2));
   IV2_mat = repmat([v2(2,1) -v2(2,2)],size(rowI2));
   IMatProy1 = dot([rowI2 colI2],IV1_mat,2);%Renglones
   IMatProy2 = dot([rowI2 colI2],IV2_mat,2);%columnas
   IMatProy1 = round(IMatProy1+abs(min(IMatProy1))+1);
   IMatProy2 = round(IMatProy2+abs(min(IMatProy2))+1);
   IAn2= round(((IMatProy1 -1)* max(IMatProy2))+IMatProy2);
   ImFilt  = zeros(max(IMatProy2),max(IMatProy1));
   ImFilt(IAn2) =  NGI;
%    figure,subplot(1,2,1),imagesc(ImFilt),axis image,
%     subplot(1,2,2),imagesc(ImMeiboSinHuecos),axis image;

   %regresamos tamaño original
   ImPaso4 = imfill(ImFilt);
   BW2 = zeros(size(ImPaso4));
   BW2(ImPaso4>0)=1;
  [BWR2,ZonaMeiboIndex,ImPaso4R,ZonaMeiboR_Index] = RectanguloMasPequeno(ImPaso4,BW2);
  [ImPaso4C,ImPaso4N] = Meibomios(BWR2.*ImPaso4R,ImPaso4R);  
  ImPaso4H = rescale(imresize(ImPaso4N,size(ImMeiboSinHuecos),'nearest'));
   BW3 = zeros(size(ImPaso4H));
   BW3(ImPaso4H>0)=1;
   
   
   if false
       figure(98)
       [ha, pos] = tight_subplot(2,2,[.1 .01],[.05 .07],[.01 .01]) ;
       set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
       subplot(2,2,1),imagesc(ImMeiboSinHuecos),colormap gray,axis off,title("1");
       subplot(2,2,2),imagesc(ImRot(105:end,:)),axis off,title("2");
       subplot(2,2,3),imagesc(ImPaso31(105:end,:)),axis off,title("3");
       subplot(2,2,4),imagesc(ImPaso4N(64:end,:)),colormap gray,axis off,title("4");
       
       %Visualización rotación
%        figure,
%        subplot(1,5,1),plot(rowI,colI,'.'),title('rowI')
%        subplot(1,5,2),plot(MatProy2,MatProy1,'.'),title('MP1')
%        subplot(1,5,3),plot(An2,'.'),title('An2')
%        subplot(1,5,4),plot(floor(MatProy2+abs(min(MatProy2))+1),...
%            floor(MatProy1+abs(min(MatProy1))+1)),title('Rounded')
%        subplot(1,5,5),imagesc(imrot);
       
   end
end




%%
%Crecer Mexihat , para hacer que se difuminen un poco 
%los bordes y perder el cortorno y no los espacios vacios en las glandulas

