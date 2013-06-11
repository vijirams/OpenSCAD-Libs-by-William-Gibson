// Parametric Printable Auger
// It is licensed under the Creative Commons - GNU GPL license.
// © 2013 by William Gibson
// http://www.thingiverse.com/thing:96462

use <../utils/build_plate.scad>



////////////
//Examples//
////////////

//Simple Example
// auger(rShaft=1/8*inch, r=.75*inch, h=1*inch, 
// turns=2, multiStart=1, flightThickness = 0.2, 
// overhangAngle=20, supportThickness=0.0);

//Multistart example
// auger(rShaft=1/2*inch, r=2*inch, h=2*inch, 
// turns=1, multiStart=3, flightThickness = 0.6, 
// overhangAngle=20, supportThickness=0.0);

//Support example
// auger(rShaft=1/2*inch, r=2*inch, h=2*inch, 
// turns=2, multiStart=1, flightThickness = 0.6, 
// overhangAngle=10, supportThickness=0.8);

//Pitch instead of turns example
// auger(rShaft=1/2*inch, r=1*inch, h=2*inch, 
// pitch=0.5*inch, multiStart=1, flightThickness = 0.6, 
// overhangAngle=20, supportThickness=0);

//Sloped auger example
// auger(rShaft=5, r1=50, r2=10, h=40, 
// turns=3, multiStart=1, flightThickness = 1, 
// overhangAngle=20, supportThickness=0.0);

//Truncated top Example
// auger(rShaft=1/8*inch, r=.75*inch, h=1*inch, 
// turns=2, multiStart=1, flightThickness = 0.2, 
// overhangAngle=20, supportThickness=0.0,
// truncateTop=true);


auger(rShaft=5, r1=30, r2=10, h=40, 
turns=4, multiStart=1, flightThickness = 1, 
overhangAngle=20, supportThickness=0.0,
truncateTop=true);



//Multiple-piece auger example
// assign(h1=50, h2=50, r1=50, r2=10, thick=1)
// {
	// auger(rShaft=5, r1=r1, r2=r2, h=h1, 
	// pitch=40, multiStart=1, flightThickness = thick, 
	// overhangAngle=20, supportThickness=0.0,
	// truncateTop=true);
	
	// rotate([0,0,439.02]) //Copy from "Total turns in degrees" 
	// translate([0,0,h1-0.1-thick])
	// auger(rShaft=5, r1=r2, r2=r2, h=h2, 
	// pitch=40, multiStart=1, flightThickness = thick, 
	// overhangAngle=20, supportThickness=0.0, $fn=202,
	// truncateTop=true);
// }


//////////////////////
//CUSTOMIZER OPTIONS//
//////////////////////

/* [Auger] */

//The total amount of twist, in degrees
Auger_twist = 877; //[90:1080]

//The radius of the auger's "flight" past the shaft
Auger_flight_radius = 20; //[5:50]

//The number of "flights" 
Auger_num_flights = 2; //[1:5]

//The height, from top to bottom of the "shaft"
Auger_flight_length = 100; //[10:200]

/* [Printer] */

//The overhang angle your printer is capable of
Printer_overhang_capability = 20; //[0:40]

//The thickness of perimeter support material
Auger_perimeter_thickness = 0.0; //[0:None, 0.8:Thin, 2:Thick]

/* [Uninteresting] */

//The radius of the auger's "shaft"
Auger_shaft_radius = 10; //[1:25]

//The thickness of the "flight" (in the direction of height)
Auger_flight_thickness = 1;  //[0.2:Thin, 1:Medium, 10:Thick]

//The difference between the larger and smaller radii
Auger_smaller_flight_radius_delta = 0; //[0:30]

Auger_handedness = "right";  //["right":Right, "left":Left]

/* [Build plate] */

