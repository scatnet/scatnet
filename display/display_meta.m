function display_meta(metaf,ind)

fn=fieldnames(metaf);
colors={'b','g','r','c','m','k','b','g','r'};
clf;
hold on;
for i=1:numel(fn)
    subplot(numel(fn),1,i);
    vec2plot=eval(['metaf.',fn{i}]);
    if exist('ind','var')
      vec2plot = vec2plot(ind,:);
    end
    plot(vec2plot);
    s = regexprep(fn{i}, '_', '');
    s=['path ' ,s];
    legend(s);
end
 
    