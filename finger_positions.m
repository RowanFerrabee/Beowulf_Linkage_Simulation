% Finds the positions of all the finger attachment joints given the lengths
% and angles of the fingers and the heights of the finger attachments.

function [joints, knuckles] = finger_positions(angles, lengths, heights)

  knuckle0 = [0,0];
  
  angle = -pi*angles(1)/180;
  knuckle1 = lengths(1)*[cos(angle), sin(angle)];
  knuckle1 += knuckle0;
  
  midpoint1 = (knuckle0 + knuckle1)/2;
  height1 = heights(1)*[cos(angle+pi/2), sin(angle+pi/2)];
  joint1 = midpoint1 + height1;
  
  
  angle = -pi*(angles(1)+angles(2))/180;
  knuckle2 = lengths(2)*[cos(angle), sin(angle)];
  knuckle2 += knuckle1;
  
  midpoint2 = (knuckle1 + knuckle2)/2;
  height2 = heights(2)*[cos(angle+pi/2), sin(angle+pi/2)];
  joint2 = midpoint2 + height2;
  
  
  angle = -pi*(angles(1)+angles(2)+angles(3))/180;
  knuckle3 = lengths(3)*[cos(angle), sin(angle)];
  knuckle3 += knuckle2;
  
  midpoint3 = (knuckle2 + knuckle3)/2;
  height3 = heights(3)*[cos(angle+pi/2), sin(angle+pi/2)];
  joint3 = midpoint3 + height3;
  
  joints = [joint1; joint2; joint3];
  knuckles = [knuckle0;knuckle1;knuckle2;knuckle3];

end