//for display only, doesn't contribute to final object
build_plate_selector = 3; //[0:Replicator 2,1: Replicator,2:Thingomatic,3:Manual]
//when Build Plate Selector is set to "manual" this controls the build plate x dimension
build_plate_manual_x = 200; //[100:400]
//when Build Plate Selector is set to "manual" this controls the build plate y dimension
build_plate_manual_y = 200; //[100:400]

build_plate(build_plate_selector,build_plate_manual_x,build_plate_manual_y);

/* [Hidden] */

M_PI = 3.14159;
mm = 1;
inch = 25.4 * mm;


*auger(
rShaft = Auger_shaft_radius,
r1 = Auger_shaft_radius + Auger_flight_radius,
r2 = Auger_shaft_radius + Auger_flight_radius - Auger_smaller_flight_radius_delta,
h = Auger_flight_length,
overhangAngle = Printer_overhang_capability,
multiStart = Auger_num_flights,
flightThickness = Auger_flight_thickness,
turns = Auger_twist/360,
pitch=0,
supportThickness = Auger_perimeter_thickness,
handedness=Auger_handedness,
//$fn=50,
$fa=12,
$fs=2
);

//////////////////////
//Auger Library Code//
//////////////////////

//Notes: 
//Specify 'pitch' OR 'turns' (pitch overrides turns)
//rShaft >= 1mm please
//flightThickness >= extrusion thickness of your printer
//supportThickness >= 2 * extrusion width of your printer, or zero to turn off.

module auger(rShaft = 0.5*inch, r, r1=1*inch, r2=1*inch, h=1*inch, multiStart=1,
turns=1, pitch=0,
flightThickness = 0.2*mm, overhangAngle=20, supportThickness=0*mm,
handedness="right" /*"left"*/,
truncateTop=false)
{	
	assign(r1 = r>0 ? r : (r1<r2?r2:r1), r2 = r > 0 ? r : (r2>r2?r1:r2))
	{
		assign(extraFlightBot = tan(overhangAngle)*(r1-rShaft), extraFlightTop = tan(overhangAngle)*(r2-rShaft))
		{
			assign(_turns = ((pitch>0?h/(pitch+flightThickness):turns)), extraHeightForTruncation=truncateTop?extraFlightTop+flightThickness:0)
			{
				if(pitch != 0)
				{
					echo("Pitch defined - ignoring turns parameter");
					//Each 1 turn is a height of (pitch+flightThickness)
					//A height of h will make x turns where x = h / (pitch+flightThickness)
					
				}
				else
				{
					if(turns < 0)
					{
						echo("ERROR: Cannot handle negative turns. Use handedness='left' instead to reverse rotation.");
					}
				}
				echo("Total turn in degrees = ", 360*_turns);
				
				assign(_turns = _turns*(h+extraHeightForTruncation)/h, h=h+extraHeightForTruncation, r2 = r2 - extraHeightForTruncation/h*(r1-r2))
				{
					//echo(r1, r2);
					
					
					difference()
					{
						
						auger_not_truncated(rShaft=rShaft, r1=r1, r2=r2, h=h, turns=_turns, 
						flightThickness=flightThickness, overhangAngle=overhangAngle, 
						multiStart=multiStart, supportThickness=supportThickness,
						handedness=handedness=="right"?1:-1);
						
						//Cut off bottom of auger so it's printable.
						translate([0,0,-extraFlightBot])
						cube([r1 * 3,r1 * 3,2*extraFlightBot], center=true);
						
						if(truncateTop)
						{
							translate([0,0,h])
							cube([r1 * 3,r1 * 3,2*(extraFlightTop+flightThickness)], center=true);
						}
					}
				}
			}
		}
	}
}



module auger_not_truncated(rShaft = 0.5*inch, r1=1*inch, r2=1*inch, h=1*inch, turns=1, flightThickness = 0.2*mm, overhangAngle=20, multiStart=1, supportThickness=0*mm, handedness=1)
{
	//echo("rShaft", rShaft);
	//echo(overhangAngle);
	
