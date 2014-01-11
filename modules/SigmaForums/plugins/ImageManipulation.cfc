<cfcomponent name="ImageManipulation" hint="Image manipulation functions." extends="coldbox.system.plugin" output="false" cache="false">

	<cfproperty name="imageObj" type="any" />

	<cfset variables.instance = StructNew() />

	<cffunction name="init" access="public" returntype="ImageManipulation" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("ImageManipulation")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("Image manipulation functions.")>
		<cfreturn this>
	</cffunction>

	<cffunction name="setImage" access="public" output="false" returntype="any">
		<cfargument name="imageObj" type="any" required="true" hint="A Image Object, File, or Binary" />
		<cfset variables.instance.imageObj = arguments.imageObj />
		<cfreturn this />
	</cffunction>
	<cffunction name="getImage" access="public" output="false" returntype="any">
		<cfreturn variables.instance.imageObj />
	</cffunction>
	<cffunction name="setObjectID" access="public" output="false" returntype="any">
		<cfargument name="objectid" type="string" required="true" />
		<cfset variables.instance.objectid = arguments.objectid />
		<cfreturn this />
	</cffunction>
	<cffunction name="getObjectID" access="public" output="false" returntype="string">
		<cfreturn variables.instance.objectid />
	</cffunction>


	<cffunction name="findImage" access="public" output="false" returntype="any" hint="Finds and returns an image object">
		<cfargument name="image" type="any" required="true" hint="A Image Object, File, or Binary" />
		<cfif IsImage(arguments.image)>
			<cfreturn arguments.image />
		<cfelseif IsBinary(arguments.image)>
			<cfreturn ImageReadBase64(ToBase64(arguments.image)) />
		<cfelseif IsImageFile(arguments.image)>
			<cfreturn ImageRead(arguments.image) />
		<cfelseif IsImageFile(ExpandPath(arguments.image))>
			<cfreturn ImageRead(ExpandPath(arguments.image)) />
		<cfelse>
			<cftry>
				<cfreturn ImageNew(arguments.image) />
				<cfcatch></cfcatch>
			</cftry>
			<cffile action="append" file="imageerr.txt" output="#getObjectID()#" addnewline="true" />
			<cfthrow message="The value passed was not an image." />
		</cfif>
	</cffunction>


	<cffunction name="addWatermark" access="public" returntype="any" output="false" hint="Adds a watermark image over another image">
		<cfargument name="watermark" type="any" required="true" hint="The watermark image obj or file path." />
		<cfargument name="transparency" type="numeric" default="40" hint="The Transparency level to apply." />
		<cfargument name="interpolation" type="string" default="highestQuality" hint="The interpolation (quality) to use." />
		<cfargument name="x" type="numeric" required="false" hint="The X axis (length) position to place the watermark." />
		<cfargument name="y" type="numeric" required="false" hint="The Y axis (height) position to place the watermark." />
		<cfargument name="xOffset" type="numeric" default="10" hint="The X axis (length) to offset the watermark." />
		<cfargument name="yOffset" type="numeric" default="0" hint="The Y axis (length) to offset the watermark." />
		<cfargument name="withinWidth" type="numeric" default="3000" hint="Resize watermark if image width is smaller then this value." />
		<cfargument name="withinHeight" type="numeric" default="500" hint="Resize watermark if image hight is smaller then this value." />
		<cfscript>
			var LOCAL = {
				w=0,
				h=0,
				watermark = imageNew(findImage(arguments.watermark)),
				image = getImage()
			};

			if(not structKeyExists(arguments,'x')){arguments.x=LOCAL.image.width;};
			if(not structKeyExists(arguments,'y')){arguments.y=LOCAL.image.height;};

			LOCAL.w = (LOCAL.image.width/(len(arguments.withinWidth)-1));
			LOCAL.h = (LOCAL.image.width-LOCAL.watermark.height)/10-(LOCAL.watermark.width/LOCAL.watermark.height)-(LOCAL.watermark.width/LOCAL.watermark.height)-10;
			//special TrueStreets width/height rules
			if(LOCAL.image.width lt arguments.withinWidth) {
				ImageResize(LOCAL.watermark,LOCAL.w,LOCAL.watermark.height,arguments.interpolation);
			};
			
			if(LOCAL.image.height lt arguments.withinHeight) {
				ImageResize(LOCAL.watermark,LOCAL.w,LOCAL.h,arguments.interpolation);
			};

			ImageSetDrawingTransparency(LOCAL.image, arguments.transparency);
			ImagePaste(LOCAL.image,LOCAL.watermark,(arguments.x-arguments.xOffset)-LOCAL.watermark.width,(arguments.y-arguments.yOffset)-LOCAL.watermark.height);

			setImage(LOCAL.image);
			return this;
		</cfscript>
	</cffunction>
	

	<cffunction name="roundedCornersMask" returntype="any" access="public" output="false" hint="Takes an image source and rounds the corners.">
		<cfargument name="arcWidth" type="numeric" default="25" hint="horizontal diameter of the rounded corners." />
		<cfargument name="arcHeight" type="numeric" default="25" hint="vertical diameter of the rounded corners." />
		<cfscript>
			var Local = structNew();
			// cfSearching: create required java objects
				Local.Color = createObject("java", "java.awt.Color");
				Local.AlphaComposite = createObject("java", "java.awt.AlphaComposite");
				Local.sourceImage = ImageGetBufferedImage(getImage());
				Local.width  = Local.sourceImage.getWidth();
				Local.height = Local.sourceImage.getHeight();
				Local.BufferedImage = createObject("java", "java.awt.image.BufferedImage");
				Local.Mask = Local.BufferedImage.init(Local.width,Local.height,Local.BufferedImage.TYPE_INT_ARGB);
				Local.graphics = Local.Mask.createGraphics();
				Local.RenderingHints = createObject("java", "java.awt.RenderingHints");
				Local.graphics.setRenderingHint(Local.RenderingHints.KEY_ANTIALIASING,Local.RenderingHints.VALUE_ANTIALIAS_ON);
				Local.graphics.setColor( Local.Color.WHITE );
				Local.graphics.fillRoundRect(0,0,Local.width,Local.height,arguments.arcWidth,arguments.arcHeight);
				Local.graphics.setComposite( Local.AlphaComposite.SrcIn );
				Local.graphics.drawImage(Local.sourceImage,0,0,javacast("null",""));
				Local.graphics.dispose();
				setImage(ImageNew(Local.Mask));
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="detailedAspectCrop" access="public" returntype="any" output="false">
		<cfargument name="x" type="numeric" required="true" hint="X position to start crop." />
		<cfargument name="y" type="numeric" required="true" hint="Y position to start crop." />
		<cfargument name="width" type="numeric" required="true">
		<cfargument name="height" type="numeric" required="true" />
		<cfargument name="newwidth" type="numeric" required="true" hint="The max width in pixles of the resulting image." />
		<cfargument name="newheight" type="numeric" required="true" hint="The max height in pixles of the resulting image." />
		<cfargument name="interpolation" type="string" default="HighestQuality" hint="resampling method name (Quality)." />
		<cfargument name="blurFactor" type="numeric" default="1" hint="Blur Factory to invoke on image." />
		<cfset ImageCrop(getImage(),arguments.x,arguments.y,arguments.width,arguments.height) />
		<cfset ImageResize(getImage(),arguments.newwidth,arguments.newheight,arguments.interpolation,arguments.blurFactor) />
		<cfreturn this />
	</cffunction>

	<cffunction name="aspectCrop" access="public" returntype="any" output="true" hint="">
		<cfargument name="cropwidth" type="numeric" required="true" hint="The pixel width of the final cropped image"/>
		<cfargument name="cropheight" type="numeric" required="true" hint="The pixel height of the final cropped image"/>
		<cfargument name="position" type="string" required="true" default="center" hint="The y origin of the crop area." />
		<cfset var nPercent = "" />
		<cfset var wPercent = "" />
		<cfset var hPercent = "" />
		<cfset var px = "" />
		<cfset var ycrop = "" />
		<cfset var xcrop = "" />

			<cfset wPercent = arguments.cropwidth / getImage().width>
			<cfset hPercent = arguments.cropheight / getImage().height>
			<cfif wPercent gt hPercent>
				<cfset nPercent = wPercent>
				<cfset px = getImage().width * nPercent + 1>
				<cfset ycrop = ((getImage().height - arguments.cropheight)/2)>
				<cfset imageResize(getImage(),px,"",'highestQuality') />
			<cfelse>
				<cfset nPercent = hPercent>
				<cfset px = getImage().height * nPercent + 1>
				<cfset xcrop = ((getImage().width - arguments.cropwidth)/2)>
				<cfset imageResize(getImage(),"",px,'highestQuality') />
			</cfif>
			<cfif listfindnocase("topleft,left,bottomleft", arguments.position)>
				<cfset xcrop = 0>
			<cfelseif listfindnocase("topcenter,center,bottomcenter", arguments.position)>
				<cfset xcrop = (getImage().width - arguments.cropwidth)/2>
			<cfelseif listfindnocase("topright,right,bottomright", arguments.position)>
				<cfset xcrop = getImage().width - arguments.cropwidth>
			<cfelse>
				<cfset xcrop = (getImage().width - arguments.cropwidth)/2>
			</cfif>
			<cfif listfindnocase("topleft,topcenter,topright", arguments.position)>
				<cfset ycrop = 0>
			<cfelseif listfindnocase("left,center,right", arguments.position)>
				<cfset ycrop = (getImage().height - arguments.cropheight)/2>
			<cfelseif listfindnocase("bottomleft,bottomcenter,bottomright", arguments.position)>
				<cfset ycrop = getImage().height - arguments.cropheight>
			<cfelse>
				<cfset ycrop = (getImage().height - arguments.cropheight)/2>
			</cfif>
			<cfset ImageCrop(getImage(),xcrop,ycrop,arguments.cropwidth,arguments.cropheight)>
		<cfreturn this />
	</cffunction>

	<cffunction name="makeShadow" access="public" returntype="any" output="false" hint="Adds a drop shadow with the given offset, blur, and color properties. The shadow increases the size of the image canvas.">
		<cfargument name="offset" type="numeric" required="true" hint="The pixel offset of the drop shadow (out and down)."/>
		<cfargument name="blurRadius" type="numeric" default="0" hint="The pixel amount by which the shadow should be blurred."/>
		<cfargument name="shadowcol" type="string" required="false" default="145,145,145" hint="The color of the drop shadow color (can be R,G,B, Hex, or named colors)."/>
		<cfargument name="maintainSize" type="boolean" default="false" hint="Toggle wether to keep origonal size." />
		<cfargument name="roundedCorners" type="boolean" default="false" />
		<cfscript>
			var iInfo = imageInfo(ImageNew(getImage()));
			var newWidth = iInfo.width+(2*arguments.offset);
			var newHeight = iInfo.height+(2*arguments.offset);
			var shadowImage = imageNew("",newWidth,newHeight,"argb");
				imageSetAntialiasing(shadowImage,"on");
				imageSetAntialiasing(getImage(),"on");
				imageSetDrawingColor(shadowImage,arguments.shadowcol);
				imageDrawRect(shadowImage,arguments.offset,arguments.offset,iInfo.width,iInfo.height,true);
				if(arguments.blurRadius gte 3){imageBlur(shadowImage,arguments.blurRadius);};
				imagePaste(shadowImage,getImage(),0,0);
				if(arguments.maintainSize){imageResize(shadowImage,iInfo.width,iInfo.height);};
				setImage(shadowImage);
				if(arguments.roundedCorners){roundedCornersMask();};
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="SimpleBottomReflect" access="public" returntype="any" output="false" hint="Adds a mirror effect below the image.">
		<cfargument name="reflectionHeight" type="numeric" default="35" hint="Height (in pixels) the reflected image will be.">
		<cfargument name="antialiasing" type="boolean" default="true" hint="Enable/disable antialiasing.">
		<cfargument name="backgroundColor" type="string" default="white" hint="Background color to use behind the reflection.">
		<cfargument name="opacity" type="numeric" default="65" hint="Set the opacity percentage (choose between 0 and 100)">
		<cfscript>
			var oStrInfo = ImageInfo(getImage());
			var strInfo = ImageInfo(getImage());
			var imgNew = ImageNew('',strInfo.width, strInfo.height+arguments.reflectionHeight,'argb');
			var imgPart = "";
			
				// Make sure the reflection hieght is not greater than the height of the image
				if(arguments.reflectionHeight gt strInfo.height){
					arguments.reflectionHeight = strInfo.height;
				};

				if(arguments.antialiasing){
					imageSetAntialiasing(imgNew,"on");
				};
				imageFlip(getImage(), "vertical");


				imgPart = ImageCopy(getImage(),0,0,strInfo.width,arguments.reflectionHeight);

				SimpleGradientMask(imgPart,arguments.backgroundColor);
				ImageFlip(getImage(), "vertical");
				ImagePaste(imgNew, getImage(), 0, 0);
				ImageSetDrawingTransparency(imgNew, 100-opacity);
				ImagePaste(imgNew, imgPart, 0, strInfo.height);

				setImage(imgNew);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="SimpleGradientMask" access="public" returntype="any" output="false" hint="Adds a gradient mask to an image.">
		<cfargument name="Image" type="any" required="true" hint="ColdFusion image object.">
		<cfargument name="backgroundColor" type="string" default="white" hint="Background color to use behind the mask.">
		<cfargument name="antialiasing" type="boolean" default="true" hint="Enable/disable antialiasing.">
		<cfscript>
			var objImage = findImage(arguments.Image);
			var strInfo = ImageInfo(objImage);
			var iInc = 50/strInfo.height;
			var i = 0;
			if(arguments.antialiasing){imageSetAntialiasing(objImage,"on");}
			ImageFlip(objImage, "vertical");
			ImageSetDrawingColor(objImage, arguments.backgroundColor);
			for(i=0;i lte (strInfo.height-1);i++) {
				ImageSetDrawingTransparency(objImage, round(iInc*i*2));
				ImageDrawLine(objImage, 0, i, strInfo.width, i);
			};
			ImageFlip(objImage, "vertical");
			return objImage;
		</cfscript>
	</cffunction>

	<cffunction name="emboss" access="public" output="false" returntype="any" hint="I emboss the image.">
		<cfargument name="size" hint="I am the size of the edge to emboss." required="yes" type="numeric">
		<cfargument name="strength" hint="I am the strength of the function." required="yes" type="numeric">
		<cfset var kernelArray = ArrayNew(1) />	
		<cfset var embossAmount = int((round(arguments.size) * 2) + 1) />
		<cfset var row = 0 />
		<cfset var column = 0 />
		<cfset var q = 0 />

		<cfif arguments.size LTE 0><cfset arguments.size=1 /></cfif>
		<cfif arguments.strength LTE 0><cfset arguments.strength=1 /></cfif>
		
		<cfloop from="1" to="#evaluate(embossAmount*embossAmount)#" index="q">
			<cfif q MOD embossAmount IS 1>
				<cfset row = row + 1 />
			</cfif>
			<cfset column = ((q-1) MOD embossAmount) + 1 />
			
			<cfif row IS column AND row LT arguments.size + 1>
				<cfset ArrayAppend(kernelArray, -arguments.strength) />
			<cfelseif row GT arguments.size + 1 AND column GT arguments.size + 1 AND row IS column>
				<cfset ArrayAppend(kernelArray, 1) />
			<cfelseif row IS arguments.size + 1 AND column IS arguments.size + 1>
				<cfset ArrayAppend(kernelArray, arguments.strength) />
			<cfelse>
				<cfset ArrayAppend(kernelArray, 0.0) />
			</cfif>
		</cfloop>
		<cfset convolve(embossAmount, kernelArray) />
		<cfreturn this />
	</cffunction>

	<cffunction name="negate" access="public" output="false" returntype="any" hint="I invert the image colors.">
		<cfset adjustLevels(255, 0) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="lighten" access="public" output="false" returntype="any" hint="I lighten the image.">
		<cfargument name="percent" hint="I am the percent to lighten the image" required="yes" type="numeric">
		<cfscript>
			if(NOT(arguments.percent GTE 0 AND arguments.percent LTE 100)){arguments.percent=50;};
			arguments.percent=round(255*(arguments.percent/100));
			adjustLevels(arguments.percent, 255);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="darken" access="public" output="false" returntype="any" hint="I darken the image.">
		<cfargument name="percent" hint="I am the percent to darken the image" required="yes" type="numeric">
		<cfscript>
			if(NOT(arguments.percent GTE 0 AND arguments.percent LTE 100)){arguments.percent=50;};
			arguments.percent=255-round(255*(arguments.percent/100));
			adjustLevels(0, arguments.percent);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="adjustLevels" access="public" output="false" returntype="any" hint="I adjust the contrast levels in the image.">
		<cfargument name="low" hint="I am the low value.  I must be between 0 and 255" required="yes" type="numeric">
		<cfargument name="high" hint="I am the high value.  I must be between 0 and 255" required="yes" type="numeric">
		<cfscript>
			var ArrayObj = CreateObject("Java", "java.lang.reflect.Array");
			var Short = CreateObject("Java", "java.lang.Short");
			var ArrayType = Short.TYPE;
			var ShortArray = ArrayObj.newInstance(ArrayType, 256);
			var slope = (arguments.high - arguments.low) / 255;
			var x1 = 0;
			var y1 = arguments.low;
			var y = 0;
			var x = 0;
				if(arguments.low LT 0 OR arguments.low GT 255){arguments.low=round(arguments.low/2);};
				if(arguments.high LT 0 OR arguments.high GT 255){arguments.high=round(arguments.high/2);};

				for(x=0;x LTE 255;x++) {
					x = int(x);
					y = int(round((slope * (x - x1)) + y1));
					ArrayObj.setShort(ShortArray, Short.parseShort(JavaCast("string", x)), Short.parseShort(JavaCast("string", y)));
				};

				applyLookupTable(ShortArray);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="applyLookupTable" access="private" output="false" returntype="any" hint="I apply a lookup table to the image.">
		<cfargument name="lookupArray" hint="I am the array which populates the lookup table." required="yes" type="array" />
		<cfscript>
			var Image = ImageGetBufferedImage(getImage());
			var NewImage = createObject("java","java.awt.image.BufferedImage");
			var RenderingHints = CreateObject("Java","java.awt.RenderingHints");
			var LookupTable = CreateObject("Java","java.awt.image.ShortLookupTable");
			var LookupOp = CreateObject("Java","java.awt.image.LookupOp");
			var Color = createObject("java","java.awt.Color");
			var AlphaComposite = createObject("java","java.awt.AlphaComposite");
			var Mask = NewImage.init(Image.Width,Image.Height,Image.Type);
			var Graphics = Mask.createGraphics();
				Graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
				Graphics.setColor(Color.WHITE);
				Graphics.fillRect(0,0,Image.Width,Image.Height);
				Graphics.setComposite( AlphaComposite.SrcIn );
				Graphics.drawImage(Image,0,0,javacast("null",""));
				LookupTable.init(0,arguments.lookupArray);
				LookupOp.init(LookupTable,RenderingHints);
				LookupOp.filter(Image,NewImage);
				Graphics.dispose();
				setImage(ImageNew(Mask));
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="convolve" access="public" output="false" returntype="any" hint="I apply a convolve opperation.">
		<cfargument name="size" hint="I am the width and height of the kernel" required="yes" type="numeric">
		<cfargument name="kernelArray" hint="I am the kernel to apply to this image." required="yes" type="array">
		<cfscript>
			var Image = ImageGetBufferedImage(getImage());
			var ConvolvedImage = createComparableImage(Image);
			var Kernel = CreateObject("Java", "java.awt.image.Kernel");
			var ConvolveOp = CreateObject("Java", "java.awt.image.ConvolveOp");
				Kernel.init(arguments.size,arguments.size,arguments.kernelArray);
				ConvolveOp.init(Kernel);
				ConvolveOp.filter(Image, ConvolvedImage);
				setImage(ImageNew(ConvolvedImage));
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="createComparableImage" access="private" output="false" returntype="any">
		<cfargument name="Image" hint="I am the image to sample" required="yes" type="any" />
		<cfargument name="width" hint="I set the width of the image" required="no" default="0" type="numeric" />
		<cfargument name="height" hint="I set the height of the image" required="no" default="0" type="numeric" />
		<cfscript>
			var NewImage = CreateObject("java", "java.awt.image.BufferedImage");
			var type = iif(arguments.Image.Type, DE(arguments.Image.Type), DE(Image.TYPE_INT_ARGB));
			var ColorModel = arguments.Image.getColorModel();
				arguments.width = iif(arguments.width, DE(arguments.width), DE(arguments.Image.getWidth()));
				arguments.height = iif(arguments.height, DE(arguments.height), DE(arguments.Image.getHeight()));
				
				if(type IS 12 or type IS 13) {
					NewImage.init(arguments.width,arguments.height,type,ColorModel);
				} else {
					NewImage.init(arguments.width,arguments.height,type);
				};

			return NewImage;
		</cfscript>
	</cffunction>

	<cffunction name="grayScale" access="public" output="false" returntype="any" hint="I set the image to gray scale.">
		<cfscript>
			var Image = ImageGetBufferedImage(getImage());
			var GrayImage = createObject("java", "java.awt.image.BufferedImage");
			var ColorSpace = CreateObject("Java", "java.awt.color.ColorSpace");
			var RenderingHints = CreateObject("Java", "java.awt.RenderingHints");
			var ColorConvertOp = CreateObject("Java", "java.awt.image.ColorConvertOp");
				GrayImage.init(Image.Width,Image.Height,Image.Type);
				ColorSpace = ColorSpace.getInstance(ColorSpace.CS_GRAY);
				RenderingHints.init(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_DEFAULT);
				ColorConvertOp.init(ColorSpace, RenderingHints);
				GrayImage = ColorConvertOp.filter(Image, GrayImage);
				setImage(ImageNew(GrayImage));
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="CalculateGradient" access="public" returntype="array" output="false" hint="Given a From and To normalized color structure (as defined by the NormalizeColor() function) that contain Red, Green, Blue, and Alpha keys, it will return the equivalent structs for each step of the gradient.">
		<cfargument name="FromColor" type="struct" required="true" hint="A normalized color struct."/>
		<cfargument name="ToColor" type="struct" required="true" hint="A normalized color struct."/>
		<cfargument name="Steps" type="numeric" required="true" hint="The number of steps overwhich to calculate the gradient." />
		<cfset var LOCAL = {} />
		<cfset LOCAL.RedDelta = (ARGUMENTS.ToColor.Red - ARGUMENTS.FromColor.Red) />
		<cfset LOCAL.GreenDelta = (ARGUMENTS.ToColor.Green - ARGUMENTS.FromColor.Green) />
		<cfset LOCAL.BlueDelta = (ARGUMENTS.ToColor.Blue - ARGUMENTS.FromColor.Blue) />
		<cfset LOCAL.AlphaDelta = (ARGUMENTS.ToColor.Alpha - ARGUMENTS.FromColor.Alpha) />
		<cfset LOCAL.RedStep = (LOCAL.RedDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.GreenStep = (LOCAL.GreenDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.BlueStep = (LOCAL.BlueDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.AlphaStep = (LOCAL.AlphaDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.Gradient = [] />
		<cfset LOCAL.Color = StructCopy( ARGUMENTS.FromColor ) />
		<cfloop index="LOCAL.StepIndex" from="1" to="#ARGUMENTS.Steps#" step="1">
			<cfset ArrayAppend( LOCAL.Gradient, StructCopy( LOCAL.Color ) ) />
			<cfset LOCAL.Color.Red = Fix( ARGUMENTS.FromColor.Red + (LOCAL.RedStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Green = Fix( ARGUMENTS.FromColor.Green + (LOCAL.GreenStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Blue = Fix( ARGUMENTS.FromColor.Blue + (LOCAL.BlueStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Alpha = Fix( ARGUMENTS.FromColor.Alpha + (LOCAL.AlphaStep * LOCAL.StepIndex) ) />
		</cfloop>
		<cfreturn LOCAL.Gradient />
	</cffunction>

	<cffunction name="ColorsAreEqual" access="public" returntype="boolean" output="false" hint="Determines if the given two *normalized* colors (as defined by NormalizeColor() function) are equal in color given the tolerance. By default, all transparent pixels are equal.">
		<cfargument name="ColorOne" type="struct" required="true" hint="A normalized color struct." />
		<cfargument name="ColorTwo" type="struct" required="true" hint="A normalized color struct." />
		<cfargument name="Tolerance" type="numeric" required="false" default="0" hint="The tolerance between the color channels when determining if the colors are equal (max possible delta in channel value)." />
		<cfargument name="AlphaPrecedence" type="boolean" required="false" default="true" hint="Flags whether or not the alpha channel takes precedence over the color channels." />
		<cfset var LOCAL = {} />
		<cfif (
			ARGUMENTS.AlphaPrecedence AND
			(ARGUMENTS.ColorOne.Alpha LTE ARGUMENTS.Tolerance) AND
			(ARGUMENTS.ColorTwo.Alpha LTE ARGUMENTS.Tolerance)
			)>
			<cfreturn true />
		</cfif>
		<cfreturn (
			(Abs( ARGUMENTS.ColorOne.Red - ARGUMENTS.ColorTwo.Red ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Green - ARGUMENTS.ColorTwo.Green ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Blue - ARGUMENTS.ColorTwo.Blue ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Alpha - ARGUMENTS.ColorTwo.Alpha ) LTE ARGUMENTS.Tolerance)
			) />
	</cffunction>

	<cffunction name="CreateGradient" access="public" returntype="any" output="false" hint="Creates a gradient rectangle to be used with other graphics.">
		<cfargument name="FromColor" type="struct" required="true" hint="The normalized color struct from which to start our gradient."/>
		<cfargument name="ToColor" type="struct" required="true" hint="The normalized color struct at which to end our gradient."/>
		<cfargument name="GradientDirection" type="string" required="true" hint="The direction in which to darw the gradient. Possible values are TopBottom, BottomTop, LeftRight, and RightLeft."/>
		<cfargument name="Width" type="numeric" required="true" hint="The width of the desired rectangle."/>
		<cfargument name="Height" type="numeric" required="true" hint="The height of the desired rectangle." />
		<cfset var LOCAL = {} />
		<cfif NOT ListFindNoCase( "TopBottom,BottomTop,LeftRight,RightLeft",ARGUMENTS.GradientDirection)>
			<cfset ARGUMENTS.GradientDirection = "TopBottom" />
		</cfif>
		<cfset LOCAL.Gradient = ImageNew("",ARGUMENTS.Width,ARGUMENTS.Height,"argb") />
		<cfswitch expression="#ARGUMENTS.GradientDirection#">
			<cfcase value="TopBottom,BottomTop" delimiters=",">
				<cfset LOCAL.StepCount = ARGUMENTS.Height />
			</cfcase>
			<cfcase value="LeftRight,RightLeft" delimiters=",">
				<cfset LOCAL.StepCount = ARGUMENTS.Width />
			</cfcase>
		</cfswitch>
		<cfset LOCAL.GradientSteps = CalculateGradient(NormalizeColor(ARGUMENTS.FromColor),NormalizeColor(ARGUMENTS.ToColor),LOCAL.StepCount) />
		<cfset ImageSetAntialiasing( LOCAL.Gradient, "off" ) />
		<cfloop index="LOCAL.StepIndex" from="1" to="#LOCAL.StepCount#" step="1">
			<cfset ImageSetDrawingColor(LOCAL.Gradient, (LOCAL.GradientSteps[LOCAL.StepIndex].Red & "," & LOCAL.GradientSteps[LOCAL.StepIndex].Green & "," & LOCAL.GradientSteps[LOCAL.StepIndex].Blue )) />
			<cfset ImageSetDrawingTransparency(LOCAL.Gradient,(100-(LOCAL.GradientSteps[LOCAL.StepIndex].Alpha/255*100))) />
			<cfswitch expression="#ARGUMENTS.GradientDirection#">
				<cfcase value="TopBottom">
					<cfset ImageDrawRect(LOCAL.Gradient,0,(LOCAL.StepIndex-1),ARGUMENTS.Width,1,true) />
				</cfcase>
				<cfcase value="BottomTop">
					<cfset ImageDrawRect(LOCAL.Gradient,0,(ARGUMENTS.Height - LOCAL.StepIndex),ARGUMENTS.Width,1,true) />
				</cfcase>
				<cfcase value="LeftRight">
					<cfset ImageDrawRect(LOCAL.Gradient,(LOCAL.StepIndex-1),0,1,ARGUMENTS.Height,true) />
				</cfcase>
				<cfcase value="RightLeft">
					<cfset ImageDrawRect(LOCAL.Gradient,(ARGUMENTS.Width-LOCAL.StepIndex),0,1,ARGUMENTS.Height,true) />
				</cfcase>
			</cfswitch>
		</cfloop>
		<cfreturn LOCAL.Gradient />
	</cffunction>

	<cffunction name="DrawGradientRect" access="public" returntype="any" output="false" hint="Takes an image and draws the given gradient rectangle on it.">
		<cfargument name="X" type="numeric" required="true" hint="The X coordinate at which to start drawing the rectangle."/>
		<cfargument name="Y" type="numeric" required="true" hint="The Y coordinate at which to start drawing the rectangle."/>
		<cfargument name="Width" type="numeric" required="true" hint="The width of the desired rectangle."/>
		<cfargument name="Height" type="numeric" required="true" hint="The height of the desired rectangle."/>
		<cfargument name="FromColor" type="any" required="true" hint="The HEX, R,G,B,A list, or color struct for the start color of our gradient."/>
		<cfargument name="ToColor" type="any" required="true" hint="TheHEX, R,G,B,A list, or color struct for the end color of our gradient."/>
		<cfargument name="GradientDirection" type="string" required="true" hint="The direction in which to darw the gradient. Possible values are TopBottom, BottomTop, LeftRight, and RightLeft." />
		<cfargument name="Alpha" type="numeric" required="false" />
		<cfset var LOCAL = {Image=getImage()} />
		<cfset LOCAL.Gradient = CreateGradient(NormalizeColor(ARGUMENTS.FromColor),NormalizeColor(ARGUMENTS.ToColor),ARGUMENTS.GradientDirection,ARGUMENTS.Width,ARGUMENTS.Height) />
		<cfset ImageSetDrawingTransparency(LOCAL.Image,50) />
		<cfset ImageSetDrawingTransparency(LOCAL.Gradient,100) />
		<cfset ImagePaste(LOCAL.Image,LOCAL.Gradient,ARGUMENTS.X,ARGUMENTS.Y) />
		<cfset setImage(LOCAL.Image) />
		<cfreturn this />
	</cffunction>

	<cffunction name="DrawGradientRectReturnImage" access="public" returntype="any" output="false" hint="Takes an image and draws the given gradient rectangle on it.">
		<cfargument name="image" type="any" required="true" >
		<cfargument name="X" type="numeric" required="true" hint="The X coordinate at which to start drawing the rectangle."/>
		<cfargument name="Y" type="numeric" required="true" hint="The Y coordinate at which to start drawing the rectangle."/>
		<cfargument name="Width" type="numeric" required="true" hint="The width of the desired rectangle."/>
		<cfargument name="Height" type="numeric" required="true" hint="The height of the desired rectangle."/>
		<cfargument name="FromColor" type="any" required="true" hint="The HEX, R,G,B,A list, or color struct for the start color of our gradient."/>
		<cfargument name="ToColor" type="any" required="true" hint="TheHEX, R,G,B,A list, or color struct for the end color of our gradient."/>
		<cfargument name="GradientDirection" type="string" required="true" hint="The direction in which to darw the gradient. Possible values are TopBottom, BottomTop, LeftRight, and RightLeft." />
		<cfargument name="Alpha" type="numeric" required="false" />
		<cfset var LOCAL = {Image=arguments.image} />
		<cfset LOCAL.Gradient = CreateGradient(NormalizeColor(ARGUMENTS.FromColor),NormalizeColor(ARGUMENTS.ToColor),ARGUMENTS.GradientDirection,ARGUMENTS.Width,ARGUMENTS.Height) />
		<cfset ImageSetDrawingTransparency(LOCAL.Image,50) />
		<cfset ImageSetDrawingTransparency(LOCAL.Gradient,100) />
		<cfset ImagePaste(LOCAL.Image,LOCAL.Gradient,ARGUMENTS.X,ARGUMENTS.Y) />
		<cfreturn LOCAL.Image />
	</cffunction>


	<cffunction name="DrawTextArea" access="public" returntype="any" output="true" hint="Draws a text area on the given canvas.">
		<cfargument name="Text" type="string" required="true" hint="The text value that we are going to write."/>
		<cfargument name="X" type="numeric" required="true" hint="The X coordinate of the start of the text."/>
		<cfargument name="Y" type="numeric" required="true" hint="The Y coordinate of the baseline of the start of the text."/>
		<cfargument name="Width" type="numeric" required="true" hint="The width of the text area in which the text should fit."/>
		<cfargument name="Attributes" type="struct" required="false" default="#StructNew()#" hint="The attributes of the font (including TextAlign and LineHeight)." />
		<cfset var LOCAL = {Image=getImage()} />
		<cfparam name="ARGUMENTS.Attributes.Size" type="numeric" default="50">
		<cfparam name="ARGUMENTS.Attributes.LineHeight" type="numeric" default="#(1.4 * ARGUMENTS.Attributes.Size)#" />
		<cfparam name="ARGUMENTS.Attributes.TextAlign" type="string" default="left" />
		<cfparam name="ARGUMENTS.Attributes.Color" type="string" default="ffffff" />
		<cfset LOCAL.Words = ARGUMENTS.Text.Split(JavaCast("string"," ")) />
		<cfset LOCAL.Lines = [] />
		<cfset LOCAL.Lines[1] = {Text="",Width=0,Height=0} />
		<cfloop index="LOCAL.WordIndex" from="1" to="#ArrayLen(LOCAL.Words)#" step="1">
			<cfset LOCAL.Word = LOCAL.Words[LOCAL.WordIndex] />
			<cfset LOCAL.Line = LOCAL.Lines[ArrayLen(LOCAL.Lines)] />
			<cfset LOCAL.Dimensions = GetTextDimensions(Trim(LOCAL.Line.Text&" "&LOCAL.Word),StructCopy(ARGUMENTS.Attributes)) />
			<cfif ((LOCAL.Dimensions.Width LTE ARGUMENTS.Width) OR (NOT Len(LOCAL.Line.Text)))>
				<cfset LOCAL.Line.Text &= (IIF(Len(LOCAL.Line.Text),DE(" "),DE(""))&LOCAL.Word) />
				<cfset LOCAL.Line.Width = Min(LOCAL.Dimensions.Width,ARGUMENTS.Width) />
				<cfset LOCAL.Line.Height = LOCAL.Dimensions.Height />
			<cfelse>
				<cfset LOCAL.Dimensions = GetTextDimensions(LOCAL.Word,StructCopy(ARGUMENTS.Attributes)) />
				<cfset LOCAL.Line = {Text=LOCAL.Word,Width=LOCAL.Dimensions.Width,Height=LOCAL.Dimensions.Height} />
				<cfset ArrayAppend(LOCAL.Lines,LOCAL.Line) />
			</cfif>
		</cfloop>
		<cfloop index="LOCAL.LineIndex" from="1" to="#ArrayLen(LOCAL.Lines)#" step="1">
			<cfset LOCAL.Line = LOCAL.Lines[LOCAL.LineIndex] />
			<cfswitch expression="#ARGUMENTS.Attributes.TextAlign#">
				<cfcase value="right">
					<cfset LOCAL.X = (ARGUMENTS.X+ARGUMENTS.Width-LOCAL.Line.Width) />
				</cfcase>
				<cfcase value="center">
					<cfset LOCAL.X = (ARGUMENTS.X+Fix((ARGUMENTS.Width-LOCAL.Line.Width)/2)) />
				</cfcase>
				<cfdefaultcase>
					<cfset LOCAL.X = ARGUMENTS.X />
				</cfdefaultcase>
			</cfswitch>
			<cfset LOCAL.Y = (ARGUMENTS.Y+((LOCAL.LineIndex-1)*ARGUMENTS.Attributes.LineHeight)) />
			<cfset ImageSetDrawingColor(LOCAL.Image,ARGUMENTS.Attributes.Color) />
			<cfset ImageDrawText(LOCAL.Image,LOCAL.Line.Text,LOCAL.X,LOCAL.Y,ARGUMENTS.Attributes) />
		</cfloop>
		<cfset setImage(LOCAL.Image) />
		<cfreturn this />
	</cffunction>


	<cffunction name="getCenteredTextPosition" access="public" returnType="struct" output="false">
		<cfargument name="image" type="any" required="true">
		<cfargument name="text" type="string" required="true">
		<cfargument name="fontname" type="any" required="true" hint="This can either be the name of a font, or a structure containing style,size,font, like you would use for imageDrawText">
		<cfargument name="fonttype" type="string" required="false" hint="Must be ITALIC, PLAIN, or BOLD">
		<cfargument name="fontsize" type="string" required="false">
		<cfset var buffered = imageGetBufferedImage(arguments.image)>
		<cfset var context = buffered.getGraphics().getFontRenderContext()>
		<cfset var font = createObject("java", "java.awt.Font")>
		<cfset var textFont = "">
		<cfset var textLayout = "">
		<cfset var textBounds = "">
		<cfset var result = structNew()>
		<cfset var fp = "">
		<cfset var width = "">
		<cfset var height = "">
		<cfif isStruct(arguments.fontname)>
			<cfset arguments.fonttype = arguments.fontname.style>
			<cfset arguments.fontsize = arguments.fontname.size>
			<cfset arguments.fontname = arguments.fontname.font>
		</cfif>
		<cfif arguments.fonttype is "plain">
			<cfset fp = font.PLAIN>
			<cfelseif arguments.fonttype is "bold">
			<cfset fp = font.BOLD>
			<cfelse>
			<cfset fp = font.ITALIC>
		</cfif>
		<cfset textFont = font.init(arguments.fontname, fp, javacast("int", arguments.fontsize))>
		<cfset textLayout = createObject("java", "java.awt.font.TextLayout").init( arguments.text, textFont, context)>
		<cfset textBounds = textLayout.getBounds()>
		<cfset width = textBounds.getWidth()>
		<cfset height = textBounds.getHeight()>
		<cfset result.x = (arguments.image.width/2 - width/2)>
		<cfset result.y = (arguments.image.height/2 + height/2)>
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPixel" access="public" returntype="struct" output="false" hint="Returns a struct containing the given pixel RGBA data.">
		<cfargument name="X" type="numeric" required="true" hint="The X coordinate of the pixel that we are returning."/>
		<cfargument name="Y" type="numeric" required="true" hint="The Y coordinate of the pixel that we are returning." />
		<cfset var LOCAL = {} />
		<cfset LOCAL.Pixels = GetPixels(getImage(),ARGUMENTS.X,ARGUMENTS.Y,1,1) />
		<cfreturn LOCAL.Pixels[1][1] />
	</cffunction>

	<cffunction name="GetPixels" access="public" returntype="array" output="false" hint="Returns a two dimensional array of RGBA values for the image. Array will be in the form of Pixels[ Y ][ X ] where Y is along the height axis and X is along the width axis.">
		<cfargument name="Image" type="any" required="true" hint="The ColdFusion image object whose pixel map we are returning." />
		<cfargument name="X" type="numeric" required="false" default="1" hint="The default X point where we will start getting our pixels (will be translated to 0-based system for Java interaction)." />
		<cfargument name="Y" type="numeric" required="false" default="1" hint="The default Ypoint where we will start getting our pixels (will be translated to 0-based system for Java interaction)." />
		<cfargument name="Width" type="numeric" required="false" default="#ImageGetWidth( ARGUMENTS.Image )#" hint="The width of the area from which we will be sampling pixels." />
		<cfargument name="Height" type="numeric" required="false" default="#ImageGetHeight( ARGUMENTS.Image )#" hint="The height of the area from which we will be sampling pixels." />
		<cfset var LOCAL = {} />
		<cfset LOCAL.Pixels = [] />
		<cfset LOCAL.Raster = ImageGetBufferedImage(ARGUMENTS.Image).GetRaster() />
		<cfloop index="LOCAL.Y" from="#ARGUMENTS.Y#" to="#(ARGUMENTS.Y+ARGUMENTS.Height-1)#" step="1">
			<cfset ArrayAppend(LOCAL.Pixels,ArrayNew(1)) />
			<cfloop index="LOCAL.X" from="#ARGUMENTS.X#" to="#(ARGUMENTS.X+ARGUMENTS.Width-1)#" step="1">
				<cfset LOCAL.PixelArray = JavaCast("int[]",ListToArray("0,0,0,0")) />
				<cfset LOCAL.Raster.GetPixel(JavaCast("int",LOCAL.X),JavaCast("int",LOCAL.Y),LOCAL.PixelArray) />
				<cfset LOCAL.Pixel = NormalizeColor("#LOCAL.PixelArray[1]#,#LOCAL.PixelArray[2]#,#LOCAL.PixelArray[3]#,#LOCAL.PixelArray[4]#") />
				<cfset ArrayAppend(LOCAL.Pixels[ArrayLen(LOCAL.Pixels)],LOCAL.Pixel) />
			</cfloop>
		</cfloop>	
		<cfreturn LOCAL.Pixels />
	</cffunction>

	<cffunction name="GetTextDimensions" access="public" returntype="struct" output="false" hint="Give the string and the font properties, the width and height of the text is calculated. If the font properties struct is missing any values, ColdFusion's default values will be used.">
		<cfargument name="Text" type="string" required="true" hint="The text whose dimensions we are going to calculate."/>
		<cfargument name="FontProperties" type="struct" required="true" hint="The font properties used to calculate the text dimensions." />
		<cfset var LOCAL = {} />
		<cfset LOCAL.Image = ImageNew("",1,1,"rgb") />
		<cfset LOCAL.Graphics = ImageGetBufferedImage(LOCAL.Image).GetGraphics() />
		<cfset LOCAL.CurrentFont = LOCAL.Graphics.GetFont() />
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties,"Size")>
			<cfset ARGUMENTS.FontProperties.Size = LOCAL.CurrentFont.GetSize() />
		</cfif>
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties, "Font" )>
			<cfset ARGUMENTS.FontProperties.Font = LOCAL.CurrentFont.GetFontName() />
		</cfif>
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties, "Style" )>
			<cfif (LOCAL.CurrentFont.IsBold() AND LOCAL.CurrentFont.IsItalic())>
				<cfset ARGUMENTS.FontProperties.Style = "bolditalic" />
				<cfset LOCAL.FontStyleMask = BitOR(LOCAL.CurrentFont.BOLD,LOCAL.CurrentFont.ITALIC) />
			<cfelseif LOCAL.CurrentFont.IsBold()>
				<cfset ARGUMENTS.FontProperties.Style = "bold" />
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.BOLD />
			<cfelseif LOCAL.CurrentFont.IsItalic()>
				<cfset ARGUMENTS.FontProperties.Style = "italic" />
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.ITALIC />
			<cfelse>
				<cfset ARGUMENTS.FontProperties.Style = "plain" />
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.PLAIN />
			</cfif>
		<cfelse>
			<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.PLAIN />
		</cfif>
		<cfset LOCAL.NewFont = CreateObject("java","java.awt.Font").Init(JavaCast("string",ARGUMENTS.FontProperties.Font),JavaCast("int",LOCAL.FontStyleMask),JavaCast("int",ARGUMENTS.FontProperties.Size)) />
		<cfset LOCAL.FontMetrics = LOCAL.Graphics.GetFontMetrics(LOCAL.NewFont) />
		<cfset LOCAL.TextBounds = LOCAL.FontMetrics.GetStringBounds(JavaCast("string",ARGUMENTS.Text),LOCAL.Graphics) />
		<cfset LOCAL.Return = {Width=Ceiling(LOCAL.TextBounds.GetWidth()),Height=Ceiling(LOCAL.TextBounds.GetHeight())} />
		<cfreturn LOCAL.Return />
	</cffunction>


	<cffunction name="HexToRGB" access="public" returntype="struct" output="false" hint="Takes a 6 digit hex value and returns a struct with Red, Green, and Blue keys.">
		<cfargument name="Hex" type="string" required="true" hint="The 6 digit hex color value." />
		<cfset var LOCAL = {} />
		<cfset ARGUMENTS.Hex = REReplace(ARGUMENTS.Hex,"(?i)[^0-9A-F]+","","all") />
		<cfset LOCAL.DecimalColor = InputBaseN(ARGUMENTS.Hex,"16") />
		<cfset LOCAL.Return = {Red=BitSHRN(BitAnd(LOCAL.DecimalColor,InputBaseN("FF0000",16)),16),Green=BitSHRN(BitAnd(LOCAL.DecimalColor,InputBaseN("00FF00",16)),8),Blue=BitAnd(LOCAL.DecimalColor,InputBaseN("0000FF",16)),Alpha=255} />
		<cfreturn LOCAL.Return />
	</cffunction>

	<cffunction name="NormalizeColor" access="public" returntype="struct" output="false" hint="Take a HEX value or R,G,B[,A] list and creates a normalized color structure that can be safely used by the other functions of this utility component.">
		<cfargument name="Color" type="any" required="true" hint="A HEX or R,G,B[,A] color list or struct." />
		<cfset var LOCAL = {} />
		<cfset LOCAL.Return = {Red=255,Green=255,Blue=255,Alpha=255,Hex="##FFFFFF"} />
		<cfif IsStruct(ARGUMENTS.Color)>
			<cfloop index="LOCAL.Key" list="Red,Green,Blue,Alpha" delimiters=",">
				<cfif StructKeyExists(ARGUMENTS.Color,LOCAL.Key)>
					<cfset LOCAL.Return[LOCAL.Key]=ARGUMENTS.Color[LOCAL.Key] />
				</cfif>
			</cfloop>		
		<cfelseif REFind("(?i)^##?[0-9A-F]{6}$",ARGUMENTS.Color)>
			<cfset ARGUMENTS.Color = REReplace(ARGUMENTS.Color,"(?i)[^0-9A-F]+","","all") />
			<cfset LOCAL.DecimalColor = InputBaseN(ARGUMENTS.Color,"16") />
			<cfset LOCAL.Return.Red = BitSHRN(BitAnd(LOCAL.DecimalColor,InputBaseN("FF0000",16)),16) />
			<cfset LOCAL.Return.Green = BitSHRN(BitAnd(LOCAL.DecimalColor,InputBaseN("00FF00",16)),8) />
			<cfset LOCAL.Return.Blue = BitAnd(LOCAL.DecimalColor,InputBaseN("0000FF",16)) />
		<cfelseif REFind("^\d+,\d+,\d+$",ARGUMENTS.Color)>
			<cfset LOCAL.Return.Red = ListGetAt(ARGUMENTS.Color,1) />
			<cfset LOCAL.Return.Green = ListGetAt(ARGUMENTS.Color,2) />
			<cfset LOCAL.Return.Blue = ListGetAt(ARGUMENTS.Color,3) />
		<cfelseif REFind( "^\d+,\d+,\d+,\d+$",ARGUMENTS.Color)>
			<cfset LOCAL.Return.Red = ListGetAt(ARGUMENTS.Color,1) />
			<cfset LOCAL.Return.Green = ListGetAt(ARGUMENTS.Color,2) />
			<cfset LOCAL.Return.Blue = ListGetAt(ARGUMENTS.Color,3) />
			<cfset LOCAL.Return.Alpha = ListGetAt(ARGUMENTS.Color,4) />
		</cfif>
		<cfset LOCAL.Return.Hex = UCase(Right("0#FormatBaseN(LOCAL.Return.Red,'16')#",2)&Right("0#FormatBaseN(LOCAL.Return.Green,'16')#",2)&Right("0#FormatBaseN(LOCAL.Return.Blue,'16')#",2)) />
		<cfreturn LOCAL.Return />	
	</cffunction>

	<cffunction name="OpacityBlend" access="public" returntype="any" output="false" hint="">
		<cfargument name="foreground" type="any" required="true" hint=""/>
		<cfargument name="background" type="any" required="true" hint=""/>
		<cfargument name="opacity" type="numeric" required="true" hint="" />
		<cfset var fRGB = "" />
		<cfset var bRGB = "" />
		<cfset var blendRGB = {} />
		<cfset var blendHEX = "" />
		<cfset var transparency = "" />
		<cfset arguments.foreground = REReplace(arguments.foreground,"(?i)[^0-9A-F]+","","all") />
		<cfset arguments.background = REReplace(arguments.background,"(?i)[^0-9A-F]+","","all") />
		<cfif arguments.opacity GTE 100>
			<cfset blendHEX = arguments.foreground>
		<cfelseif arguments.opacity LTE 0>
			<cfset blendHEX = arguments.background>
		<cfelse>
			<cfset fRGB = HexToRGB(arguments.foreground)>
			<cfset bRGB = HexToRGB(arguments.background)>
			<cfset transparency = 100 - arguments.opacity>
			<cfset blendRGB.red =  ceiling((bRGB.red - fRGB.red) / 100 * transparency + fRGB.red)>
			<cfset blendRGB.green = ceiling((bRGB.green - fRGB.green) / 100 * transparency + fRGB.green)>
			<cfset blendRGB.blue = ceiling((bRGB.blue - fRGB.blue) / 100 * transparency + fRGB.blue)>
			<cfset blendHex = UCase(Right("0#FormatBaseN(blendRGB.red,'16')#",2)&Right("0#FormatBaseN(blendRGB.green,'16')#",2)&Right("0#FormatBaseN(blendRGB.blue,'16')#",2)) />
		</cfif>
		<cfreturn blendHex>
	</cffunction>

	<cffunction name="ReflectImage" access="public" returntype="any" output="false" hint="Reflects image along the given side with the given properties.">
		<cfargument name="Side" type="string" required="true" hint="The side of the image that we are going to reflect. Valid values include Top, Right, Bottom, and Left."/>
		<cfargument name="BackgroundColor" type="any" required="false" default="FFFFFF" hint="The HEX color of the canvas background color used in the reflection."/>
		<cfargument name="Offset" type="numeric" required="false" default="0" hint="The offset of the reflection from the image."/>
		<cfargument name="Size" type="numeric" required="false" default="100" hint="The height or width of the given reflection (depending on the side being reflected)."/>
		<cfargument name="StartingAlpha" type="numeric" required="false" default="25" hint="The starting alpha channel of the covering !!background color!! (between 0 and 255 where 0 is completely transparent)." />
		<cfset var LOCAL = {Image=getImage()} />
		<cfif NOT ListFindNoCase( "Top,Right,Bottom,Left",ARGUMENTS.Side)>
			<cfset ARGUMENTS.Side = "Bottom" />
		</cfif>
		<cfif ListFindNoCase("Top,Bottom", ARGUMENTS.Side)>
			<cfset LOCAL.Width = ImageGetWidth(LOCAL.Image) />
			<cfset LOCAL.Height = (ImageGetHeight(LOCAL.Image)+ARGUMENTS.Offset+ARGUMENTS.Size) />
		<cfelse>
			<cfset LOCAL.Height = ImageGetHeight(LOCAL.Image) />
			<cfset LOCAL.Width = (ImageGetWidth(LOCAL.Image)+ARGUMENTS.Offset+ARGUMENTS.Size) />
		</cfif>
		<cfset LOCAL.Result = ImageNew("",LOCAL.Width,LOCAL.Height,"argb") />

		<cfset LOCAL.Reflection = ImageNew('',ImageGetWidth(LOCAL.Image),ImageGetHeight(LOCAL.Image),'argb') />
		<cfset ImagePaste(LOCAL.Reflection,LOCAL.Image,0,0) />
		<cfif ListFindNoCase("Top,Bottom",ARGUMENTS.Side )>
			<cfset ImageFlip(LOCAL.Reflection,"vertical") />
		<cfelse>
			<cfset ImageFlip(LOCAL.Reflection,"horizontal") />
		</cfif>
		<cfset LOCAL.FromColor = NormalizeColor(ARGUMENTS.BackgroundColor) />
		<cfset LOCAL.ToColor = StructCopy(LOCAL.FromColor) />
		<cfset LOCAL.FromColor.Alpha = ARGUMENTS.StartingAlpha />
		<cfset LOCAL.ToColor.Alpha = 255 />

		<cfswitch expression="#ARGUMENTS.Side#">
			<cfcase value="Top">
				<cfset LOCAL.Reflection = DrawGradientRectReturnImage(LOCAL.Reflection,0,(ImageGetHeight(LOCAL.Reflection)-ARGUMENTS.Size),ImageGetWidth(LOCAL.Reflection),ARGUMENTS.Size,LOCAL.FromColor,LOCAL.ToColor,"BottomTop") />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Image,0,(ImageGetHeight(LOCAL.Result)-ImageGetHeight(LOCAL.Image))) />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Reflection,0,(-ImageGetHeight(LOCAL.Reflection)+ARGUMENTS.Size)) />
			</cfcase>
			<cfcase value="Bottom">
				<cfset LOCAL.Reflection = DrawGradientRectReturnImage(LOCAL.Reflection,0,0,ImageGetWidth(LOCAL.Reflection),ARGUMENTS.Size,LOCAL.FromColor,LOCAL.ToColor,"TopBottom") />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Image,0,0) />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Reflection,0,(ImageGetHeight(LOCAL.Image)+ARGUMENTS.Offset)) />
			</cfcase>
			<cfcase value="Left">
				<cfset LOCAL.Reflection = DrawGradientRectReturnImage(LOCAL.Reflection,(ImageGetWidth(LOCAL.Reflection)-ARGUMENTS.Size),0,ARGUMENTS.Size,ImageGetHeight(LOCAL.Reflection),LOCAL.FromColor,LOCAL.ToColor,"RightLeft") />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Image,(ImageGetWidth(LOCAL.Result)-ImageGetWidth(LOCAL.Image)),0) />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Reflection,(-ImageGetWidth(LOCAL.Reflection)+ARGUMENTS.Size),0) />
			</cfcase>
			<cfcase value="Right">
				<cfset LOCAL.Reflection = DrawGradientRectReturnImage(LOCAL.Reflection,0,0,ARGUMENTS.Size,ImageGetHeight(LOCAL.Reflection),LOCAL.FromColor,LOCAL.ToColor,"LeftRight") />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Image,0,0) />
				<cfset ImagePaste(LOCAL.Result,LOCAL.Reflection,(ImageGetWidth(LOCAL.Image)+ARGUMENTS.Offset),0) />
			</cfcase>
		</cfswitch>
		<cfset setImage(LOCAL.Result) />
		<cfreturn this />
	</cffunction>

	<cffunction name="TileImage" access="public" returntype="any" output="false" hint="Takes your ColdFusion image object and tiles the given image over it.">
		<cfargument name="TileImage" type="any" required="true" hint="The image that we are going to tile onto our ColdFusion image."/>
		<cfargument name="X" type="numeric" required="false" default="0" hint="The X point at which we are going to start our tiling."/>
		<cfargument name="Y" type="numeric" required="false" default="0" hint="The Y point at which we are going to start our tiling." />
		<cfset var LOCAL =  {Image=getImage()} />
		<cfset LOCAL.ImageDimensions = {Width=ImageGetWidth(LOCAL.Image),Height=ImageGetHeight(LOCAL.Image)} />
		<cfset LOCAL.TileDimensions = {Width=ImageGetWidth(ARGUMENTS.TileImage),Height=ImageGetHeight(ARGUMENTS.TileImage)} />
		<cfset LOCAL.StartCoord = {X=ARGUMENTS.X,Y=ARGUMENTS.Y } />
		<cfloop condition="(LOCAL.StartCoord.X GT 0)">
			<cfset LOCAL.StartCoord.X -= LOCAL.TileDimensions.Width />
		</cfloop>
		<cfloop condition="(LOCAL.StartCoord.Y GT 0)">
			<cfset LOCAL.StartCoord.Y -= LOCAL.TileDimensions.Height />
		</cfloop>
		<cfset LOCAL.PasteCoord = StructCopy(LOCAL.StartCoord) />
		<cfloop index="LOCAL.PasteCoord.Y" from="#LOCAL.StartCoord.Y#" to="#LOCAL.ImageDimensions.Height#" step="#LOCAL.TileDimensions.Height#">
			<cfloop index="LOCAL.PasteCoord.X" from="#LOCAL.StartCoord.X#" to="#LOCAL.ImageDimensions.Width#" step="#LOCAL.TileDimensions.Width#">
				<cfset ImagePaste(LOCAL.Image,ARGUMENTS.TileImage,LOCAL.PasteCoord.X,LOCAL.PasteCoord.Y) />
			</cfloop>
		</cfloop>
		<cfset setImage(LOCAL.Image) />
		<cfreturn this />
	</cffunction>

	<cffunction name="TrimCanvas" access="public" returntype="any" output="false" hint="Trims the canvas to the smallest possible rectangle using the given background color.">
		<cfargument name="BackgroundColor" type="string" required="true" hint="The HEX, R,G,B[,A] or normalized background color that will be used to trim the canvas."/>
		<cfargument name="Tolerance" type="numeric" required="false" default="10" hint="The tolerance of difference in any given color channel between the background color and the current pixel whereby the pixels can still be considered equal" />
		<cfset TrimCanvasSide("Top",ARGUMENTS.BackgroundColor,ARGUMENTS.Tolerance) />
		<cfset TrimCanvasSide("Bottom",ARGUMENTS.BackgroundColor,ARGUMENTS.Tolerance) />
		<cfset TrimCanvasSide("Left",ARGUMENTS.BackgroundColor,ARGUMENTS.Tolerance) />
		<cfset TrimCanvasSide("Right",ARGUMENTS.BackgroundColor,ARGUMENTS.Tolerance) />
		<cfreturn this />
	</cffunction>

	<cffunction name="TrimCanvasSide" access="public" returntype="any" output="false" hint="Trims the given side of a canvas using the given background color.">
		<cfargument name="Side" type="string" required="true" hint="The side of the canvas that we are trimming. Possible value are Top, Bottom, Left, Right." />
		<cfargument name="BackgroundColor" type="string" required="true" hint="The HEX background color that will be used to trim the canvas." />
		<cfargument name="Tolerance" type="numeric" required="false" default="10" hint="The tolerance of difference in any given color channel between the background color and the current pixel whereby the pixels can still be considered equal" />
		<cfset var LOCAL = {} />
			<cfif NOT ListFindNoCase( "Top,Right,Bottom,Left", ARGUMENTS.Side )>
				<cfset ARGUMENTS.Side = "Bottom" />
			</cfif>
			<cfset LOCAL.InputImage = getImage() />
			<cfset LOCAL.Image = ImageCopy(LOCAL.InputImage,0,0,ImageGetWidth(LOCAL.InputImage),ImageGetHeight(LOCAL.InputImage)) />
			<cfset LOCAL.Color = THIS.NormalizeColor(ARGUMENTS.BackgroundColor) />
			<cfset LOCAL.KeepTrimming = true />

			<cfloop condition="#LOCAL.KeepTrimming#">
			<cfswitch expression="#ARGUMENTS.Side#">
				<cfcase value="Top">
					<cfset LOCAL.Pixels = THIS.GetPixels(LOCAL.Image,0,0,ImageGetWidth(LOCAL.Image),1) />
					<cfset LOCAL.Pixels = LOCAL.Pixels[1] />
					<cfloop index="LOCAL.Pixel" array="#LOCAL.Pixels#">
						<cfif NOT THIS.ColorsAreEqual(LOCAL.Pixel,LOCAL.Color,ARGUMENTS.Tolerance)>
							<cfset LOCAL.KeepTrimming = false />
							<cfbreak />
						</cfif>
					</cfloop>
					<cfif LOCAL.KeepTrimming>
						<cfset ImageCrop(LOCAL.Image,0,1,ImageGetWidth(LOCAL.Image),(ImageGetHeight(LOCAL.Image)-1)) />
					</cfif>
				</cfcase>
				<cfcase value="Bottom">
					<cfset LOCAL.Pixels = THIS.GetPixels(LOCAL.Image,0,(ImageGetHeight(LOCAL.Image)-1),ImageGetWidth(LOCAL.Image),1) />
					<cfset LOCAL.Pixels = LOCAL.Pixels[1] />
					<cfloop index="LOCAL.Pixel" array="#LOCAL.Pixels#">
						<cfif NOT THIS.ColorsAreEqual(LOCAL.Pixel,LOCAL.Color,ARGUMENTS.Tolerance)>
							<cfset LOCAL.KeepTrimming = false />
							<cfbreak />
						</cfif>
					</cfloop>
					<cfif LOCAL.KeepTrimming>
						<cfset ImageCrop(LOCAL.Image,0,0,ImageGetWidth(LOCAL.Image),(ImageGetHeight(LOCAL.Image)-1)) />
					</cfif>
				</cfcase>
				<cfcase value="Left">
					<cfset LOCAL.Pixels = THIS.GetPixels(LOCAL.Image,0,0,1,ImageGetHeight(LOCAL.Image)) />
					<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen(LOCAL.Pixels)#" step="1">
						<cfset LOCAL.Pixel = LOCAL.Pixels[ LOCAL.RowIndex ][1] />
						<cfif NOT THIS.ColorsAreEqual(LOCAL.Pixel,LOCAL.Color,ARGUMENTS.Tolerance)>
							<cfset LOCAL.KeepTrimming = false />
							<cfbreak />
						</cfif>
					</cfloop>
					<cfif LOCAL.KeepTrimming>
						<cfset ImageCrop(LOCAL.Image,1,0,(ImageGetWidth(LOCAL.Image)-1),ImageGetHeight(LOCAL.Image)) />
					</cfif>
				</cfcase>
				<cfcase value="Right">
					<cfset LOCAL.Pixels = THIS.GetPixels(LOCAL.Image,(ImageGetWidth(LOCAL.Image)-1),0,1,ImageGetHeight(LOCAL.Image)) />
					<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen(LOCAL.Pixels)#" step="1">
						<cfset LOCAL.Pixel = LOCAL.Pixels[LOCAL.RowIndex][1] />
						<cfif NOT THIS.ColorsAreEqual(LOCAL.Pixel,LOCAL.Color,ARGUMENTS.Tolerance)>
							<cfset LOCAL.KeepTrimming = false />
							<cfbreak />
						</cfif>
					</cfloop>
					<cfif LOCAL.KeepTrimming>
						<cfset ImageCrop(LOCAL.Image,0,0,(ImageGetWidth(LOCAL.Image)-1),ImageGetHeight(LOCAL.Image)) />
					</cfif>
				</cfcase>
			</cfswitch>
		</cfloop>
		<cfset setImage(LOCAL.Image) />
		<cfreturn this />
	</cffunction>

	<cffunction name="ReplaceColors" access="public" returntype="void" output="false" hint="Finds and Replaces colors in a image">
		<cfargument name="FRGBList" type="string" required="true" hint="Full R,G,B,A Color List to Find" />
		<cfargument name="RRGBList" type="string" required="true" hint="Full R,G,B,A Color List to Replace with" />
		<cfscript>
			var i = 1;
			var x = 0;
			var y = 0;
			var BufferedImage = ImageGetBufferedImage(getImage());
			var w = ImageGetWidth(getImage());
			var h = ImageGetHeight(getImage());
			var RenderingHints = createObject("java", "java.awt.RenderingHints");
			var replaceColorRGB = newColor(ListGetAt(ARGUMENTS.RRGBList,1),ListGetAt(ARGUMENTS.RRGBList,2),ListGetAt(ARGUMENTS.RRGBList,3),ListGetAt(ARGUMENTS.RRGBList,4)).getRGB();
			var findColorRGB = newColor(ListGetAt(ARGUMENTS.FRGBList,1),ListGetAt(ARGUMENTS.FRGBList,2),ListGetAt(ARGUMENTS.FRGBList,3),ListGetAt(ARGUMENTS.FRGBList,4)).getRGB();
				BufferedImage.getGraphics().setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
				for(x=0;x LT w; x++) {
					for(y=0;y LT h; y++) {
						if( BufferedImage.getRGB(x,y) EQ findColorRGB ) {
							BufferedImage.setRGB(x,y,replaceColorRGB);
						};
					};
				};
				setImage(ImageNew(BufferedImage));
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="newColor" access="public" output="false" returntype="any" hint="Takes RGBA color list and returns composed java.awt.Color object">
		<cfargument name="r" type="numeric" required="true" hint="0-255 Red value" />
		<cfargument name="g" type="numeric" required="true" hint="0-255 Green value" />
		<cfargument name="b" type="numeric" required="true" hint="0-255 Blue value" />
		<cfargument name="a" type="numeric" default="255" hint="0-255 Alpha value" />
		<cfreturn createObject("java", "java.awt.Color").init(JavaCast('int',ARGUMENTS.r),JavaCast('int',ARGUMENTS.g),JavaCast('int',ARGUMENTS.b),JavaCast('int',ARGUMENTS.a)) />
	</cffunction>



	<!---
	<cffunction name="writeOutTmpImage" access="public" output="false" returntype="string" hint="I write the image to disk.">
		<cfargument name="format" hint="I am the format of the data to return." default="png" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." default="100" type="numeric" />
		<cfset var tmpFilepath = GetTempDirectory() & CreateUUID() & ".jpg" />
		<cfset var OutputStream = CreateObject("Java", "java.io.FileOutputStream").init(tmpFilepath) />
		<cftry>
			<cfset writeToOutputStream(arguments.format,OutputStream,arguments.quality) />
			<cfcatch>
				<cfset OutputStream.close() />
				<cftry>
					<cffile action="delete" file="#tmpFilepath#" />
					<cfcatch></cfcatch>
				</cftry>				
				<cfrethrow />
			</cfcatch>
		</cftry>
		<cfreturn tmpFilepath />
	</cffunction>
	--->
	
	<cffunction name="saveImageToPath" access="public" output="false" returntype="void">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="format" type="string" default="jpg" />
		<cfset var outFile = createObject("java","java.io.File").init( ARGUMENTS.Path ) />
		<cfset var buffered = ImageGetBufferedImage( getImage() ) />
		<cfset var ImageIOFull = createObject("java","javax.imageio.ImageIO").write(buffered,ARGUMENTS.format,outFile) />
	</cffunction>

	<cffunction name="getTmpImage" access="public" output="false" returntype="any">
		<cfset var tmpFilePath = writeOutTmpImage() />
		<cfreturn ImageRead(tmpFilePath) />
	</cffunction>

	<cffunction name="writeOutTmpImage" access="public" output="false" returntype="string" hint="I write the image to disk.">
		<cfargument name="format" type="string" default="jpg" />
		<cfset var tmpFilepath = GetTempDirectory() & CreateUUID() & ".#arguments.format#" />
		<cfset var outFile = createObject("java","java.io.File").init(tmpFilepath) />
		<cfset var buffered = ImageGetBufferedImage(getImage()) />
		<cfset var ImageIOFull = createObject("java","javax.imageio.ImageIO").write(buffered,arguments.format,outFile) />
		<cftry>
			<cfthread name="del_#Replace(CreateUUID(),'-','','all')#" action="run" priority="low" fileObj="#outFile#">
				<cfset sleep(10000) /><cfset fileObj.delete() />
			</cfthread>
			<cfcatch></cfcatch>
		</cftry>
		<cfreturn tmpFilepath />
	</cffunction>

	<cffunction name="getBase64" access="public" output="false" returntype="string" hint="I return the image data in base64.">
		<cfargument name="format" hint="I am the format of the data to return." default="png" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." default="100" type="numeric" />
		<cfreturn ToBase64(getBinary(arguments.format, arguments.quality)) />
	</cffunction>

	<cffunction name="getBinary" access="public" output="false" returntype="binary" hint="I return the image data in binary.">
		<cfargument name="format" hint="I am the format of the data to return." default="png" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." default="100" type="numeric" />
		<cfset var OutputStream = CreateObject("Java", "java.io.ByteArrayOutputStream").init() /> 
		<cfset writeToOutputStream(arguments.format, OutputStream, arguments.quality) />
		<cfreturn OutputStream.toByteArray() />
	</cffunction>	

	<cffunction name="writeToOutputStream" access="private" output="false" returntype="void" hint="I write the image to a java outputstream.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="OutputStream" hint="I am the OutputStream to write to." required="yes" type="any" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="yes" type="numeric" />
		<cfset writeQualityToOutputStream(arguments.format, arguments.OutputStream, arguments.quality) />
		<cfset arguments.OutputStream.close() />
	</cffunction>

	<cffunction name="writeQualityToOutputStream" access="private" output="false" returntype="void" hint="I write the image to an outputstream at a specific quality setting.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="OutputStream" hint="I am the OutputStream to write to." required="yes" type="any" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="yes" type="numeric" />
		<cfset var Image = ImageGetBufferedImage(getImage()) />
		<cfset var ImageWriterIterator = 0 />
		<cfset var ImageWriter = 0 />
		<cfset var ImageWriteParam = 0 />
		<cfset var ImageTypeSpecifier = 0 />
		<cfset var IIOMetadata = 0 />
		<cfset var IIOImage = 0 />
		<cfset var ImageOutputStream = 0 />
		<cfset var width = getImage().width />
		<cfset var height = getImage().height />
		<cfset var proportion = 0 />
		<cfset var newWidth = 0 />
		<cfset var newHeight = 0 />
		<cfset var ThumbnailImage = 0 />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var List = 0 />
			<cfset ImageWriterIterator = getImageIO().getImageWritersByFormatName(arguments.format) />
			<cfloop condition="ImageWriterIterator.hasNext()">
					<cfset ImageWriter = ImageWriterIterator.next() />
					<cfset ImageWriteParam = ImageWriter.getDefaultWriteParam() />
					<cfset IIOImage = CreateObject('java','javax.imageio.IIOImage').init(Image,JavaCast('null',''),JavaCast('null','')) />
					<cfset ImageOutputStream = getImageIO().createImageOutputStream(arguments.OutputStream) />
					<cfset ImageWriter.setOutput(ImageOutputStream) />
					<cfset ImageWriter.write(JavaCast('null',''),IIOImage,ImageWriteParam) />
					<cfset Image.flush() />
					<cfset ImageOutputStream.flush() />
					<cfset ImageWriter.dispose() />
					<cfset ImageOutputStream.close() />
					<cfset arguments.OutputStream.close() />
					<cfbreak />
				<cftry>

					<cfcatch></cfcatch>
				</cftry>
			</cfloop>
	</cffunction>

	<cffunction name="getImageIO" access="private" output="false" returntype="any">
		<cfif not structKeyExists(variables.instance,'ImageIO')>
			<cfset variables.instance.ImageIO = CreateObject("Java", "javax.imageio.ImageIO") />
		</cfif>
		<cfreturn variables.instance.ImageIO />
	</cffunction>

</cfcomponent>