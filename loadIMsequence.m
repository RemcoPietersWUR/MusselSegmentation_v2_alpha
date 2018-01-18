function CTstack=loadIMsequence(FileInfo,idFirst,idLast,Layer)
%loadIMsequence, load images into the the memory.
%Input:
%FileInfo: Pathname, Filename/Prefix
%idFirst: First image of the sequence to load into memory, type char
%idLast: Last inmage of the sequence to load into memory, type char
%Layer: defines color layer of input images, monochrome layer=1,RGB layer=3

%Preallocate memory
%Number of slices to load
Nslices=numel(str2double(idFirst):str2double(idLast));
%Load first image to get image size
IM=imread([FileInfo.path, filesep, FileInfo.prefix, ...
    FileInfo.id_start, FileInfo.ext]);
%Combine double stitched image to single image
[~,~,IMdepth]=size(IM);
if IMdepth == 3
    IM=imadd(immultiply(IM(:,:,1),0.5),immultiply(IM(:,:,2),0.5));
end

%preallocate memory
CTstack = zeros([size(IM),Layer, Nslices],class(IM));
%Get images
CTstack(:,:,:,1)=IM;
%Decode numbering type
%Zero padding
FieldWidth = numel(idFirst);
formatSpec=['%0',num2str(FieldWidth),'u'];
for id=2:Nslices
    SliceNumber = sprintf(formatSpec,(str2double(idFirst)-1+id));
    CTstack(:,:,:,id)=imread([FileInfo.path, filesep, FileInfo.prefix, ...
    SliceNumber, FileInfo.ext]);
end