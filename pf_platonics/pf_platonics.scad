// --- BUILD TYPE ---

// 1: Face
// 2: Edge
PART = 1;

// 0: Tetrahedron
// 1: Hexahedron
// 2: Octahedron
// 3: Dodecahedron
// 4: Icosahedron
// 5: Truncated octahedron hexes and edges (bonus shape!)
SHAPE = 0;

// --- CONFIG ---

HEIGHT = 2;
WIDTH = 10;
LEG_LENGTH = 15;
FACE_RADIUS = 10;

// Set $fs to change arc precision
// (To use $fa instead, set $fs arbitrarily small and make $fa larger)
$fa = 0.01;
$fs = 1;

// --- CONSTANTS AND DERIVED VALUES ---

ANGLES = [
  acos(1 / 3),
  90,
  180 - acos(1 / 3),
  180 - atan(2),
  180 - acos(sqrt(5) / 3),
  2 * acos(1 / sqrt(3))
];

CORNERS = [
  3,
  4,
  3,
  5,
  3,
  6
];

ANGLE = ANGLES[SHAPE];
CORNER = CORNERS[SHAPE];

FACE = PART == 1;
EDGE = PART == 2;

// --- BUILD ---

if (FACE || !1) face();
if (EDGE || !1) edge();
  
// ------

module hole() {
  square([WIDTH, HEIGHT], center=true);
}
module circ(w=WIDTH) {
  circle(w / 2);
}
module leg() {
  linear_extrude(height=HEIGHT, center=true)
  difference() {
    hull() {
      circ();
      translate([LEG_LENGTH, 0])
      circ();
    }
  translate([LEG_LENGTH + WIDTH / 2, 0])
  hole();
  }
}

module edge() {
  leg();
  rotate([0, 0, ANGLE])
  leg();
//  hull() intersection() {
//    union() {
//    leg();
//    rotate([0, 0, ANGLE])
//      leg();
//    }
//    cube([WIDTH, WIDTH, HEIGHT * 2], center=true);
//  }
}

module face() {
  corner_angle = 360 / CORNER;
  linear_extrude(height=HEIGHT, center=true)
  for (i = [0:CORNER - 1])
  difference() {
    hull() {
      circ();
      translate([
        cos(corner_angle * i),
        sin(corner_angle * i)
      ] * FACE_RADIUS)
      circ();
    }
    rotate(corner_angle * i)
    translate([FACE_RADIUS + WIDTH / 2, 0])
    hole();
  }

}
