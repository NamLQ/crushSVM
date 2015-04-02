function dpt = training_kernel(l_prior,l_mean,l_Sigma,l_inSig)

[row,col] = size(l_mean);
dpt = zeros(col,col);

for i = 1:col
    for j = i:col
        Sigma_i = l_Sigma(:,i*2-1:i*2)';
        Sigma_j = l_Sigma(:,j*2-1:j*2)';
        inSig_i = l_inSig(:,i*2-1:i*2)';
        inSig_j = l_inSig(:,j*2-1:j*2)';
        tmp1 = inv(inSig_i+inSig_j);
        tmp2 = inSig_i*l_mean(:,i)+inSig_j*l_mean(:,j);
        tmp3 = l_prior(i)*l_prior(j) * det(tmp1)^0.5 * det(Sigma_i)^(-0.5) * det(Sigma_j)^(-0.5);
        tmp4 = l_mean(:,i)'*inSig_i*l_mean(:,i) + l_mean(:,j)'*inSig_j*l_mean(:,j) - tmp2'*tmp1*tmp2;
        dpt(i,j) = tmp3*exp(-0.5*tmp4);
        dpt(j,i) = dpt(i,j);
    end
end

dpt = dpt/(2*pi);