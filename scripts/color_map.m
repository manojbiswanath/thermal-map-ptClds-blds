im2 = imread('new/original_face1_georeferenced_dist_to_normal_normalBoth2.png');
  I = rgb2gray(im2);

 imwrite(I,'new/gray.png');

 im = imread('new/gray.png');

im = imlocalbrighten(im);
%im = imbcg(im,'b',0.4);

%myColorMap = hot; 
myColorMap = imlocalbrighten(hot,0.5); 

rgbImage = ind2rgb(im, myColorMap);

 image(rgbImage);
 impixelinfo;

 %imwrite(rgbImage,'latest/face2/orig/simplified_face2_tramsformed_dist_to_normal_normalBoth2_hot.png');
