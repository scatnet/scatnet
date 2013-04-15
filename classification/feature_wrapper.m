function t = feature_wrapper(x,objects,fun,input_sz,output_sz, ...
	obj_normalize,collapse)
	if nargin < 4
		input_sz = [];
	end
	
	if nargin < 5
		output_sz = [];
	end
	
	if nargin < 6
		obj_normalize = Inf;
	end
	
	if nargin < 7
		collapse = 0;
	end
	
	if isempty(input_sz)
		buf = zeros(objects(1).u2-objects(1).u1+ones(size(objects(1).u1)), ...
			length(objects));
		
		u1 = [objects.u1];
		u2 = [objects.u2];
	else
		buf = zeros(input_sz,length(objects));

		u1 = round(([objects.u1]+[objects.u2]+1)/2-input_sz/2);
		u2 = u1+input_sz-1;
	end

	for l = 1:length(objects)
		ind = max(u1(l),1):min(u2(l),length(x));

		buf(:,l) = [zeros(max(0,1-u1(l)),1); x(ind); zeros(max(0,u2(l)-length(x)),1)];
	end
	
	if ~isempty(obj_normalize)
		if obj_normalize == 1
			n = sum(abs(buf),1);
		elseif obj_normalize == 2
			n = sqrt(sum(abs(buf).^2,1));
		elseif obj_normalize == Inf
			n = max(abs(buf),[],1);
		end
		
		buf = bsxfun(@times,buf,1./n);
	end

	t = fun(buf);

	if ~isempty(output_sz)
		N = size(t,2);
		extent = floor(output_sz/(2*input_sz)*N);
		
		t = t(:,N/2+1-extent:N/2+1+extent,:);
	end
	
	if collapse
		t = reshape(t,[size(t,1)*size(t,2) 1 size(t,3)]);
	end
end
