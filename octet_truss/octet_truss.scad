// --- BUILD TYPE ---

NODE = 1;
MULTINODE = !1;
LEG = !1;

// --- CONFIG ---

LEG_LENGTH = 50;
NODE_DIAMETER = 20;
MULTINODE_X = 4;
MULTINODE_Y = 4;

// Don't change these

hd = NODE_DIAMETER / 8;
ld = NODE_DIAMETER / 4;

hd1 = hd * sqrt(2);
hd2 = hd;
ld1 = ld * sqrt(2);
ld2 = ld;

inrad = NODE_DIAMETER / 2 / sqrt(2);

truncate_tip = 1;

// --- DRAW ---

if (LEG) {
  draw_leg();
}

if (NODE) {
  draw_node();
}

if (MULTINODE) {
  for (i = [0:MULTINODE_X - 1]) for (j=[0:MULTINODE_Y - 1]) {
    translate([i, j, 0] * (NODE_DIAMETER * sqrt(2) / 2 + 0.5))
    draw_node();
  }
}

// --- VECTOR CONSTANTS ---

cv = [
  [-1,-1,-1], // 00
  [-1,-1, 1], // 01
  [-1, 1,-1], // 02
  [-1, 1, 1], // 03
  [ 1,-1,-1], // 04
  [ 1,-1, 1], // 05
  [ 1, 1,-1], // 06
  [ 1, 1, 1], // 07
  
  [ 0, 0,-2], // 08
  [ 0, 0, 2], // 09
  [ 0,-2, 0], // 10
  [ 0, 2, 0], // 11
  [-2, 0, 0], // 12
  [ 2, 0, 0], // 13
];

cf = [
  [ 3,11, 7, 9],
  [ 7,11, 6,13],
  [ 6,11, 2, 8],
  [ 2,11, 3,12],
  [ 5,10, 1, 9],
  [ 1,10, 0,12],
  [ 0,10, 4, 8],
  [ 4,10, 5,13],
  
  [ 8, 2,12, 0],
  [12, 3, 9, 1],
  [ 9, 7,13, 5],
  [13, 6, 8, 4],
];

tv = [
  [0, 0, 0],
  [2, 0, 0],
  [1, 1, 1],
  [0, 2, 0],
  [1, 1,-1]
];

tf = [
  [0, 2, 1],
  [0, 3, 2],
  [0, 4, 3],
  [0, 1, 4],
  [1, 2, 3, 4]
];

// --- STUFF ---

module hole(s=1, rot=false) {
  lv = [
    [hd1, 0],
    [0, hd2],
    [-hd1, 0],
    [0, -hd2]
  ];
  rotV = rot ? [0, 0, 90] : [0, 0, 0];
  rotate(rotV)
    linear_extrude(height=NODE_DIAMETER*2, center=true)
    polygon(lv*s);
}

module holes(s=1) {
  rotate([0,45,0]) hole(s);
  rotate([45,0,0]) hole(s, 1);
  rotate([0,-45,0]) hole(s);
  rotate([-45,0,0]) hole(s, 1);
  rotate([90,0,45]) hole(s);
  rotate([0,90,45]) hole(s, 1);
}

module nodehull() {
  intersection() {
    polyhedron(cv * NODE_DIAMETER / 4, cf);
    cube([1,1,1] * NODE_DIAMETER * sqrt(3) / 2, center=true);
  }
}

module leg_extrudable(s=1) {
  ld1Vec = [ld1, 0];
  ld2Vec = [0, ld2];
  lv = [
    (ld1Vec + ld2Vec) / 2,
    ld2Vec,
    (-ld1Vec + ld2Vec) / 2,
    (-ld1Vec - ld2Vec) / 2,
    -ld2Vec,
    (ld1Vec - ld2Vec) / 2,
  ];
  polygon(lv * s);
}

module leg_end() {
  intersection() {
    rotate([-90, 0, 0])
    rotate([0, 0, 45])
    polyhedron(tv * ld / 2, tf);
    translate([0, 0, -10 - truncate_tip])
    linear_extrude(20, center=true)
    leg_extrudable(0.5);
  }
}

module draw_node() {
  rotate([0, 0, 45])
  difference() {
    nodehull();
    holes();
  }
}

module draw_leg() {
  l1 = LEG_LENGTH - inrad;
  l2 = LEG_LENGTH - inrad * 2;
  rotate([0, 90, 0])
  rotate([90, 0, 0]) {
    linear_extrude(height=l2, center=true)
    leg_extrudable(0.75);
    hull() {
      linear_extrude(height=l1, center=true)
      leg_extrudable(0.5);
      for (i = [0:1])
        rotate([180 * i, 0 ,0])
        translate([0, 0, LEG_LENGTH / 2])
        leg_end();
    }
  }
}