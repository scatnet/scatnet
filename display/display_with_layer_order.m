function display_with_layer_order(Sx,renorm)

% Renormalized by default
if (nargin<2)
    renorm = 1 ;
end

for m=1:numel(Sx)

    clear var_x ; clear var_y ;
    clear title_x ; clear title_y ;
    title_x = {} ; title_y = {} ;
    
    % List of variables for the vertical sort
    for k=1:m-1
        var_y{k}.name = 'j' ;
        var_y{k}.index = k ;
        if (min(Sx{m}.meta.j(k,:)) < ...
            max(Sx{m}.meta.j(k,:)))
            title_y{numel(title_y)+1} = sprintf('j_%d',k) ;
        end
    end
    
    % List of other variables, for the horizontal sort
    names = fieldnames(Sx{m}.meta) ;
    cur_index = 1 ;
    for s=1:numel(names)
        if not(strcmp(names{s},'j'))
            var_string = sprintf('Sx{%d}.meta.%s',m,names{s}) ;
            cur_field = eval(var_string) ;
            l = size(cur_field,1) ;
            for l2=1:l
                if (min(cur_field(l2,:)) < ...
                    max(cur_field(l2,:)))
                    var_x{cur_index}.name = names{s} ;
                    var_x{cur_index}.index = l2 ;
                    title_x{cur_index} = sprintf('%s_%d', ...
                                                 names{s},l2) ;
                    cur_index = cur_index + 1 ;
                end
            end
        end
    end

    % Special cases
    if not(exist('var_y','var'))
        var_y{1}.name = 'j' ;
        var_y{1}.index = 1 ;        
    end
    if not(exist('var_x','var'))
        var_x = var_y ;
        title_x = title_y ; title_y = {} ;
        var_y{1}.name = 'j' ;
        var_y{1}.index = m ;
    end
    
    % Display
    figure ; image_scat_layer_order(Sx{m},var_x,var_y,renorm) ;
    
    % Construct xtitle
    if isempty(title_x)
        title_x_string = sprintf('Layer %d',m) ;
    elseif (numel(title_x)==1)
        title_x_string = sprintf('Layer %d ; sorted by %s', ...
                                 m,title_x{1}) ;
    else
        title_x_string = sprintf(['Layer %d ; sorted by alphabetical ' ...
                            'order over ('],m) ;
        for s=1:numel(title_x)
            title_x_string = sprintf('%s%s,', title_x_string, ...
                                     title_x{s}) ;
        end
        title_x_string(end) = ')' ;
    end
    
    % Construct ytitle
    if isempty(title_y)
        title_y_string = '' ;
    elseif (numel(title_y)==1)
        title_y_string = sprintf('Sorted by %s', ...
                                 title_y{1}) ;
    else
        title_y_string = ['Sorted by alphabetical ' ...
                          'order over ('] ;
        for s=1:numel(title_y)
            title_y_string = sprintf('%s%s,', title_y_string, ...
                                     title_y{s}) ;
        end
        title_y_string(end) = ')' ;
    end

    % Titles
    ylabel(title_y_string) ;
    xlabel(title_x_string) ;
    
end