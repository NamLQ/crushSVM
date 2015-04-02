% ----------------------------------------------------------------------- %
%             Demo for Support Cluster Machine (SCM) (c) 2007             %
% ----------------------------------------------------------------------- %
% Bin Li                                                                  %
% Dept. Computer Science & Engineering, Fudan University, Shanghai, China %
% ----------------------------------------------------------------------- %
% This is adapted from the SVM demo provided by B. Schoelkopf, available  %
% at http://www.learning-with-kernels.org                                 %
% ----------------------------------------------------------------------- %
% @inproceedings{Li:ICML07,                                               %
%   author = {Bin Li and Mingmin Chi and Jianping Fan and Xiangyang Xue}, %
%   booktitle =	{Proc. of the 24th Int'l Conf. on Machine Learning},      %
%   title =	{Support Cluster Machine},                                    %
%   pages = {505--512},                                                   %
%   year = {2007},                                                        %
% }                                                                       %
% ----------------------------------------------------------------------- %


f = figure(1);
set(f,'Position',[200 200 800 600],'Name','Demo for Support Cluster Machine (SCM)'); 
clf;
clear;

global C; 
global scale;

C       = 10;  % upper bound (regularization parameter)
scale   = 0.1; % scale the ellipses which denote the clusters
l_prior = [];  % priors (weights) of the training clusters
l_mean  = [];  % means of the training clusters
l_Sigma = [];  % covariance matrices of the training clusters
l_inSig = [];  % inverse covariance matrices of the training clusters
l_label = [];  % labels of the training clusters

while 1   
    [l_prior,l_mean,l_Sigma,l_inSig,l_label] = click_cluster(l_prior,l_mean,l_Sigma,l_inSig,l_label);
    
    % construct the kernel matrix
    pos_clusters  = find(l_label==+1);
    neg_clusters  = find(l_label==-1);
    [dim,ell] = size(l_mean);
    G = training_kernel(l_prior,l_mean,l_Sigma,l_inSig);
    H = (l_label'*l_label).*G;
    % learn the SCM
    c = -ones(ell,1);  % linear term
    A = l_label;       % lhs of equality constraint
    b = 0;             % rhs of equality constraint
    bl = zeros(ell,1); % lower bound
    bu = C*l_prior';   % upper bound P_i*C
    % solves the quadratic programming problem
    % min  1/2x'*H*x + c'*x 
    % s.t. A*x = b
    %      l <= x <= u
    alpha = quadprog(H,c,[],[],A,b,bl,bu);
    % use the multipliers cloeset to C/2, C/4, and C/8 for computing the threshold:
    [tmp,ind2p] = min(abs(alpha(pos_clusters)-C/2));
    [tmp,ind2n] = min(abs(alpha(neg_clusters)-C/2));
    [tmp,ind4p] = min(abs(alpha(pos_clusters)-C/4));
    [tmp,ind4n] = min(abs(alpha(neg_clusters)-C/4));
    [tmp,ind8p] = min(abs(alpha(pos_clusters)-C/8));
    [tmp,ind8n] = min(abs(alpha(neg_clusters)-C/8));
    b = (H(pos_clusters(ind2p),:)*alpha - H(neg_clusters(ind2n),:)*alpha ...
       + H(pos_clusters(ind4p),:)*alpha - H(neg_clusters(ind4n),:)*alpha ...
       + H(pos_clusters(ind8p),:)*alpha - H(neg_clusters(ind8n),:)*alpha)/6;
    alpha = alpha.*l_label';
    
    % create test patterns (vectors) on a grid 
    test_num = 30;
    mins = [-1,-1];
    maxs = [1,1];
    x_range = mins(1):((maxs(1)-mins(1))/(test_num-1)):maxs(1);
    y_range = mins(2):((maxs(2)-mins(2))/(test_num-1)):maxs(2);
    [xs,ys] = meshgrid(x_range,y_range); % two matrices
    grid_patterns = [xs(:)';ys(:)'];
    % compute the output on grid_patterns
    RD = testing_kernel(grid_patterns,l_prior,l_mean,l_Sigma,l_inSig);
    pgrid_output = (RD*alpha-b)';
    % plot the output decision boundary
    imag = -reshape(pgrid_output,test_num,test_num);
    FeatureLines = [0 -100000 100000]'; % cheap hack to only get the decision boundary
    colormap('cool');
    pcolor(x_range,y_range,imag);
    [c,h] = contour(x_range,y_range,imag,FeatureLines,'k');
    set(h(1),'LineWidth',2);
    i = 1;
    while length(h)>i
        set(h(i+1),'LineWidth',2);
        i = i+1;
    end
    % plot the support boundaries
    FeatureLines = [-1 1]';
    [c,h] = contour(x_range,y_range,imag,FeatureLines,'k');
    set(h(1),'LineWidth',2,'LineStyle',':');
    i = 1;
    while length(h)>i
        set(h(i+1),'LineWidth',2,'LineStyle',':');
        i = i+1;
    end
    shading interp
    % plot the support clusters
    for i = 1:ell
        if alpha(i)>0.001
            q(i) = plot_cluster(l_mean(:,i),l_Sigma(:,i*2-1:i*2)'*l_prior(:,i)*scale,[0 0 1],3,'-');
        elseif alpha(i)<-0.001
            q(i) = plot_cluster(l_mean(:,i),l_Sigma(:,i*2-1:i*2)'*l_prior(:,i)*scale,[1 0 0],3,'-');
        elseif alpha(i)>=0
            q(i) = plot_cluster(l_mean(:,i),l_Sigma(:,i*2-1:i*2)'*l_prior(:,i)*scale,[0 0 1],1,'-');
        elseif alpha(i)<0
            q(i) = plot_cluster(l_mean(:,i),l_Sigma(:,i*2-1:i*2)'*l_prior(:,i)*scale,[1 0 0],1,'-');
        end
    end
    figure(1)
    brighten(0.6)
    
    cont_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.11 0.15 0.05],'string','Click to Continue');
    x = ginput(1);
end