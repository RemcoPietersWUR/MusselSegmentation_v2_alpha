function showOverlay(IM,BW,header)
%showOverlay display grayscale image with overlay of segmented area


%Make overlay, RGB, green
overlay = cat(3, zeros(size(BW)), ...
    ones(size(BW)), zeros(size(BW))); 
%Show overlay
imshow(IM)
hold on
hfig = imshow(overlay); 
set(hfig, 'AlphaData', immultiply(BW,IM)) 
hold off
title(header);
end