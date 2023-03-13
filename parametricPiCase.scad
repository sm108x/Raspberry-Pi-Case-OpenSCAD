/*[Board selection]*/
boardSize="B"; // [A, B]
boardVersion=4; // [1,2,3,4]
boardVariant=""; // [Standard, Plus]

/* [Margins] */
// the margin between the board and the case
sideMargin=.9;
// margin around connectors
connectorHoleMargin=.5;
// space between the bottom of the board and the floor of the case
bottomMargin=2;
// margin around the port blocks
portBlockMargin=0.5;

/*[Thickness]*/
// Thickness of the base
baseThickness=1.9;
// Thickness of the side walls
wallThickness=2.1;
// Lid Thickness
lidThickness=1.9;

/*[Resolution]*/
$fs=.5;
$fa=5;

/*[Features]*/
sdCardExtendToCaseBottom=true;
lidHeight=10;
coverCase=true;
heightDelta=0; //[-20:0.1:40]

/*[What parts to render]*/
renderParts="whole"; //[whole, top, bottom, split]
splitHeight=7; // [0:0.1:50]

/*[Vents]*/
// the size of the margin on the the outside of the board outline where vents are not allowed
bottomVentInsets=4;
// the ratio of open to filled surface (decimal between 0 and 1, higher = more open)
bottomVentsOpenRatio=.8;
// over height

bottomVentsFrequency=0;
/*[Fan spec]*/
fanMount="screws"; //[screws,grippers,throughScrews,recessedIntoLid]
fanSide=40;
fanHubDiameter=25;
fanSideRoundingRadius=2;
fanThickness=10.5;
fanScrewHoleRadius=1.5;
// distances from outside
fanDistanceFromEdge=.5;
fanDiameter=fanSide-fanDistanceFromEdge*2;
fanHoleOutsideDistanceFromEdge=1.9;
fanHoleDistanceFromEdge=fanHoleOutsideDistanceFromEdge+fanScrewHoleRadius;
// how wide are the fingers gripping the fan
fanGripWidth=8;
// how far off-center length-ways is the fan (negative=towards sdcard)
fanXoffset=-5;
fanYoffset=0;
// stand-off to leave space for the fan to spin
fanGrillDistance=.5;
fanGripperTolerance=.1;

/* [Hidden] */
// The below are not configurable
boardThickness=1;
boardCornerRadius=3;
mountingHoleXoffset=58;
mountingHoleYoffset=49;

usbBlockDepth=17.5;
usbBlockCenterOffset=4;
ethBlockDepth=22;
ethBlockCenterOffset=4;

usbBlockHeight=16;

MIN=-1;
CENTER=0;
MAX=1;

function getBoardLength() = boardSize=="B"?85:65;
function getBoardHeight() = 56;
function getBoardMaxZ()=boardThickness+usbBlockHeight+connectorHoleMargin*2;

insideCaseHeight=getBoardMaxZ()+bottomMargin+(coverCase?0:lidThickness)+heightDelta;
outsideCaseHeight=insideCaseHeight+baseThickness+(coverCase?lidThickness:0);
caseLength=getBoardLength()+(sideMargin+wallThickness)*2;
caseWidth=getBoardHeight()+(sideMargin+wallThickness)*2;

module alignToBoard(x=CENTER, y=CENTER, z=CENTER) {
  translate([x*getBoardLength()/2, y*getBoardHeight()/2, z*boardThickness]) {
    children();
  }
}

module alignToMountingHoles(z=MIN) {
  for (x=[MIN, MAX]) {
    for (y=[MIN, MAX]) {
      alignToMountingHole(x,y, z) children();
    }
  }
}

module alignToMountingHole(x=MIN, y=MIN, z=CENTER) {
  alignToBoard(MIN, MIN, z){
    translate([3.5, 3.5, 0]) {
      translate([(x+1)/2*mountingHoleXoffset, (y+1)/2*mountingHoleYoffset, 0]) {
        children();
      }
    }
  }
}

