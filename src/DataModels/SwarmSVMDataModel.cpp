//===========================================================================
/*!
 *
 *
 * \brief       SwarmSVM data model
 *
 *
 *
 * \author      Aydin Demircioglu
 * \date        2014
 *
 *
 * \par Copyright 1995-2014 Shark Development Team
 *
 * <BR><HR>
 * This file is part of Shark.
 * <http://image.diku.dk/shark/>
 *
 * Shark is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Shark is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Shark.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
//===========================================================================


#include <fstream>
#include <iostream>

// WTF??
#define BOOST_SPIRIT_USE_PHOENIX_V3

#include <boost/spirit/include/phoenix_core.hpp>
#include <boost/spirit/include/phoenix_operator.hpp>
#include <boost/spirit/include/phoenix_stl.hpp>
#include <boost/spirit/include/qi.hpp>
#include <boost/regex.hpp>


#ifndef REPLACE_BOOST_LOG
#include <boost/log/core.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/trivial.hpp>
#endif


#include <shark/Core/Exception.h>
#include <shark/Data/Dataset.h>
#include <shark/Data/Libsvm.h>

#include "AbstractSVMDataModel.h"
#include "SwarmSVMDataModel.h"
#include "DataModelContainer.h"
#include "SharkSVM.h"
#include "SVMDataModelFactory.h"


using namespace std;


namespace shark {


    SwarmSVMDataModel::SwarmSVMDataModel() {
    }



    SwarmSVMDataModel::~SwarmSVMDataModel() {
    }
    
    
    
    int SwarmSVMDataModel::readNext () {

        // HACK:
        // match model
        boost::cmatch matchedStrings;
        boost::regex SwarmSVMExpression ("# model: (.*)");
        
        std::string line;
        std::getline (m_inputStream, line);
        if (m_inputStream.eof()) { 
            return (-1);
        }
        
        std::string modelName = "ERROR";
        BOOST_LOG_TRIVIAL(debug) << "Read line: " << line;
        if (boost::regex_search (line.c_str(), matchedStrings, SwarmSVMExpression)) {
            modelName = boost::lexical_cast<std::string>( matchedStrings[1] );
            BOOST_LOG_TRIVIAL (info) << "Found model " << modelName;
        }

        // match model types
        boost::regex ModelTypeExpression ("# model-type: (.*)");
        
        std::getline (m_inputStream, line);
        if (m_inputStream.eof()) { 
            return (-1);
        }
        
        BOOST_LOG_TRIVIAL(debug) << "Read line: " << line;
        std::string modelType;
        if (boost::regex_search (line.c_str(), matchedStrings, ModelTypeExpression )) {
            modelType = boost::lexical_cast<std::string>( matchedStrings[1] );
        }
        
        // create model with given name
        BOOST_LOG_TRIVIAL (info) << "Found " << modelType << " model.";
        SVMDataModel svmModel = SVMDataModelFactory::createFromString(modelType);
        svmModel -> load(m_inputStream);
        container = svmModel->dataContainer();
        container -> setModelName (modelName);
        
        return (0);
    }



    
    void  SwarmSVMDataModel::load (std::ifstream &inputStream) {
        // HACK: the idea is as follows: load will always get the next model.
        // if there is no model left, we just return. or something.

        
        // HACK: does not do anything anymore
    }
    
    
    
    void SwarmSVMDataModel::save (std::ofstream &outputStream) {
        // sanity check
        if (!outputStream)
            throw (SHARKSVMEXCEPTION ("File can not be opened for writing!"));
        
    }
    
    
}


