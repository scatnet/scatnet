function [feat_train,feat_test,train_id,test_id]= classif_split(feat,Ntrain,iter,Ntestmax)
% split db between training and testing
if ~exist('iter','var') iter = 1; end
if  ~exist('Ntestmax','var') Ntestmax = 100000000; end
s = RandStream.create('mt19937ar','seed',iter);
RandStream.setGlobalStream(s);


for i = 1:numel(feat)
  p = randperm(numel(feat{i}));
  train_id{i} = p(1:Ntrain);
  test_id{i} = p(Ntrain+1:min(Ntrain+1+Ntestmax,numel(feat{i})));
  for j = 1:numel(train_id{i})
    feat_train{i}{j} = feat{i}{train_id{i}(j)};
  end
  for j = 1:numel(test_id{i})
    feat_test{i}{j} = feat{i}{test_id{i}(j)};
  end
end

