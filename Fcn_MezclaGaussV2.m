function [clusterX,y,sol] = Fcn_MezclaGaussV2(X,NoE)
%X is data
%NoE Number of elements
%T targets
%figure,histogram(X,100,'Normalization','probability')
gmfit = fitgmdist(X,NoE,'CovarianceType','full'... % covariance full forza a que exista una matriz relacionada en x
     ,'SharedCovariance',false,...%significa que las covarianzas no se pueden cruzar, osea son diferentes
     'Options',statset('MaxIter',2500),'RegularizationValue',.01); %maximo 1k iteraciones de EM

%%
clusterX = cluster(gmfit,X);

%Plano = linspace(min(X(:)),max(X(:)));
%PlanoGrid = meshgrid(Plano,Plano);
PlanoGrid = 0:1/255:1;
for i = 1:NoE
    y(i,:) = normpdf(PlanoGrid,gmfit.mu(i),sqrt(gmfit.Sigma(i)));%Sigma con sqrt o sin sqrt ? 
end

%% solucion
p = [1/(2*gmfit.Sigma(1))-1/(2*gmfit.Sigma(2)) (gmfit.mu(2)/gmfit.Sigma(2))-(gmfit.mu(1)/gmfit.Sigma(1)) ...
    (gmfit.mu(1)^2/(2*gmfit.Sigma(1))-gmfit.mu(2)^2/(2*gmfit.Sigma(2))-log10(gmfit.Sigma(2)/gmfit.Sigma(1)))];
sol = roots(p);
if false
    figure(98)
    subplot(1,2,1),plot(y(1,:)),hold on,plot(y(2,:),'r'), hold off
    subplot(1,2,2),boxplot(y')
end

