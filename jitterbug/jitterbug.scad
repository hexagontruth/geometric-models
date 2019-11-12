// --- BUILD TYPE ---

PART = 3;
TEST = 0;

// --- CONFIG ---

// This is a bit overbuilt and it's not clear all of these params
// are necessary. Change one to see what it does.
n = 70;
h = 6;
hole_r = 3;
lip_h = 2;
lip_r = 3.6;
hole_inset = 6;

bolt_b = 1;
lip_g = 0.75;
lip_o = 0.4;
w = 0.2;
w2 = 0.2;

bolt_h = h - lip_h;

// Set $fs to change arc precision
// (To use $fa instead, set $fs arbitrarily small and make $fa larger)
$fs = 0.5;
$fa = 0.1;

// --- CONSTANTS AND DERIVED VALUES ---

r2 = sqrt(2)/2;
r3 = sqrt(3)/2;
da = acos(1 / 3);

outer_r = hole_r + hole_inset;
run_h = h / tan((180 - da) / 2);
rise_i = outer_r * tan((180 - da) / 2);


// --- MAIN ---

PANEL = PART % 2 == 1 ? true : false;
NODE = floor(PART/2) % 2 == 1 ? true : false;

difference(convexity=10) {
  union() {
    if (PANEL)
      panel();
    if (NODE)
      node();
  }
  if (TEST)
    translate([50,0,0]) cube([1,1,1]*100, center=true);
}

// --- STUFF ---

module rotator() {
  rotate([acos(1 / sqrt(3)), 0, 0])
  rotate([0, 0, 45])
  children();
}

module cyl(r1, r2=false, diff=false, fn=0) {
  r2 = r2 == false ? r1 : r2;
  h = diff ? h * 3 : h;
  center = diff ? true : false;
  cylinder(h, r1, r2, $fn=fn, center=center);
}

module bolt() {
  difference() {
    union() {
      cylinder(h=bolt_h + lip_h / 2, r1=hole_r - w, r2=hole_r - w);
      translate([0, 0, bolt_h + w2])
      cylinder(h=lip_h - w2, r1=hole_r + lip_o, r2=hole_r - w);
    }
    for (i = [0:2])
      rotate([0, 0, 120 * i])
      translate([0, n, 0])
      cube([lip_g, n * 2, n * 2], center=true);
  }
}

// --- MODELSTUFF ---

module panel()
translate([0,0,h])
rotate([0,180,0]) {
  difference(convexity=10) {
    union() {
      hull(convexity=10) {
        for (i = [0:2]) {
          rotate(120 * i)
          translate([0, n * r3 * 2 / 3 - outer_r * 2])
          cyl(outer_r, outer_r - run_h);
        }
      }
    }
    hull() {
      for (i = [0:2]) {
        rotate(120 * i)
        translate([0, n * r3 * 2 / 3 - outer_r * 2]) {
          cyl(hole_r, diff=true);
          translate([0, 0, -lip_h])
          cylinder(h=lip_h * 2, r1=lip_r, r2=lip_r);
        }
      }
    }
  }
  for (i = [0:2]) {
    rotate(120 * i)
    translate([0, n * r3 * 2 / 3 - outer_r * 2, 0])
    difference(convexity=10) {
      cyl(outer_r, outer_r - run_h);
      cyl(hole_r, diff=true);
      translate([0, 0, -lip_h])
      cylinder(h=lip_h * 2, r1=lip_r, r2=lip_r);
    }
  }
}

module node() {
  bolt_pivot = rise_i - h;
  translate([0, n * r3 * 2 / 3 - outer_r * 2]) {
    for (i=[0:1])
    translate([0, 0, -bolt_pivot])
    rotate([-da * i, 0, 0])
    translate([0, 0, bolt_pivot]) {
      rotate([0, 0, 60 * i]) bolt();
    }
    difference() {
      hull() {
        for (i=[0:1])
          translate([0,0,-bolt_pivot])
          rotate([-da * i, 0, 0])
          translate([0, 0, bolt_pivot])
          translate([0, 0, -bolt_b])  {
            cylinder(h=bolt_b, r1=hole_r - w, r2=hole_r - w);
            translate([0, 0, -1])
            cube([hole_r, hole_r, 1], center=true);
          }
      }
    }
  }
}
