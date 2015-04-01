## SwarmSVM -- A collection of SVM solver.
##
## Copyright (C) 2015 Aydin Demircioglu <aydin.demircioglu@ini.rub.de>
##
## This file is part of the SwarmSVM library for GNU R.
## It is made available under the terms of the GNU General Public
## License, version 2, or at your option, any later version,
## incorporated herein by reference.
##
## This program is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with this program; if not, write to the Free
## Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
## MA 02111-1307, USA

ssvm <- function(x, y = NULL, scaled = TRUE,
                 type = "Epsilon_SVM", # GaussianProcess
                 kernel ="rbfdot", verbose = TRUE,
                 kpar = "automatic", C = 1, nu = 0.2, epsilon = 0.001, gamma=1,
                 prob.model = FALSE, class.weights = NULL, cross = 0, fit = TRUE,
                 cache = 40, tol = 0.001, shrinking = TRUE, sigma=1, ...,
                 subset, na.action = na.omit)
{
    type <- match.arg(type)

    val <- .Call("SVMregression",
                 X=x, y=y,
                 list(C=C,
                      gamma=gamma,
                      epsilon=epsilon,
                      sigma=sigma,
                      type=type,
                      kernel=kernel,
                      verbose = verbose
                      ),
                 PACKAGE="SharkSVM")
    print("Finished..")
    class(val) <- c("swam.svm")
    val
}


bsgd <- function(x, y = NULL, scaled = TRUE,
                 verbose = TRUE, budget = 500,
                 kpar = "automatic", C = 1, gamma=1,  epochs = 1,
                 prob.model = FALSE, class.weights = NULL, cross = 0, fit = TRUE,
                 cache = 40, tol = 0.001, shrinking = TRUE, ...,
                 subset, na.action = na.omit)
{
    val <- .Call("BSGDWrapper",
                 X=x, y=y,
                 list(C=C,
                      gamma=gamma,
                      budget = budget,
                      verbose = verbose,
                      epochs = epochs
                      ),
                 PACKAGE="SwarmSVM")
    print("Finished..")
    class(val) <- c("swarm.bsgd")
    val
}


# Generic methods
plot.svm <- function(x, ...) {
	warning("No plotting available for class", class(x)[1],"\n")
	invisible(x)
}

print.svm <- function(x, digits=5, ...) {
	cat("Error term", x, "\n")
	invisible(x)
}

summary.svm <- function(object, digits=5, ...) {
	cat("Detailed summary of SVM model for", class(object)[1], "\n")
	invisible(object)
}
