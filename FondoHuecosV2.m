function [ImInterp,ImLocalLap] = FondoHuecosV2(ImConBrillos,indexIM)
   %Quitar Luz de Fondo
   ImZonaMeiboR_LapL= locallapfilt(single(ImConBrillos),.5,15);
   ImZonaMeiboR_SinFondo = rescale(ImConBrillos- ImZonaMeiboR_LapL);
   ImLocalLap = zeros(size(ImConBrillos));
   ImLocalLap(indexIM) = ImZonaMeiboR_SinFondo(indexIM);
   %Resaltar segmentos , no bordes
   %Z=MexicanHAtFunction(10,40,true);
   %ImMex = imfilter(ImMeiboSinFondo,Z,'conv');
   ImLocalLap = locallapfilt(single(ImLocalLap),5,.15);
   % Ajusta contraste de region de meibomios y hacemos huecos
   ImLocalLap =rescale(ImLocalLap);
   ImMeiboSinFondo2 = ImLocalLap;
   ImMeiboSinFondo2 (ImMeiboSinFondo2<.8) = 0;
   %ImMeiboSinFondo2 = medfilt2(ImMeiboSinFondo,[57,57]);
   ImInterp = ImLocalLap-ImMeiboSinFondo2;
   
   %% Llenamos huecos 
   ImInterp = rescale(imfill(ImInterp ));
   
end

