
gradf  = function (v, beta, q, j) {
	print ("grad is called")
}


MLSVM = function (X, Y, kmax, k, maxiter = 100) {
	# if kmax is given, we will ignore k
	# if k is given, we will ignore kmax
	
	# initialize the variables
	theta.xi 
	theta.v
	theta.w

	iter = 0
	stopCriterium = FALSE
	while (stopCriterium == FALSE) {
		# e-step
		# do we need some trick to save memory?
		
		q[i,j] = theta.xi [j] * post(x, v, z_i = j) * post (y_i | x_i, w_j)
		
		normfactor = 0
		for (j in 1:N) {
			normfactor = normfactor + q[i,j]
		}
		
		for (i in 1:N) {
			for (j in 1:M) {
				q[i,j] = q[i,j]/normfactor
			}
		}
		
		# m-step
		
		zeta = 1
		
		# update xis
		theta.xi[j] = 
		
		# updatet vs
		# apply L-BFGS
		# TODO: replace probably with something fasteR?
		# TODO: warmstart this.
		optim(par, 
			fn, 
			gr = NULL, ...,
			method = "L-BFGS-B", 
			lower = -Inf, 
			upper = Inf,
			control = list(), 
			hessian = FALSE)
		theta.v[j] = 

		# update w
		for (j in 1:k) {
			# copy over alphas
			for (i in 1:N) {
				alpha[i] = q[i,j]
			}
			
			# warmstart liblinear-ACF with alphas and weight
			C = 0.5*zeta
			sObj = liblinear(alpha = alpha, weight = theta.w[i])
			
			theta.w[i] = sObj$w
		}
	
		# check stopCriterium
		iter = iter + 1
		if (iter > maxiter) {
			stopCriterium = TRUE
		}
	}
}
