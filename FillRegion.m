function [ImFilled] = FillRegion(ImBin)
[row,col,~] = find(ImBin);
MaxLocal = [];
MinLocal = [];
for i=1:length(row)-1
    a= row(i);
    b= row(i+1);
    if b < a 
        %Minimo local
        MaxLocal(length(MaxLocal)+1) = a;
        MinLocal(length(MinLocal)+1) = b;
    end
end
ImFilled=zeros(size(ImBin));
col2 = unique(col);
for i=1:length(MaxLocal)
    ImFilled(MinLocal(i):MaxLocal(i)-1,col2(i))=linspace(MinLocal(i),MaxLocal(i),MaxLocal(i)-MinLocal(i));
end
ImFilled(ImFilled~=0)=1;
%imagesc(ImFilled)
end

