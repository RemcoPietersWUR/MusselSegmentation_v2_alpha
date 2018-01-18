%Segmentation_v2_alpha
%--------------------------------------------------------------------------
%ToDo

% 1 Better (stronger) binarization foot
%Compare new boundary to filter boundary
%--------------------------------------------------------------------------
clear all
close all

%Parameters
Binarize_method = 'global'; %Threshold method. 'global' global thresholding using Otsu's method.
% 'adaptive' loccaly thresholding using first order statistics
adj_intensity = true;
median_filter = true;
median_sigma = 1; %Numbers of neigbours for median filtering
conn = 8; %Connectivity for the connected components 2D: 4 or 8
%Structual closing element lines
se = strel('disk',5);
se2=strel('disk',10);


%% Get file info CT images
FileInfo = importCT;
%load FileInfo.mat;

%% Load image sequence in memory
FirstSlice = FileInfo.id_start; %First slice for segmentation, type char
%FirstSlice = '0001';
LastSlice = FileInfo.id_stop; %Last slice for segmentation, type char
%LastSlice = '1017';

CTstack=loadIMsequence(FileInfo,FirstSlice,LastSlice,1);

%%Align and select mussel
ui_slice = round(str2double(LastSlice)-str2double(FirstSlice),0)/2;
[orientation_angle,IMrot] = select_cross_section(CTstack,ui_slice);

%Free memory
clear CTstack


%Select processing region between foot and nose
pos_foot_nose=processing_selection(IMrot,'X');
%pos_foot_nose=[27,512;1013,512];
%Make substack
IMrot=IMrot(:,:,floor(pos_foot_nose(1,1)):floor(pos_foot_nose(2,1)));

%CT-stack size in pixels
[px_x,px_y,px_z] = size(IMrot);

%% Image noise filtering
%Remove outliers in 3D-space with median filter
if median_filter
    IMrot = medfilt3(IMrot,median_sigma*[3,3,3]);
end
[graylevel] = graythresh(IMrot(:,:,ui_slice));
%% Binarize
BW=false(size(IMrot));
for idx = 1:px_z
    if adj_intensity
        BW(:,:,idx) = imbinarize(imadjust(IMrot(:,:,idx)), Binarize_method);
    else
        %BW(:,:,idx) = imbinarize(IMrot(:,:,idx), Binarize_method);
        BW(:,:,idx) = imbinarize(IMrot(:,:,idx), graylevel);
    end
end

%% Compute convex hull
BWhull=false(size(IMrot));
for idx = 1:px_z
    IMcon = localcontrast(IMrot(:,:,idx));
    
    BW2 = edge(IMcon,'canny');
    BW3 = immultiply(BW2,BW(:,:,idx));
    
    %Remove small patches
    BW4 = bwareaopen(BW3,10);%
    %Get convexhull
    BWhull(:,:,idx) = bwconvhull(BW4);
end

%Boundary of convex hull
for slice = 1:px_z
    B = bwboundaries(BWhull(:,:,slice),'noholes');
    A= B{1,1};
    
    %Displacement between points
    for idx = 1:(length(A)-1)
        delta(idx,:)=A(idx+1,:)-A(idx,:);
    end
    %Compute the outline based on displacement delta
    x = zeros(length(A),1);
    y = zeros(length(A),1);
    x(1)=A(1,1);
    y(1)=A(1,2);
    for idx = 1:length(delta)
        x(idx+1) = x(idx) + delta(idx,1);
        y(idx+1) = y(idx) + delta(idx,2);
    end
    %Normalize delta
    for idx = 1:length(delta)
        delta(idx,:) = delta(idx,:) / norm(delta(idx,:));
    end
    % %Draw normal lines
    % for i=1:length(delta)
    %     line([x(i)+delta(i,2), x(i)],[y(i)-delta(i,1), y(i)]);
    % end
    % axis equal
    
    %Normal lines to boundary factor determines the length
    factor = 50;
    for i=1:length(delta)
        %round to full pixel
        Y(i,:)=round([y(i)-factor*delta(i,1),y(i)],0);
        X(i,:)=round([x(i)+factor*delta(i,2), x(i)],0);
    end
    
    %Gradient
    Gval = cell(1,length(delta));
    for i=1:length(delta)
        %March inwards convexhull boundary is start point
        %XX & YY are local xy values to sample gray value
        Xedge = x(i);
        Yedge = y(i);
        if delta(i,2)>0
            XX=Xedge:X(i,1);
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            elseif delta(i,1)>0
                YY=flip(Y(i,1):Yedge);
            else
                YY=Yedge*ones(1,numel(XX));
            end
        elseif delta(i,2)<0
            XX=flip(X(i,1):Xedge);
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            elseif delta(i,1)>0
                YY=flip(Y(i,1):Yedge);
            else
                YY=Yedge*ones(1,numel(XX));
            end
        else
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            else
                YY=flip(Y(i,1):Yedge);
            end
            XX=Xedge*ones(1,numel(YY));
        end
        for idp=1:numel(XX)
            Gval_loc(idp) = IMrot(XX(idp),YY(idp),slice);
        end
        clear XX
        clear YY
        Gval{1,i}=Gval_loc;
        clear Gval_loc
    end
    
    %Compute derivatives, change to signed int16
    for section = 1:length(delta)
        Gval_s= int16(Gval{1,section});
        Gval_d1{1,section} = diff(Gval_s);
        Gval_d2{1,section} = diff(Gval_s,2);
        clear Gval_s
    end
    
    %Find outer- en innerline & plot
