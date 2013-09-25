function [stack,infos] = classif_stack_all(feat)
ntot = 0;
for i=  1:numel(feat)
    ntot = ntot + numel(feat{i});
end
stack = zeros(ntot, size(feat{1}{1},2));
infos = zeros(ntot, 2);
k = 1;
for i =1 :numel(feat)
    for j  = 1:numel(feat{i});
        stack(k,:) = feat{i}{j};
        infos(k,:) = [i,j];
        k = k +1;
    end
end
end
