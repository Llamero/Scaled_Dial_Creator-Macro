createDial = true;
deg = 240; //Total rotation angle
radius = 300; //Internal radius of scale
majorTick = 20; //Total number of major tick mark divisions
minorTick = 100; //Total number of minor tick mark divisions
major = 75; //Length in pixels of major tick mark
minor = 25; //Length in pixels of minor tick mark
majorWidth = 4; //Final width of major tick mark (stdev)
minorWidth = 2; //Final width of minor tick mark (stdev)
addLabel = true; //Boolean - if true add label to major tick marks
nLabel = 10; //Total number of font labels to add
labelCCW = 0; //Most counter-clockwise label value
labelCW = 1; //Most clockwise label value
nDec = 1; //Number of decimal places in label (NOTE: negtive value = # of decimal places in scientific notation)
fontSize = 40; //Sets font size for labels
labelOffset = 10; //Gap length in pixels between font and major tick mark
labelFooter = ""; //String added to end of numerical label
smooth = 1; //Final smoothing for antialiasing of tick marks
aspectRatio = 0.98; //Ratio of vertical / horizontal label radius - used to bring labels closer to marks
draft = 0; //Counter of the current dial draft

while(createDial){
	draft++;
	Dialog.create("Settings for dial scale creator");
	Dialog.addMessage("Tick mark settings:"); 
	Dialog.addNumber("Total rotation angle (degrees)", deg);
	Dialog.addNumber("Internal radius of scale in pixels (i.e. image resolution)", radius);
	Dialog.addNumber("Number of major tick mark divisions", majorTick);
	Dialog.addNumber("Number of minor tick mark divisions", minorTick);
	Dialog.addNumber("Length of major tick mark (pixels)", major);
	Dialog.addNumber("Length of minor tick mark (pixels)", minor);
	Dialog.addNumber("Width of major tick mark (pixels)", majorWidth);
	Dialog.addNumber("Width of minor tick mark (pixels)", minorWidth);
	Dialog.addMessage("Label Settings:"); 
	Dialog.addCheckbox("Add labels to scale", addLabel) 
	Dialog.addNumber("Number of label divisions", nLabel);
	Dialog.addNumber("Most counter-clockwise label value", labelCCW);
	Dialog.addNumber("Most clockwise label value", labelCW);
	Dialog.addNumber("Number of decimal places in label", nDec);
	Dialog.addNumber("Label font size", fontSize);
	Dialog.addNumber("Space between major tick mark and label (pixels)", labelOffset);
	Dialog.addString("Text to add after label (such as \"%\")", labelFooter);
	Dialog.addMessage("Advanced Settings:"); 
	Dialog.addNumber("Label radius aspect ratio (vertical/horizontal)", aspectRatio);
	Dialog.show();
	
	deg = Dialog.getNumber(); //Total rotation angle
	radius = Dialog.getNumber(); //Internal radius of scale
	majorTick = Dialog.getNumber(); //Total number of major tick mark divisions
	minorTick = Dialog.getNumber(); //Total number of minor tick mark divisions
	major = Dialog.getNumber(); //Length in pixels of major tick mark
	minor = Dialog.getNumber(); //Length in pixels of minor tick mark
	majorWidth = Dialog.getNumber(); //Final width of major tick mark (stdev)
	minorWidth = Dialog.getNumber(); //Final width of minor tick mark (stdev)
	addLabel = Dialog.getCheckbox(); //Boolean - if true add label to major tick marks
	nLabel = Dialog.getNumber(); //Total number of font labels to add
	labelCCW = Dialog.getNumber(); //Most counter-clockwise label value
	labelCW = Dialog.getNumber(); //Most clockwise label value
	nDec = Dialog.getNumber(); //Number of decimal places in label (NOTE: negtive value = # of decimal places in scientific notation)
	fontSize = Dialog.getNumber(); //Sets font size for labels
	labelOffset = Dialog.getNumber(); //Gap length in pixels between font and major tick mark
	labelFooter = Dialog.getString(); //String added to end of numerical label
	aspectRatio = Dialog.getNumber(); //Ratio of vertical / horizontal label radius - used to bring labels closer to marks
	
	setBatchMode(true);
	imageWidth = round(2.1*(radius+major));
	newImage("Draft " + draft, "8-bit white", imageWidth, imageWidth, 1);
	
	//Draw tick marks
	drawTickMarks("Draft " + draft, minorWidth, minor, minorTick);//Adjust width and length of minor tick marks
	drawTickMarks("Draft " + draft, majorWidth, major, majorTick);//Adjust width and length of major tick marks

	
	//Add labels if desired
	if(addLabel) drawLabels("Draft " + draft);

	setBatchMode("exit and display");
	createDial = getBoolean("Would you like to further adjust the settings and redraw the dial?");

}

function drawTickMarks(i, width, length, nTick){

	selectWindow(i);
	setLineWidth(width);
	
	rad = deg*PI/180; //Convert total angle to radians
	startAngle = PI - rad/2; //0 points down
	
	//Draw labels at desired intervals
	for(a=0; a<=nTick; a++){
		currentAngle = startAngle + a*(rad/nTick);
		x1 = round(imageWidth/2 + radius * sin(currentAngle));
		y1 = round(imageWidth/2 + radius * cos(currentAngle));
		x2 = round(imageWidth/2 + (radius + length) * sin(currentAngle));
		y2 = round(imageWidth/2 + (radius + length) * cos(currentAngle));
		makeLine(x1, y1, x2, y2);
		run("Add Selection...", "width=" + width + " stroke=black");
		run("Select None");
	}
	run("Flatten");	//Using flatten rather than "drawLine" creates antialiased lines
	close(i);
	selectWindow(i + "-1");
	rename(i);
}

function drawLabels(i){	
	selectWindow(i);
	
	//find the largest label text box
	setFont("SansSerif", fontSize, "antialiased");
	labelStep = (labelCW-labelCCW)/nLabel;
	labelMax = 0;
	for(a=0; a<=nLabel; a++){
		currentLabel = "" + d2s(labelCCW + labelStep*a, nDec) + labelFooter;
		labelWidth = getStringWidth(currentLabel);
		if(labelWidth > labelMax) labelMax = labelWidth;
	}
	
	//Resize image to fit labels
	maxWidth = 2*(radius + major + labelMax + labelOffset);
	setBackgroundColor(255, 255, 255);
	run("Canvas Size...", "width=" + maxWidth + " height=" + maxWidth + " position=Center");
	
	rad = deg*PI/180; //Convert total angle to radians
	startAngle = PI - rad/2; //0 points down
	labelRadius = radius + major + labelOffset + labelMax/2; //distance to center of label

	//Draw labels at desired intervals
	for(a=0; a<=nLabel; a++){
		currentLabel = "" + d2s(labelCW - labelStep*a, nDec) + labelFooter;
		currentAngle = startAngle + a*(rad/nLabel);
		adjustedRadius = labelRadius*((1-aspectRatio)*abs(sin(currentAngle))+aspectRatio); //Reduce radius of vertical labels if desired
		xCen = round(maxWidth/2 + adjustedRadius * sin(currentAngle));
		yCen = round(maxWidth/2 + adjustedRadius * cos(currentAngle));
		labelWidth = getStringWidth(currentLabel);
		xLabel = xCen-labelWidth/2;
		yLabel = yCen+fontSize*0.6;
		drawString(currentLabel, xLabel, yLabel);	
	}
}


