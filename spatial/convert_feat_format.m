% from new to old format
function feat = convert_feat_format (db, nClass, nPerClass)
    k = 1;
    for i = 1:nClass
        for j = 1:nPerClass
            tmp = db.features(:, k);
            feat{i}{j} = reshape(tmp, [1, numel(tmp)]);
            k = k + 1;
        end
    end
end
