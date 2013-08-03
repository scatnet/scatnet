function Wop = renorm_operators(Wop, h, K, method)
	
	for m = 1:numel(Wop)
		Wop{m} = @(U)(renorm_op(U, Wop{m}));
	end
	
	function [S,Up] = renorm_op(U, op)
		Urn = renorm_layer(U, h, K, method);
		[S, Up] = op(Urn);
		S = op(U);
	end
end