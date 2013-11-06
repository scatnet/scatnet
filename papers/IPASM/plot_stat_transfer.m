function plot_stat_transfer(T,limi,limi2,str)

if nargin < 3
limi=size(T,1)-2;
limi2=limi;
end

%figure
pupu=min(limi,size(T,1))
start=2;

cc=colormap('jet');
step=floor(size(cc,1) / pupu);
for i=start:pupu
plot(T(i,i+1:limi2),'Color',cc(i*step,:),'LineWidth',str)
%semilogy(T(i,i+1:limi2),'Color',cc(i*step,:))
leg{i-start+1}=sprintf('%d ',i);
hold on
end
legend(leg)
hold off

