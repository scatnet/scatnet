function [arr1,arr2] = readidx(FILENAME,t1,t2)
	
	%[fid, message] = fopen(FILENAME,'r','ieee-be');
	fid= fopen(FILENAME,'r','b')
	[FILENAME,PERMISSION,MACHINEFORMAT,ENCODING] = fopen(fid)
	magic = fread(fid, 1, 'int32');
	if magic==2051
		num = fread(fid, 1, 'int32');
		ndim(1) = fread(fid, 1, 'int32');
		ndim(2) = fread(fid, 1, 'int32');
		a = ndim(1)*ndim(2);
	elseif magic==2049
		num = fread(fid, 1, 'int32');
		a=1;
	else
		disp('unknown magic number');
	end
	arr1 = zeros(a,t1);
	arr2 = zeros(a,t2-t1);
	for i=1:t1
		arr1(:,i) = fread(fid, a, 'uint8');
	end
	for i=t1+1:t2
		arr2(:,i-t1) = fread(fid, a, 'uint8');
	end
	
	fclose(fid);
end