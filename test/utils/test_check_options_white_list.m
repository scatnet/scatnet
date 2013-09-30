clear;

options.J = 1;
options.L = 2;
options.m = 3;

white_list = {'J', 'L', 'm', 'aa'};
options2.M = 4;
options2.J = 1;
options2.K = 3;

check_options_white_list(options, white_list);
check_options_white_list(options2, white_list);