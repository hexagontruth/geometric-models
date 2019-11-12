// --- BUILD TYPE ---

part = 1;

// --- CONFIG ---

HEIGHT = 2;
HOLE_LENGTH = 6;
LEG_WIDTH = 10;
LEG_LENGTH = 20;
NODE_RADIUS = 30;
CORNER_RADIUS = 0.5;

// Change these to e.g. print arbitrary press fit polyhedral faces,
// irregular honeycombs, etc.

ANGLE = 2 * acos(1/sqrt(3));
SIDES = 6;
LEGS = 2;

// Set $fs to change arc precision
// (To use $fa instead, set $fs arbitrarily small and make $fa larger)
$fa = 0.01;
$fs = 1;

// --- DERIVED VALUES ---

d = HEIGHT - CORNER_RADIUS*2;
hl = HOLE_LENGTH + CORNER_RADIUS;
hw = HEIGHT + CORNER_RADIUS * 2 + 0.1;
w = LEG_WIDTH - CORNER_RADIUS * 2;
l = LEG_LENGTH - CORNER_RADIUS * 2;
r = NODE_RADIUS - CORNER_RADIUS * 2;
ir = NODE_RADIUS + CORNER_RADIUS - HOLE_LENGTH * 2 / cos(180 / SIDES);
apothem = NODE_RADIUS * cos(180 / SIDES);

// --- BUILD ---

mink() {
  if (floor(part / 2) % 2 == 1)
    edge();
  if (part % 2 == 1)
    node();
}

// --- STUFF ---

module mink() {
  minkowski() {
    children();
    sphere(CORNER_RADIUS);
  }
}

module disc(r) {
  cylinder(h=d, r1=r, r2=r);
}

module hole2() {
  square([hl * 2, hw], center=true);
}

module hole3() {
  linear_extrude(d * 10, center=true)
  hole2();
}

module leg() {
  difference() {
    hull() {
      disc(w / 2);
      translate([l - w, 0, 0])
      disc(w / 2);
    }
    translate([l - w / 2 ,0, 0])
    hole3();
  }
}

module edge() {
  for (i=[0:LEGS-1])
    rotate([0, 0, ANGLE * i])
    leg();
}

module node() {
  linear_extrude(height=d, center=true) {
    difference() {
      rotate(360 / SIDES / 2)
      circle(r, $fn=SIDES);
      rotate(360 / SIDES / 2)
      circle(ir, $fn=SIDES);
      for (i = [0:SIDES - 1]) {
        rotate(360 / SIDES * i)
        translate([apothem, 0, 0])
        hole2();
      }
    }
  }
}
