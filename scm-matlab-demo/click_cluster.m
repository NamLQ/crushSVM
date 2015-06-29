function [l_prior,l_mean,l_Sigma,l_inSig,l_label] = click_cluster(l_prior,l_mean,l_Sigma,l_inSig,l_label);

global C;
global scale;

num     = size(l_mean,2);
pos_num = num/2+sum(l_label)/2;
neg_num = num-pos_num;

clf
hold on
axis([-1.3 1 -1 1])
axis('off')

for i = 1:num
    if l_label(i)==1
        p(i) = plot_cluster(l_mean(:,i)',l_Sigma(:,i*2-1:i*2)'*l_prior(i)*scale,[0 0 1],2,'-');
    else
        p(i) = plot_cluster(l_mean(:,i)',l_Sigma(:,i*2-1:i*2)'*l_prior(i)*scale,[1 0 0],2,'-');
    end
end

slider_C     = uicontrol('style','slider','units','normal','pos',[0.03 0.84 0.15 0.05],'value',log10(C),'Min',-1,'Max',3);
text_C       = uicontrol('style','text','units','normal','pos',[0.03 0.89 0.15 0.03],'string','C');
text_scale   = uicontrol('style','text','units','normal','pos',[0.03 0.81 0.15 0.03],'string','0.1          10       1000');
train_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.6 0.15 0.05],'string','Train');
clear_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.5 0.15 0.05],'string','Clear');

% box around the allowed field for the patterns
l = line([-1 1 1 -1 -1],[-1 -1 1 1 -1]);
set(l,'color',[1 1 1],'linestyle',':')

while 1
    [x(1),x(2),button] = ginput(1);
    
    % generate the prior and covariance randomly
    prior = 0.2+rand(1)*0.8;   % range = [0.2 1.0]
    var_x = 0.5+rand(1)/2;     % range = [0.5 1.0]
    var_c = (rand(1)-0.5)*0.8; % range = [-0.4 0.4]
    var_y = 0.5+rand(1)/2;     % range = [0.5 1.0]
    Sigma = [var_x var_c;var_c var_y]/10;
    inSig = inv(Sigma);
    % position where the button is clicked
    in_range = (x(1)>-1 & x(1)<1 & x(2)>-1 & x(2)<1);
    in_train = (x(1)>-1.6 & x(1)<-1.16 & x(2)>0.16 & x(2)<0.32);
    in_clear = (x(1)>-1.6 & x(1)<-1.16 & x(2)>-0.08 & x(2)<0.08);
    
    % MIDDLE BUTTON: remove a cluster which is closest to the cursor
    if button==2 && in_range
        [min_dist min_ind] = min(dist(l_mean',x'));
        l_prior = l_prior(:,[1:(min_ind-1) (min_ind+1):num]);
        l_mean  = l_mean(:,[1:(min_ind-1) (min_ind+1):num]);
        l_Sigma = l_Sigma(:,[1:(min_ind-1)*2 (min_ind*2+1):num*2]);
        l_inSig = l_inSig(:,[1:(min_ind-1)*2 (min_ind*2+1):num*2]);
        if l_label(min_ind)==1
            pos_num = pos_num-1;
        else
            neg_num = neg_num-1;
        end
        l_label = l_label(:,[1:(min_ind-1) (min_ind+1):num]);
        delete(p(min_ind));
        p = p(:,[1:(min_ind-1) (min_ind+1):num]);
    % LEFT BUTTON: add one positive cluster
    elseif button==1 && in_range
        l_prior  = [l_prior prior];
        l_mean   = [l_mean x'];
        l_Sigma  = [l_Sigma Sigma'];
        l_inSig  = [l_inSig inSig'];
        p(num+1) = plot_cluster(x,Sigma'*prior*scale,[0 0 1],2,'-');
        pos_num  = pos_num+1;
        l_label  = [l_label 1];
    % RIGHT BUTTON: add one negative cluster
    elseif button==3 && in_range
        l_prior  = [l_prior prior];
        l_mean   = [l_mean x'];
        l_Sigma  = [l_Sigma Sigma'];
        l_inSig  = [l_inSig inSig'];
        p(num+1) = plot_cluster(x,Sigma'*prior*scale,[1 0 0],2,'-');
        neg_num  = neg_num+1;
        l_label  = [l_label -1];
    % Traing the SCM
    elseif button==114 || in_train
        if pos_num*neg_num>0
            C = 10^get(slider_C,'value');
            break
        else
            disp('One class is empty - click a cluster');
            in_train = 0;
        end
    elseif in_clear
        for i = 1:num,
            delete(p(i));
        end
        num     = 0;
        pos_num = 0;
        neg_num = 0;
        l_prior = [];
        l_label = [];
        l_mean  = [];
        l_Sigma = [];
        l_inSig = [];
    end
    num = pos_num+neg_num;
end

for i = 1:num,
    delete(p(i));
end

set(slider_C,'visible','off')
set(text_C,'visible','off')
set(text_scale,'visible','off')
set(train_button,'visible','off')
set(clear_button,'visible','off')