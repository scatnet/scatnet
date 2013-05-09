function src = phone_src(directory)
	if nargin < 1
		directory = 'timit';
	end
	
	[phones,original,mapping] = phone_list(0);
	
	src = create_src(directory,@(x)(phone_objects_fun(x,phones,original,mapping)));

	[temp1,temp2,fold_mapping] = phone_list(1);

	[temp,reorder] = sort(phones);

	[temp,I] = ismember(reorder,mapping);
	src.cluster = fold_mapping(I);
end

function [segments,classes] = phone_objects_fun(file,phones,original,mapping)
	[path_str,name,ext] = fileparts(file);

	if strcmp(name,'SA1') || strcmp(name,'SA2')
		segments = [];
		classes = {};

		return;
	end

	set = phrase_set(file);

	if set == 3		% test but not in core, dev
		segments = [];
		classes = {};

		return;
	end

	phn = parse_phn([path_str filesep name '.PHN'],original,mapping);
	
	segments = struct();
	classes = {};

	for n = 1:length(phn)
		segments(n).u1 = phn(n).t1;
		segments(n).u2 = phn(n).t2;
		segments(n).subset = set;
		classes{n} = phones{phn(n).phone};
	end
end

function [phones,original,mapping] = phone_list(do_fold)
	if nargin < 1
		do_fold = 1;
	end
	
	stops = {'b','d','g','p','t','k','dx','q'};
	closures = {'cl','vcl','bcl','dcl','gcl','pcl','tcl','kcl','qcl'};
	affricates = {'jh','ch'};
	fricatives = {'s','sh','z','zh','f','th','v','dh'};
	nasals = {'m','n','ng','em','en','eng','nx'};
	semivowels_glides = {'l','r','w','y','hh','hv','el'};
	vowels = {'iy','ih','eh','ey','ae','aa','aw','ay','ah','ao','oy','ow','uh','uw','ux','er','ax','ix','axr','ax-h'};
	others = {'pau','epi','h#'};
	
	original = [stops closures affricates fricatives nasals semivowels_glides vowels others];
	
	% Kai-Fu Lee clustering, see K.F. Lee and H-W. Hon, "Speaker-Independent Phone Recognition Using Hidden Markov Models," IEEE TASSP 1989
	
	allophones = {{'uw','ux'},{'er','axr'},{'m','em'},{'n','nx'},{'ng','eng'},{'hh','hv'},{'cl','pcl','tcl','kcl','qcl'},{'vcl','bcl','dcl','gcl'},{'sil','h#','pau'}};
	
	folding = {{'sil','cl','vcl','epi'},{'el','l'},{'en','n'},{'sh','zh'},{'ao','aa'},{'ih','ix'},{'ah','ax'}};
	
	removed = {'q','ax-h'};
	
	phones = {};
	
	for k = 1:length(original)
		phone = original{k};
		for r = 1:length(allophones)
			if ~isempty(strmatch(phone,allophones{r},'exact'))
				phone = allophones{r}{1};
				break;
			end
		end
		if do_fold
			for r = 1:length(folding)
				if ~isempty(strmatch(phone,folding{r},'exact'))
					phone = folding{r}{1};
					break;
				end
			end
		end
		if ~isempty(strmatch(phone,removed,'exact'))
			phone = [];
		end
		if ~isempty(phone) && isempty(strmatch(phone,phones,'exact'))
			phones = [phones phone];
		end
		mapped{k} = phone;
	end
	
	for k = 1:length(mapped)
		if isempty(mapped{k})
			mapping(k) = 0;
		else
			ind = strmatch(mapped{k},phones,'exact');
			mapping(k) = ind;
		end
	end
end

function phn = parse_phn(filename,original,mapping)
	txt = fileread(filename);
	
	lines = regexp(txt,'\n','split');
	
	n = 1;
	phn = struct();
	
	for k = 1:length(lines)-1
		parts = regexp(lines{k},' ','split');
		phone_label = parts{3};
		phone = mapping(find(strcmp(phone_label,original),1));
		if phone == 0, continue; end
		if isempty(phone)
			error('empty phone');
		end

		phn(n).t1 = str2double(parts{1});
		phn(n).t2 = str2double(parts{2});
		phn(n).phone = phone;
		n = n+1;
	end
end

function set = phrase_set(file)
	core_set = {'FDHC0','FMGD0','FPAS0','MCMJ0','MJDH0','MKLT0','MNJM0','MTLS0', ...
				'FELC0','FMLD0','FPKT0','MDAB0','MJLN0','MLLL0','MPAM0','MWBT0', ...
				'FJLM0','FNLP0','MBPM0','MGRT0','MJMP0','MLNT0','MTAS1','MWEW0'};
							
	dev_set = {'FAKS0','MMDB1','MBDG0','FEDW0','MTDT0','FSEM0','MDVC0','MRJM4','MJSW0','MTEB0', ...
			   'FDAC1','MMDM2','MBWM0','MGJF0','MTHC0','MBNS0','MERS0','FCAL1','MREB0','MJFC0', ...
			   'FJEM0','MPDF0','MCSH0','MGLB0','MWJG0','MMJR0','FMAH0','MMWH0','FGJD0','MRJR0', ...
			   'MGWT0','FCMH0','FADG0','MRTK0','FNMR0','MDLS0','FDRW0','FJSJ0','FJMG0','FMML0', ...
			   'MJAR0','FKMS0','FDMS0','MTAA0','FREW0','MDLF0','MRCS0','MAJC0','MROA0','MRWS1'};
																						
	path_str = fileparts(file);

	path_parts = regexp(path_str,filesep,'split');

	if strcmp(path_parts{end-2},'TRAIN')
		set = 0;
	elseif strcmp(path_parts{end-2},'TEST')
		if any(strcmp(path_parts{end},core_set))
			set = 1;
		elseif any(strcmp(path_parts{end},dev_set))
			set = 2;
		else
			set = 3;
		end
	else
		set = [];
	end
end
