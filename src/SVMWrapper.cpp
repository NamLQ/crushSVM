// -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
//
// SwarmSVM -- A collection of SVM solvesr.
//
// Copyright (C) 2015  Aydin Demircioglu, aydin.demircioglu /at/ ini.rub.de
//
// This file is part of the SwarmSVM library for GNU R.
// It is made available under the terms of the GNU General Public
// License, version 2, or at your option, any later version,
// incorporated herein by reference.
//
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public
// License along with this program; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
// MA 02111-1307, USA

#include <Rcpp.h>

#include "utils.h"

#include <shark/Algorithms/Trainers/CSvmTrainer.h> // the C-SVM trainer
#include <shark/Models/Kernels/GaussianRbfKernel.h> //the used kernel for the SVM
#include <shark/ObjectiveFunctions/Loss/ZeroOneLoss.h> //used for evaluation of the classifier
#include <shark/Data/DataDistribution.h> //includes small toy distributions


using namespace std;
using namespace shark;



double CSVM(
	KernelClassifier<RealVector> &kc,
	double C, 
	GaussianRbfKernel<> *kernel,
	bool bias,
	double epsilon, 
	const shark::WeightedLabeledData<RealVector, unsigned int> &training,
	double cacheSize = 0x1000000
	) {
	std::cout << training << "\n";
	
	CSvmTrainer<RealVector> trainer(kernel, C, bias);
	trainer.stoppingCondition().minAccuracy = epsilon;
	trainer.setCacheSize( cacheSize);
	trainer.train(kc, training);
	
	ZeroOneLoss<unsigned int> loss; // 0-1 loss
	Data<unsigned int> output = kc(training.inputs()); // evaluate on training set
	double train_error = loss.eval(training.labels(), output);
	cout << "training error:\t" <<  train_error << endl;
	
	// FIXME, this is stupid.
	return train_error;
}

/*
SVM R_GaussianProcess(SVM svm, Array<double> x, Array<double> y) {

	GaussianProcess t_svm(&svm, x, y);
	SVM_Optimizer SVMopt;
	SVMopt.init(t_svm);

	// train the SVM
	SVMopt.optimize(svm, x, y);

	return svm;
}
*/


using namespace Rcpp;

RcppExport SEXP SVMWrapper(SEXP Xs, SEXP Ys, SEXP Ws, SEXP svmParameters) {

	try {
		Rcpp::List rparam(svmParameters);
        double C = Rcpp::as<double>(rparam["C"]);
        double epsilon = Rcpp::as<double>(rparam["epsilon"]);
        double gamma = Rcpp::as<double>(rparam["gamma"]); 
        double sigma = Rcpp::as<double>(rparam["sigma"]);
        string type = Rcpp::as<string>(rparam["type"]);
        string kernel = Rcpp::as<string>(rparam["kernel"]);
		bool verbose = Rcpp::as<bool>(rparam["verbose"]);
	

		Rcpp::NumericMatrix xR = Rcpp::NumericMatrix(Xs);
		Rcpp::NumericVector yR = Rcpp::NumericVector(Ys);
		Rcpp::NumericVector wR;
		if (Ws == R_NilValue) {
			if (verbose) std::cout << "No weights.\n";
			std::vector<double> weights(yR.size(), 1.0);
			Rcpp:NumericVector c = wrap(weights);
			wR = c;
		} else {
			wR = Rcpp::NumericVector(Ws);
		}
		
		
		// get weights.
		shark::WeightedLabeledData<RealVector, unsigned int> wdata;
		generateWeightedDatasetFromR  (xR, yR, wR, wdata) ;
		
		
		// convert data
		if (verbose) std::cout << "Converting data.. " << std::endl;
		std::vector<RealVector> inputs;

		if (verbose == true) {
			std::cout << "Parameters:\n";
			std::cout<<"\tC: \t\t" << C << "\n";
			std::cout<<"\tgamma: \t\t" << gamma << "\n";
			std::cout<<"\teps: \t\t" << epsilon << "\n";
		}

		
			
		// define things	
		KernelClassifier<RealVector> kc;
		GaussianRbfKernel<> sharkkernel(gamma);

		double trainError ;
		if(type=="CSVM") {
			bool useBias = true;
            trainError = CSVM (kc, C, &sharkkernel, useBias, epsilon, wdata);
        } else {
        	return R_NilValue;
        }

//         // compute the mean squared error on the training data:
//         MeanSquaredError mse;
//         double err = mse.error(svm, x, y);
// 
//         unsigned int dimension = svm.getDimension();
//         unsigned int offset = svm.getOffset();
//         unsigned int nSV = svm.getExamples();


// 		ZeroOneLoss<unsigned int> loss; // 0-1 loss
// 		Data<unsigned int> output = kc(test.inputs()); // evaluate on training set
// 		double test_error = loss.eval(test.labels(), output);
// 		cout << "test error:\t" << test_error << endl;


		
		// Find the support vector
		cout << "obtaining alphas:\t" << endl;
		RealMatrix fAlpha = kc.decisionFunction().alpha();
		size_t nSV = fAlpha.size1();
		cout << "size of alphas:\t" << nSV << endl;
		Rcpp::NumericVector alpha(nSV);
		
		// HACK: some hacks.
		cout << "copying alphas:\t" << endl;
		for (size_t x = 0; x < nSV; x++) {
			double currentAlpha = row (fAlpha, x)[0];
			alpha[x] = currentAlpha;
		}

		cout << "copying offset:\t" << endl;
		double offset = kc.decisionFunction().offset()[0];
		
		cout << "creating list:\t" << endl;
		Rcpp::List rl = R_NilValue;
		rl = Rcpp::List::create(Rcpp::Named("error") = trainError,
        		Rcpp::Named("offset") = offset,
        		Rcpp::Named("nSV") = nSV,
        		Rcpp::Named("alpha") = alpha);
		cout << "returning list:\t" << endl;
		return rl;

    } catch(std::exception &ex) {
		cout << "oops:\t" << endl;
		forward_exception_to_r(ex);
    } catch(...) {
		cout << "oops:\t" << endl;
		::Rf_error("c++ exception (unknown reason)");
    }

    cout << "nothing:\t" << endl;
	return R_NilValue;
}


