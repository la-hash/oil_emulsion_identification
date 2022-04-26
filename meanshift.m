
function l=meanshift(im,hs,hr,err,kernelType) 
% MEANSHSEGM Mean shift segmentation
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
%  
% Segment a grayscale or color image using mean shift image segmentation
% Warning: Segmenting a medium-size image (200x 300 pixels)
% takes a couple of minutes and the time increases with
% the image and kernel size.  
%
% Usage: l = meanshsegm(im,hs,hr)
%  im   [m x n x d]  Scalar (d=1) or color (d=3) input image.
%  hs  (default 10)
%      Spatial kernel size, in pixels.
%  hr  (default 20 for gaussian kernel and default 40 for Epanechnikov kernel)
%      Range kernel size.
% err  (default 0.2)
% norm of error which determine when to stop iteration
% kernelType (default 'gaussian')
% 'gaussian' for gaussian kernel, 'Epan' for Epanechnikov kernel
% l  [m x n]  Output labeling. Each pixel position contains an integer
%  1... N corresponding to an assigned region number; N is the
%  number of regions.
  

if ~exist('kernelType','var')
    kernelType='gaussian'
end
 
if ~exist('hs','var')
    hs=15;
end
 
if ~exist('hr','var')
    if strcmp(kernelType,'gaussian')==1
        hr=20;
    else
        hr=40;
    end
end
 
if ~exist('err','var')
    err=0.2;
end
 

[m,n,d] = size(im);
h  = [hs hs repmat(hr,1,d)];
z  = zeros( m, n, d+2 );
im = double(im);
 

for ix = 1:n
  for iy = 1:m
    y = double( [ix iy reshape(im(iy,ix,:),1,d)] );
    xl = max(ix-hs,1);  xh = min(ix+hs,n);  nw = xh-xl+1;
    yl = max(iy-hs,1);  yh = min(iy+hs,m);  mw = yh-yl+1;
    nw = nw*mw;  iw = (0:(nw-1))';
    fw = [fix(iw/mw+xl) mod(iw,mw)+yl reshape(im(yl:yh,xl:xh,:),[],d)];
    while true
      r = (fw-repmat(y,nw,1)) ./ repmat(h,nw,1);
      rs = sum( r.*r, 2 );
      if strcmp(kernelType,'gaussian')==1
          w=exp(-rs/2);
      else
          w=1-rs;
          w(w<0)=0;
      end
      y0 = y;
      y = w'*fw/sum(w);
      if norm(y-y0)<err, break; end
    end
    z(iy,ix,:) = y;
  end 
end 
 
s = ones( 2*m+1, 2*n+1, 'int8' );
s(1:2:(2*m+1),:) = zeros( m+1, 2*n+1, 'int8' );
s(:,1:2:(2*n+1)) = zeros( 2*m+1, n+1, 'int8' );
 
s(2:2:2*m,3:2:(2*n-1)) = all(cat(3, ...                
  abs(z(:,2:end,1:2)-z(:,1:(end-1),1:2)) < hs, ...
  abs(z(:,2:end,3:end)-z(:,1:(end-1),3:end)) < hr ),3);
s(3:2:(2*m-1),2:2:2*n) = all(cat(3, ...                
  abs(z(2:end,:,1:2)-z(1:(end-1),:,1:2)) < hs, ...
  abs(z(2:end,:,3:end)-z(1:(end-1),:,3:end)) < hr ),3);
 

l = bwlabel( s, 4 ); 
l = l( 2:2:2*m, 2:2:2*n );  

