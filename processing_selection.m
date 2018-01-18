function [pos_foot_nose] =processing_selection(CTstack,plane)
%Slider GUI
scrsz = get(groot,'ScreenSize');
hFig = figure('OuterPosition',[0 0.05*scrsz(4) scrsz(3) 0.95*scrsz(4)]);
hAx = axes('Parent',hFig);
[pix_x, pix_y, pix_z] = size(CTstack);
startSlice = pix_x/2;
stopSlice = pix_x;
pos_foot_nose=[1,pix_y/2;pix_z,pix_y/2];
%Slider control
uicontrol('Parent',hFig, 'Style','slider', 'Value',startSlice, 'Min',1,...
    'Max',stopSlice, 'SliderStep', [1 10]./(stopSlice-startSlice), ...
    'Position',[150 5 300 20], 'Callback',@slider_callback)
%Text above slider
hTxt = uicontrol('Style','text', 'Position',[290 28 150 15], 'String',['X Slice ',num2str(startSlice)]);
%Show overlay
if strcmp(plane,'X')
    imshow(squeeze(CTstack(startSlice,:,:)))
else
    imshow(squeeze(CTstack(:,startSlice,:)))
end
title('Select processing range')
%Get foot location
%foot line
line([1,1],[1,pix_y],'Color','b','LineWidth',1);
%nose line
line([pix_z,pix_z],[1,pix_y],'Color','y','LineWidth',1);

foot_nose = imline(hAx,[1,pix_y/2;pix_z,pix_y/2]);
constrainbox = makeConstrainToRectFcn('imline',[1,pix_z],[1,pix_y]);
setPositionConstraintFcn(foot_nose,constrainbox)
user_input=wait(foot_nose);
if isempty(user_input)
    %do nothing
else
    pos_foot_nose=getPosition(foot_nose);
end
delete(foot_nose);
%foot line
line([floor(pos_foot_nose(1,1)),floor(pos_foot_nose(1,1))],[1,pix_y],'Color','c','LineWidth',1);
%nose line
line([floor(pos_foot_nose(2,1)),floor(pos_foot_nose(2,1))],[1,pix_y],'Color','w','LineWidth',1);


% Callback function
    function slider_callback(hObj, eventdata)
        %Get slide number from slider position
        slice = round(get(hObj,'Value'));
        %Update slice image
        if strcmp(plane,'X')
            imshow(squeeze(CTstack(slice,:,:)))
        else
            imshow(squeeze(CTstack(:,slice,:)))
        end
        title('Select processing range')
        line([floor(pos_foot_nose(1,1)),floor(pos_foot_nose(1,1))],[1,pix_y],'Color','b','LineWidth',1);
        %nose line
        line([floor(pos_foot_nose(2,1)),floor(pos_foot_nose(2,1))],[1,pix_y],'Color','y','LineWidth',1);
        
        %Update slider text
        set(hTxt, 'String',['X Slice ',num2str(slice)]);
        foot_nose = imline(hAx,pos_foot_nose);
        setPositionConstraintFcn(foot_nose,constrainbox)
        user_input=wait(foot_nose);
        if isempty(user_input)
            pos_foot_nose=pos_foot_nose;
        else
            pos_foot_nose=getPosition(foot_nose);
        end
        delete(foot_nose);
        %foot line
        line([floor(pos_foot_nose(1,1)),floor(pos_foot_nose(1,1))],[1,pix_y],'Color','c','LineWidth',1);
        %nose line
        line([floor(pos_foot_nose(2,1)),floor(pos_foot_nose(2,1))],[1,pix_y],'Color','w','LineWidth',1);
    end
uiwait(hFig);
end