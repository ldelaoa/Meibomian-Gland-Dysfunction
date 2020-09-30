function [NumMeibos,RenMasLargo,GlandU4,Ventanas,DifEntreVentanas] = NumMeibosxRenglon(img,Vis)
warning('off','all')
imgC = img;
Largo=0;
pks_max=0;
locs_max=[];
GlandUbica = zeros(size(img));
x = 0:1/255:1;
distUmbral = fitdist(imgC(:),'Kernel','Kernel','epanechnikov');
% umbral= pdf(distUmbral,x);
% ValorUmbral = (find(umbral==max(umbral))*1.3)/256;
% img(img>ValorUmbral)=1;
% img(img<=ValorUmbral)=0;
% VectorSuma = sum(img,2);
% RenMasLargo = find(VectorSuma==max(VectorSuma));
% RenMasLargo = RenMasLargo(1);
for i = 1:2:size(imgC,1)
    vect = lowpass(imgC(i,:),.2);
    [pks,locs]=findpeaks(vect,'MinPeakHeight',.5,'MinPeakWidth',10);%.85 y 10
    
    if numel(pks)~=0
        GlandUbica(i,locs)=1;
    end
    
    if numel(pks)>numel(pks_max)
        pks_max = pks;
        locs_max = locs;
    end
    if Vis
        figure(11)
        subplot(1,2,1),imagesc(imgC),colormap gray,axis image; hold on; line([1 size(imgC,2)],[i i],'Color','red','LineWidth',1.5); hold off
        subplot(1,2,2),plot(vect),axis([0 size(imgC,2) 0 1]),title(i),hold on, ...
        plot(locs,pks,'x'),hold off;
        
        figure(12)
        imagesc(imgC),colormap gray,axis image; hold on; 
        line([1 size(imgC,2)],[i i],'Color','red','LineWidth',1.5);
        x=[1:length(vect)];
        plot(x,vect*-155,'r','LineWidth',1.5),
        plot(locs,pks*-155,'x'),hold off;
        pause(.5)
    end
end
NumMeibos=numel(pks_max);


%% filtros morfo para crear im binaria
SE=strel('sphere',1);%3
GlandU1 = imdilate(GlandUbica,SE);
SE=strel('square',1);%4
GlandU2 = imerode(GlandU1,SE);
SE = strel('rectangle',[1 1]);%len deg, 20 5
GlandU3 = imdilate(GlandU2,SE);
SE = strel('sphere',1);%3
GlandU4 = imdilate(GlandU3,SE);

%% Renglon mas largo
% umbral= pdf(distUmbral,x);
% ValorUmbral = (find(umbral==max(umbral))*1.3)/256;
% img(img>ValorUmbral)=1;
% img(img<=ValorUmbral)=0;
% VectorSuma = sum(img,2);
% RenMasLargo = find(VectorSuma==max(VectorSuma));
% RenMasLargo = RenMasLargo(1);
VectorSuma = sum(GlandU3,2);
RenMasLargo = find(VectorSuma==max(VectorSuma));
RenMasLargo = RenMasLargo(1);

%% Ubicaciones
Ubicaciones = GlandU3(RenMasLargo,:);
Diferencias = diff(Ubicaciones);
Ventanas1 = find(Diferencias==-1);
DifEntreVentanas = round(mean(diff(Ventanas1)));
Ventanas = cumsum(ones(1,length(Ventanas1))*DifEntreVentanas);
Ventanas(numel(Ventanas)) = size(GlandU3,2);

if Vis
    subplot(2,2,1),imagesc(GlandU1),axis image,colormap gray
    subplot(2,2,2),imagesc(GlandU2),axis image,colormap gray
    subplot(2,2,3),imagesc(GlandU3),axis image,colormap gray
    subplot(2,2,4),imagesc(GlandU4),axis image,colormap gray, hold on 
    plot(linspace(1,size(imgC,2)),RenMasLargo,'r.'),hold off
end
end

