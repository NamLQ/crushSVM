function dpt = testing_kernel(data,l_prior,l_mean,l_Sigma,l_inSig);

[row1,col1] = size(data);
[row2,col2] = size(l_mean);
dpt = zeros(col1,col2);

for i = 1:col1
    for j = 1:col2
        Sigma = l_Sigma(:,j*2-1:j*2)';
        inSig = l_inSig(:,j*2-1:j*2)';
        tmp1 = det(Sigma)^(-0.5);
        tmp2 = data(:,i)-l_mean(:,j);
        tmp3 = tmp2'*inSig*tmp2;
        dpt(i,j) = tmp1*exp(-0.5*tmp3);
    end
end

dpt = dpt/(2*pi);