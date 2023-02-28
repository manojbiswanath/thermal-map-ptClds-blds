finalimage = imread('C:\Users\manoj\Documents\MATLAB\old\radius_1_checkVertical_parallel_normalOpposite_considerDistance_homogeneous2.png');  %face 1

binary_without_thermal = 255 * (finalimage(:, :, :) == 192);

finalimage = imlocalbrighten(finalimage);
%finalimage = bsxfun(@imlocalbrighten, finalimage, cast(binary_without_thermal, 'like', finalimage));
%finalimage = imbcg(finalimage,'b',0.1);

% Apply texture mask    
mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face1.jpg');  %face 1
%mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face2.jpg');  %face 2
[h w c] = size(finalimage);
mask = imresize(mask,[h w]);

% Count no. of window/door pixels
binary_win_do = mask(:, :, :) == 255;
pixelCount_win_do = sum(binary_win_do(:))/3;

level = graythresh(mask);
%mask = imcomplement(imbinarize(mask,level));
mask = 255*imbinarize(mask,level);

%finalimage = bsxfun(@times, finalimage, cast(mask, 'like', finalimage));
finalimage = bsxfun(@plus, finalimage, cast(mask, 'like', finalimage));
image(finalimage);
impixelinfo;

%imwrite(B,'brightened_face1.png');
