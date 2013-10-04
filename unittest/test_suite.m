% This script launches all the testUnits.

d = dir(pwd);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i=1:length(nameFolds)
    cd([pwd filesep nameFolds{i}]);
    eval([nameFolds{i} '_test_suite']);
    cd('..');
end