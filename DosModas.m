function [ImPaso5] = DosModas(ImMeiboSinFondoX,ImMeiboSinHuecos,Vent)
  %Prueba de Normalidad
   ImPaso5 = zeros(size(ImMeiboSinFondoX));
   for k = 1:size(Vent,1)
       Vent_Vector= find(ImMeiboSinFondoX(:,Vent(k,1):Vent(k,2)));
       if ~isempty(Vent_Vector)
           Imagen_Paso4  = zeros(size(ImMeiboSinHuecos(:,Vent(k,2)-Vent(k,1))));
           Imagen_Paso4 = rescale(ImMeiboSinHuecos(:,Vent(k,1):Vent(k,2)));
           Imagen_Paso4Vector = Imagen_Paso4(Vent_Vector);
           ImMeiboSinFondo_Vector = Imagen_Paso4(Vent_Vector);
           pdNormal = fitdist(ImMeiboSinFondo_Vector,'Kernel','Kernel','epanechnikov');
           %histNormal = histfit(ImMeiboSinFondo_Vector,256,'Kernel');
           x = 0:1/255:1;
           pdfNormal = pdf(pdNormal,x);
           PShapiro = swtest(pdfNormal,.1);
           [PKS]  = kstest(pdfNormal,'Tail','smaller');
           %Suma de Gaussianas
           [N,~] = histcounts(ImMeiboSinFondo_Vector,256);
           histOrig = rescale(N);
           histNorm = rescale(pdfNormal);
           if PKS == 1
               [N,~] = histcounts(ImMeiboSinFondo_Vector,256);
               [GausN,y] = Fcn_MezclaGaussV2(histNorm',2);
               %pFisher = anova2(y',1,'off');
               %print("ANOVA",'-djpeg')
               [H0,pT]= ttest(y(1,:),y(2,:)); %h = 1, rejection of the null hypothesis 
               pot = 1; y2=0;
%                figure(99), 
%                subplot(2,2,1),plot(y'),title("Valor de T: 1")
%                axis([0 300 0 3])
%                subplot(2,2,2),boxplot(y'),title(strcat("Valor de Potencia ",sprintf("%f",pot))),xlabel("No-GM | GM "),...
%                axis([0.5 2.5 -.5 3.7])
%                pause(.5);
               while(and(pT(1)>0.1,pot<4))%.31
                   ImMeiboExpo_Vector = rescale((ImMeiboSinFondo_Vector).^pot);
                   pdNormal2 = fitdist(ImMeiboExpo_Vector,'Kernel','Kernel','epanechnikov');
                   histNorm2 = rescale(pdf(pdNormal2,x));
                   [GausN2,y2,sol] = Fcn_MezclaGaussV2(histNorm2',2);
                   %print(strcat("Valor de Potencia ",sprintf("%f",pot)),'-djpeg')
                   %pFisher = anova2(y2',1,'off'); %Probar con prueba T
                   [H0,pT]= ttest(y2(1,:),y2(2,:)); %h = 1, rejection of the null hypothesis 
                   pot = pot+.2;
                   y3=[y2(2,:);y2(1,:)];
%                    figure(99), 
%                    subplot(2,2,3),plot(y3'),title(strcat("Valor de T: ",sprintf("%f",pT(1))))
%                    axis([0 300 0 3])
%                    subplot(2,2,4),boxplot(y3'),title(strcat("Valor de Potencia ",sprintf("%f",pot))),xlabel("No-GM | GM "),...
%                    axis([0.5 2.5 -.5 3.7])
               end %while
               %[N2,~] = histcounts(ImMeiboExpo_Vector,256);
               %figure,plot(N,'xb'),hold on,plot(N2,'.r'),legend('Antes','Despues'),hold off

           end%PKS
           if y2 ~=0
               %InterX = (find(y2(1,:)<y2(2,:),1,'first')/256)*.4;
               InterX = sol(2)*1;
               ImMeiboExpo = zeros(size(Imagen_Paso4));
               ImMeiboExpo(Vent_Vector) = ImMeiboExpo_Vector;           
               ImPaso5_Parte = ImMeiboExpo;
               ImPaso5_Parte=rescale(ImPaso5_Parte);
               ImPaso5_Parte(ImPaso5_Parte>InterX)=1;%.1
               ImPaso5_Parte(ImPaso5_Parte<=InterX)=0;%.1
               ImPaso5(ImPaso5<InterX)=0;
             %   subplot(1,2,1),imagesc(ImMeiboExpo),colormap gray, axis image
              %  subplot(1,2,2),imagesc(ImPaso5_Parte),colormap gray, axis image
               ImPaso5(:,Vent(k,1):Vent(k,2)) = ImPaso5_Parte;
               a="y~=0 ANOVA";
           else
               InterX = (find(y(1,:)>y(2,:),1,'first')/256);
               VectorVertical = rescale(ImMeiboSinFondo_Vector);
               %t = otsuthresh(VectorVertical);
               h = hist(ImMeiboSinFondo_Vector,256);
               h = find(h== max(h))/256;
               if numel(h)>1
                   h = h(2);
               end
               h=h*1.16;
               t = graythresh(ImMeiboSinFondo_Vector(ImMeiboSinFondo_Vector>h));
               VectorVertical(VectorVertical>t) = 1;
               VectorVertical(VectorVertical<=t) = 0;
               ImagenVertical = zeros(size(Imagen_Paso4));
               ImagenVertical(Vent_Vector) = VectorVertical;
               ImPaso5(:,Vent(k,1):Vent(k,2)) = ImagenVertical;
               a="y=0 Manual";
           end
            %imagesc(ImPaso5),colormap gray,axis image,title(a)
            %pause(.5)
       end %if de Vent Vector
   end%For 2 modas

end

