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

#include <shark/Data/DataDistribution.h> //includes small toy distributions

#include "SwarmSVM.h"
#include "Data/SparseData.h"

using namespace std;
using namespace shark;





using namespace Rcpp;

RcppExport SEXP  readSparseData(SEXP svmParameters) {

	std::cout << "Starting.. " << std::endl;
	try {
        Rcpp::List rparam(svmParameters);
        double C = Rcpp::as<double>(rparam["C"]);
		std::string filename = Rcpp::as<std::string>(rparam["filename"]);
		bool normalizeLabels = Rcpp::as<bool>(rparam["normalizeLabels"]);
		bool verbose = Rcpp::as<bool>(rparam["verbose"]);

		if (verbose) std::cout << "Reading data.. " << std::endl;
		SparseDataModel<RealVector> sdm;
		LabelOrder labelOrder;
		size_t dimensions = 0;
		ClassificationDataset sdata = sdm.importData (filename,  
			&labelOrder, 
			normalizeLabels, 
			dimensions);
		
		// convert data
		if (verbose) std::cout << "Converting data.. " << std::endl;
		
		Rcpp::NumericMatrix xR = Rcpp::NumericMatrix();
		Rcpp::NumericVector yR = Rcpp::NumericVector();
		
// 		// probably stupid, but for now its ok
// 		unsigned int examples = xR.rows();
// 		for (size_t e = 0; e < examples; e++) {
// 			NumericMatrix::Row zzrow = xR( e, _);
// 			std::vector<double> tmp (zzrow.begin(), zzrow.end());
// 			RealVector tmpRV (tmp.size());
// 			std::copy (tmp.begin(), tmp.end(), tmpRV.begin());
// 			inputs.push_back(tmpRV);
// 		}
// 
// 		std::vector<unsigned int> labels(yR.begin(),yR.end());
// 		
// 		ClassificationDataset trainingData = createLabeledDataFromRange(inputs, labels);
		Rcpp::List rl = R_NilValue;
		rl = Rcpp::List::create();
// 			Rcpp::Named("error") = trainError,
//         		Rcpp::Named("offset") = offset,
//         		Rcpp::Named("nSV") = nSV,
//         		Rcpp::Named("alpha") = alpha);
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


