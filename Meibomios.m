function [ImC1,ImN] = Meibomios(RegionMeibo,ImagenN)

%ajusta contraste
MinRegionMeibo=min(min(RegionMeibo(RegionMeibo(:)>0)));
MaxRegionMeibo = max(max(RegionMeibo));
RangoMeibo = MaxRegionMeibo-MinRegionMeibo;
ImC1 = (ImagenN - MinRegionMeibo ) ./ RangoMeibo;
%ImC1 = ImagenN.*(MaxRegionMeibo/RangoMeibo); 
%Recorta de 0 a 1
ImN=ImC1;
ImN(ImN>1)=1;
ImN(ImN<0)=0;   
end