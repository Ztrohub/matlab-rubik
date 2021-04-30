size = [180 180];
img = cropRubik('gambar1.jpg', size);

img = histeq(img);
% img = img ./ 16;
% image(img);
figure;imshow(img);

sizec = round(size / 3);
img_potongan = zeros(3, 3);

%   1      2      3      4      5      6
% merah, orange, kuning, hijau, biru, putih
% hue (0, 40, 60, 120, 200), saturation 0%

figure;
for i=1:3
    for j=1:3
        rect = [(j-1)*sizec(2), (i-1)*sizec(1), sizec(2), sizec(1)];
        cropped = imcrop(img, rect);
        
        domR = mean2(cropped(:,:,1));
        domG = mean2(cropped(:,:,2));
        domB = mean2(cropped(:,:,3));
        
        temp = zeros(1,1,3);
        temp(1,1,1) = domR;
        temp(1,1,2) = domG;
        temp(1,1,3) = domB;
        
        hsv = rgb2hsv(temp);
        hsv(1,1,2) = round(hsv(1,1,2));
        hsv(1,1,3) = 1;
        
        subplot(3, 3, 3*(i-1)+j);
        imshow(temp);

%         imshow(imcrop(img, rect));
    end
end

