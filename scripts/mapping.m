clear;
close all;
format long g;

tStart = cputime;  % seconds
 
% axis on;
% grid on;
% view(19,46);


%ptCloud2 = pcread('Z:\filtered_simplified\New folder\reprojected\SubTCA_simplified2_transformed_FME_affiner_reprojected_offsetted.pcd');
%ptCloud2=ply_read('Z:\filtered_simplified\New folder\volume\SubTCA_filtered_georeferenced_rot_trans_volume_ascii.ply');
ptCloud2=ply_read('Z:\filtered_simplified\New folder\reprojected\face2\SubTCA_filtered_transformed_FME_affiner_reprojected_offsetted_filtered_face2_ascii.ply');


%xyz = reshape(ptCloud2.Location, [], 3);
%ptCloud2 = pointCloud(xyz);
%ptCloud2.Color;
 

%  pcshow(ptCloud2);
%  hold on;

% % Face 1
% Xmin = 691064.41442195;
% Xmax = 691088.7124075526;
% Ymin = 5336062.479256758;
% Ymax = 5336124.055458277;
% Zmin = 514.59;
% Zmax = 533.823;

% Face 2
Xmin = 691046.4223489834;
Xmax = 691064.41442195;
Ymin = 5336069.603285683;
Ymax = 5336062.479256758;
Zmin = 514.59;
Zmax = 533.823;

%patch([Xmin Xmax Xmax Xmin], [Ymin Ymax Ymax Ymin], [Zmin Zmin Zmax Zmax],'red');
%patch(normalize([Xmin Xmax Xmax Xmin]), normalize([Ymin Ymax Ymax Ymin]), normalize([Zmin Zmin Zmax Zmax]),'red');
%hold on;

% Xmin_vol = 691063.4842233481;
% Xmax_vol = 691089.6426061545;
% Ymin_vol = 5336062.112200139;
% Ymax_vol = 5336124.422514896;
% Zmin_vol = 514.59;
% Zmax_vol = 533.838;

% roi = [Xmin_vol Xmax_vol Ymin_vol Ymax_vol Zmin_vol Zmax_vol];
% indices2 = findPointsInROI(ptCloud2,roi); 
 
% plot3(ptCloud2.Location(indices2,1),ptCloud2.Location(indices2,2),ptCloud2.Location(indices2,3),'.y');
%  hold on;


% %clip point cloud
% V2=[ [Xmin Ymin Zmin]; [Xmax Ymax Zmin]; [Xmax Ymax Zmax]; [Xmin Ymin Zmax] ];
% V2=V2-mean(V2); %assumes R2016b or later, otherwise use bsxfun()
% [U2,S2,W2]=svd(V2,0);
% normal=W2(:,end);
% maxDistance = 1;    % in meters
% referenceVector = normal;
% [model1,inlierIndices,outlierIndices] = pcfitplane(ptCloud2,maxDistance,referenceVector);
% plane1 = select(ptCloud2,inlierIndices);
% ptCloud2 = plane1;
%pcwrite(ptCloud2,'Z:\filtered_simplified\New folder\reprojected\SubTCA_simplified2_transformed_FME_affiner_reprojected_offsetted_clipped_matlab.pcd')
% plotv(normal,'-');
% hold on;
%  pcshow(plane1);
%  hold on;

 n = sqrt((Xmax-Xmin)^2+(Ymax-Ymin)^2)/0.1;     % texel width = 0.1 meter
 %n = norm([Xmax Ymax] - [Xmin Ymin])/0.1;      % texel width = 0.1 meter

dx = (Xmax-Xmin)/n;
dy = (Ymax-Ymin)/n;     % sqrt((dx)^2 + (dy)^2) = 0.1

X = [];
X_next = Xmin;  % starting at corner vertex

Y = [];
Y_next = Ymin;  % starting at corner vertex

for i = 1:n
    X(i) = X_next;
    Y(i) = Y_next;
    X_next = X_next + dx;
    Y_next = Y_next + dy;
end



dz = 0.1;   % texel height = 0.1 meter
nz = (Zmax-Zmin)/dz;
Z = [];
Z_next = Zmin;    % starting at corner vertex

for k = 1:nz
    Z(k) = Z_next;
    Z_next = Z_next + dz;
end


K = 220;
radius = 0.3;

%blankimage = ones(floor(nz),floor(n),1);
blankimage = [];

dist_arr = [];
angle_or_dist_to_normal_arr = [];
total_detected_neighbours = 0;
detected_with_thermal = 0;
detected_without_thermal = 0;
detected_far_than_nearest = 0;
detected_multiple_vertical = 0;

