function xab = conv2dsep(x, a, b)
	xab = conv2(conv2(x, a, 'same'),b, 'same');
end
