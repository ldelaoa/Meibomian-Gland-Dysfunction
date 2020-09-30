function [ImC1,ImN] = ContrasteYNormaliza(Im)
    
    %ajusta contraste
    ImC= (Im-min(Im(:)));
    ImC1 = ImC.*(255/(max(ImC(:))-min(ImC(:)))); 
    %normaliza de 0 a 1
    ImN=ImC1./max(ImC1(:));
end