module boardOutline(holes=true) {
  circleXoffset=getBoardLength()-boardCornerRadius*2;
  circleYoffset=getBoardHeight()-boardCornerRadius*2;
  difference() {
    hull() {
      for (x=[0:1]) {
        for (y=[0:1]) {
          translate([-circleXoffset/2+x*circleXoffset, -circleYoffset/2+y*circleYoffset, 0]) {
            circle(r=boardCornerRadius);
          }
        }
      }
    }
    if (holes) {
      alignToMountingHoles() circle(r=2.8/2);;
    }
  }
}

module board() {
  linear_extrude(height=boardThickness, center=true, convexity=10, twist=0) {
    boardOutline();
  }
}

module alignToPowerConnector() {
  xoffset=(boardSize=="B" && boardVersion>=4)?(3.5+7.7):(10.6);
  alignToBoard(MIN, MIN, MAX){
    translate([xoffset, 0, 3.2/2]) {
      children();
    }
  }
}

module alignToHdmi0() {
  alignToBoard(MIN, MIN, MAX){
    translate([3.5+7.7+14.8, 0, 3/2]) {
      children();
    }
  }
}

module alignToHdmi1() {
  alignToHdmi0()
    translate([13.5, 0, 0])
      children();
}

module alignToAudioJack() {
  xoffset=(boardSize=="B" && boardVersion>=4)?(3.5+7.7+14.8+13.5+7+7.5):53.5;
  alignToBoard(MIN, MIN, MAX) translate([xoffset, 0, 6/2]) {
    children();
  }
}

module powerConnectorOutline(margin=connectorHoleMargin) {
  if (boardSize=="B" && boardVersion>=4) {
    offset(r=margin)
      square(size=[10,4], center=true); // 9.1x3.8
  } else {
    offset(r=margin)
    square(size=[10,4], center=true); // 9.1x3.8
  }
}

module powerConnectorHole() {
  alignToPowerConnector() hdmiSideHole() powerConnectorOutline();
}

module hdmiSideHole() {
  caseHole(rotation=0) children();
}

module caseHole(rotation=0) {
  rotate([0, 0, rotation]) {
    translate([0, -sideMargin, 0]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=wallThickness*2, center=true, convexity=10, twist=0) {
          children();
        }
      }
    }
  }
}

module microHdmiHoleOutline(margin=connectorHoleMargin) {
  offset(r=margin)
  square(size=[6, 2], center=true);
}

module hdmi0hole() {
  alignToHdmi0(){
    hdmiSideHole(){
      microHdmiHoleOutline();
    }
  }
}

module hdmi1hole() {
  alignToHdmi1(){
    hdmiSideHole(){
      microHdmiHoleOutline();
    }
  }
}

module audioJackHole() {
  alignToAudioJack() hdmiSideHole() circle(d=6+connectorHoleMargin*2); // 6 measured
}

module hdmiConnectorOutline(margin=connectorHoleMargin) {
  offset(r=margin) square(size=[14, 4.5], center=true);
}

module hdmiHoles() {
  if (boardSize=="B" && boardVersion==4) {
    hdmi0hole();
    hdmi1hole();
  } else {
    alignToHdmi() hdmiSideHole() hdmiConnectorOutline();
  }
}

module alignToHdmi() {
  alignToBoard(MIN, MIN, MAX) translate([32, 0, 6.5/2]) children();
}

module usbHoleOutline(margin=.5) {
  height=(boardSize=="B")?16:8; // FIX height for model A
  offset(r=margin)
  square(size=[13.5, height], center=true);
}

module alignToUsbLeft() {
  yOffset=(boardVersion>=4)?9:29;
  alignToBoard(MAX, MIN, MAX) translate([0, yOffset, 16/2]) children();
}

module alignToUsbRight() {
  yoffset=(boardVersion>=4)?(27-9):(47-29);
  alignToUsbLeft() translate([0, yoffset, 0]) children();
}

