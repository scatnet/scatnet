% SVM_TRAIN Train an SVM classifier
%
% Usage
%    model = SVM_TRAIN(db, train_set, options)
%
% Input
%    db (struct): The database containing the feature vector.
%    train_set (int): The object indices of the training instances.
%    options (struct): The training options:
%          options.kernel_type (char): The kernel type: 'linear' or 'gaussian'
%             (default 'gaussian').
%          options.C (numeric): The slack factor (default 8).
%          options.gamma (numeric): The gamma of the Gaussian kernel (default 
%             1e-4).
%          options.no_inplace (boolean): Do not use the inplace version of 
%             LIBSVM, even if it available (default false).
%          options.full_test_kernel (boolean): Explicity calculate the test
%             kernel instead of relying on the precalculated kernel. Used if 
%             the kernel is only defined on the training vectors (default 
%             false).
%          options.w (boolean): Add weights to rebalance the training set if 
%             it is inbalanced. The rebalancing is done so that the distribu-
%             tion of the training samples seem to be uniform for all the 
%             classes (default 0).
%
% Output
%    model (struct): The SVM model.
%
% Description
%    The svm_train function provides an interface to the LIBSVM set of
%    SVM training routines. If available, will use the inplace version found
%    in libsvm-compact (see http://www.di.ens.fr/data/software/) to save
%    memory and speed up calculations.
%
% See also
%    SVM_TEST, CLASSIF_ERR, CLASSIF_RECOG

function model = svm_train(db,train_set,opt)
	  if nargin < 3
                opt = struct();
        end

        %if ~exist('svmtrain_inplace')
        %        error('you should make sure svmtrain_inplace is available...');
        %end

        opt = fill_struct(opt,'no_inplace',0);
        opt = fill_struct(opt,'full_test_kernel',0);

        opt = fill_struct(opt,'kernel_type','gaussian');

        opt = fill_struct(opt,'gamma',1e-4);
        opt = fill_struct(opt,'C',8);
        opt = fill_struct(opt, 'w',0);
        opt = fill_struct(opt, 'b',0);

        ind_features = [];
        feature_class = [];
        for k = 1:length(train_set)
                ind = db.indices{train_set(k)};
                ind_features = [ind_features ind];
                feature_class = [feature_class ...
                db.src.objects(train_set(k)).class*ones(1,length(ind))];
        end


        precalc_kernel = isfield(db,'kernel') && ...
        strcmp(opt.kernel_type,db.kernel.kernel_type);

        params = ['-q -c ' num2str(opt.C)];
        if ~precalc_kernel
                if strcmp(opt.kernel_type,'linear')
                        params = [params ' -t 0'];
                elseif strcmp(opt.kernel_type,'gaussian')
                        params = [params ' -t 2 -g ' num2str(opt.gamma)];
                else
                        error('Unknown kernel type!');
                end
                features = db.features(:,ind_features);
        else
                [kernel_mask,kernel_ind] = ismember(1:size(db.features,2),db.kernel.kernel_set);

                ind_features = kernel_ind(ind_features(kernel_mask(ind_features)));

                if exist('svmtrain_inplace') && ~opt.no_inplace
                        feature_class = zeros(1,size(db.features,2));
                        for k = 1:length(db.indices)
                                feature_class(db.indices{k}) = db.src.objects(k).class;
                        end
                        feature_class = feature_class(db.kernel.kernel_set);
                        features = db.kernel.K;

                        if strcmp(db.kernel.kernel_type,'linear') && ...
                                strcmp(db.kernel.kernel_format,'square')
                                params = [params ' -t 4'];
                        elseif strcmp(db.kernel.kernel_type,'linear') && ...
                                strcmp(db.kernel.kernel_format,'triangle')
                                params = [params ' -t 5'];
                        elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
                                strcmp(db.kernel.kernel_format,'square')
                                params = [params ' -t 6 -g ' num2str(opt.gamma)];
                        elseif strcmp(db.kernel.kernel_type,'gaussian') && ...
                                strcmp(db.kernel.kernel_format,'triangle')
                                params = [params ' -t 7 -g ' num2str(opt.gamma)];
                        else
                                error('Unknown kernel type/format!');
                        end
                else
                        params = [params ' -t 4'];

                        if strcmp(db.kernel.kernel_format, 'triangle')
                                error(['Triangular kernels not supported for standard ' ...
                                ' LIBSVM version. Please try libsvm-compact.'])
                        end
                        features = db.kernel.K(:,ind_features);

                        if strcmp(db.kernel.kernel_type,'gaussian')
                                features(2:end,:) = exp(-opt.gamma*features(2:end,:));
                                params = [params ' -g ' num2str(opt.gamma)];
                        end
                end
        end


        if opt.w 
                db_weights = calc_train_weights(db, train_set, opt);
                params = [params db_weights];
        end


        params=[params ' -b ' num2str(opt.b)];


        model.full_test_kernel = opt.full_test_kernel;

        model.train_set = train_set;

        if ~exist('svmtrain_inplace') || opt.no_inplace
                model.svm = svmtrain(double(feature_class.'), ...
                double(features.'),params);
        else
                model.svm = svmtrain_inplace(feature_class, ...
                single(features),params,ind_features);
        end
end

function db_weights = calc_train_weights(db,train_set)

    % The weight of each class k is the ratio btw the total number of
    % training features Nfeat_tot, and the number of training features of 
    % the class Nfeat_train_k ie w_k =  Nfeat_tot/Nfeat_train_k
    
        ind_objs = {};
        ind_feats = {};
        db_weights = [];
    
    % Find the total number of features in the training set
        tot_ind_objs = 1:numel(db.src.objects);
        tot_ind_feats = [db.indices{tot_ind_objs}];
        mask = ismember(tot_ind_feats,[db.indices{train_set}]);
        nb_train_feats = numel(tot_ind_feats(mask>0));
       
        for k = 1:length(db.src.classes)
                ind_objs{k} = find([db.src.objects.class] == k);
                ind_feats{k} = [db.indices{ind_objs{k}}];
                mask_class = ismember(ind_feats{k},[db.indices{train_set}]);
                ind_feats{k} = ind_feats{k}(mask_class > 0);
                db_weights = [db_weights ' -w' num2str(k) ' ' num2str(nb_train_feats/numel(ind_feats{k}))];
        end
end
