function [dRecta,dCurva] = SavitzkyGolay(Img_Tort1)
    BwP = double(bwperim(Img_Tort1));
    [ y, x] = find(BwP);
    if mod(length(x),2)
        len = length(x);
    else
        len = length(x)-1;
    end
    pointsx = sgolayfilt(x,2,len);
    pointsy = sgolayfilt(y,2,len);
    %imagesc(BwP),hold on, plot(pointsx,pointsy,'rx'),hold off
    [dRecta,~] = pdist2([pointsx(1) pointsy(1)],[pointsx(length(pointsx)) pointsy(length(pointsy))], 'euclidean', 'Largest',1);
    dCurva = length(pointsx);
end