	if(supportThickness > 0)
	{
		assign(supportAngle = atan2(h, r1-r2))
		{
			echo("supportAngle=",supportAngle);
			if(supportAngle < overhangAngle)
			echo("WARNING: Cannot print support material; overhang angle too steep");
			
			echo("delta r", sin(supportAngle)*supportThickness);
			echo("delta h", cos(supportAngle)*supportThickness);
			difference()
			{
				
				cylinder(h=h, r1=r1+0.3, r2=r2+0.3, $fa=$fa/2);
				
				translate([0,0,-0.1])
				cylinder(h=h-cos(supportAngle)*supportThickness, r1=r1+0.1-sin(supportAngle)*supportThickness, r2=r2+0.1-sin(supportAngle)*supportThickness, $fs=0.5);
				
				translate([0,0,-1])
				cylinder(h=h+2, r=r2+0.1-sin(supportAngle)*supportThickness);
				
			}
		}
	}
	
	cylinder(r=rShaft, h=h,$fs=0.5); //Central shaft
	
	
	for(start=[1:1:multiStart]) //render each flight
	{
		rotate([0,0,handedness*360*(start-1)/multiStart])
		augerFlight(flightThickness=flightThickness, turns=turns, rHidden=(rShaft>6?rShaft-5:1), rShaft=rShaft, r1=r1, r2=r2, h=h, overhangAngle=overhangAngle, handedness=handedness);
		
	} 
}


module augerFlight(flightThickness, turns, rHidden, rShaft, r1, r2, h, overhangAngle, handedness)
{
	//echo(r1, r2);
	if($fs < 0.1)
	{
		echo("WARNING: $fs too small - clamping to 0.1");
	}
	if($fa < 0.1)
	{
		echo("WARNING: $fa too small - clamping to 0.1");
	}
	
	//Calculate numSteps based on $fn, $fs, $fa
	assign($fs = max(0.1, $fs), $fa = max(0.1, $fa),
	numSteps=($fn > 0.0) ? $fn : 
	max(5,
	max(h/(max($fs,0.1)),
	max(360.0 * turns / $fa, 
	r1*2*M_PI*turns / max($fs,0.1)))))
	{
		echo("Number of Steps calculations:");
		echo("minimum",5);
		echo("height step", h/(max($fs,0.1)));
		echo("angle", 360.0 * turns / $fa);
		echo("perimeter size", r1*2*M_PI*turns / max($fs,0.1));
		echo("numSteps = maximum: ", numSteps);
		
		assign(heightStep=((h-(flightThickness))/numSteps))
		{
			
			for(step=[0:1:numSteps-1]) //For each step in a flight
			{
				assign(rBot=r1+(r2-r1)*(step+1)/numSteps, rTop=r1+(r2-r1)*step/numSteps)
				{
					assign(extraFlight = tan(overhangAngle)*(rBot-rShaft))
					{
						translate([0,0,-extraFlight]) //Move down so the extraFlight material is below z=0
						{
							rotate([0,0,handedness*turns*step/numSteps*360])
							translate([0,0,heightStep*step])
							if(handedness==1)
							augerPolyhedron(flightThickness=flightThickness, extraFlight=extraFlight, rHidden=rHidden, rShaft=rShaft, rBot=rBot, rTop=rTop, turns=turns, numSteps=numSteps, heightStep=heightStep);
							else
							mirror([1,0,0])
							augerPolyhedron(flightThickness=flightThickness, extraFlight=extraFlight, rHidden=rHidden, rShaft=rShaft, rBot=rBot, rTop=rTop, turns=turns, numSteps=numSteps, heightStep=heightStep);
							
						}
					} 
				}
			}
		}
	}
	
