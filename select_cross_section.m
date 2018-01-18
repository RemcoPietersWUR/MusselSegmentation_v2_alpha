function [theta,IMrot]= select_cross_section(CTstack,show_slice)
%select_cross_section, user indicates cross-section through the midplane of
%the mussel. This is used to select the first/last slice and to verify the
%verticale orientation of the mussel

fig1 = figure;
imshow(CTstack(:,:,:,show_slice));
title('Draw line between shell halfs to rotate the mussel. Double click on line to continue');
%interactive line drawig
h=imline;
position=round(wait(h)); %use round to get pixel coordinates
close(fig1)

%Compute orientation angle of shell in degrees, atan2d (four-quadrant in
%degrees).
theta = atan2d((position(1,1)-position(2,1)),(position(1,2)-position(2,2)));
IMrot=zeros(size(squeeze(CTstack)),'uint16');
for slice=1:size(CTstack,4)
IMrot(:,:,slice) = imrotate(CTstack(:,:,:,slice),-theta-90,'crop');
end


% %Asumption CT reconstruction rotation centre is in the middle of the image.
% %Show sagital cross section around the center cross of the image
% imshow(IMrot(:,:,show_slice))
% %Show cross section planes on image
% Xpx = size(CTstack,2);
% Ypx = size(CTstack,1);
% %X plane
% line([Xpx/2,Xpx/2],[1,Ypx],'Color','r','LineWidth',4);
% %Y plane
% line([1,Xpx],[Ypx/2,Ypx/2],'Color','g','LineWidth',4);


