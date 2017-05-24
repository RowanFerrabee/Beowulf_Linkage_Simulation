% Finds the positions of all linkages given the finger attachment
% joint positions, linkage lengths, and hole position ratios.

function [points] = linkage_positions(joints, lengths, ratios)

  error = [-100,-100];

  point5 = third_point(joints(3,:),joints(4,:),lengths(5),lengths(6));
  if point5 ~= error
    point4 = joints(3,:) + (point5 - joints(3,:))*ratios(2);
    point3 = third_point(joints(2,:),point4,lengths(3),lengths(4));
    if point3 ~= error
      point2 = joints(2,:) + (point3 - joints(2,:))*ratios(1);
      point1 = third_point(joints(1,:),point2,lengths(1),lengths(2));
      if point1 ~= error
        points = [point1;point2;point3;point4;point5];
      else
        %fprintf('Point 1 Failed\n')
        points = [error;error;error;error;error];
      end
    else
      %fprintf('Point 3 Failed\n')
      points = [error;error;error;error;error];
    end
  else
    %fprintf('Point 5 Failed\n')
    points = [error;error;error;error;error];
  end
end