	module augerPolyhedron(flightThickness, extraFlight, rHidden, rShaft, rTop, rBot, turns, numSteps, heightStep)
	{
		//_1 is first angle, _2 is second angle
		//_I is inside, _O is outside
		
		
		assign(top_1_I=flightThickness+extraFlight, bot_1_I=0, 
		top_1_O=flightThickness+extraFlight, bot_1_O=extraFlight, 
		degOverlap=0.1, 
		rHiddenCorrection=(rShaft-rHidden)/(rBot-rShaft)
		)
		{		
			//echo(extraFlight);
			//echo(rHidden, rShaft, rBot, rTop);
			//echo("rHiddenCorrection=",rHiddenCorrection);
			//echo("rHiddenCorrection*extraFlight=",rHiddenCorrection*extraFlight);
			//echo("heightStep=",heightStep);
			
			polyhedron(
			points=[
			[0,rHidden,bot_1_I-rHiddenCorrection*extraFlight],	//0
			[0,rHidden,top_1_I],					//1
			[0,rBot, bot_1_O], 						//2
			[0,rTop, top_1_O], 						//3
			
			[-rHidden*sin(360*turns/numSteps+degOverlap), //4
			rHidden*cos(360*turns/numSteps+degOverlap),
			bot_1_I+heightStep-rHiddenCorrection*extraFlight], //+rHiddenCorrection*heightStep-rHiddenCorrection*extraFlight],
			//
			
			[-rHidden*sin(360*turns/numSteps+degOverlap), //5
			rHidden*cos(360*turns/numSteps+degOverlap),
			top_1_I+heightStep],
			
			[-rBot*sin(360*turns/numSteps+degOverlap), //6
			rBot*cos(360*turns/numSteps+degOverlap), 
			bot_1_O+heightStep],
			
			[-rTop*sin(360*turns/numSteps+degOverlap), //7
			rTop*cos(360*turns/numSteps+degOverlap), 
			top_1_O+heightStep]
			
			],
			triangles=[
			[0,1,2], //"triangle" 1
			[2,1,3],
			
			[4,6,5], //"triangle" 2
			[6,7,5],
			
			[1,4,5],
			[1,0,4], //Inner "square"
			
			[3,7,6],
			[3,6,2], //Outer "square"
			
			[0,2,4],
			[4,2,6], //Bottom "square"
			
			[1,5,3],
			[5,7,3], //Top "square"
			
			]);
		}
	}
	
	module augerPolyhedronBackup(flightThickness, extraFlight, rShaft, r, turns, numSteps, heightStep)
	{
		//_1 is first angle, _2 is second angle
		//_I is inside, _O is outside
		assign(top_1_I=flightThickness+extraFlight, bot_1_I=0, top_1_O=flightThickness+extraFlight, bot_1_O=extraFlight, degOverlap=0.1)
		{		
			polyhedron(
			points=[
			[0,rShaft,bot_1_I],		//0
			[0,rShaft,top_1_I],		//1
			[0,r, bot_1_O], //2
			[0,r, top_1_O], //3
			
			[-rShaft*sin(360*turns/numSteps+degOverlap), //4
			rShaft*cos(360*turns/numSteps+degOverlap),
			bot_1_I+heightStep],
			
			[-rShaft*sin(360*turns/numSteps+degOverlap), //5
			rShaft*cos(360*turns/numSteps+degOverlap),
			top_1_I+heightStep],
			
			[-r*sin(360*turns/numSteps+degOverlap), //6
			r*cos(360*turns/numSteps+degOverlap), 
			bot_1_O+heightStep],
			
			[-r*sin(360*turns/numSteps+degOverlap), //7
			r*cos(360*turns/numSteps+degOverlap), 
			top_1_O+heightStep]
			
			],
			triangles=[
			[0,1,2], //"triangle" 1
			[2,1,3],
			
			[4,6,5], //"triangle" 2
			[6,7,5],
			
			[1,4,5],
			[1,0,4], //Inner "square"
			
			[3,7,6],
			[3,6,2], //Outer "square"
			
			[0,2,4],
			[4,2,6], //Bottom "square"
			
			[1,5,3],
			[5,7,3], //Top "square"
			
			
			]);
		}
	}
}



