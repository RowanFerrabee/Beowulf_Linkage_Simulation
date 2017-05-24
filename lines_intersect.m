function [intersect] = lines_intersect(line_1, line_2)
    intersect = false;
    [line_1_start_x, line_1_start_y, line_1_end_x, line_1_end_y] = deal(line_1{:});
    [line_2_start_x, line_2_start_y, line_2_end_x, line_2_end_y] = deal(line_2{:});

    p = [line_1_start_x, line_1_start_y, 0];
    r = [line_1_end_x - line_1_start_x, line_1_end_y - line_1_start_y, 0];
    
    q = [line_2_start_x, line_2_end_x, 0];
    s = [line_2_end_x - line_2_start_x, line_2_end_y - line_2_start_y, 0];
    
    a = cross(r, s);
    a = a(3);
    b = cross(q - p, r);
    b = b(3);
    c = cross(q - p, s);
    c = c(3);
    
    t = c/a;
    u = b/a;
    
    if (a == 0 && b == 0)
        % Lines are colinear
        intersect = true;
    elseif (a == 0 && b ~= 0)
        % Lines are parallel
        intersect = false;
    elseif (a ~= 0 && t >= 0 && t <= 1 && u >= 0 && u <= 1)
        % Line segments meet at p + tr = q + us
        intersect = true;
    else
        % Line segments are not parallel but do not intersect
        intersect = false;
    end
end