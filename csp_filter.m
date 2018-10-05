function [output1 output2] = csp_filter(data1, data2, csp_coeffs)

csp_dim = size(csp_coeffs,1); 

n_trials1 = size(data1, 3); 
output1 = zeros(csp_dim, n_trials1); 

for ik = 1:n_trials1
    temp = csp_coeffs * data1(:,:,ik); 
    temp = var(temp', 0);
    output1(:,ik) = temp';
end


n_trials2 = size(data2, 3); 
output2 = zeros(csp_dim, n_trials2); 

for ik = 1:n_trials2
    temp = csp_coeffs * data2(:,:,ik); 
    temp = var(temp', 0);
    output2(:,ik) = temp';
end

output1 = output1';
output2 = output2';