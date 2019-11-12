// --- BUILD TYPE ---

// 1: Strut
// 2: Connector
// 3: Both
PART = 1;

// --- CONFIG ---

LEN_STRUT = 20;
LEN_CON = 10;
WIDTH = 10;
HEIGHT = 2;

$fa = 0.01;
$fs = 0.1;

// --- BUILD ---

if (PART % 2 == 1)
  part();

if (floor(PART / 2) % 2 == 1)
  connector();

// --- STUFF ---

module leg() {
  difference() {
    hull() {
      circle(WIDTH/2);
      translate([LEN_STRUT, 0])
      circle(WIDTH / 2);
    }
    translate([LEN_STRUT + WIDTH / 2, 0])
    square([WIDTH, HEIGHT], center=true);
  }
}

module connector() {
  translate([0, WIDTH * 1.5, 0])
  rotate([0, 0, 90])
  linear_extrude(height=HEIGHT, center=true)
  difference() {
    hull() {
      circle(WIDTH / 2);
      translate([LEN_CON, 0])
      circle(WIDTH / 2);
    }
    translate([-WIDTH / 2, 0])
    square([WIDTH, HEIGHT], center=true);
    translate([LEN_CON + WIDTH / 2, 0])
    square([WIDTH, HEIGHT], center=true);
  }
}

module part() {
  a = acos(-1 / 3);
  difference() {
    rotate([0, 0, 90 - a / 2])
    linear_extrude(height=HEIGHT, center=true) {
      leg();
      rotate(a)
      leg();
    }
  translate([0, 5, 0])
  cube([HEIGHT, 10, 10], center=true);
  }
}


