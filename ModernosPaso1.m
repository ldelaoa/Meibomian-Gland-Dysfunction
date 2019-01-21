clc
%este programa crea las bases de datos de entrenamiento y validación.

%Definir valores
superior = 21;%213;
inferior = 21;%210;
Train=.7;%todos los (1-Train) es porque invertimos porcentajes para mediana

%matriz completa de contornos, se llena en el for.
MatrizBW3d=zeros(superior+inferior,1024,1360);
%hacer matrices de convolución , se llena en el for
MatrizCompletaT=zeros(inferior+superior,1131);
for i= 1:(inferior+superior)
    Ruta = 'C:\Users\Omedic\Desktop\MCI\Imagenes\Meibografias\MeiboImg2\';
    %crea mascara en ceros para detectar contornos
    mask = zeros(1024,1360); 
    if i <= inferior
        RutaC=strcat(Ruta,'lid_l_ (',sprintf('%d',i),').BMP');
        mask(600:700,400:800) = 1; %inf - rectangulo
    else
        RutaC=strcat(Ruta,'lid_u_ (',sprintf('%d',i-inferior),').BMP');
        mask(300:400,400:800) = 1; %sup - rectangulo
    end
    %preparar imagen para ambos metodos
    Imagen3=imread(RutaC);
    Imagen = mean(Imagen3,3);
    [ImagenC1,ImagenN] = ContrasteYNormaliza(Imagen);
    
    %detectarBordes para mediana
    [Im1] = PreProcesamientoV2(ImagenN);
    bw = activecontour(Im1,mask,300);
    MatrizBW3d(i,:,:)= bw;
   
    %Crear Kernel para Modernos
    salto1 =7;
    salto2 = 5;
    MascaraKernel = ones(salto1,salto1).*(1/(salto1^2));
    ImF = imfilter(ImagenN,MascaraKernel);
    ImF = ImF(ceil(salto1/2):salto1:end,ceil(salto1/2):salto1:end);
    MascaraKernel = ones(salto2,salto2).*(1/(salto2^2));
    ImF2 = imfilter(ImF,MascaraKernel);
    ImF2 = ImF2(ceil(salto2/2):salto2:end,ceil(salto2/2):salto2:end);
    %Guardar
    MatrizCompletaT(i,:)=ImF2(:); %cada renglon es una imagen 
end
%%
%Preparar Indices
Bootstrap = 20; %vías 
for  L = 1:Bootstrap
    %crear indices por bootstrap
    indicesS = randperm(superior);
    indicesI = randperm(inferior);
    superior_train = indicesS(1:floor(superior*Train));
    inferior_train = indicesI(1:floor(inferior*Train));
    superior_val = indicesS(floor(superior*Train)+1:end);
    inferior_val = indicesI(floor(inferior*Train)+1:end);
    %crear vectores de respuestas
    VectorRespuestas(1:inferior+superior) = [ones(1,inferior) ones(1,superior)*-1]';
    VTrain = [VectorRespuestas(inferior_train) VectorRespuestas(superior_train+max(inferior))];
    VVal = [VectorRespuestas(inferior_val) VectorRespuestas(superior_val+max(inferior))];
    %%
    %Entrenar Mediana
    MatrizBW2dI = squeeze(mean(MatrizBW3d(inferior_val,:,:),1));
    MatrizBW2dI(MatrizBW2dI<5/9)=0;
    MatrizBW2dS = squeeze(mean(MatrizBW3d(inferior+superior_val,:,:),1));
    MatrizBW2dS(MatrizBW2dS<2/3)=0;
    %probar mediana
    Y_Mediana=zeros(1,length(VVal));
    for i = 1:length(VVal)
        j=[inferior_val superior_val];
        if i < length(inferior_val)
            RutaC=strcat(Ruta,'lid_l_ (',sprintf('%d',j(i)),').BMP');
        else
            RutaC=strcat(Ruta,'lid_u_ (',sprintf('%d',j(i)),').BMP');
        end
        %preparar
        Imagen3=imread(RutaC);
        Imagen = mean(Imagen3,3);
        [ImagenC1,ImagenN] = ContrasteYNormaliza(Imagen);

        %sacar la mediana de Superior
        Mascara=MatrizBW2dS.*ImagenN;
        Mascara=Mascara(Mascara>0);
        MedianaS = median(Mascara(:));
        %sacar la mediana de Inferior
        Mascara=MatrizBW2dI.*ImagenN;
        Mascara=Mascara(Mascara>0);
        MedianaI = median(Mascara(:));

        %decidir según sea signo
        Signo = (MedianaS - MedianaI);
        if Signo <0
            disp('inferior');
            Y_Mediana(i)=-1;
        else
            disp('superior');
            Y_Mediana(i)=1;
        end
    end


    %%
    %Entrenar Modernos
    MatrizCompleta = MatrizCompletaT';%cada columna es una imagen 
    %crear matrices train y val
    Matriz_Train=[MatrizCompleta(:,inferior_train) MatrizCompleta(:,superior_train+max(inferior))];
    Matriz_Val = [MatrizCompleta(:,inferior_val) MatrizCompleta(:,superior_val+max(inferior))];
    %imagesc(reshape(Matriz_Train(:,1),29,39))
    %mezcla imagenes de train
    Seed = randperm(length(VTrain));
    Matriz_Train = Matriz_Train(:,Seed);
    VTrain = VTrain(Seed);
    %%
    %Aqui van los modelos
    %Bosques
    Mdl = TreeBagger(50,Matriz_Train',VTrain','OOBPrediction','On','Method','classification');
    [Y_Bosques,scores_Bosques] = predict(Mdl,Matriz_Val');
    %SVM
    SVMModel = fitcsvm(Matriz_Train',VTrain','Standardize',true,'KernelFunction','RBF','KernelScale','auto');
    [Y_SVM,scores_SVM] = predict(SVMModel,Matriz_Val');
    %redes 
    % create network
    net = network( ...
    size(Matriz_Train,1), ... % numInputs, number of inputs,
    2, ... % numLayers, number of layers
    [1; 1], ... % biasConnect, numLayers-by-1 Boolean vector,
    [ones(1,size(Matriz_Train,1))' zeros(1,size(Matriz_Train,1))']', ... % inputConnect, numLayers-by-numInputs Boolean matrix,
    [0 0; 1 0], ... % layerConnect, numLayers-by-numLayers Boolean matrix
    [0 1] ... % outputConnect, 1-by-numLayers Boolean vector
    );
    % View network structure
    %view(net);

    %Define topology and transfer function
    % number of hidden layer neurons
    net.layers{1}.size = 5;
    net.layers{2}.size = 5;
    % hidden layer transfer function
    net.layers{1}.transferFcn = 'logsig';
    net.layers{2}.transferFcn = 'logsig';

    %Configure network
    net = configure(net,num2cell(Matriz_Train),num2cell(VTrain));

    %Train net and calculate neuron output
    % initial network response without training
    initial_output = net(num2cell(Matriz_Train));
    % network training
    net.trainFcn = 'trainlm';
    net.performFcn = 'mse';
    net.trainParam.showWindow = false;
    net = train(net,Matriz_Train,VTrain);

    % network response after training
    final_output = net(inputs);
end