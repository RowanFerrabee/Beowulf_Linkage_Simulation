clc;
clear all;
close all;
more off;

% Constants
MIN_LINK_LENGTH = 1;
MAX_LINK_LENGTH = 4;
MAX_LINK_RATIO = 1;
MIN_LINK_RATIO = 0;

MAX_PERFORMANCE = 0;
params_at_max = {};

for rand_test = 1:1000
    rand_test
    % Define starting finger conditions
    finger_section_lengths = [2,2,2];
    back_of_hand_joint = [-1,1];
    finger_attachment_heights = [1,1,1];

    link_lengths(1:6) = MIN_LINK_LENGTH;
    link_lengths = link_lengths + (MAX_LINK_LENGTH - MIN_LINK_LENGTH).*rand(1,6);
    
    link_ratios(1:2) = MIN_LINK_RATIO;
    link_ratios = link_ratios + rand(1,2);
    
    num_iters = 100;
    link_learn_rate = 0.003;
    ratio_learn_rate = 0.0008;
    step_size = 0.001;

    % Set save_params to default to the initial params value
    save_params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    
    iter = 0;
    prev_performance = 0;
    did_break = false;
    while ~did_break
        params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
        
        performance = evaluate_model(params, false, false);
        
        % TODO: Here, check for decreasing value, not staying the same
        if (abs(prev_performance - performance) <  1e-5 || iter > 20000) 
            did_break = true;
        else
            prev_performance = performance;
        end
        
        if mod(iter, 5) == 0
            fprintf('Iter: %d, Performance: %f\n', iter, performance);
        end
        
        if performance ~= -100
            save_params = params;
        else
            did_break = true;
            break;
        end
        
        for i = 1:length(link_lengths)
            params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
            orig_performance = evaluate_model(params, false, false);
            
            link_lengths(i) = link_lengths(i) + step_size;
            
            params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
            new_performance = evaluate_model(params, false, false);
            
            link_lengths(i) = link_lengths(i) - step_size;
            
            grad = (new_performance - orig_performance) / step_size;
            
            % Bound link lengths
            if (link_lengths(i) + grad*link_learn_rate > 0 && link_lengths(i) + grad*link_learn_rate < MAX_LINK_LENGTH)
                link_lengths(i) = link_lengths(i) + grad*link_learn_rate;
            end
        end
        
        for i = 1:length(link_ratios)
            
            params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
            orig_performance = evaluate_model(params, false, false);
            
            link_ratios(i) = link_ratios(i) + step_size;
            
            params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
            new_performance = evaluate_model(params, false, false);
            
            link_ratios(i) = link_ratios(i) - step_size;
            
            grad = (new_performance - orig_performance) / step_size;
            
            if (link_ratios(i) + grad*ratio_learn_rate < 0 && link_ratios(i) + grad*ratio_learn_rate > MAX_LINK_RATIO)
                link_ratios(i) = link_ratios(i) + grad*ratio_learn_rate;
            end
        end
        iter = iter + 1;
    end

    params = {finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios};
    performance = evaluate_model(params, false, false);
    if performance ~= -100
      save_params = params;
    end

    performance = evaluate_model(save_params, false, false);

    if performance > MAX_PERFORMANCE
       params_at_max = save_params;
       MAX_PERFORMANCE = performance;
    end
    
    did_break = false;
end

[finger_section_lengths,back_of_hand_joint,finger_attachment_heights,link_lengths,link_ratios] = deal(params_at_max{:});

performance = evaluate_model(params_at_max, false, true);
fprintf('Final Performance: %f\n', performance);

fprintf('Link Lengths:\n');
link_lengths
fprintf('Link Ratios:\n');
link_ratios