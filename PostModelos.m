function [smoothX,smoothY] = PostModelos(Res_Modelo,SE1,SE2)
SE = strel('disk',SE1,8);
K = imerode(Res_Modelo,SE);
SE = strel('line',SE2,0);
K1 = imerode(K,SE);
J = imclose(K1,SE); 
%SavitzkyGolay Filter
% Now get the boundaries.
biggestBlob = ExtractNLargestBlobs(logical(J),1);

SE = strel('disk',10,8);
biggestBlob2 = imdilate(biggestBlob,SE);
boundaries = bwboundaries(biggestBlob2);
if numel(boundaries)~=0
    firstBoundary = boundaries{1};
    % Get the x and y coordinates.
    x = firstBoundary(:, 2);
    y = firstBoundary(:, 1);
    framelen = 201;%101
    polynomialOrder = 5;%12
    if numel(x)<=framelen
        framelen = numel(x);
        polynomialOrder = numel(x)-2;
        if rem(numel(x),2)==0
            framelen=framelen-1;
        end
    end
    smoothX = sgolayfilt(x, polynomialOrder, framelen);
    smoothY = sgolayfilt(y, polynomialOrder, framelen);
else
    smoothX = 0;
    smoothY = 0;
end
end

