function [Tmin,Tmax,Tmed,Tstd] = tortuosity(BW_G)
[CC,numel] = bwlabel(BW_G,8); %label for each element
k=1;
dRecta = zeros(numel,1);
dCurva= zeros(numel,1);
while k ~=numel
    [rc] = find(CC==k); % coordinates for each elem
    if bwarea(rc)>60      
        Img_Tort1 = zeros(size(CC)); %image for each elem
        Img_Tort1(rc) = 1;

        [dRecta(k),dCurva(k)]= SavitzkyGolay(Img_Tort1);%curvature
    end
    k=k+1;
end
dRecta = nonzeros(dRecta);
dCurva = nonzeros(dCurva);
t = dRecta./dCurva;
Tmin = min(t);
Tmax = max(t);
Tmed = mean(t);
Tstd = std(t);
end