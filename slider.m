function slider(FirstSlice,LastSlice,CTstack,BWfinal,type)
%Slider GUI
hFig = figure('menu','none');
hAx = axes('Parent',hFig);
startSlice = str2double(FirstSlice);
stopSlice = str2double(LastSlice);
%Slider control
uicontrol('Parent',hFig, 'Style','slider', 'Value',startSlice, 'Min',startSlice,...
    'Max',stopSlice, 'SliderStep', [1 10]./(stopSlice-startSlice), ...
    'Position',[150 5 300 20], 'Callback',@slider_callback)
%Text above slider
hTxt = uicontrol('Style','text', 'Position',[290 28 150 15], 'String',['Slice ',num2str(startSlice)]);
%Show overlay
if strcmpi('Area',type)
    showOverlay(CTstack(:,:,startSlice),BWfinal(:,:,startSlice),'Segmented Area');
else
    showOutline(CTstack(:,:,startSlice),BWfinal(:,:,startSlice),'Segmented Area');
end
% Callback function
    function slider_callback(hObj, eventdata)
        %Get slide number from slider position
        slice = round(get(hObj,'Value'));
        %Update slice image
        if strcmpi('Area',type)
            showOverlay(CTstack(:,:,slice),BWfinal(:,:,slice),'Segmented Area');
        else
            showOutline(CTstack(:,:,slice),BWfinal(:,:,slice),'Segmented Area');
        end
        %Update slider text
        set(hTxt, 'String',['Slice ',num2str(slice)]);
        hold off
    end
uiwait(hFig);
end