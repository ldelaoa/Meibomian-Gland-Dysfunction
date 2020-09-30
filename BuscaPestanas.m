function [row,col] = BuscaPestanas(ImagenN)
%A partir de las imagenes de meibograf�a buscamos el centroide del cuerpo
%de pesta�as. 

Bw1= imbinarize(1-histeq(ImagenN),.95);
Bw2= imbinarize(1-histeq(ImagenN),.85);

ImBw = Bw2 - Bw1;
ImBWh = imfill(ImBw,'holes');
SE = strel('line',3,0);
imer = imerode(ImBWh,SE);
imdil = imdilate(imer,SE);

MedianIm=medfilt2(imdil,[10 10]);

% %% Tecnica 3
% [B,L,N,A]=bwboundaries(MedianIm,8);
% Vals = cell2mat(B(1:N));
% polgn = polyshape(Vals(:,1),Vals(:,2));
% [CentroPest(1),CentroPest(2)] = centroid(polgn);
% %% Tecnica 2
% [x,y]= find(MedianIm);
% polgn = polyshape(x,y);
% [CentroPest(3),CentroPest(4)] = centroid(polgn);
%% Tecnica 1
Ilabel = bwlabel(MedianIm);
stat = regionprops(Ilabel,'centroid');
V = struct2array(stat);
rows = V(1:2:end);
cols = V(2:2:end);
%Marzo 23, voy a usar rows-cols en lugar de row col
polgn = polyshape(rows,cols);
[row,col] = centroid(polgn);

%% Display 
    if false
        figure(10),
        imagesc(MedianIm),colormap gray
        hold on
        plot(row,col,'x')
        hold off
        pause(1)
        close 10
    end
end

