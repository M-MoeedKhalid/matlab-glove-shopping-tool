

%% Hand length measuring tool

%% Muhammad Moeed Khalid 
%% SP15-BCS-146


%% Ali raza
%% SP15-BCS-146










clear all;
clc;
I = imread('TestImage.png');

[Hand,ColorHand] = SkinMask(I);
Hand = bwareafilt(Hand, 1);
figure,imshow(Hand);
Hand=imfill(Hand,'holes');
    stats = regionprops(Hand, 'BoundingBox', 'Area' );
    for i= 1 : length(stats)
        Areai(i)= stats(i).Area;
    end
    biggestBlob= find(Areai==max(Areai)); 
    sbb=stats(biggestBlob);
   
%create a structuring Element of radius 50
se=strel('disk',50,0);
opened= imopen(Hand,se);
% 
figure,subplot(2,2,1),
imshow(Hand);
title('Segmented Image','FontSize', 24)
subplot(2,2,2),
imshow(opened);
title('Opened Image','FontSize', 24)
% 
% %Subtract the opened image from the original one
fingers=logical(Hand-opened);
subplot(2,2,3),
imshow(fingers);
title('Segmented-OpenedImage','FontSize', 24)

% %Extract the largest blob i.e the Thumb
joinedfingers=imdilate(fingers,strel('disk',10,0));
joinedfingers=bwareafilt(joinedfingers,1);
fingers=fingers-joinedfingers;
fingers=max(0,fingers);
thumb=bwareafilt(logical(fingers),1);
subplot(2,2,4),
imshow(thumb);
title('Morphological Operations','FontSize', 24)



    stats = regionprops(thumb, 'BoundingBox', 'Area' );
    for i= 1 : length(stats)
        Areai(i)= stats(i).Area;
    end
    biggestBlob= find(Areai==max(Areai)); 
    sbb2=stats(biggestBlob);


width= (sbb2.BoundingBox(1)+sbb2.BoundingBox(3))-sbb.BoundingBox(1);
width=(width*0.2)+width;

format long g;
format compact;
fontSize = 20;
positionVector2 = [0.1, 0.2, 0.7, 0.7];
% figureHandle = figure;
figure,subplot('Position',positionVector2);
imshow(I, []),
rectangle('Position',[sbb.BoundingBox(1),...
                      sbb.BoundingBox(2),...
                      width,...
                      sbb.BoundingBox(4)], 'EdgeColor','r','LineWidth',2 );

axis on;
title('Your Input Image','FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'name','Detecting Hand','numbertitle','off')

message = sprintf('Please Select the A4 paper in the image.');
reply = questdlg(message, 'Calibrate spatially', 'OK', 'Cancel', 'OK');
if strcmpi(reply, 'Cancel')
	return;
end


try
	success = false;
	instructions = sprintf('Left click on the left edge of the A4 paper.\nRight click on the right edge of the A4 paper');
	title(instructions);

	[cx, cy, rgbValues, xi,yi] = improfile(1000);
	distanceInPixels = sqrt( (xi(2)-xi(1)).^2 + (yi(2)-yi(1)).^2);

	% Plot the line.
	hold on;
	LineType = plot(xi, yi, 'b-', 'LineWidth', 2);

	calibration.distanceInUnits = 29.7;
	calibration.distancePerPixel = calibration.distanceInUnits / distanceInPixels;
	success = true;
	
	message = sprintf('The length of your hand is %.2f centimeters',(width * calibration.distancePerPixel));
	uiwait(msgbox(message));
catch ME
	errorMessage = sprintf('Something Went Wrong');
	fprintf(1, '%s\n', errorMessage);
end

return;