
function src =instsnds_sigma_src_multi_obj(directory,T)

if nargin < 1
    error('you must provide at least one directory');
end

if nargin < 2
    T= 2^16;
end

src = create_sigma_src(directory,@(file)(objects_fun(file,directory,T)));
end

function [objects,classes] = objects_fun(file,directory,T)

tmpsnd=data_read(file);
pow2=size(tmpsnd,1);
%pow2=pow2-32000;

nbobjs1 = floor(pow2/T);
slgth=nbobjs1*T;

shortf_ind=file;
path_folders = regexp(directory,filesep,'split');
if length(path_folders) < 3
    file=shortf_ind(length(directory)+2:end);
else file=shortf_ind(length(directory)-2:end);
end

objects=struct();
classes={};

%disp('lol')
path_str = fileparts(file);
path_parts = regexp(path_str,filesep,'split');

cname=path_parts{end};
if strcmp(cname(end),'p')==1
    cname=cname(1:end-1);
end
%classes={cname};
if mod(slgth,T)~=0
    error('T must divide slgth and T must be a power of 2');
end

nbobjs = slgth/T;

for n=1:nbobjs
    objects(n).u1=1+(n-1)*T;
    objects(n).u2=n*T;
    classes{n}=cname;
end
end

