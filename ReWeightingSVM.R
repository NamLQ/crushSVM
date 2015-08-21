
# as such this only works for linear SVMs. 
# if needed, first map your data by some nystrom approximation
# to a finite dimensional over-space and do this scheme here there.
#
# this algorithm is from
# 
# @inproceedings{kujala2009walk,
#   title={A walk from 2-norm SVM to 1-norm SVM},
#   author={Kujala, Jussi and Aho, Timo and Elomaa, Tapio},
#   booktitle={Data Mining, 2009. ICDM'09. Ninth IEEE International Conference on},
#   pages={836--841},
#   year={2009},
#   organization={IEEE}
# }
#

reWeightingSVM <- function (X, Y, rounds = 2) {
    # init v with ones 
    d = length(Y)
    v = 1 + 0*Y

    for (t in 1:rounds) {
        # transform the whole data matrix
        rV = t(replicate(d, v))
        tX = X*v
        
        # now solve SVM with the transformed data, retrieve weight
        w = ssvm (blabla)
        
        # readjust v
        v = sqrt(abs(w*v))
    }
    
    # readjust last weights
    w = w*v
    
    return(w)
}
