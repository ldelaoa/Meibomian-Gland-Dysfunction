function [ImMorfo] = FiltroMorfoMeiboV3(ImOr)
%% Morfolo
SE = strel('disk',1);
ImOr = imerode(ImOr,SE);
ImBwL = bwlabel(ImOr);
for i = 1:max(max(ImBwL))
    [rr,cc] = find(ImBwL == i);
    if length(rr)<50 %Quitamos los pequeños
        ImBwL(ImBwL == i)=0;
    end
    alto = max(rr)-min(rr);
    ancho  = max(cc)-min(cc);
    if ancho > (alto)*50%1.5 %quitamos los cuerpos acostados
        ImBwL(ImBwL == i)=0;
    end
end
    ImMorfo = ImBwL;
    ImMorfo(ImMorfo~=0)=1;

    ImMorfo = imfill(ImMorfo);
    ImMorfo = imfill(ImMorfo);
end