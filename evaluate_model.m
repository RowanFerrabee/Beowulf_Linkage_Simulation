function [performance] = evaluate_model(params, does_print, does_plot)

  performance = 0;
  [finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios] = deal(params{:});

  angle_weights = [1,1.2,1.4,1.6,1.8,2];
  link_weights = [1,1.4,1.8];
  
  if does_plot
    figure;
  end
  
  for i = 1:6

    angle = 12*(i-1);
    
    if does_print
      fprintf('Evaluating finger at angle: %d\n',angle)
    end
    
    %% Get finger geometry
    finger_section_angles = [angle, angle, angle];

    % Get position of finger attachment joints

    [joints, knuckles] = finger_positions(finger_section_angles, finger_section_lengths, finger_attachment_heights);

    % Get position of all links

    joints = [back_of_hand_joint; joints];
    points = linkage_positions(joints, link_lengths, link_ratios);

    %% Solve for forces

    % Link 1

    % First link has no applied force, but has an external torque applied
    Fin = [0, 0];
    fOffset = 0;  % Will not be used since Fin = 0
    Tin = -1;

    link = points(1,:) - joints(1,:);
    thetaOut = atan2(points(2,2)-points(1,2), points(2,1)-points(1,1));

    [reactionA, fOut] = solve_linkage(link, Fin, fOffset, Tin, thetaOut);


    % For all following links, no external torques are applied
    Tin = 0;

    % Link 2

    Fin = -1 .* fOut;
    fOffset = [link_lengths(3)*link_ratios(1)];

    link = points(3,:) - joints(2,:);
    thetaOut = atan2(points(4,2)-points(3,2), points(4,1)-points(3,1));

    [reactionB, fOut] = solve_linkage(link, Fin, fOffset, Tin, thetaOut);


    % Link 3

    Fin = -1 .* fOut;
    fOffset = [link_lengths(5)*link_ratios(2)];

    link = points(5,:) - joints(3,:);
    thetaOut = atan2(joints(4,2)-points(5,2), joints(4,1)-points(5,1));

    [reactionC, fOut] = solve_linkage(link, Fin, fOffset, Tin, thetaOut);

    reactionD = -1 .* fOut;
    
    if does_print
      fprintf('Node 1: %f, %f, %f \n', norm(fOut), reactionA(1), reactionA(2));
      fprintf('Node 2: %f, %f, %f \n', norm(fOut), reactionB(1), reactionB(2));
      fprintf('Node 3: %f, %f, %f \n', norm(fOut), reactionC(1), reactionC(2));
      fprintf('Node 4: %f, %f \n\n', reactionC(1), reactionC(2));
    end
    
    %% Checks
    if (abs(norm(joints(1,:)-points(1,:)) - link_lengths(1)) > 0.001)
      fprintf('Link 1 Wrong Length')
    end
    if (abs(norm(points(2,:)-points(1,:)) - link_lengths(2)) > 0.001)
      fprintf('Link 2 Wrong Length')
    end
    if (abs(norm(joints(2,:)-points(3,:)) - link_lengths(3)) > 0.001)
      fprintf('Link 3 Wrong Length')
    end
    if (abs(norm(points(4,:)-points(3,:)) - link_lengths(4)) > 0.001)
      fprintf('Link 4 Wrong Length')
    end
    if (abs(norm(joints(3,:)-points(5,:)) - link_lengths(5)) > 0.001)
      fprintf('Link 5 Wrong Length')
    end
    if (abs(norm(joints(4,:)-points(5,:)) - link_lengths(6)) > 0.001)
      fprintf('Link 6 Wrong Length')
    end

    if does_plot
      
      MAX_FORCE_ARROW = 4;
      %% Plot it all
      subplot(2,3,i)
      hold on;
      % Plot all links
      plot(points(:,1),points(:,2))
      plot([joints(4,1),points(5,1)],[joints(4,2),points(5,2)])
      plot([joints(3,1),points(5,1)],[joints(3,2),points(5,2)])
      plot([joints(2,1),points(3,1)],[joints(2,2),points(3,2)])
      plot([joints(1,1),points(1,1)],[joints(1,2),points(1,2)])
      % Plot all pin joints
      scatter([joints(:,1);knuckles(:,1);points(:,1);joints(:,1)],[joints(:,2);knuckles(:,2);points(:,2);joints(:,2)],9)
      % Plot finger attachments
      plot(knuckles(:,1),knuckles(:,2),'g')
      plot([knuckles(1,1),joints(2,1),knuckles(2,1)],[knuckles(1,2),joints(2,2),knuckles(2,2)],'g')
      plot([knuckles(2,1),joints(3,1),knuckles(3,1)],[knuckles(2,2),joints(3,2),knuckles(3,2)],'g')
      plot([knuckles(3,1),joints(4,1),knuckles(4,1)],[knuckles(3,2),joints(4,2),knuckles(4,2)],'g')
      % Plot back of hand - 'ground'
      plot([-3,knuckles(1,1),knuckles(1,1),-3],[back_of_hand_joint(2)-0.2,back_of_hand_joint(2)-0.2,back_of_hand_joint(2),back_of_hand_joint(2)],'k')
      % Draw force arrows
      forces = [reactionA;reactionB;reactionC;reactionD];
      forces = MAX_FORCE_ARROW * forces / max(sqrt(sum(forces.^2,2)));
      origins = joints;
      tips = joints+forces;
      plot([origins(:,1) tips(:,1)].',[origins(:,2) tips(:,2)].','r')
      
      lim = axis;
      if (lim(2) - lim(1) > lim(4) - lim(3))
        lim(4) = lim(3) + lim(2) - lim(1);
      else
        lim(2) = lim(1) + lim(4) - lim(3);
      end
      axis([lim(1)-1 lim(2)+1 lim(3)-1 lim(4)+1])
      hold off;
    end
    
    angles = pi*finger_section_angles/180;
    ideal_reactionB = [cos(-angles(1)-pi/2), sin(-angles(1)-pi/2)];
    ideal_reactionC = [cos(-angles(1)-angles(2)-pi/2), sin(-angles(1)-angles(2)-pi/2)];
    ideal_reactionD = [cos(-angles(1)-angles(2)-angles(3)-pi/2), sin(-angles(1)-angles(2)-angles(3)-pi/2)];

    angle_weights(i)*link_weights(1)*reactionB*(ideal_reactionB.');
    angle_weights(i)*link_weights(2)*reactionC*(ideal_reactionC.');
    angle_weights(i)*link_weights(3)*reactionD*(ideal_reactionD.');
    
    performance += angle_weights(i)*link_weights(1)*reactionB*(ideal_reactionB.');
    performance += angle_weights(i)*link_weights(2)*reactionC*(ideal_reactionC.');
    performance += angle_weights(i)*link_weights(3)*reactionD*(ideal_reactionD.');
    
  end

end