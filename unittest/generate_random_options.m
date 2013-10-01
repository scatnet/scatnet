% GENERATE_RANDOM_OPTIONS Create random options according to some
% delimiters
%
% Usage
%	options = GENERATE_RANDOM_OPTIONS(white_list,type,values)
%
% Input
%    white_list (cell): the white-list corresponding to the name of the
%    field of the options
%    type (cell of string): the type of the variable that one should
%    expect. 'c' continuous, 'i' integer, 'd' discrete
%    values (cell of cell): the corresponding values to a given type.
%
% Output
%    filt_for_disp (numerical): displayed (real) image.
%
% Description
%    For continous and integer, one excepts some interval given by 
%    {{s},{e}} where s is the first extremity of the interval and e the
%    end.
%    When the value is discrete, a value of the corresponding cell of
%    values is chosen.
%
% Example: If white_list = {'filter_type', 'precision', 'Q', 'J', 'L',
%   'sigma_phi','sigma_psi','xi_psi', 'slant_psi'};
%   type = {'d', 'i', 'i', 'i', 'i', 'c', 'c', 'c', 'c'}
%   values = { {'morlet','gabor'}, {0,1}, {1,10}, {1,10}, 
%   {1,10}, {0,50}, {0,30}, {0,30}, {0,10} };
%
%   then GENERATE_RANDOM_OPTIONS(white_list,type,values) is for instance
% 
%     filter_type: 'morlet'
%       precision: 0
%               Q: 3
%               J: 8
%               L: 9
%       sigma_phi: 25.7629
%       sigma_psi: 26.1973
%          xi_psi: 1.8308
%       slant_psi: 8.2580
% 
% See also
%   CHECK_OPTIONS_WHITE_LIST


function options=generate_random_options(white_list,type,values)

assert(length(white_list)==length(type));
assert(length(white_list)==length(values));

options=struct;

for i=1:length(white_list)
   switch type{i}
       case 'c'  % continuous
           r=values{i}{1}+rand*(values{i}{2}-values{i}{1});
           options=setfield(options,white_list{i},r);
       case 'i'  % integer
           r=floor(values{i}{1}+rand*(1+values{i}{2}-values{i}{1}-1));
           options=setfield(options,white_list{i},r);
       case 'd'  % discrete
           s=ceil(rand*(length(values{i})));
           options=setfield(options,white_list{i},values{i}{s});
   end
end
end