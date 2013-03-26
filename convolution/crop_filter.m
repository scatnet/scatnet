function filter_small = crop_filter(filter, options)

options.null = 1;
half_bb_length = getoptions(options, 'half_bb_length', -1);
if (half_bb_length == -1)
  halb_bb_length = support_bounding_box(filter, options);
end

filter_small = 