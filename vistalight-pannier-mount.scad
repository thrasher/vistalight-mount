// Vistalight pannier mount
// Jason Thrasher
// 7/19/2018
//
// dimensions in mm

$fs = 0.1; // mm per facet in cylinder
$fa = 5; // degrees per facet in cylinder
$fn = 100;

VL_WIDTH = 84.68;
VL_HEIGHT = 57.6;
VL_DEPTH = 21.5;
VL_NOB_DIA = 6 + 0.7; // 6.0 mm exact
VL_NOB_HEIGHT = 2.5 + 0.5; // 2.5 mm exact
VL_NOB_OFFSET = 19;

module bolt() {
    HEIGHT = 3.5;
    cylinder(d = 5.5, h = HEIGHT);
    translate([0,0,HEIGHT])
        cylinder(d = 13, h = 30);
}
module nobs() {
    translate([VL_NOB_OFFSET, 0, 0])
    cylinder(d = VL_NOB_DIA, h = VL_NOB_HEIGHT);
}

module mirror_copy(v = [1, 0, 0]) {
    children();
    mirror(v) children();
}
module vistalight() {
    translate([TUBE_DIA, 0, -VL_HEIGHT/2])
    rotate([-90,0,90])
    {
        translate([0, 0, -VL_DEPTH/2])
        cube([VL_WIDTH, VL_HEIGHT, VL_DEPTH], center=true);
        bolt();
        mirror_copy([1, 1, 0])
            mirror_copy([-1, 1, 0])
                nobs();
    }
}


TUBE_DIA = 8.35; // 8.35mm exact
SECTION_WIDTH = 50;
TOP_BEND_RAD = 20;
module rack_section() {

    translate([0, SECTION_WIDTH/2,0]) {
        rotate([90,0,0])
        cylinder(d = TUBE_DIA, h = SECTION_WIDTH/2);
    //    translate([TUBE_DIA, 0, 0])
    //    cylinder(d = TUBE_DIA, h = SECTION_WIDTH);

        translate([-TOP_BEND_RAD, 0, 0])
        rotate_extrude(angle = 90, convexity = 100)
            translate([TOP_BEND_RAD, 0, 0])
            circle(d = TUBE_DIA);
    }
}
module weld() {
    // space out the weld gap, front-to-back
    scale([1.0, 1.0, 1.0])

    rotate([-90,0,0]) {
        hull() {
            cylinder(d=TUBE_DIA, h=SECTION_WIDTH/2, center=true);
            translate([RACK_BOTTOM_FORWARD_OFFSET, TUBE_DIA, 0])
            cylinder(d=TUBE_DIA, h=SECTION_WIDTH/2, center=true);
        }
    }
}
module rack_top() {
    rack_section();
    mirror_copy([0, 1, 0])
        rack_section();
}
RACK_BOTTOM_FORWARD_OFFSET = -(1 + .6); // offset from rack_top to rack_bottom
module rack_bottom() {
    translate([RACK_BOTTOM_FORWARD_OFFSET, 0, -TUBE_DIA])
    rotate([0,-60,0])
    rack_top();
}
module rack() {
    rack_top();
    rack_bottom();
    weld();
}


module clamp_bolt() {
    CUT_DIMS = 30;
    translate([0,0,-CUT_DIMS]) {
        cylinder(d = 2.5, h = CUT_DIMS);
        translate([0,0,CUT_DIMS])
        cylinder(d = 8, h = CUT_DIMS);

        // recess for threads
        translate([0,0,CUT_DIMS - 4])
        cylinder(d = 3.2, h = 20);
    }
}
module raw_part() {
    MOUNT_WIDTH = 20;
    difference() {
    hull() {
        translate([TUBE_DIA/2, 0, -VL_HEIGHT/2])
            cube([TUBE_DIA, MOUNT_WIDTH, VL_HEIGHT-VL_NOB_OFFSET +2*VL_NOB_DIA], center = true);
        rotate([90, 0, 0])
        cylinder(d = 1.5*TUBE_DIA, h = MOUNT_WIDTH, center = true);
        translate([RACK_BOTTOM_FORWARD_OFFSET,0,-TUBE_DIA])
        rotate([90, 0, 0])
        cylinder(d = 1.5*TUBE_DIA, h = MOUNT_WIDTH, center = true);
    }

        // cut slot
        translate([0,0,-50])
        cube([2,100,100], center=true);

        // cut off pointy bottom
        translate([-25,0,-42])
        cube([50, 50, 40], center=true);

        // cut mounting bolt
        translate([-4,0,-17])
        rotate([0,-90,0])
        clamp_bolt();
    }

}
module part() {
    difference() {
        raw_part();
        rack();
        vistalight();
    }
}
//color("Black") rack();

//color("red") vistalight();

part();

//        clamp_bolt();