% Surface normalize
% X = normalize(X);
% Y = normalize(Y);
% Z = normalize(Z);


if(Xmax>Xmin); Xlimit=Xmax; else Xlimit=Xmin; end;
if(Ymax>Ymin); Ylimit=Ymax; else Ylimit=Ymin; end;
if(Zmax>Zmin); Zlimit=Zmax; else Zlimit=Zmin; end;

%              for row = floor(nz/2)
%              for col = floor(n/2)
%% do not consider border texels less than 10 cm
for row = 1:nz-1
    for col = 1:n-1
        if (X(col+1) <= Xlimit) && (Y(col+1) <= Ylimit) && (Z(row+1) <= Zlimit)
%% consider border texels less than 10 cm
% for row = 1:nz
%     for col = 1:n
%         if (X(col) < Xlimit) && (Y(col) < Ylimit) && (Z(row) < Zlimit)
%              if (col == floor(n))
%                 X(col+1) = Xmax;
%                 Y(col+1) = Ymax;
%              end
%              if (row == floor(nz))
%                 Z(row+1) = Zmax;
%              end

             point = [X(col)  Y(col)  Z(row)];
             point_next_col = [X(col+1)  Y(col+1)  Z(row)];
             point_next_row_col = [X(col+1)  Y(col+1)  Z(row+1)];
             point_next_row = [X(col)  Y(col)  Z(row+1)];
             point_mid = [point(1)+(dx/2), point(2)+(dy/2), point(3)+(dz/2)]; % midpoint of texel; starting at 0.05 distance -> horizontally sqrt((dx/2)^2 + (dy/2)^2) = 0.05, vertically dz = 0.05
                  

            x = [point(1) point_next_col(1) point_next_row_col(1) point_next_row(1)];
            y = [point(2) point_next_col(2) point_next_row_col(2) point_next_row(2)];
            z = [point(3) point_next_col(3) point_next_row_col(3) point_next_row(3)];
   
            norm_x = normalize(x);
            norm_y = normalize(y);
            norm_z = normalize(z);

            %figure;
            %patch(norm_x,norm_y,norm_z,'red');

            % Surface normalize
            %patch(x,y,z,'red');

%             hold on;
%             axis on
%             grid on
%             view(19,46);



            V=[point;point_next_col;point_next_row_col;point_next_row];
            V=V-mean(V); %assumes R2016b or later, otherwise use bsxfun()
            %V = bsxfun(@minus, V, mean(V));
            [U,S,W]=svd(V,0);