%     figure
%     imshow(IMrot(:,:,slice))
%     hold on
%     plot(A(:,2),A(:,1))%A is convexhull boundary
    outline = zeros(2,length(delta));
    inline = zeros(2,length(delta));
    for i = 1:length(delta)
        %March inwards convexhull boundary is start point
        Xedge = x(i);
        Yedge = y(i);
        if delta(i,2)>0
            XX=Xedge:X(i,1);
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            elseif delta(i,1)>0
                YY=flip(Y(i,1):Yedge);
            else
                YY=Yedge*ones(1,numel(XX));
            end
        elseif delta(i,2)<0
            XX=flip(X(i,1):Xedge);
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            elseif delta(i,1)>0
                YY=flip(Y(i,1):Yedge);
            else
                YY=Yedge*ones(1,numel(XX));
            end
        else
            if delta(i,1)<0
                YY=Yedge:Y(i,1);
            else
                YY=flip(Y(i,1):Yedge);
            end
            XX=Xedge*ones(1,numel(YY));
        end
        [~,in_edg]=max(Gval_d1{1,i});
        [~,out_edg]=min(Gval_d1{1,i});
%         plot(YY(in_edg),XX(in_edg),'.r')
%         plot(YY(out_edg),XX(out_edg),'.g')
        outline(:,i)=[XX(in_edg),YY(in_edg)];
        inline(:,i)=[XX(out_edg),YY(out_edg)];
        clear XX
        clear YY
    end
    
    
    TMout=false(size(BW(:,:,slice)));
    TMin=false(size(BW(:,:,slice)));
    for i = 1:length(delta)
        TMout(outline(1,i),outline(2,i))=1;
        TMin(inline(1,i),inline(2,i))=1;
    end
    TMout_c=imclose(TMout,se);
    TMin_c=imclose(TMin,se);
    TM(:,:,slice)=logical(imadd(TMout_c,TMin_c));
    %Clean up
    clear delta
end
for slice = 1:px_z
    TM(:,:,slice)=bwmorph(TM(:,:,slice),'bridge');
    TM(:,:,slice)=imclose(TM(:,:,slice),se2);
end
for slice = 1:px_z
    Bound = bwboundaries(TM(:,:,slice));
    boundlength=cellfun(@numel,Bound);
    [~,idx]=sort(boundlength,'descend');
    TM2=false(size(TM(:,:,slice)));
    TM3=false(size(TM(:,:,slice)));
    boundary1=Bound{idx(1)};
    for id=1:length(boundary1)
        TM2(boundary1(id,1),boundary1(id,2))=true;
    end
     boundary2=Bound{idx(2)};
    for id=1:length(boundary2)
        TM3(boundary2(id,1),boundary2(id,2))=true;
    end
    TM(:,:,slice)=imabsdiff(imfill(TM2,'holes'),imfill(TM3,'holes'));
    clear bound
    clear boundlength
    clear idx
    clear TM2
    clear TM3
end
slider(FirstSlice,LastSlice,IMrot,TM,'Area');

%Calculate region properties
%first for slice 1 to determine size table
stats = regionprops('table',TM(:,:,1),IMrot(:,:,1),'Area',...
    'BoundingBox','Centroid','Perimeter','MaxIntensity','MeanIntensity',...
    'MinIntensity','WeightedCentroid');
Slice = ones(height(stats),1).*1;
SliceProps = [table(Slice),stats];
for slice = 2:px_z
stats = regionprops('table',TM(:,:,slice),IMrot(:,:,slice),'Area',...
    'BoundingBox','Centroid','Perimeter','MaxIntensity','MeanIntensity',...
    'MinIntensity','WeightedCentroid');
Slice = ones(height(stats),1).*slice;
SliceProps = [SliceProps;[table(Slice),stats]];
end
[filenameProps, pathnameProps] = uiputfile('ShellProps.xlsx',...
                       'Save file');
if isequal(filenameProps,0) || isequal(pathnameProps,0)
   disp('User selected Cancel')
else
   writetable(SliceProps,fullfile(pathnameProps,filenameProps));
end

%Plots
VarPlot=table2array(SliceProps);
scatter(VarPlot(:,1),VarPlot(:,2),2,'filled')
xlabel('Height (px)')
ylabel('Cross sectional area (px)')
figure
s1=scatter3(VarPlot(:,3),VarPlot(:,4),VarPlot(:,1),2,[0,0,1],'filled');
hold on
s2=scatter3(VarPlot(:,10),VarPlot(:,11),VarPlot(:,1),2,[1,0,0],'filled');
hold off
xlim([1,1024]);
ylim([1,1024]);
zlim([1,px_z])
xlabel('X (px)')
ylabel('Y (px)')
zlabel('Height (px)')
title('Centroid of shell part (Blue none weighted,Red density weighted)')    