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
wallThickness=1.5;
// Lid Thickness
lidThickness=1.5;

/*[Resolution]*/
$fs=.5;
$fa=5;

/*[Features]*/
sdCardExtendToCaseBottom=true;
lidHeight=10;
coverCase=false;
heightDelta=0;

/*[What parts to render]*/
renderBottom=true;
splitHeight=1.1;

/*[Vents]*/
// the size of the margin on the the outside of the board outline where vents are not allowed
bottomVentInsets=4;
// the ratio of open to filled surface (decimal between 0 and 1, higher = more open)
bottomVentsOpenRatio=.8;
// over height

bottomVentsFrequency=0;
/*[Fan spec]*/
fanMount="screws"; //[screws,grippers]
fanSide=40;
fanHubDiamter=25;
fanSideRoundingRadius=2;
fanThickness=11;
fanScrewHoleRadius=3/2;
// distances from outside
fanDistanceFromEdge=.5;
fanHoleDistanceFromEdge=2+fanScrewHoleRadius;
// how wide are the fingers gripping the fan
fanGripWidth=8;
// how far off-center length-ways is the fan (negative=towards sdcard)
fanxofset=-5;
// stand-off to leave space for the fan to spin
fanGrillDistance=.5;

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
  if (bottomVentsFrequency>0) {
    alignToBoard(CENTER, CENTER, CENTER) translate([0, 0, -baseThickness-bottomMargin]) {
      linear_extrude(height=baseThickness, center=false, convexity=10, twist=0) {
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

module basicCaseShell() {
  translate([0, 0, -baseThickness-bottomMargin]) {
    translate([0, 0, baseThickness]) {
      alignToMountingHoles(z=CENTER){
        difference() {
          cylinder(d=4, h=bottomMargin, center=false);
          cylinder(d=2.6, h=bottomMargin, center=false);
        }
      }
    }
    alignToBoard(CENTER, CENTER, CENTER){
      difference() {
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
        translate([0, 0, baseThickness+bottomMargin]) {
          //holes
          caseHoles(height=outsideCaseHeight);
          // inner volumes for the port blocks
          alignToEthPort() portBlock(ethBlockDepth, ethBlockCenterOffset) ethHoleOutline(0);
          alignToUsbLeft() portBlock(usbBlockDepth, usbBlockCenterOffset) usbHoleOutline(0);
          alignToUsbRight() portBlock(usbBlockDepth, usbBlockCenterOffset) usbHoleOutline(0);
        }

        // fan grill
        translate([fanxofset, 0, outsideCaseHeight-lidThickness/2]) {
          difference() {
            cylinder(d=fanSide, h=lidThickness+1, center=true);
            cylinder(d=fanHubDiamter, h=lidThickness, center=true);
            for (i=[0:1]) {
              rotate([0, 0, 45+i*90]) {
                cube(size=[fanSide, 3, lidThickness], center=true);
              }
            }
          }
        }
      }
      // fan mount
      translate([fanxofset, 0, +outsideCaseHeight-lidThickness]) {
        if (fanMount=="grippers") {
          // grippers
          for (i=[0:3]) {
            rotate([0, 0, i*90]) {
              translate([0, fanSide/2, 0]) {
                rotate([0, 90, 0]) {
                  fanGrip();
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
                    cylinder(r=fanScrewHoleRadius+1, h=fanScrewHoleLength, center=false);
                    cylinder(r=fanScrewHoleRadius, h=fanScrewHoleLength, center=false);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


module alignToCaseOuterShell(x=CENTER, y=CENTER, z=CENTER) {
  echo("TO DEBUG");
  translate([0, 0, -baseThickness-bottomMargin]) {
    translate([x*caseLength/2, y*caseWidth/2, z*outsideCaseHeight/2]) {
      alignToBoard() children();
    }
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

module basicFanMass(args) {
  linear_extrude(height=fanThickness, center=true, convexity=10, twist=0) {
    roundedSquare(fanSide, fanSideRoundingRadius);
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
    translate([fanxofset, 0, -baseThickness-bottomMargin+outsideCaseHeight-lidThickness-maxGripHeight/2]) {
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

if (renderBottom) {
  caseBottom();
}else{
  intersection() {
    cube(size=[45,45,10], center=true);
    translate([-fanxofset, 0, 20]) {
      mirror([0, 0, 1]) {
        caseTop();
      }
    }
  }
}
