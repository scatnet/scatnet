% prepare_database: Calculates the features from objects in a source.
% Usage
%    database = prepare_database(src, feature_fun, options)
% Input
%    src: The source specifying the objects.
%    feature_fun: The feature functions applied to each object.
%    options: Options for calculating the features:
%       options.feature_sampling: specifies how to sample the feature vectors
%           in time/space (default 1).
%       options.file_normalize: The normalization of each file before being
%          given to feature_fun. Can be empty, 1, 2, or Inf (default []).
%       options.parallel: If 1, tries to use the Distributed Computing Tool-
%          box to speed up calculation (default 1).
%       Other options are listed in the help for the feature_wrapper function.
% Output
%    database: The database of feature vectors.

function db = prepare_inst_db2(src,feature_fun,opt)
if nargin < 3
    opt = struct();
end

opt = fill_struct(opt, 'feature_sampling', 1);
opt = fill_struct(opt, 'file_normalize', []);
opt = fill_struct(opt, 'parallel', 1);
opt = fill_struct(opt, 'average', 0);
opt = fill_struct(opt, 'zero_complete',0);
opt = fill_struct(opt,'sig_normalize',0);


features = cell(1,length(src.files));
obj_ind = cell(1,length(src.files));

rows = 0;
cols = 0;
precision = 'double';

if (opt.parallel)
    % parfor loop
    
    parfor k = 1:length(src.files)
        file_objects = find([src.objects.ind]==k);
        
        if length(file_objects) == 0
            continue;
        end
        
        tm0 = tic;
        
        %x=rand(2^17,1);
        x = data_read(src.files{k});
        
        if ~isempty(opt.average)
            if opt.average == 1
                x=x-mean(x,1);
            end
        end
        
        if ~isempty(opt.file_normalize)
            if opt.file_normalize == 1
                x = x/sum(abs(x(:)));
            elseif opt.file_normalize == 2
                x = x/sqrt(sum(abs(x(:)).^2));
            elseif opt.file_normalize == Inf
                x = x/max(abs(x(:)));
            end
        end
        
        
        if ~isempty(opt.zero_complete)
            if opt.zero_complete == 1 && isfield(src,'Tmax')
                x=zero_complete(x,src.Tmax);
            elseif opt.zero_complete == 1 && ~isfield(src,'Tmax')
                disp('lol')
                error('Tmax must be a field of src!');
            end
        end
        
        if ~isempty(opt.sig_normalize)
            if opt.sig_normalize == 1
                x=x./std(x,[],1);
            end
        end
        
        %features{k} = cell(1,length(file_objects));
        obj_ind{k} = file_objects;
        
        features{k} = apply_features(x,src.objects(file_objects),feature_fun,opt);
        %buf=zeros(100,300,300);
        %for l = 1:length(file_objects)
        %features{k}= buf(:,1:opt.feature_sampling:end,l);
        %end
        
        fprintf('calculated features for %s. (%.2fs)\n',src.files{k},toc(tm0));
    end
else
    time_start = clock;
    for k = 1:length(src.files)
        file_objects = find([src.objects.ind]==k);
        
        if length(file_objects) == 0
            continue;
        end
        
        tm0 = tic;
        x = data_read(src.files{k});
        if opt.average == 1
            x=x-mean(x,1);
        end
        if ~isempty(opt.file_normalize)
            if opt.file_normalize == 1
                x = x/sum(abs(x(:)));
            elseif opt.file_normalize == 2
                x = x/sqrt(sum(abs(x(:)).^2));
            elseif opt.file_normalize == Inf
                x = x/max(abs(x(:)));
            end
        end
        
        if ~isempty(opt.zero_complete)
            if opt.zero_complete == 1 && isfield(src,'Tmax')
                x=zero_complete(x,src.Tmax);
            elseif opt.zero_complete == 1 && ~ isfield(src,'Tmax')
                error('Tmax must be a field of src! ');
            end
        end
        
        
        if ~isempty(opt.sig_normalize)
            if opt.sig_normalize == 1
                x=x./std(x,[],1);
            end
        end
                
        features{k} = cell(1,length(file_objects));
        obj_ind{k} = file_objects;
        
        features{k} = apply_features(x,src.objects(file_objects),feature_fun,opt);
        size(features{k})
        %for l = 1:length(file_objects)
        %	features{k}{l} = buf(:,1:opt.feature_sampling:end,l);
        %end
        time_elapsed = etime(clock, time_start);
        estimated_time_left = time_elapsed * (length(src.files)-k) / k;
        fprintf('calculated features for %s. (%.2fs)\n',src.files{k},toc(tm0));
        fprintf('%d / %d : estimated time left %d seconds\n',k,length(src.files),floor(estimated_time_left));
    end
end

% 	nonempty = find(~cellfun(@isempty,features));
%
% 	rows = size(features{nonempty(1)}{1},1);
% 	cols = sum(cellfun(@(x)(sum(cellfun(@(x)(size(x,2)),x))),features(nonempty)));
%
%     precision = class(features{nonempty(1)}{1});
% 	db.src = src;
% 	db.features = [];
%
% 	db.indices = cell(1,length(src.objects));
%


%%here we suppose that we are computing a scattering of order 2
feats{1}=cell(1,length(features{1}{2}.signal));
for f=1:length(features{1}{2}.signal)
    feats{1}{f}=[];
end

% feats{2}=cell(1,length(features{1}{3}.signal));
% for f=1:length(features{1}{3}.signal)
%     feats{2}{f}=[];
% end

dfeats=length(features);

for k = 1:dfeats
    for f=1:length(features{k}{2}.signal)
        for j=1:min(5,size(features{k}{2}.signal{1},3))
            feats{1}{f}=[feats{1}{f};single(features{k}{2}.signal{f}(:,:,j))];
        end
    end
%     
%     for f=1:length(features{k}{3}.signal)
%         for j=1:5 %size(features{k}{3}.signal{1},3);
%             feats{2}{f}=[feats{2}{f};single(features{k}{3}.signal{f}(:,:,j))];
%         end
%     end
    
end

 db=feats;

end

function out = apply_features(x,objects,feature_fun,opt)
if ~iscell(feature_fun)
    feature_fun = {feature_fun};
end
out = {};
for k = 1:length(feature_fun)
    if nargin(feature_fun{k}) == 2
        disp('lol2')
        out{k,1} = feature_fun{k}(x,objects);
    elseif nargin(feature_fun{k}) == 1
        out{k,1} = feature_wrapper(x,objects,feature_fun{k},opt);
    else
        error('Invalid number of inputs for feature function!')
    end
end

if length(feature_fun) == 1
    out = out{1};
else
    out = cellfun(@(x)(permute(x,[2 1 3])),out,'UniformOutput',false);
    out = permute([out{:}],[2 1 3]);
end
end

function x =zero_complete(x, T)

if size(x,1) > 1
    x=[x; zeros(T-size(x,1),1)];
else
    x=[x, zeros(1,T-size(x,2))];
    
end

end



