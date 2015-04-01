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

#ifndef SwarmSVM_h
#define SwarmSVM_h

// FIXME: remove this later on
// need to fake boost log as it is not available on LIDO for now
#define REPLACE_BOOST_LOG
#ifdef REPLACE_BOOST_LOG
#define localstr(s) #s
#define BOOST_LOG_TRIVIAL_FULL(x)    std::cout << std::endl << "(" << localstr(x) << "): "
#define BOOST_LOG_TRIVIAL(x)    std::cout << std::endl << ": "
#endif

// if we need not replace boost, we can include it
#ifndef REPLACE_BOOST_LOG
#include <boost/log/core.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/trivial.hpp>
#include <boost/log/utility/setup/console.hpp>
#endif


using namespace std;


#include <shark/Core/Exception.h>

#include <sstream>


namespace shark {
	
    ///! strategies for budgeted sgd.
    ///
    class BudgetMaintenanceStrategy {
        public:
            enum _BudgetMaintenanceStrategy {
                REMOVE = 0,
                MERGE = 1,
                PROJECT = 2
            };
    };



    /**
     * \brief Top-level exception class of the shark library.
     */
    class SharkSVMException : public shark::Exception {
        public:
            /**
             * \brief Default c'tor.
             * \param [in] what String that describes the exception.
             * \param [in] file Filename the function that has thrown the exception resides in.
             * \param [in] line Line of file that has thrown the exception.
             */
            SharkSVMException (const std::string &what = std::string(), const std::string &file = std::string(), unsigned int line = 0)            {
                m_what = what;
                m_file = file;
                m_line = line;
                std::ostringstream o;
                o << file << ":" << line << ": " << what;
                m_what = o.str();
            }
    };

}


/**
 * \brief Convenience macro that creates an instance of class shark::exception,
 * injecting file and line information automatically.
 */
#define SHARKSVMEXCEPTION(message) shark::SharkSVMException(message, __FILE__, __LINE__)



#include <Rcpp.h>

#endif
