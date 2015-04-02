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
#include "utils.h"
#include "Data/SparseData.h"

using namespace std;
using namespace shark;





using namespace Rcpp;

RcppExport SEXP  readSparseData(SEXP svmParameters) {

	std::cout << "Starting.. " << std::endl;
	try {
        Rcpp::List rparam(svmParameters);
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
		generateFromShark (sdata, xR, yR) ;
		
		Rcpp::List rl = R_NilValue;
		rl = Rcpp::List::create(
				Rcpp::Named("x") = xR,
         		Rcpp::Named("y") = yR);
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



RcppExport SEXP writeSparseData(SEXP Xs, SEXP Ys, SEXP svmParameters) {
		
	std::cout << "Starting.. " << std::endl;
	try {
		Rcpp::NumericMatrix xR = Rcpp::NumericMatrix(Xs);
		Rcpp::NumericVector yR = Rcpp::NumericVector(Ys);
			
		Rcpp::List rparam(svmParameters);
		std::string filename = Rcpp::as<std::string>(rparam["filename"]);
		bool verbose = Rcpp::as<bool>(rparam["verbose"]);
		
		// convert to dataset
		ClassificationDataset sparseData;
		generateDatasetFromR (xR, yR, sparseData);
	
		if (verbose) std::cout << "Writing sparse data to " << filename <<  std::endl;
		
		SparseDataModel<RealVector> sdm;
		sdm.exportData (sparseData, filename);
		
		Rcpp::List rl = R_NilValue;
		rl = Rcpp::List::create();

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

