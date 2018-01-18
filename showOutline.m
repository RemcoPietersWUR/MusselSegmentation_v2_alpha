function [IM2]=showOutline(IM,BW,header)
%showOutline display grayscale image with overlay of segmented outline

%Find outline in BW image
Outline = bwperim(BW);
%Show outline as white line, assume 16bit tiff
IM2=IM;
IM2(Outline)=65536;

%Show image
imshow(IM2);
title(header);
end