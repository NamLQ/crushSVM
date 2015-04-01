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


#ifndef UTILS_H
#define UTILS_H

#include <shark/Data/DataDistribution.h> //includes small toy distributions
#include <Rcpp.h>


using namespace shark;
using namespace std;
using namespace Rcpp;

// convert to dataset
// const would be nice, but i get errors then.

void generateFromR (Rcpp::NumericMatrix &xR, Rcpp::NumericVector &yR, shark::ClassificationDataset &data) 
{
	// probably stupid, but for now its ok
	unsigned int examples = xR.rows();
	std::vector<RealVector> inputs;
	for (size_t e = 0; e < examples; e++) {
		NumericMatrix::Row zzrow = xR( e, _);
		std::vector<double> tmp (zzrow.begin(), zzrow.end());
		RealVector tmpRV (tmp.size());
		std::copy (tmp.begin(), tmp.end(), tmpRV.begin());
		inputs.push_back(tmpRV);
	}
	std::vector<unsigned int> labels(yR.begin(),yR.end());
	data = createLabeledDataFromRange(inputs, labels);
}


void generateFromShark (const shark::ClassificationDataset  &dataset, Rcpp::NumericMatrix &xR, Rcpp::NumericVector &yR) 
{
	// labels
	std::vector<unsigned int> tmpV (dataset.labels().numberOfElements());
	std::copy (dataset.labels().elements().begin(), dataset.labels().elements().end(), tmpV.begin());
	yR = wrap(tmpV);

	// inputs
	size_t rows = dataset.inputs().numberOfElements();
	size_t cols = dataset.inputs().element(0).size();
	
	// do not know why i need this, but heck.
	Rcpp:NumericMatrix P (rows, cols);
	xR = P;

	for (size_t e = 0; e < rows; e++) {
		RealVector currentRow = dataset.inputs().element(e);
		std::copy(currentRow.begin(), currentRow.end(), xR.row(e).begin());
	}
}


#endif
