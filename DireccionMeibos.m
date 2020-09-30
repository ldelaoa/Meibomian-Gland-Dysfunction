function [v1,v2,MeiboDeg] = DireccionMeibos(ImMeiboSinHuecos)
   [row,col,v] = find(ImMeiboSinHuecos); % Imagen_Paso3
   MatrizPCA = [row col v];
   [coeff] = pca(MatrizPCA,'Algorithm','eig');
   v1 = [0 0 0 ;coeff(1,:)];
   v2 = [0 0 0 ;coeff(2,:)];
   v3 = [0 0 0 ;coeff(3,:)];
   vdif = v2-v1;
   vcomp = [coeff(1,:);coeff(2,:)];
   gradDif = atan(vcomp(:,2)) * 180 / pi;
   
   %Primero sacamos pendiente de vector resultante y segun lo sea sacamos
   %su angulo respecto a X positiva 
   m = (vdif(2,2)-vdif(1,2))/(vdif(2,1)-vdif(1,1));
   m2 = (vcomp(2,2)-vcomp(1,2))/(vcomp(2,1)-vcomp(1,1));
   MeiboDeg = (atan(m2) * 180 / pi);
   
       if false
           %vis3d
           figure(97)
           scatter3(row,col,log(v),10,v*[1 0 0],'filled');hold on
           plot3(v1(:,1)*500,v1(:,2)*500,v1(:,3),'r')
           plot3(v2(:,1)*500,v2(:,2)*500,v2(:,3),'b')
           view(90,90);
           %plot3(vdif(:,1)*500,vdif(:,2)*500,vdif(:,3),'k'),hold off
           %vis2d
           figure(96)
           plot(v1(:,1)*500,v1(:,2)*500,'r'),hold on 
           plot(v2(:,1)*500,v2(:,2)*500,'b')
           %plot(vcomp(:,1)*500,vcomp(:,2)*500,'g')
           %plot(vdif(:,1)*500,vdif(:,2)*500,'k'),hold off
       end
        
end

