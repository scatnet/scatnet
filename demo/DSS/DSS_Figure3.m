run_name ='DSS_Figure3'
 N=2^10;
fparam.filter_type = {'gabor_1d'};
 %fparam.B = 8;
 fparam.Q = 4;
 fparam.J= T_to_J(128,fparam.Q);
 fparam.filter_format='fourier';

 
filters = filter_bank(N, fparam);
nbTimePt=length(filters{1}.psi.filter{1}); %in the case

f=zeros(nbTimePt,length(filters{1}.psi.filter));

f(:,1)=filters{1}.psi.filter{1};


for k=2:length(filters{1}.psi.filter)
    R=round(nbTimePt/length(filters{1}.psi.filter{k}));
    
    f(:,k)=interp(filters{1}.psi.filter{k},R);
end
 
 
 
fig_width = 3.5;
fig_height = 0.6;
figure(1);
clf;
set(gcf,'PaperSize',[fig_width fig_height]);
set(gcf,'PaperPosition',[3 3 fig_width fig_height]);
set(gcf,'Units','inches');
set(gcf,'Position',[3 3 fig_width fig_height]);
axes('Units','inches','Position',[0.05 0.05 fig_width-0.1 fig_height-0.1]);
plot(1:size(f,1),filters{1}.phi.filter,'r',1:size(f,1),f,'b');
ylim([0 max(f(:))*1.2]);
xlim([1 size(f,1)/2*1.1]);
set(gca,'XTick',[]);set(gca,'YTick',[]);


