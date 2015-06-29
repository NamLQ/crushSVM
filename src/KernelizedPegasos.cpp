// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-


// ..

// This code is a rip-off from Shark, (C) Copyright 1995-2015 Shark Development Team





#include "RcppArmadillo.h"

// [[Rcpp::depends(RcppArmadillo)]]

// simple example of creating two matrices and
//
// [[Rcpp::export]]




/// \brief Constructor
		///
		/// \param  kernel          kernel function to use for training and prediction
		/// \param  loss            (sub-)differentiable loss function
		/// \param  C               regularization parameter - always the 'true' value of C, even when unconstrained is set
		/// \param  offset          whether to train with offset/bias parameter or not
		/// \param  unconstrained   when a C-value is given via setParameter, should it be piped through the exp-function before using it in the solver?
		/// \param  cacheSize       size of the cache
		KernelSGDTrainer(KernelType* kernel, const LossType* loss, double C, bool offset, bool unconstrained = false, size_t cacheSize = 0x4000000)
		: m_kernel(kernel)
		, m_loss(loss)
		, m_C(C)
		, m_offset(offset)
		, m_unconstrained(unconstrained)
		, m_epochs(0)
		, m_cacheSize(cacheSize)
		{ }
	
	// dataset objects (intern in c++) sind...
	{
			std::size_t ell = dataset.numberOfElements();
			unsigned int classes = numberOfClasses(dataset);
			ModelType& model = classifier.decisionFunction();
			
			model.setStructure(m_kernel, dataset.inputs(), m_offset, classes);
			
			RealMatrix& alpha = model.alpha();
			
			// pre-compute the kernel matrix (may change in the future)
			// and create linear array of labels
			KernelMatrixType  km(*(this->m_kernel), dataset.inputs());
			PartlyPrecomputedMatrixType  K(&km, m_cacheSize);
			UIntVector y = createBatch(dataset.labels().elements());
			const double lambda = 0.5 / (ell * m_C);
			
			double alphaScale = 1.0;
			std::size_t iterations;
			if(m_epochs == 0) iterations = std::max(10 * ell, std::size_t(std::ceil(m_C * ell)));
			else iterations = m_epochs * ell;
			
			// preinitialize everything to prevent costly memory allocations in the loop
			arma::vec f_b(classes, 0.0);
			arma::vec derivative(classes, 0.0);
			
			// SGD loop
			blas::vector<QpFloatType> kernelRow(ell, 0);
			for(std::size_t iter = 0; iter < iterations; iter++)
			{
				// active variable
				std::size_t b = Rng::discrete(0, ell - 1);
				
				// learning rate
				const double eta = 1.0 / (lambda * (iter + ell));
				
				// compute prediction
				f_b.clear();
				K.row(b, kernelRow);
				axpy_prod(trans(alpha), kernelRow, f_b, false, alphaScale);
				if(m_offset) noalias(f_b) += model.offset();
				
				// stochastic gradient descent (SGD) step
				derivative.clear();
				m_loss->evalDerivative(y[b], f_b, derivative);
				
				// alphaScale *= (1.0 - eta * lambda);
				alphaScale = (ell - 1.0) / (ell + iter);   // numerically more stable
				
				noalias(row(alpha, b)) -= (eta / alphaScale) * derivative;
				if(m_offset) noalias(model.offset()) -= eta * derivative;
			}
			
			alpha *= alphaScale;
			
			// model.sparsify();
		}
		

		
		/// check whether the model to be trained should include an offset term
		bool trainOffset() const
		{ return m_offset; }
		
		///\brief  Returns the vector of hyper-parameters.
		RealVector parameterVector() const
		{
			size_t kp = m_kernel->numberOfParameters();
			RealVector ret(kp + 1);
			if(m_unconstrained)
				init(ret) << parameters(m_kernel), log(m_C);
			else
				init(ret) << parameters(m_kernel), m_C;
			return ret;
		}
		
		///\brief  Sets the vector of hyper-parameters.
		void setParameterVector(RealVector const& newParameters)
		{
			size_t kp = m_kernel->numberOfParameters();
			SHARK_ASSERT(newParameters.size() == kp + 1);
			init(newParameters) >> parameters(m_kernel), m_C;
			if(m_unconstrained) m_C = exp(m_C);
		}
		
		///\brief Returns the number of hyper-parameters.
		size_t numberOfParameters() const
		{
			return m_kernel->numberOfParameters() + 1;
		}
		
	protected:
		KernelType* m_kernel;                     ///< pointer to kernel function
		const LossType* m_loss;                   ///< pointer to loss function
		double m_C;                               ///< regularization parameter
		bool m_offset;                            ///< should the resulting model have an offset term?
		bool m_unconstrained;                     ///< should C be stored as log(C) as a parameter?
		std::size_t m_epochs;                     ///< number of training epochs (sweeps over the data), or 0 for default = max(10, C)
		
		// size of cache to use.
		std::size_t m_cacheSize;
		
	};
	
	
}
#endif

arma::mat rcpparma_hello_world() {
    arma::mat m1 = arma::eye<arma::mat>(3, 3);
    arma::mat m2 = arma::eye<arma::mat>(3, 3);
	                     
    return m1 + 3 * (m1 + m2);
}


// another simple example: outer product of a vector, 
// returning a matrix
//
// [[Rcpp::export]]
arma::mat rcpparma_outerproduct(const arma::colvec & x) {
    arma::mat m = x * x.t();
    return m;
}

// and the inner product returns a scalar
//
// [[Rcpp::export]]
double rcpparma_innerproduct(const arma::colvec & x) {
    double v = arma::as_scalar(x.t() * x);
    return v;
}


// and we can use Rcpp::List to return both at the same time
//
// [[Rcpp::export]]
Rcpp::List rcpparma_bothproducts(const arma::colvec & x) {
    arma::mat op = x * x.t();
    double    ip = arma::as_scalar(x.t() * x);
    return Rcpp::List::create(Rcpp::Named("outer")=op,
                              Rcpp::Named("inner")=ip);
}
