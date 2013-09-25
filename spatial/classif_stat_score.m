function out = classif_stat_score(all_predicted_label)
% function out = classif_stat_score(all_predicted_label)
% 20 nov 2012 - laurent sifre
nclass = numel(all_predicted_label);
confusion_matrix = zeros(nclass,nclass);

for i = 1:nclass
  number_of_correct_per_class(i) = sum(all_predicted_label{i} == i);
  number_per_class(i) = numel(all_predicted_label{i});
  tmp = [all_predicted_label{i};0;nclass+1];
  tmp = hist(tmp,nclass+2);
  tmp = tmp(2:end-1);
  confusion_matrix(i,:) = tmp;
end

score_avg = sum(number_of_correct_per_class)/sum(number_per_class);
score_per_class_avg = sum(number_of_correct_per_class./number_per_class)/nclass;


out.score_avg = score_avg;
out.score_per_class_avg = score_per_class_avg;
out.confusion_matrix = confusion_matrix;
