%Apply texture mask
finalimage = imread('new/hots_new/original_face1_georeferenced_dist_to_normal_normalBoth.png');

mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face1.jpg');  %face 1

%mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face2.jpg');  %face 2

[h w c] = size(finalimage);
mask = imresize(mask,[h w]);

mask = circshift(mask, [0 12]); %face 1


image(mask);

level = graythresh(mask);

%mask = imcomplement(imbinarize(mask,level));
mask = 255*imbinarize(mask,level);

%finalimage = bsxfun(@times, finalimage, cast(mask, 'like', finalimage));
finalimage = bsxfun(@plus, finalimage, cast(mask, 'like', finalimage));

 figure
 image(finalimage);
 impixelinfo;

   
 imwrite(finalimage,'new/hots_new/mid.png');


% Grey
finalimage = imread('new/hots_new/mid.png');
binary_without_thermal = 192 * (finalimage(:, :, :) == 15);
binary_without_thermal = cat(3, binary_without_thermal(:, :, 1), binary_without_thermal(:, :, 1), binary_without_thermal(:, :, 1));
finalimage = bsxfun(@plus, finalimage, cast(binary_without_thermal, 'like', finalimage));
image(finalimage);
impixelinfo;
%imwrite(finalimage,'new/hots_new/original_face1_georeferenced_dist_to_normal_normalBoth_masked.png');
