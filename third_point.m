% Given two points, and the lengths of the links attached to them,
% find the location of the point where the links intersect
% POINT WILL BE COUNTERCLOCKWISE FROM POINT1

function [point] = third_point(point1, point2, length1, length2)

  length3 = norm(point1 - point2);
  if (length1 + length2 < length3)
    disp(sprintf('Lengths too short!'))
  end
  
  alpha = acos((length1^2+length3^2-length2^2)/(2*length1*length3));
  theta = atan2(point2(2)-point1(2), point2(1)-point1(1));
  
  angle = theta + alpha;
  
  point = point1 + length1*[cos(angle),sin(angle)];

end