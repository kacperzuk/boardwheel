// cd ~/.local/share/OpenSCAD/libraries
// git clone https://github.com/revarbat/BOSL

include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>
use <BOSL/joiners.scad>
use <BOSL/metric_screws.scad>

$fn = $preview ? 20 : 100;

max_overhang = 60;

outer_diameter = 136; // srednica tego, co wchodzilo w rowki
outer_width = 5.3; // szerokosc tego, co wchodzilo w rowki
inner_width = 35.7;
inner_diameter = outer_diameter - 5*2; // srednica najwiekszej powierzchni styku z silnikiem

shaft_bump_inner_diameter = 47;
shaft_bump_outer_diameter = 34;
shaft_bump_len = 5;

shaft_diameter = 15.8;
shaft_len = 51;

shaft_cutout_start = 4.5;
shaft_cutout_len = 45;
shaft_cutout_deepness = 2.75;

outer_bump_diameter = 110;
outer_bump_len = 12;

screw_hole_ring_diameter = 120;
screw_hole_diameter = 4;
screw_hole_count = 6;
screw_hole_len = 10.6-4.25;
screw_hole_head_len = 4.25;
screw_hole_head_diameter = 9;

total_motor_len = outer_bump_len + 2* outer_width + inner_width;

echo(total_motor_len);

//top_rim_w = 27;
//top_rim_h = top_rim_w/tan(max_overhang);
top_rim_h = 19;
top_rim_w = top_rim_h*tan(max_overhang);

ring_diameter = inches(6.5)+5;
ring_fillet_deepness = 10;

module screws() {
    up(outer_bump_len + outer_width + inner_width + outer_width)
    zring(r=screw_hole_ring_diameter/2, n=screw_hole_count)
    metric_bolt(pitch=0, size=screw_hole_diameter, l=screw_hole_len, headtype="countersunk", align="sunken"); 
}

module screws_long() {
    up(outer_bump_len + outer_width + inner_width + outer_width - screw_hole_len - screw_hole_head_len)
    zring(r=screw_hole_ring_diameter/2, n=screw_hole_count)
    metric_bolt(pitch=0, size=screw_hole_diameter, l=40, headtype="countersunk", align=V_UP); 
}


module base_no_screws() {
    
// wypustka z ozdobna gwiazdka
cyl(l = outer_bump_len, fillet1=2, d1 = outer_bump_diameter, d2 = inner_diameter, align=V_UP);
up(outer_bump_len) {

// pierwsza obrecz
cyl(l = outer_width, d = outer_diameter, fillet=1, align=V_UP);
up(outer_width) {

// srodek, najwieksza powierzchnia styku
cyl(l=inner_width, d=inner_diameter, align=V_UP);
up(inner_width) {

// druga obrecz
cyl(l=outer_width, d = outer_diameter, chamfer=1, align=V_UP);
    
    
    
up(outer_width) {

// bump od oski
cyl(l=shaft_bump_len, d1=shaft_bump_inner_diameter, d2=shaft_bump_outer_diameter, fillet2=1, align=V_UP);

up(shaft_bump_len) {
// oska
difference() {
    cyl(l = shaft_len, d=shaft_diameter, chamfer2=1, align=V_UP);
    up(shaft_cutout_start)
    left(shaft_diameter/2)
    cuboid([shaft_cutout_deepness, shaft_diameter, shaft_cutout_len], align=V_UP+V_RIGHT);
}
}
}
}
}
}
}

function inches(x) = x*25.4;

module holder_top_rim() {
    difference() {
    up(5+total_motor_len) {
        tube(h=top_rim_h, id1 = outer_diameter, od1=inches(6), id2=outer_diameter-top_rim_w, od2 = inches(6), align=V_UP);
    }
    up(5) screws_long();
}

}

module outer_diameter_cutout() {
    cyl(d=outer_diameter, h=outer_width, align=V_BOTTOM);
    cyl(d1=outer_diameter, d2=inner_diameter, h=(outer_diameter-inner_diameter)/tan(max_overhang), align=V_UP);
}

module holder() {
    holder_top_rim();
    xrot(180) holder_top_rim();
    difference() {
      group() {
        tube(h = inches(6), id=inner_diameter, od=inches(6), align=V_CENTER);
        up(inches(3))
        cyl(d=inches(6), h=outer_diameter-inner_diameter, align=V_BOTTOM);

      };
      up(5+outer_bump_len+outer_width+inner_width) {
          cyl(h=20, d=outer_diameter, align=V_UP);
      }
      
      up(5+outer_bump_len+outer_width) {
          outer_diameter_cutout();
      }
      down(5+outer_bump_len) {
          outer_diameter_cutout();

          down(inner_width+outer_width) {
          outer_diameter_cutout();

          }
      }
      
      xrot(180) up(5) screws_long();
    }
}

module top_ring() {
    start = 5 + outer_bump_len + outer_width*2 + inner_width;
    difference() {
      up(start) {
        tube(h=inches(3)-start, id=inches(3), od=inner_diameter + (inches(6) - inner_diameter)/2, align=V_UP);
        up(inches(3)-start)
          difference() {
              tube(h=17, id=inches(3), od=ring_diameter, align=V_UP);
              torus(r2=ring_fillet_deepness, d=inches(6)+ring_fillet_deepness*2);
          }
      }
      up(5)
        screws_long();
      up(start)
      tube(h=top_rim_h, od = inches(6), id = outer_diameter - top_rim_w);
    }
    
}

module bottom_ring() {
    difference() {
        xrot(180) top_ring();
        valve_cutout();
    }
}

module filler() {
    difference() {
    outer_diameter_cutout();
    cyl(d=inner_diameter, h=100);
    cyl(d=outer_diameter+1, h=100, align=V_BOTTOM);

    }
    
}

module valve_cutout() {
    valve_cutout_deepness = 0.45*(inches(6) - outer_diameter);
    echo(valve_cutout_deepness=valve_cutout_deepness);
    zrot(360/screw_hole_count/2)
    right(inches(3))
    yscale(2)

    {
      up(10)
      cyl(h=inches(3)+10, fillet2=7, r = valve_cutout_deepness, align=V_DOWN);
    
      down(inches(3))
      yrot(max_overhang)
      cyl(h=inches(6), r=valve_cutout_deepness);
    }
        
}

//xdistribute(200) {
    
// ta grupa to przyklad
/*
group() {
difference() {
group() {
holder();
up(25)
    screws_long();
up(20)
    top_ring();
}
cuboid([200,200,300], align=V_RIGHT+V_CENTER);
}
up(5) base_no_screws();
xrot(180) up(5) base_no_screws();
}
*/

    //up(5) base_no_screws();

// reszta to rzeczy juz do druku


//difference() {
//    filler();
//    cuboid([200,200,300], align=V_RIGHT+V_CENTER);
//}

//difference() {
//holder();
//    cuboid([200,200,300], align=V_RIGHT+V_CENTER);
//}
//xrot(180)
//top_ring();
//difference() {
//holder();
//valve_cutout();
//}

bottom_ring();
//bottom_ring();

/*
intersection() {
    difference() {
      holder();
      valve_cutout();
    }
    cuboid([200,200,300], align=V_RIGHT);
}
*/
