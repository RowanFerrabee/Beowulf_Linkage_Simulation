clc;
clear all;
close all;

% Define starting finger conditions
finger_section_lengths = [2,2,2];
back_of_hand_joint = [-1,1];
finger_attachment_heights = [1,1,1];
link_lengths = [3,3.236,3,3.236,3,3.828];%[2,2.236,2,2.236,2,2.828];
link_ratios = [0.5,0.5];

% Define hyperparams
num_iters = 11;
link_learn_rate = 0.01;
ratio_learn_rate = 0.002;
step_size = 0.001;

for iter = 1:num_iters
  
  params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
  performance = evaluate_model(params, false, false);
  fprintf('Iter: %d, Performance: %f\n', iter, performance);
  
  for i = 1:length(link_lengths)
    
    params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    orig_performance = evaluate_model(params, false, false);
    
    link_lengths(i) += step_size;

    params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    new_performance = evaluate_model(params, false, false);
    
    link_lengths(i) -= step_size;
    
    grad = (new_performance - orig_performance) / step_size;
    link_lengths(i) += grad*link_learn_rate;
    
  end
  
  for i = 1:length(link_ratios)
    
    params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    orig_performance = evaluate_model(params, false, false);
    
    link_ratios(i) += step_size;

    params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    new_performance = evaluate_model(params, false, false);
    
    link_ratios(i) -= step_size;
    
    grad = (new_performance - orig_performance) / step_size;
    link_ratios(i) += grad*ratio_learn_rate;
    
  end
  
end

params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
performance = evaluate_model(params, false, true);
fprintf('Final Performance: %f\n', performance);

fprintf('Link Lengths:\n');
link_lengths
fprintf('Link Ratios:\n');
link_ratios
