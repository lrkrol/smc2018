
% INPUTS
% input_data: data separated by class(data is in cell format)
% csp_dim: # of CSP filters per class

%
% OUTPUTS
% csp_coeff: selected CSP filters (n_classes*csp_dim by n_channels)
% patterns: all the csp patterns


function [csp_coeff patterns] = csp_train(input_data, csp_dim)

% extract useful values
n_classes = length(input_data);

[ n_channels n_samples ]  = size(input_data{1}{1});

n_trials = zeros(1,n_classes);

for class = 1:n_classes
    n_trials(class) = length(input_data{class});
end

cov_classes = cell(1,n_classes);

for i = 1:n_classes
    for j = 1:n_trials(i)
         cov_classes{i}{j} = cov(input_data{i}{j}',1)/trace(cov(input_data{i}{j}',1));
    end
end

R = cell(1,n_classes);

for i = 1:n_classes
    R{i} = zeros(n_channels, n_channels);
    for j = 1:n_trials(i)
        R{i} = R{i}+cov_classes{i}{j};
    end
    R{i} = R{i}/n_trials(i);
end

Rsum = R{1} + R{2};


% find the rank of Rsum
rank_Rsum = rank(Rsum);

% do an eigenvector/eigenvalue decomposition
[V, D] = eig(Rsum);

if(rank_Rsum < n_channels)
%     disp(['pre_CSP_train: WARNING -- reduced rank data']);

    % keep only the non-zero eigenvalues and eigenvectors
    d = diag(D);
    d = d(end - rank_Rsum+ 1 : end);
    D = diag(d);

    V = V(:, end - rank_Rsum + 1 : end);
    

    % create the whitening transform
    W_T = D^(-.5) * V';

else
    % create the whitening transform
    W_T = D^(-.5) * V';
    
end


% Whiten Data Using Whiting Transform
for k = 1:n_classes
    S{k} = W_T * R{k} * W_T';
    
end

%generalized eigenvectors/values
[B, D] = eig(S{1},S{2});

%sort
[D, ind]=sort(diag(D), 'descend');
B = B(:,ind);

%Resulting Projection Matrix-these are the spatial filter coefficients
% result = (W*B)'
result = B'*W_T;

% resort CSP coefficients
dimm = n_classes*csp_dim;

[m n] = size(result);

%check for valid dimensions
if(m<dimm)
    disp('Cannot reduce to a higher dimensional space!');
    return
end

%instantiate filter matrix
csp_coeff = zeros(dimm,n);

for d = 1:dimm
    
    if d<csp_dim+1
        csp_coeff(d,:) = result(d,:);
    else
        csp_coeff(d,:) = result(m-(d-csp_dim-1),:);
    end
    
end

patterns_all = pinv(result')';
patterns = zeros(n, dimm);
for d = 1:dimm
    
    if d<csp_dim+1
        patterns(:,d) = patterns_all(:,d);
    else
        patterns(:,d) = patterns_all(:,m-(d-csp_dim-1));
    end
    
end

