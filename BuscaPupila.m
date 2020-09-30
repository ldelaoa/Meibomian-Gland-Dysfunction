function [row,col] = BuscaPupila(ImagenN,Vis)
%A esta funci�n le llega una imagen y regresa la ubicaci�n del centro de la
%pupila. en cordenadas row,col
%Versi�n 0 - 5 de marzo 
%binarizamos 1- imagen, para quedarnos con lo m�s negro
ImBw = imbinarize(1-ImagenN,.99); 
%PAra llenar hoyos en las pupilas por la iluminaci�n
BW1 = imfill(ImBw,'holes');
%[rMin,rMax] = find(imBw);
[center,radiB]= imfindcircles(BW1,[80 180],'Method','PhaseCode','ObjectPolarity','bright','Sensitivity',.985);
if ~isempty(center)
    Index = length(radiB);
     for i = 1:numel(radiB)   
        M = zeros(size(ImagenN));
        M(round(center(i,2)),round(center(i,1))) = 1;
        R = bwdist(M);
        T = R >= radiB(i);
        ImE = entropyfilt(ImagenN);
        CircEntr = (1-T).*ImE;
        Index(i) = entropy(CircEntr(CircEntr~=0));
     end
    minEntr = min(Index);
    IndexC = find(Index == minEntr);
    col = center(IndexC,1);
    row = center(IndexC,2);
    radiB = radiB(IndexC);
    
    
else %Primera validacion fallida
   ImBw = imbinarize(1-histeq(ImagenN),.89); 
   SE = strel('disk',5);
   ImBw=imerode(ImBw,SE);
   BW2 = imfill(ImBw,'holes');
   BW3 = BW2 - BW1;
   [center1,radiB1]= imfindcircles(BW3,[130 230],'Method','TwoStage','ObjectPolarity','bright','Sensitivity',.99);
   [center2,radiB2]= imfindcircles(BW3,[210 310],'Method','TwoStage','ObjectPolarity','bright','Sensitivity',.99);
   center = [center1;center2];
   radiB = [radiB1;radiB2];
    if ~isempty(center)
        Index = length(radiB);
        ImE = entropyfilt(ImagenN);

         for i = 1:numel(radiB)   
            M = zeros(size(ImagenN));
            M(round(center(i,2)),round(center(i,1))) = 1;
            R = bwdist(M);
            T = R >= radiB(i);
            CircEntr = (1-T).*ImE;
            Index(i) = entropy(CircEntr);
         end
        minEntr = min(Index);
        IndexC = find(Index == minEntr);
        col = center(IndexC,1);
        row = center(IndexC,2);
        radiB = radiB(IndexC);
    else
%         radii = 200:2:250;
%         BW4 = edge(BW3,'canny');
%         h = circle_hough(BW4, radii, 'normalise');
%         
        row = round(size(ImagenN,1)/2);
        col = round(size(ImagenN,2)/2);
    end
end    
if and(Vis,~isempty(center))
    figure(10)
    imagesc(ImagenN),colormap gray;
    hold on
    viscircles([col row], radiB,'Color','b');
    hold off
    pause(1)
    close 10
end

end

