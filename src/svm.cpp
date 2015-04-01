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
#include <shark/Algorithms/Trainers/CSvmTrainer.h> // the C-SVM trainer
#include <shark/Models/Kernels/GaussianRbfKernel.h> //the used kernel for the SVM
#include <shark/ObjectiveFunctions/Loss/ZeroOneLoss.h> //used for evaluation of the classifier
#include <shark/Data/DataDistribution.h> //includes small toy distributions


using namespace std;
using namespace shark;



double R_Epsilon_SVM(
	KernelClassifier<RealVector> &kc,
	double C, 
	GaussianRbfKernel<> *kernel,
	bool bias,
	double epsilon, 
	const ClassificationDataset &training,
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

RcppExport SEXP SVMregression(SEXP Xs, SEXP Ys, SEXP svmParameters) {

	std::cout << "Starting.. " << std::endl;
	try {
		Rcpp::NumericMatrix xR = Rcpp::NumericMatrix(Xs);
        Rcpp::NumericVector yR = Rcpp::NumericVector(Ys);
        Rcpp::List rparam(svmParameters);
        double C = Rcpp::as<double>(rparam["C"]);
        double epsilon = Rcpp::as<double>(rparam["epsilon"]);
        double gamma = Rcpp::as<double>(rparam["gamma"]); 
        double sigma = Rcpp::as<double>(rparam["sigma"]);
        string type = Rcpp::as<string>(rparam["type"]);
        string kernel = Rcpp::as<string>(rparam["kernel"]);
		bool verbose = Rcpp::as<bool>(rparam["verbose"]);
		
		// convert data
		if (verbose) std::cout << "Converting data.. " << std::endl;
		std::vector<RealVector> inputs;

		if (verbose == true) {
			std::cout << "Parameters:\n";
			std::cout<<"\tC: \t\t" << C << "\n";
			std::cout<<"\tgamma: \t\t" << gamma << "\n";
			std::cout<<"\teps: \t\t" << epsilon << "\n";
		}
		// probably stupid, but for now its ok
		unsigned int examples = xR.rows();
		for (size_t e = 0; e < examples; e++) {
			NumericMatrix::Row zzrow = xR( e, _);
			std::vector<double> tmp (zzrow.begin(), zzrow.end());
			RealVector tmpRV (tmp.size());
			std::copy (tmp.begin(), tmp.end(), tmpRV.begin());
			inputs.push_back(tmpRV);
		}

		std::vector<unsigned int> labels(yR.begin(),yR.end());
		
		ClassificationDataset trainingData = createLabeledDataFromRange(inputs, labels);
		
			
		// define things	
		KernelClassifier<RealVector> kc;
		GaussianRbfKernel<> sharkkernel(gamma);

		type=="Epsilon_SVM";
		
		double trainError ;
		if(type=="Epsilon_SVM") {
			bool useBias = true;
            trainError = R_Epsilon_SVM(kc, C, &sharkkernel, useBias, epsilon, trainingData);
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


