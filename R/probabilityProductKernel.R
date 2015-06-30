## crushSVM -- A collection of SVM solver.
##
## Copyright (C) 2015 Aydin Demircioglu <aydin.demircioglu@ini.rub.de>
##
## This file is part of the crushSVM library for GNU R.
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


# gaussian, diagonal PPK
gdPPK <- function(
	prior1,
	diag1,
	mean1,
	prop2,
	diag2,
	mean2,
	...)
{
	# some checks..

	d = length(mean1)
	k = prior1 * prior2 * exp (sum( (mean1 - mean2)^2/(diag1^2 + diag2^2) ))
	k = k/prod ( sqrt(2*pi* (diag1^2 + diag2^2) ))
}


