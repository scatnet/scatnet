function plot_full_transfer(T)

cc=colormap('jet');
step=floor(size(cc,1) / size(T,1));

lowlimit=-2;
earlystop=2;
earlyend=1;

for i=1:size(T,1)-earlyend
plot([max(lowlimit,2-i):size(T,2)-i+1-earlystop],T(i,max(1,i+lowlimit-1):end-earlystop),'Color',cc(i*step,:))
leg{i}=sprintf('%d',i);
hold on
end
legend(leg)
hold off