module usbSideHole() {
  rotate([0, 0, 90]) hdmiSideHole() children();
}

module usbHoleLeft() {
  alignToUsbLeft() usbSideHole() usbHoleOutline();
}

module usbHoleRight() {
  alignToUsbRight() usbSideHole() usbHoleOutline();
}

module alignToSingleUsb() {
  alignToBoard(MAX, MIN, MAX) translate([0, 29, 8/2]) children();
}

module singleUsbHole(margin=connectorHoleMargin) {
  alignToSingleUsb() usbSideHole() usbHoleOutline();
}

module usbHoles() {
  if (boardSize=="A") {
    singleUsbHole();
  } else{
    if (boardVersion==4 || boardVersion>1 || boardVersion==1&&boardVariant=="Plus") {
      usbHoleLeft();
      usbHoleRight();
    } else {
      #linear_extrude(height=10, center=true, convexity=10, twist=0) {
        text("Unsupported", size=10, font="Liberation Sans", halign="left", valign="baseline",
          spacing=1.0, direction="ltr", language="en", script="latin");
      }
    }
  }
}

module alignToEthPort() {
  yOffset=(boardVersion>=4)?45.75:10.25;
  alignToBoard(MAX, MIN, MAX) translate([0, yOffset, 13.5/2]) children();
}

module ethHoleOutline(margin=.5) {
  offset(r=margin)
  square(size=[16, 13.5], center=true);
}

module ethHoles() {
  if (boardSize!="A") {
    alignToEthPort() usbSideHole() ethHoleOutline();
  }
}

module sdCardHoleOutline(margin=connectorHoleMargin) {
  offset(r=margin)
    square(size=[11, 1], center=true);
}

module alignToSdCard() {
  alignToBoard(MIN, MIN, MIN) translate([0, 3.5+24.5, -.5]) children();
}

module sdCardHole(extendToCaseBottom=sdCardExtendToCaseBottom) {
  extraHeight=baseThickness+bottomMargin;
  translate([0, 0, extendToCaseBottom?(-extraHeight/2):0])
    minkowski() {
      alignToSdCard()
        caseHole(rotation=-90)
          sdCardHoleOutline();
      if (extendToCaseBottom) {
        cube(size=[.01,.01,extraHeight], center=true);
      }
    }
}

module bottomVentsPattern() {
  height=getBoardHeight();
  length=getBoardLength();
  distance=height/bottomVentsFrequency;
  xCount=ceil(bottomVentsFrequency/height*length);
  squareSide=distance*sqrt(bottomVentsOpenRatio);
  for (i=[0:xCount-1]) {
    for (j=[0:bottomVentsFrequency-1]) {
      translate([-length/2+i*distance+(distance-squareSide)/2, -height/2+j*distance+(distance-squareSide)/2, 0]) {
        square(squareSide);
      }
    }
  }
}

module bottomVentsOutline() {
  intersection() {
    offset(r=-bottomVentInsets)
      boardOutline();
    bottomVentsPattern();
  }
}

module bottomVents() {
  fudge=.1;
  if (bottomVentsFrequency>0) {
    #alignToBoard(CENTER, CENTER, MIN) translate([0, 0, -baseThickness-bottomMargin-fudge]) {
      linear_extrude(height=baseThickness+fudge*2, center=false, convexity=10, twist=0) {
        bottomVentsOutline();
      }
    }
  }
}

module topVents() {
  echo("TODO");
}

module sideVents(height) {
  echo("TODO");
}

module ventHoles(height) {
  bottomVents();
  topVents();
  sideVents(height);
}

module caseHoles(height) {
  powerConnectorHole();
  hdmiHoles();
  audioJackHole();
  usbHoles();
  ethHoles();
  sdCardHole();
  ventHoles(height);
}

