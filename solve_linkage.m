function [reactionForce, fOut] = solve_linkage(link, Fin, fOffset, Tin, thetaOut)

  momentArm1 = link .* fOffset ./ norm(link);
  moment1 = cross([momentArm1, 0], [Fin, 0]);
  moment1 = moment1(3);
  
  alpha = asin(link(2) / norm(link));
  fOutMag = (Tin + moment1) / (norm(link) * sin(pi - alpha + thetaOut));
  
  fOut = [fOutMag * cos(thetaOut), fOutMag * sin(thetaOut)];
  
  reactionForce = [0,0];
  reactionForce(1) = -1 * (fOut(1) + Fin(1));
  reactionForce(2) = -1 * (Fin(2) + fOut(2));

end