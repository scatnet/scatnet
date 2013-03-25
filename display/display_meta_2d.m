function display_meta_2d(metaf,field_name_1,id1,field_name_2,id2)


vec2plot=eval(['metaf.',field_name_1]);
vec2plot = vec2plot(:,id1);

vec2plot2=eval(['metaf.',field_name_2]);
vec2plot2 = vec2plot2(:,id2);

scatter(vec2plot,vec2plot2);


xlabel([field_name_1,int2str(id1)]);
ylabel([field_name_2,int2str(id2)]);
  