module fanGrill() {
  difference() {
    cylinder(d=fanDiameter, h=lidThickness, center=false);
    cylinder(d=fanHubDiameter, h=lidThickness, center=false);
    for (i=[0:3]) {
      rotate([0, 0, 45+i*90]) {
        translate([0, -1, 0]) {
          cube(size=[fanSide, 2, fanThickness], center=false);
        }
      }
    }
  }
  translate([0, 0, lidThickness-fanGrillDistance]) {
    cylinder(d=fanDiameter, h=lidThickness, center=false);
  }
}

module alignToFanScrewHoles() {
  screwHoleDistance=fanSide-fanHoleDistanceFromEdge*2;
  translate([-screwHoleDistance/2, -screwHoleDistance/2, 0]) {
    for (i=[0:1]) {
      for (j=[0:1]) {
        translate([i*screwHoleDistance, j*screwHoleDistance, 0]) {
          children();
        }
      }
    }
  }
}

module basicCaseShell() {
  difference() {
    // shell
    alignToBoard(CENTER, CENTER, MIN) translate([0, 0, -baseThickness-bottomMargin]) difference(){
      // outside of shell
      linear_extrude(height=outsideCaseHeight, center=false, convexity=10, twist=0) {
        offset(r=wallThickness+sideMargin)
        boardOutline(holes=false);
      }
      // inside of shell
      translate([0, 0, baseThickness]) {
        linear_extrude(height=insideCaseHeight, center=false, convexity=10, twist=0) {
          offset(r=sideMargin)
          boardOutline(holes=false);
        }
      }
    }
    //holes
    caseHoles(height=outsideCaseHeight);
    // inner volumes for the port blocks
    alignToEthPort() portBlock(ethBlockDepth, ethBlockCenterOffset) ethHoleOutline(0);
    hull() {
      alignToUsbLeft() portBlock(usbBlockDepth, usbBlockCenterOffset) usbHoleOutline(0);
      alignToUsbRight() portBlock(usbBlockDepth, usbBlockCenterOffset) usbHoleOutline(0);
    }

    // fan grill
    alignToCaseOuterShell(CENTER, CENTER, MAX) translate([fanXoffset, fanYoffset, 0]) {
      mirror([0, 0, 1]){
        if (fanMount=="recessedIntoLid") {
          linear_extrude(height=lidThickness, center=false, convexity=10, twist=0) {
            offset(r=fanGripperTolerance)
            fanOutline();
          }
        }else{
          fanGrill();
          if (fanMount=="throughScrews"){
            alignToFanScrewHoles() cylinder(r=fanScrewHoleRadius, h=lidThickness*2, center=false);
          }
        }
      }
    }
  }

  // fan mount
  alignToCaseOuterShell(CENTER, CENTER, MAX){
    translate([fanXoffset, fanYoffset, -lidThickness]) {
      if (fanMount=="grippers" || fanMount=="recessedIntoLid") {
        // grippers
        translate([0, 0, (fanMount=="recessedIntoLid")?lidThickness:0]) {
          for (i=[0:3]) {
            rotate([0, 0, i*90]) {
              translate([0, fanSide/2+fanGripperTolerance, 0]) {
                rotate([0, 90, 0]) {
                  fanGrip();
                }
              }
            }
          }
        }
      } else if (fanMount=="screws"){
        fanScrewHoleLength=2;
        for (i=[0:3]) {
          rotate([0, 0, i*90]) {
            translate([fanSide/2-fanHoleDistanceFromEdge, fanSide/2-fanHoleDistanceFromEdge, 0]) {
              mirror([0, 0, 1]) {
                difference() {
                  cylinder(r=fanScrewHoleRadius+.4, h=fanScrewHoleLength, center=false);
                  cylinder(r1=fanScrewHoleRadius*.95, r2=fanScrewHoleRadius*1.01, h=fanScrewHoleLength, center=false);
                }
              }
            }
          }
        }
      }
    }
  }
  // board mounting points
  alignToMountingHoles(z=MIN) translate([0, 0, -bottomMargin]) {
    difference() {
      cylinder(d=4, h=bottomMargin, center=false);
      cylinder(d=2.6, h=bottomMargin, center=false);
    }
  }
}

