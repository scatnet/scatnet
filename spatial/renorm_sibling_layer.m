% renorm_sibling_layer : renormalize a layer of scattering
%
% Usage
%   layer_renorm = renorm_sibling_layer(Sx, op, sibling)
%
% Input
%   layer (struct) : one layer of scattering
%   op (function_handle) : to apply to siblings 3d matrix (L1 or L2 norm)
%   sibling (function_handle) : returns the list of sibling of a path p
%
% Output
%   layer_renorm (struct) : the renormalized layer of scattering
%
% Description
%   renorm_sibling_layer is a generic function to renormalize a scattering
%   network. It should not be used as is but as part of a 
%   global renormalization strategy of the whole network. Examples of 
%   such global network renormalization are :
%       renorm_sibling_2d
%       renorm_sibling_3d
%


function [layer_renorm, denom, partition_id_for_path] = ...
    renorm_sibling_layer(layer, op, sibling)

%% compute the partition of siblings
P = numel(layer.signal);
partition = {};
partition_id_for_path = zeros(1,P);
not_yet_in_partition = ones(1,P);
partition_id = 1;
for p = 1:P
    if (not_yet_in_partition(p))
        p_sib = sibling(p);
        partition{partition_id} = p_sib;
        not_yet_in_partition(p_sib) = 0;
        partition_id_for_path(p_sib) = partition_id;
        partition_id = partition_id + 1;
    end
end

%% for each partition_id compute the denominator for renormalization
for partition_id = 1:max(partition_id_for_path)
    % stack the siblings in a 3d matrix
    part = partition{partition_id};
    % allocate the 3d matrix
    tmp = zeros([size(layer.signal{part(1)}), numel(part)]);
    % fill in the 3d matrix
    for i = 1:numel(part)
        tmp(:,:,i) = layer.signal{part(i)};
    end
    % apply the operator along the last dimensions
    denom{partition_id} = op(tmp);
end

%% renormalize all paths
layer_renorm = layer;
for p = 1:P
    partition_id = partition_id_for_path(p);
    layer_renorm.signal{p} = layer.signal{p} ./ denom{partition_id};
end

end