function [FileInfo] = importCT
%Locate files
[filename, path] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
         '*.*','All Files' },'Select reconstructed cross-section');
[pathIM,filenameIM,extIM] = fileparts(fullfile(path,filename));
%Find alphathic part of the filename
prefixIM=filenameIM(1:find(isstrprop(filenameIM, 'alpha'),1,'last'));
%Get file properties
files = dir([pathIM,filesep,prefixIM,'*',extIM]);
%Get only sequently numbered files
%Define counter to sort index array
counter =1;
for i=1:numel(files)
    Filename=files(i).name;
    index=Filename(numel(prefixIM)+1:end-numel(extIM));
    if isstrprop(index,'digit')
        id(i)=cellstr(index);
        counter=counter+1;
    end
end
%Sort index array id
sort(id);
%Output in strut
FileInfo.path=pathIM;
FileInfo.prefix=prefixIM;
FileInfo.ext=extIM;
FileInfo.id_start=char(id(1));
FileInfo.id_stop=char(id(end));
end