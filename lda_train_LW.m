% perform LDA on some data
% based on "Fisher Linear Discriminant Analysis" -
% regularization based on Ledoit Wolf formula
%
% INPUT
% X: feature matrix --> trials X features 
% Y: data set outputs, assumed to be passed in as a single column vector
%     and consist of classes 0 and 1
% method: 'LW' for ledoit-wolf shrinkage method, 'None' for no shrinkage
%
% OUTPUT
% w: weight vector
% b: threshold 
% class_stat: mean pf each class and the common covariance 
% sh_par: shrinkage parameter for each class 

% 09/28/07 -- created
% 02/17/09 -- modified for current classification format
% 06/27/17 -- modified for current classification format -- Mahta

function [W, B, class_stats, sh_par] = lda_train_LW(X, Y, method)


% extract a few useful things
ind0 = find(Y == 0);
ind1 = find(Y == 1);
num0 = length(ind0);
num1 = length(ind1);

% first find the mean for each class
m0 = mean(X(ind0, :), 1)';
m1 = mean(X(ind1, :), 1)';

% compute the within-class scatter matrices
% be lazy -- use cov and multiply by class count
if strcmp(method, 'LW') == 1
    lam0=cal_shrinkage(X(ind0, :), Y, 1);
    lam1=cal_shrinkage(X(ind1, :), Y, 1);
elseif strcmp(method, 'None') == 1
    lam0 = 0; 
    lam1 = 0; 
end

S_0 = cov(X(ind0, :), 1);
S_1 = cov(X(ind1, :), 1);

sh_par = [lam0, lam1]; 


% Regularization
d = mean(diag(S_0)) *lam0;
[dim1, dim2] = size(S_0);
S_0 = (1-lam0)*S_0 + (eye(dim1) * d);

d = mean(diag(S_1)) * lam1;
[dim1, dim2] = size(S_1);
S_1 = (1-lam1)*S_1 + (eye(dim1) * d);

% total within-class scatter
S_W = (S_0 * num0+ S_1* num1)/(num0 + num1);

% solve for optimal projection
W = inv(S_W) * (m0 - m1);

B = (m0'*W+m1'*W)/2;


class_stats.mu0 = m0;
class_stats.mu1 = m1;
class_stats.Sigma = S_W;