%             along_vector=W(:,1);
%             ortho_mat = null(along_vector(:).');
%             normal_vector = ortho_mat(:,1);
            normal_vector=W(:,end);
%             normal_vector = hom2cart(reshape(normal_vector,1,4));
%             normal_vector = reshape(normal_vector,3,1);

            %figure;
           %intr = cross(along_vector(1:3), normal_vector(1:3));
%             plotv(along_vector,'-');
%             hold on;
%             plotv(normal_vector(1:3),'-');
%             hold on;
%             axis on
%             grid on
%             view(19,46);


            % Surface normalize
%             plot3(point(1),point(2),point(3), 'b*');
%             hold on;
%             plot3(point_next_col(1),point_next_col(2),point_next_col(3), 'b*');
%             hold on;
%             plot3(point_next_row(1),point_next_row(2),point_next_row(3), 'b*');
%             hold on;
%             plot3(point_next_row_col(1),point_next_row_col(2),point_next_row_col(3), 'b*');
%             hold on;

            %[indices,dists] = findNearestNeighbors(ptCloud2,point_mid,K);
            [indices,dists] = findNeighborsInRadius(ptCloud2,point_mid,radius);
 
%             plot3(ptCloud2.Location(indices,1),ptCloud2.Location(indices,2),ptCloud2.Location(indices,3),'.y');
%             hold on;

%             plot3(point_mid(1),point_mid(2),point_mid(3), 'k*');
%             hold on;
             [Mmin,Imin] = min(dists);
%               plot3(ptCloud2.Location(indices(Imin),1),ptCloud2.Location(indices(Imin),2),ptCloud2.Location(indices(Imin),3),'.g'); % min dist point
%               hold on;
             [Mmax,Imax] = max(dists);
%             plot3(ptCloud2.Location(indices(Imax),1),ptCloud2.Location(indices(Imax),2),ptCloud2.Location(indices(Imax),3),'g*'); % max dist point         
%              hold on;


%             % point-plane distance
%             if (~isempty(Imin))
%                 no = cross(point - point_next_col, point - point_next_row);
%                 Po = ptCloud2.Location(indices(Imin),:);
% 
%                 %First way
%                 d = dot(-point, no);
%                 nnorm = no/norm(no); 
%                 p = d/norm(no);
%                 Distance = dot(nnorm, Po) + p;
%                 
%                 %Second way
%                 xPo=Po(1);yPo=Po(2);zPo=Po(3);
%                 d_=dot(no, point); d_=-d_;
%                 d1=norm(no(1)*xPo+no(2)*yPo+no(3)*zPo+d_);
%                 d2=sqrt(no(1)^2+no(2)^2+no(3)^2);
%                 Distance2_alt=(d1/d2);
% 
%                 %Third way
%                  Plane=[point;point_next_row;point_next_row_col]; 
%                  c=mean(Plane);
%                  N=null(bsxfun(@minus, Plane,c), 1e-4);
%                  N=mean(N,2); 
%                  Distance2_alt_alt = abs(dot(N,c-Po));
%             end
            

 
            %check if point is vertical to mid-point of texel
            is_vertical = true;
            Imin_min_arr = [];

            if (~isempty(Imin))
                total_detected_neighbours = total_detected_neighbours + 1;

                Pext = ptCloud2.Location(indices(Imin),:); % external point

                counter2 = 1;           
                Imin_min_arr(counter2) = Imin;
                counter2 = counter2 + 1;
                angle_degrees = acosd((dot(normal_vector(1:3), Pext-point_mid))/(norm(normal_vector(1:3))*norm(Pext-point_mid)));
                %angle_degrees = dists(Imin) * sind(angle_degrees); % case - distance to normal
                angle_degrees_min = angle_degrees;
                dist_min = dists(Imin);

                quality2 = 1 - ptCloud2.Intensity(indices(Imin_min_arr))/255;
                
                while ( (quality2 == 0) && (Imin < size(indices,1)) )
                    Imin = Imin + 1;
                    Pext = ptCloud2.Location(indices(Imin),:); % external point
                    angle_degrees = acosd((dot(normal_vector(1:3), Pext-point_mid))/(norm(normal_vector(1:3))*norm(Pext-point_mid)));
                    %angle_degrees = dists(Imin) * sind(angle_degrees); % case - distance to normal
                    angle_degrees_min = angle_degrees;
                    dist_min = dists(Imin);
                    Imin_min_arr = [];
                    counter2 = 1;
                    Imin_min_arr(counter2) = Imin;
                    counter2 = counter2 + 1;
                    quality2 = 1 - ptCloud2.Intensity(indices(Imin_min_arr))/255;
                    if(quality2 ~= 0)
                        break;
                    end
                end

                Imin_checkpoint = Imin;

              %START: Minimize angle or distance to normal                
                while ( Imin < size(indices,1) )
                    Imin = Imin + 1;
                    Pext = ptCloud2.Location(indices(Imin),:); % external point
                    angle_degrees = acosd((dot(normal_vector(1:3), Pext-point_mid))/(norm(normal_vector(1:3))*norm(Pext-point_mid)));
                    %angle_degrees = dists(Imin) * sind(angle_degrees); % case - distance to normal
                    quality2 = 1 - ptCloud2.Intensity(indices(Imin))/255;
                    if((angle_degrees < angle_degrees_min) && (quality2 ~= 0))
                        angle_degrees_min = angle_degrees;
                        Imin_min_arr = [];
                        counter2 = 1;
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                        dist_min = dists(Imin);
                    elseif((angle_degrees == angle_degrees_min) && (dists(Imin) < dist_min) && (quality2 ~= 0))         
                        Imin_min_arr = [];
                        counter2 = 1;
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                        dist_min = dists(Imin);
                    elseif((angle_degrees == angle_degrees_min) && (dists(Imin) == dist_min) && (quality2 ~= 0))
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                    end
                end

                normal_vector = - normal_vector;
                Imin = Imin_checkpoint;
                while ( Imin < size(indices,1) )
                    Imin = Imin + 1;
                    Pext = ptCloud2.Location(indices(Imin),:); % external point
                    angle_degrees = acosd((dot(normal_vector(1:3), Pext-point_mid))/(norm(normal_vector(1:3))*norm(Pext-point_mid)));
                    %angle_degrees = dists(Imin) * sind(angle_degrees); % case - distance to normal
                    quality2 = 1 - ptCloud2.Intensity(indices(Imin))/255;
                    if((angle_degrees < angle_degrees_min) && (quality2 ~= 0))
                        angle_degrees_min = angle_degrees;
                        Imin_min_arr = [];
                        counter2 = 1;
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                        dist_min = dists(Imin);
                    elseif((angle_degrees == angle_degrees_min) && (dists(Imin) < dist_min) && (quality2 ~= 0))         
                        Imin_min_arr = [];
                        counter2 = 1;
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                        dist_min = dists(Imin);
                    elseif((angle_degrees == angle_degrees_min) && (dists(Imin) == dist_min) && (quality2 ~= 0))
                        Imin_min_arr(counter2) = Imin;
                        counter2 = counter2 + 1;
                    end
                end
              %END: Minimize angle or distance to normal  

                if length(Imin_min_arr)>1
                    detected_multiple_vertical = detected_multiple_vertical + 1;
                    Pext = median(ptCloud2.Location(indices(Imin_min_arr),:)); 
                else
                    Pext = ptCloud2.Location(indices(Imin_min_arr),:); 
                end

                if( Mmin < median(dists(Imin_min_arr)) )
                    detected_far_than_nearest = detected_far_than_nearest + 1;
                end
                               
                dist_arr(total_detected_neighbours) = median(dists(Imin_min_arr));   
                angle_or_dist_to_normal_arr(total_detected_neighbours) = angle_degrees_min;

%             norm_x_ = normalize([x Pext(1) point_mid(1)]);
%             norm_y_ = normalize([y Pext(2) point_mid(2)]);
%             norm_z_ = normalize([z Pext(3) point_mid(3)]);
%             Pext(1) = norm_x_(5);
%             Pext(2) = norm_y_(5);
%             Pext(3) = norm_z_(5);
%             point_mid(1) = norm_x_(6);
%             point_mid(2) = norm_y_(6);
%             point_mid(3) = norm_z_(6);

%               plot3(Pext(1), Pext(2), Pext(3), 'b*');        
%               hold on;
%               line([point_mid(1) Pext(1)], [point_mid(2) Pext(2)], [point_mid(3) Pext(3)]);
%               hold on;
%               line([point_mid(1) point(1)], [point_mid(2) point(2)], [point_mid(3) point(3)]);
%               hold on;
%               line([point_mid(1) point_next_col(1)], [point_mid(2) point_next_col(2)], [point_mid(3) point_next_col(3)]);
%               hold on;
%               line([point_mid(1) point_next_row(1)], [point_mid(2) point_next_row(2)], [point_mid(3) point_next_row(3)]);
%               hold on;

            end

            quality = 1 - median(ptCloud2.Intensity(indices(Imin_min_arr)))/255;
            if (quality == 0)
                detected_without_thermal = detected_without_thermal + 1;
            end


            %if (~isempty(Imin_min_arr)) && (quality ~= 0)
            if (~isempty(Imin_min_arr)) && (quality ~= 0) && (is_vertical == true)

                blankimage(row,col,1) = quality * cast(median(ptCloud2.Color(indices(Imin_min_arr))),"double")/255;
                blankimage(row,col,2) = 0;
                blankimage(row,col,3) = 0;
                detected_with_thermal = detected_with_thermal + 1;
            else
                %blankimage(row,col,:) = 192/255;
                blankimage(row,col,:) = 0;
            end
       end
    end
end

 finalimage = flipdim(blankimage,1);

imwrite(finalimage,'latest/face2/simplified_face2_transformed_onlyDistance2.png');

% Apply texture mask
%mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face1.jpg');  %face 1
mask = imread('Z:\thermal_images\resized\masked\gray_192_masked_face2.jpg');  %face 2
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
 
figure
image(finalimage);
impixelinfo;
  
imwrite(finalimage,'latest/face2/simplified_face2_transformed_onlyDistance.png');


%% Results
detected_with_thermal
detected_without_thermal
pixelCount_win_do
total_detected_neighbours
detected_far_than_nearest
detected_multiple_vertical
mean_dist_arr = mean(dist_arr)
mean_angle_or_dist_to_normal_arr = mean(angle_or_dist_to_normal_arr)
detected_with_thermal_without_win_do = detected_with_thermal - pixelCount_win_do
total_pixels = h * w
detection_rate = detected_with_thermal/total_pixels
detection_rate_without_win_do = detected_with_thermal_without_win_do/(total_pixels-pixelCount_win_do)
tEnd = cputime - tStart % seconds






