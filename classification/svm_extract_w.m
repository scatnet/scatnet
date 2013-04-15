function w = svm_extract_w(db,model)
	if model.svm.Parameters(2) == 0			% linear SVM
		class_ct = model.svm.nr_class;
		w = zeros(size(model.svm.SVs,2),class_ct*(class_ct-1)/2);
		r = 1;
		pairs = [];
		for n1 = 1:class_ct
			for n2 = n1+1:class_ct
				pairs = [pairs [n1; n2]];

				class1_SVs = 1+sum(model.svm.nSV(1:n1-1)):sum(model.svm.nSV(1:n1));
				class2_SVs = 1+sum(model.svm.nSV(1:n2-1)):sum(model.svm.nSV(1:n2));

				sv_coef1 = model.svm.sv_coef(class1_SVs,n2-1);
				sv_coef2 = model.svm.sv_coef(class2_SVs,n1);
				
				w(:,r) = (model.svm.SVs(class1_SVs,:).'*sv_coef1) + ...
					(model.svm.SVs(class2_SVs,:).'*sv_coef2);
				
				r = r+1;
			end
		end
	end
end
