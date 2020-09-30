function [BW] = SegmentaParpado (ImagenN)

    load('ModeloV4_SVM_100k');%'SVMModel

    %% Paso Quitar Luz de fondo y ajuste de contraste y hacemos huecos
    [indexIM] = find(ImagenN+.1);
    [ImInterp,ImLocalLap] = FondoHuecosV2(ImagenN,indexIM);
    %% Paso Genera Rasgos
    [rows,cols] = find(ImInterp+.1);
    Matriz = MandasRowsColsRegresaMatrizV2(rows,cols,ImInterp,99);
    disp('fin principio');
    %%  %SVM
    [Y_SVM,~] = predict(SVMModel,Matriz(2:14,:)');   
    Res_SVM = rescale(reshape(Y_SVM,1024,[]));
    %% Tratamieto post
    [smoothX_SVM,smoothY_SVM]=PostModelos(Res_SVM,6,20);
    if sum(smoothX_SVM)==0
        [smoothX_SVM,smoothY_SVM]=PostModelos(Res_SVM,3,20);
    end
    %Con el borde definido, genera una imagen binaria y mejora el contraste
    Borde=[(smoothY_SVM(:)) (smoothX_SVM(:))];
    BW = poly2mask(Borde(:,2),Borde(:,1),size(Res_SVM,1),size(Res_SVM,2));
end