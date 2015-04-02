function h = plot_cluster(mean,cova,color,line,mark)
% center: mean of the Gaussian
% width: sqrt(dominant eigenvalue of the covariance) * scale factor
% height: sqrt(other eigenvalue of the covariance) * scale factor
% theta: angle between dominant eigenvector and x-axis

center = mean;
[V,D]  = eig(cova);
width  = sqrt(D(1,1));
height = sqrt(D(2,2));
  
compl  = complex(V(1,1),V(1,2));
theta  = angle(compl);
alpha  = 0:.005:2*pi;
x      = width*cos(alpha);
y      = height*sin(alpha);
xp     = x*cos(theta)+y*sin(theta);
yp     = x*sin(theta)-y*cos(theta);

h = plot(center(1)+xp,center(2)+yp,mark,'LineWidth',line);
set(h,'Color',color);