function [imgLines, corrValue, projectedImg, projectedColor, rebuildColor] = colorValue(rubik)
    editSize = [120, 120];
    
%     figure;imshow(rubik);
    imgray = rgb2gray(rubik);
    BW = imbinarize(imgray, 0.01);
    [x, y] = size(BW);
    patt = imread('pattern/patt1.jpg');
    c1 = normxcorr2(patt, BW);
    patt = imread('pattern/patt2.jpg');
    c2 = normxcorr2(patt, BW);
    patt = imread('pattern/patt3.jpg');
    c3 = normxcorr2(patt, BW);
    patt = imread('pattern/patt4.jpg');
    c4 = normxcorr2(patt, BW);
    c = (c1 + c2 + c3 + c4) / 2;
    corrValue.C = c;
    corrValue.C1 = c1;
    corrValue.C2 = c2;
    corrValue.C3 = c3;
    corrValue.C4 = c4;
    figure;surf(c); %---------------------------------------------------------------------------
    shading flat;
    
    flattenedC = reshape(c.',1,[]);
    %get 0.4% percentile from maximum values
    lim = prctile(flattenedC, 99.6);
    
    cuttedC = zeros(size(BW));
    for i=1:x
        for j=1:y
            cuttedC(i,j) = c(size(patt,1)/2 + i,size(patt,2)/2 + j) > lim;
        end
    end
%     figure;imshow(cuttedC);
    
    stl = strel('disk', 8);
    cuttedC = imdilate(cuttedC, stl);
    stl = strel('disk', 7);
    cuttedC = imerode(cuttedC, stl);
    
    CC = bwconncomp(cuttedC);
    stats = regionprops(CC, 'centroid');
    pts = cat(1, stats.Centroid);
    
    left2 = pts(1,:);
    right2 = pts(1,:);
    bottom2 = pts(1,:);
    for i=2:size(pts, 1)
        if left2(1) > pts(i,1)
            left2 = pts(i,:);
        end
        if right2(1) < pts(i,1)
            right2 = pts(i,:);
        end
        if bottom2(2) < pts(i,2)
            bottom2 = pts(i,:);
        end
    end
    
    idx = 1;
    while idx <= size(pts, 1)
        if isequal(pts(idx,:), left2) || isequal(pts(idx,:), right2) || isequal(pts(idx,:), bottom2)
            pts(idx,:) = [];
        else
            idx = idx + 1;
        end
    end
    
    left1 = pts(1,:);
    right1 = pts(1,:);
    bottom1 = pts(1,:);
    for i=2:size(pts, 1)
        if left1(1) > pts(i,1)
            left1 = pts(i,:);
        end
        if right1(1) < pts(i,1)
            right1 = pts(i,:);
        end
        if bottom1(2) < pts(i,2)
            bottom1 = pts(i,:);
        end
    end
    
    idx = 1;
    while idx <= size(pts, 1)
        if isequal(pts(idx,:), left1) || isequal(pts(idx,:), right1) || isequal(pts(idx,:), bottom1)
            pts(idx,:) = [];
        else
            idx = idx + 1;
        end
    end
    
    middleC = pts(1,:);
    
    %normalize point
    %left
    left3 = (left1 - middleC) * (middleC(1) - 1) / abs(left1(1) - middleC(1) + 1) + middleC;
    left3(1) = max(min(left3(1), x), 1);
    left3(2) = max(min(left3(2), y), 1);
    
    %right
    right3 = (right1 - middleC) * (x - middleC(1) + 1) / abs(right1(1) - middleC(1) + 1) + middleC;
    right3(1) = max(min(right3(1), x), 1);
    right3(2) = max(min(right3(2), y), 1);
    
    %bottom
    bottom3 = (bottom1 - middleC) * (y - middleC(2) + 1) / abs(bottom1(2) - middleC(2) + 1) + middleC;
    bottom3(1) = max(min(bottom3(1), x), 1);
    bottom3(2) = max(min(bottom3(2), y), 1);
    
    %top point
    midLR = (right3 + left3) / 2;
    LRcor = midLR .* 2 - middleC;
    LRcor(1) = max(min(LRcor(1), x), 1);
    LRcor(2) = max(min(LRcor(2), y), 1);
    
    %bottom left point and bottom right point
    LBcor = left3 - middleC + bottom3;
    LBcor(1) = max(min(LBcor(1), x), 1);
    LBcor(2) = max(min(LBcor(2), y), 1);
    RBcor = right3 - middleC + bottom3;
    RBcor(1) = max(min(RBcor(1), x), 1);
    RBcor(2) = max(min(RBcor(2), y), 1);
    
    linesX = [LRcor(1) left3(1) LRcor(1) right3(1) middleC(1) left3(1)...
        middleC(1) right3(1) middleC(1) bottom3(1) RBcor(1) right3(1)...
        RBcor(1) bottom3(1) LBcor(1) left3(1) LBcor(1) bottom3(1)];
    linesY = [LRcor(2) left3(2) LRcor(2) right3(2) middleC(2) left3(2)...
        middleC(2) right3(2) middleC(2) bottom3(2) RBcor(2) right3(2)...
        RBcor(2) bottom3(2) LBcor(2) left3(2) LBcor(2) bottom3(2)];
    imgLines.x = linesX;
    imgLines.y = linesY;
%     figure;imshow(rubik);hold on; %----------------------------------------------------------------------------------
%     plot(imgLines.x, imgLines.y, 'bo',...
%         'LineWidth',4,...
%         'MarkerSize',20,...
%         'MarkerEdgeColor','b',...
%         'MarkerFaceColor',[0.5,0.5,0.5]);
%     line(imgLines.x, imgLines.y,...
%         'LineWidth',4,...
%         'MarkerSize',20,...
%         'MarkerEdgeColor','b',...
%         'MarkerFaceColor',[0.5,0.5,0.5]);
%     hold off;
    
    %mask side by side
    maskTop = zeros([x, y]);
    maskTop(round(LRcor(2)), round(LRcor(1))) = 1;
    maskTop(round(left3(2)), round(left3(1))) = 1;
    maskTop(round(right3(2)), round(right3(1))) = 1;
    maskTop(round(middleC(2)), round(middleC(1))) = 1;
    maskTop = bwconvhull(maskTop);
    maskLeft = zeros([x, y]);
    maskLeft(round(LBcor(2)), round(LBcor(1))) = 1;
    maskLeft(round(left3(2)), round(left3(1))) = 1;
    maskLeft(round(bottom3(2)), round(bottom3(1))) = 1;
    maskLeft(round(middleC(2)), round(middleC(1))) = 1;
    maskLeft = bwconvhull(maskLeft);
    maskRight = zeros([x, y]);
    maskRight(round(RBcor(2)), round(RBcor(1))) = 1;
    maskRight(round(bottom3(2)), round(bottom3(1))) = 1;
    maskRight(round(right3(2)), round(right3(1))) = 1;
    maskRight(round(middleC(2)), round(middleC(1))) = 1;
    maskRight = bwconvhull(maskRight);
    
    Top = rubik .* repmat(maskTop, [1,1,3]);
    Left = rubik .* repmat(maskLeft, [1,1,3]);
    Right = rubik .* repmat(maskRight, [1,1,3]);
    
%     figure;imshow(Top);
    
    %image projection
    %left
    mattL1 = [
        LBcor(1) bottom3(1) middleC(1) left3(1);
        LBcor(2) bottom3(2) middleC(2) left3(2)
        ];
    mattL2 = [
        1 x x 1;
        y y 1 1
        ];
    tform = maketform('projective', mattL1', mattL2')
    tform = projective2d(tform.tdata.T);
    Left = imwarp(Left, tform, 'nearest');
    LeftGray = rgb2gray(Left);
    LeftBw = LeftGray > 0.01;
    allEl = bwconvhull(LeftBw);
    bound = regionprops(allEl, 'BoundingBox');
    Left = imcrop(Left, bound(1).BoundingBox);
    Left = imresize(Left, [x y]);
      figure;imshow(Left);
    
    %small projection correction
    LeftGray = rgb2hsv(Left);
    LeftGray = LeftGray(:,:,3) > 0.5;
    correctPoint = zeros(2);
    for i=1:y
        for j=1:i
            xn = j;
            yn = y - i + j;
            if LeftGray(yn, xn) > 0.5
                correctPoint = [xn, yn];
                break;
            end
        end
        if correctPoint(1) > 0 && correctPoint(2) > 0
            break;
        end
    end
    mattL1 = [
        correctPoint(1) x x 1;
        correctPoint(2) y 1 1
        ];
    mattL2 = [
        1 x x 1;
        y y 1 1
        ];
    tform = maketform('projective', mattL1', mattL2');
    tform = projective2d(tform.tdata.T);
    Left = imwarp(Left, tform, 'nearest');
    LeftGray = rgb2gray(Left);
    LeftBw = LeftGray > 0.01;
    allEl = bwconvhull(LeftBw);
    bound = regionprops(allEl, 'BoundingBox');
    Left = imcrop(Left, bound(1).BoundingBox);
    Left = imresize(Left, [x y]);
    
    figure;imshow(Left);
    
    %right
    mattR1 = [
        RBcor(1) bottom3(1) middleC(1) right3(1);
        RBcor(2) bottom3(2) middleC(2) right3(2)
        ];
    mattR2 = [
        x 1 1 x;
        y y 1 1
        ];
    tform = maketform('projective', mattR1', mattR2');
    tform = projective2d(tform.tdata.T);
    Right = imwarp(Right, tform, 'nearest');
    RightGray = rgb2gray(Right);
    RightBw = RightGray > 0.01;
    allEl = bwconvhull(RightBw);
    bound = regionprops(allEl, 'BoundingBox');
    Right = imcrop(Right, bound(1).BoundingBox);
    Right = imresize(Right, [x y]);
    
    %small projection correction
    RightGray = rgb2hsv(Right);
    RightGray = RightGray(:,:,3) > 0.5;
    correctPoint = zeros(2);
    for i=1:x
        for j=1:i
            xn = x - j;
            yn = x - i + j;
            if RightGray(yn, xn) > 0.5
                correctPoint = [xn, yn];
                break;
            end
        end
        if correctPoint(1) > 0 && correctPoint(2) > 0
            break;
        end
    end
    mattR1 = [
        1 correctPoint(1) x 1;
        y correctPoint(2) 1 1
        ];
    mattR2 = [
        1 x x 1;
        y y 1 1
        ];
    tform = maketform('projective', mattR1', mattR2');
    tform = projective2d(tform.tdata.T);
    Right = imwarp(Right, tform, 'nearest');
    RightGray = rgb2gray(Right);
    RightBw = RightGray > 0.01;
    allEl = bwconvhull(RightBw);
    bound = regionprops(allEl, 'BoundingBox');
    Right = imcrop(Right, bound(1).BoundingBox);
    Right = imresize(Right, [x y]);
    
    %top
    mattT1 = [
        LRcor(1) left3(1) middleC(1) right3(1);
        LRcor(2) left3(2) middleC(2) right3(2)
        ];
    mattT2 = [
        1 1 x x;
        1 y y 1
        ];
    tform = maketform('projective', mattT1', mattT2');
    tform = projective2d(tform.tdata.T);
    Top = imwarp(Top, tform, 'nearest');
    TopGray = rgb2gray(Top);
    TopBw = TopGray > 0.01;
    allEl = bwconvhull(TopBw);
    bound = regionprops(allEl, 'BoundingBox');
    Top = imcrop(Top, bound(1).BoundingBox);
    Top = imresize(Top, [x y]);
    
    projectedImg = [
        Top zeros([x y 3]);
        Left Right
        ];
    
    %color
    pixSize = floor(editSize / 6);
    %top
    colorTop = zeros([editSize/2 3]);
    xs = x / 3;
    ys = y / 3;
    for i=1:3
        for j=1:3
            cell = imcrop(Top, [xs * (i - 1) ys * (j - 1) xs ys]);
            
            stl = strel('square', 10);
            cell = imdilate(cell, stl);
            
            [imnd, map] = rgb2ind(cell,3,'nodither');
            cell = ind2rgb(imnd, map);
            
            hsv = rgb2hsv(cell);
            h = hsv(:,:,1);
            s = hsv(:,:,2) > 0.5;
            hsv = ones([1 1 3]);
            hsv(1,1,1) = mode(h(:));
            hsv(1,1,2) = mode(s(:));
            
            o1 = imresize(hsv2rgb(hsv), pixSize-[2 2], 'nearest');
            colorTop(((j-1)*pixSize(1)+2):(j*pixSize(1)-1), ((i-1)*pixSize(2)+2):(i*pixSize(2)-1), :) = o1;
        end
    end
    
    %left
    colorLeft = zeros([editSize/2 3]);
    xs = x / 3;
    ys = y / 3;
    for i=1:3
        for j=1:3
            cell = imcrop(Left, [xs * (i - 1) ys * (j - 1) xs ys]);
            
            stl = strel('square', 10);
            cell = imdilate(cell, stl);
            
            [imnd, map] = rgb2ind(cell,3,'nodither');
            cell = ind2rgb(imnd, map);
            
            hsv = rgb2hsv(cell);
            h = hsv(:,:,1);
            s = hsv(:,:,2) > 0.5;
            hsv = ones([1 1 3]);
            hsv(1,1,1) = mode(h(:));
            hsv(1,1,2) = mode(s(:));
            
            o1 = imresize(hsv2rgb(hsv), pixSize-[2 2], 'nearest');
            colorLeft(((j-1)*pixSize(1)+2):(j*pixSize(1)-1), ((i-1)*pixSize(2)+2):(i*pixSize(2)-1), :) = o1;
        end
    end
    
    %right
    colorRight = zeros([editSize/2 3]);
    xs = x / 3;
    ys = y / 3;
    for i=1:3
        for j=1:3
            cell = imcrop(Right, [xs * (i - 1) ys * (j - 1) xs ys]);
            
            stl = strel('square', 20);
            cell = imdilate(cell, stl);
            
            [imnd, map] = rgb2ind(cell,3,'nodither');
            cell = ind2rgb(imnd, map);
            
            hsv = rgb2hsv(cell);
            h = hsv(:,:,1);
            s = hsv(:,:,2) > 0.5;
            hsv = ones([1 1 3]);
            hsv(1,1,1) = mode(h(:));
            hsv(1,1,2) = mode(s(:));
            
            o1 = imresize(hsv2rgb(hsv), pixSize-[2 2], 'nearest');
            colorRight(((j-1)*pixSize(1)+2):(j*pixSize(1)-1), ((i-1)*pixSize(2)+2):(i*pixSize(2)-1), :) = o1;
        end
    end
    colorTop = imresize(colorTop, editSize, 'nearest');
    colorLeft = imresize(colorLeft, editSize, 'nearest');
    colorRight = imresize(colorRight, editSize, 'nearest');
    projectedColor = [colorTop zeros([editSize, 3]);...
        colorLeft colorRight];
    
    faceTop.x = [1 1; -1 -1];
    faceTop.y = [1 -1; 1 -1];
    faceTop.z = [1 1; 1 1];
    faceTop.img = colorTop;
    
    faceLeft.x = [-1 1; -1 1];
    faceLeft.y = [-1 -1; -1 -1];
    faceLeft.z = [1 1; -1 -1];
    faceLeft.img = colorRight;
    
    faceRight.x = [-1 -1; -1 -1];
    faceRight.y = [1 -1; 1 -1];
    faceRight.z = [1 1; -1 -1];
    faceRight.img = colorLeft;
    
    rebuildColor.Top = faceTop;
    rebuildColor.Left = faceLeft;
    rebuildColor.Right = faceRight;
    
%     figure;imshow(imgLines); % --------------------------------------------------------------
%     figure;imshow(projectedImg); % --------------------------------------------------------------
%     figure;imshow(projectedColor); % --------------------------------------------------------------
    
%     figure;
%     surf(faceTop.x, faceTop.y, faceTop.z, faceTop.img, 'facecolor', 'texturemap', 'edgecolor', 'none', 'FaceAlpha',0.8);hold on;
%     surf(faceLeft.x, faceLeft.y, faceLeft.z, faceLeft.img, 'facecolor', 'texturemap', 'edgecolor', 'none', 'FaceAlpha',0.8);hold on;
%     surf(faceRight.x, faceRight.y, faceRight.z, faceRight.img, 'facecolor', 'texturemap', 'edgecolor', 'none', 'FaceAlpha',0.8);hold off;
%     xlim([-3 1]);
%     ylim([-3 1]);
%     zlim([-1 3]);
    
    %figure;imshow(projectedColor);
    %figure;imshow(projectedImg);
    %figure;imshow(Top);
    %figure;imshow(colorTop);
    %figure;imshow(Left);
    %figure;imshow(colorLeft);
    %figure;imshow(Right);
    %figure;imshow(colorRight);
    %rebuild rubik
    %prjTop = 
end