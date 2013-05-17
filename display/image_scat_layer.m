% image_scat_layer : return scattering outputs images next to each other
%
% Usage:
%	image_scat_layer(S{3}) return all the images of the third layer
%	of scattering S embeded next to each other in a large image
%	with their meta in the upper left hand corner

function big_img = image_scat_layer(Scatt, renorm, dsp_legend)
	if (numel(size(Scatt.signal{1})) == 3)
		p2 = 1;
		for p = 1:numel(Scatt.signal)
			for theta = 1:size(Scatt.signal{1},3)
				ScattBis.signal{p2} = Scatt.signal{p}(:,:,theta);
				ScattBis.meta.j(:,p2) = Scatt.meta.j(:,p);
				ScattBis.meta.theta2(:,p2) = Scatt.meta.theta2(:,p);
				ScattBis.meta.theta(:,p2) = theta;
				ScattBis.meta.k2(:,p2) = Scatt.meta.k2(:,p);
				p2 = p2 + 1;
			end
		end
		
		if ~exist('renorm','var');
			renorm  = 1;
		end
		if ~exist('dsp_legend','var');
			dsp_legend  = 1
		end
		big_img = image_scat_layer(ScattBis, renorm, dsp_legend);
		return
	end
	if ~exist('renorm','var');
		renorm  = 1;
	end
	if ~exist('dsp_legend','var');
		dsp_legend  = 1;
	end
	
	numel_per_width= zeros(10000,1);
	numel_per_height = zeros(10000,1);
	if (~isfield(Scatt,'signal'))
		Scatt2 = Scatt;
		clear Scatt; % avoid warning
		Scatt.signal = Scatt2;
	end
	if (size(Scatt.signal{1},3)==3)
		for rgb = 1:3
			for p=1:numel(Scatt.signal)
				Scattrgb{rgb}.signal{p}=squeeze(Scatt.signal{p}(:,:,rgb));
			end
			big_img(:,:,rgb) = display_scatt_2d_all_layer(Scattrgb{rgb});
		end
	else
		for p = 1:numel(Scatt.signal)
			curr_sz = size(Scatt.signal{p});
			numel_per_width(curr_sz(2)) = numel_per_width(curr_sz(2)) + 1;
			numel_per_height(curr_sz(1)) = numel_per_height(curr_sz(1)) + 1;
		end
		
		
		% block style
		widths = find(numel_per_width);
		
		total_width = ceil(sqrt(numel_per_width(max(widths))))* max(widths);
		curr_y = 0;
		
		% first pass to compute size and allocate
		
		
		for j = numel(widths):-1:1
			w= widths(j);
			curr_x = 0;
			
			for p = 1:numel(Scatt.signal)
				curr_sig = Scatt.signal{p};
				if (size(curr_sig,2) == w)
					h = size(curr_sig,1);
					if (curr_x >= total_width)
						curr_x = 0;
						curr_y = curr_y + size(curr_sig,1);
					end
					curr_x = curr_x + w;
				end
			end
			curr_y = curr_y + h;
			
		end
		big_img = zeros(curr_y,total_width);
		% second pass to put in the matrix what has to be put in
		curr_y = 0;
		for j = numel(widths):-1:1
			w= widths(j);
			curr_x = 0;
			
			for p = 1:numel(Scatt.signal)
				curr_sig = Scatt.signal{p};
				if (size(curr_sig,2) == w)
					h = size(curr_sig,1);
					if (curr_x >= total_width)
						curr_x = 0;
						curr_y = curr_y + size(curr_sig,1);
					end
					K = max(max(abs(Scatt.signal{p})));
					if (renorm==0)
						ds = size(Scatt.signal{1},1)/size(Scatt.signal{p},1);
						K = ds;
					end
					if (renorm==3)
						K=1 ;% preserve_l2_norm is off;
					end
					if (renorm == 2) % input is in log2 : substract the constant !
						ds = size(Scatt.signal{1},1)/size(Scatt.signal{p},1);
						K = log2(ds);
						big_img( (1:size(Scatt.signal{p},1)) + curr_y , (1:size(Scatt.signal{p},2)) + curr_x ) = Scatt.signal{p} -K;
					else
						big_img( (1:size(Scatt.signal{p},1)) + curr_y , (1:size(Scatt.signal{p},2)) + curr_x ) = Scatt.signal{p}/K;
					end
					curr_x = curr_x + w;
				end
			end
			curr_y = curr_y + h;
			
		end
		
		% renormalize
		m = min(big_img(:));
		M = max(big_img(:));
		big_img =  (big_img-m)/(M-m);
		
		
		% last pass for legend
		curr_y = 0;
		for j = numel(widths):-1:1
			w= widths(j);
			curr_x = 0;
			
			for p = 1:numel(Scatt.signal)
				curr_sig = Scatt.signal{p};
				if (size(curr_sig,2) == w)
					h = size(curr_sig,1);
					if (curr_x >= total_width)
						curr_x = 0;
						curr_y = curr_y + size(curr_sig,1);
					end
					
					try
						str_legend = meta2str(Scatt.meta,p);
						str_legend_split = textscan(str_legend,'%s','delimiter',' ');
					catch %% error means no meta to display
						str_legend_split{1}={};
					end
					if (dsp_legend ==0)
						str_legend_split{1}={};
					end
					str_legend_split = str_legend_split{1};
					for jl = 1:numel(str_legend_split)
						
						
						str = str_legend_split{jl};
						
						imstr = str2imfast(str);
						[n,m] = size(imstr);
						
						y_min =   n*(jl-1) + 1 +  curr_y;
						y_max =   n*(jl-1) + n + curr_y;
						x_min =   curr_x + 1;
						x_max =   curr_x + m;
						
						y_min = min(y_min,size(big_img,1));
						x_min = min(x_min,size(big_img,2));
						y_max = min(y_max,size(big_img,1));
						x_max = min(x_max,size(big_img,2));
						ny = y_max - y_min +1;
						nx = x_max - x_min +1;
						big_img(y_min:y_max,x_min:x_max) = max(imstr(1:ny,1:nx),0.5* big_img(y_min:y_max,x_min:x_max));
					end
					
					curr_x = curr_x + w;
				end
			end
			curr_y = curr_y + h;
			
		end
		
	end
end