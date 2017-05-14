clc;
close all;
clear all;

% Define finger conditions
finger_section_lengths = [2,2,2];
back_of_hand_joint = [-1,1];

% Define linkage parameters we wish to evaluate
finger_attachment_heights = [1,1,1];
link_lengths = [2,2.236,2,2.236,2,2.828];
link_ratios = [0.5,0.5];

params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};

performance = evaluate_model(params, true, true)

fprintf('Performance: %f\n\n', performance)