module alignToCaseOuterShell(x=CENTER, y=CENTER, z=CENTER) {
  caseMinZ=-baseThickness-bottomMargin-boardThickness;
  caseCenterZ=caseMinZ+outsideCaseHeight/2;
  translate([0, 0, caseCenterZ]) {
    translate([x*caseLength/2, y*caseWidth/2, z*outsideCaseHeight/2]) children();
  }
}

module portBlock(depth, offset) {
  minkowski() {
    translate([-depth+offset, 0, 0]) {
      rotate([0,90,0]) linear_extrude(height=depth, center=false) {
        rotate([0, 0, 90]) {
          children();
        }
      };
    }
    cube(size=portBlockMargin*2, center=true);
  }
}

module roundedRectangle(sides=[10,10], roundingRadius=1) {
  xoffset=sides[0]-roundingRadius*2;
  yoffset=sides[1]-roundingRadius*2;
  translate([-xoffset/2, -yoffset/2, 0]) {
    hull() {
      for (x=[0:1]) {
        for (y=[0:1]) {
          translate([x*xoffset, y*yoffset, 0]) {
            circle(r=roundingRadius);
          }
        }
      }
    }
  }
}

module roundedSquare(side, roundingRadius=1) {
  roundedRectangle([side, side], roundingRadius);
}

module fanOutline() {
  roundedSquare(fanSide, fanSideRoundingRadius);
}

module basicFanMass(args) {
  linear_extrude(height=fanThickness, center=true, convexity=10, twist=0) {
    fanOutline();
  }
}

module fan(cubeMargin=0) {
  alignToBoard(MIN, MAX, MAX)
  translate([fanSide/2, -fanSide/2, 12]) {
    minkowski() {
      basicFanMass();
      cube(size=[cubeMargin, cubeMargin, cubeMargin], center=true);
    }
  }
}

module basicCaseLid() {
  alignToBoard(CENTER, CENTER, CENTER){
    difference() {
      linear_extrude(height=lidHeight, center=true, convexity=10, twist=0) {
        offset(r=wallThickness+sideMargin) boardOutline(holes=false);
      }
      translate([0, 0, lidThickness]) {
        linear_extrude(height=lidHeight, center=true, convexity=10, twist=0) {
          offset(r=sideMargin) boardOutline(holes=false);
        }
      }
    }
  }
}

module fanGrip() {
  linear_extrude(height=fanGripWidth, center=true, convexity=10, twist=0) {
    fanGripOutline();
  }
}

module fanGripOutline() {
  polygon(points=[
    [0,0],
    [fanThickness,0],
    [fanThickness+.75, -.6],
    [fanThickness+1, 0],
    [fanThickness+1, 2],
    [0,6]
    ]);
}

module cutter() {
  maxGripHeight=fanThickness+1;
  difference() {
    translate([0, 0, -baseThickness-bottomMargin-outsideCaseHeight/2+splitHeight]) {
      cube(size=[caseLength, caseWidth, outsideCaseHeight], center=true);
    }
    translate([fanXoffset, fanYoffset, -baseThickness-bottomMargin+outsideCaseHeight-lidThickness-maxGripHeight/2]) {
      cube(size=[fanSide+16, fanSide+16, maxGripHeight], center=true);
    }
  }
}

module caseBottom() {
  intersection() {
    basicCaseShell();
    cutter();
  }
}

module caseTop() {
  difference() {
    basicCaseShell();
    cutter();
  }
}

if (renderParts=="top") {
  caseTop();
} else if(renderParts=="bottom"){
  caseBottom();
} else if(renderParts=="whole"){
  basicCaseShell();
} else if(renderParts=="split"){
  translate([0, 0, 10]) {
    caseTop();
  }
  caseBottom();
}
