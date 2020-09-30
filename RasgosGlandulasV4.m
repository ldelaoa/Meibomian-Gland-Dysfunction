function [Vect] = RasgosGlandulasV4(ImagenN,BW_P,BW_G)  
    %% Rasgos
    Bw_G_Inx = find(BW_G);
    AreaReal = sum(BW_G(:))/ sum(BW_P(:));
    
    [ImFilledMan]= FillRegion(BW_G);
    AreaClinica = sum(ImFilledMan(:))/ sum(BW_P(:));
    
    ImgSelect0 = rescale(BW_G.*ImagenN);
    ImgSelect = (ImgSelect0 - mean(ImgSelect0(:))) / std(ImgSelect0(:));
    
    %VectEntro = ImgSelect0(Bw_G_Inx);
    ImgEntro = entropyfilt(ImgSelect);
    EntroMean = mean(ImgEntro(Bw_G_Inx));
    EntroStd = std(ImgEntro(Bw_G_Inx));
    
    [Tmin,Tmax,Tmed,Tstd]= tortuosity(BW_G);
    
    RHist_V = rescale(hist(ImgSelect(Bw_G_Inx),256));
    HistoK = kurtosis(RHist_V);
    HistoSK = skewness(RHist_V);
    HistMed = mean(RHist_V);
    HistStd = std(RHist_V,1);   
    HistMax =find(RHist_V==max(RHist_V))/256;
    %% Crear Vector de Rasgos
    [Vect(:)] = [AreaReal;AreaClinica;HistMax(1);HistMed;HistStd;HistoK;HistoSK;...
        EntroMean;EntroStd;Tmin;Tmax;Tmed;Tstd];      
end
