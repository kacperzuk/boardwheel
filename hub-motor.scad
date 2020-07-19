// cd ~/.local/share/OpenSCAD/libraries
// git clone https://github.com/revarbat/BOSL

include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>
use <BOSL/joiners.scad>
use <BOSL/metric_screws.scad>
use <threads.scad>

$fn = $preview ? 20 : 100;

max_overhang = 60;

outer_diameter = 138; // srednica tego, co wchodzilo w rowki
outer_width = 5.3; // szerokosc tego, co wchodzilo w rowki
inner_width = 35.7;
inner_diameter = 128.5; // srednica najwiekszej powierzchni styku z silnikiem

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


ring_diameter = inches(6.5)+5;
ring_fillet_deepness = 5;

holder_od = 145;
holder_h = inches(5.5) - 2*ring_fillet_deepness;
holder_fillet = 5;
top_ring_h = 10;

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

module plastic_screws_threads() {
    up(holder_h/2 + top_ring_h)
    zrot(360/screw_hole_count/4)
    zring(r=(outer_diameter + holder_od)/2/2, n=screw_hole_count)
    {
        if($preview) {
          screw(screwsize=3,screwlen=35,headsize=6,headlen=3,countersunk=false);
        } else {
          metric_thread (3, 0.5, 35, internal=true, $fn=10);
        }
    }
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

module outer_diameter_cutout() {
    cyl(d=outer_diameter, h=outer_width, align=V_BOTTOM);
    cyl(d1=outer_diameter, d2=inner_diameter, h=(outer_diameter-inner_diameter)/tan(max_overhang), align=V_UP);
}

module holder() {
    difference() {
      group() {
        cyl(h=holder_h, d=holder_od, align=V_CENTER, fillet=holder_fillet);
      };
      cyl(h = holder_h, d=inner_diameter, align=V_CENTER);

      up(5+outer_bump_len+outer_width+inner_width+outer_width) {
          outer_diameter_cutout();
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
    }
}

module top_ring() {
    difference() {
     up(holder_h/2) {
     difference() {
         tube(h=top_ring_h, id=inches(3), od=ring_diameter, align=V_UP);
         torus(r2=ring_fillet_deepness, d=holder_od+ring_fillet_deepness*2);
         tube(h=ring_fillet_deepness, id=holder_od+ring_fillet_deepness*2, od=ring_diameter);
     };
     down(holder_fillet) {
         difference() {
         cyl(h=holder_fillet, d=holder_od, align=V_UP);
         up(holder_fillet)
         cyl(h=holder_fillet*3, d=holder_od, fillet=holder_fillet, align=V_DOWN);
         }
     }
 }
     up(5)
       screws_long();
     plastic_screws_threads();
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
    valve_cutout_deepness = 0.60*(holder_od - outer_diameter);
    echo(valve_cutout_deepness=valve_cutout_deepness);
    zrot(360/screw_hole_count/2)
    {
      right(holder_od/2) {
        up(10)
        yscale(2)
          cyl(h=holder_h, fillet2=1, r = valve_cutout_deepness, align=V_DOWN);
      }

      
      down(holder_h/2+2*top_ring_h-5) {
        zrot(-5) {
          difference() {
            pie_slice(ang=40, h=top_ring_h, r=(holder_od/2 + valve_cutout_deepness));
            pie_slice(ang=40, h=top_ring_h, r=(holder_od/2 - valve_cutout_deepness));
          }
          up(valve_cutout_deepness*2) {
          zrot(15) right(holder_od/2) tube(od=valve_cutout_deepness*3.5, id=valve_cutout_deepness*3.5-2, orient=ORIENT_Y, $fn=20 );
          zrot(25) right(holder_od/2) tube(od=valve_cutout_deepness*3.5, id=valve_cutout_deepness*3.5-2, orient=ORIENT_Y, $fn=20 );
          zrot(35) right(holder_od/2) tube(od=valve_cutout_deepness*3.5, id=valve_cutout_deepness*3.5-2, orient=ORIENT_Y, $fn=20);
          }
        }
      }

     }
        
}

//xdistribute(200) {
    
// ta grupa to przyklad
module viz() {
group() {
difference() {
group() {
difference() {
holder();
    valve_cutout();
}
up(25)
    screws_long();
    top_ring();
    bottom_ring();
}
cuboid([200,200,300], align=V_LEFT+V_CENTER);
}
up(5) base_no_screws();
xrot(180) up(5) base_no_screws();
}
}


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

//bottom_ring();
//bottom_ring();

module holder_print() {
intersection() {
    difference() {
      holder();
      valve_cutout();
      plastic_screws_threads();
      xrot(180) plastic_screws_threads();

    }
    cuboid([200,200,300], align=V_RIGHT);
}

left(5)
intersection() {
    difference() {
      holder();
      valve_cutout();
              plastic_screws_threads();
      xrot(180) plastic_screws_threads();

    }
    cuboid([200,200,300], align=V_LEFT);
}
}


module tire() {
    color("grey") {
    difference() {
        cyl(h=inches(6), d=inches(10.5), fillet=inches(1));
        cyl(h=inches(7), d=holder_od+25*2);
    }
    
    difference() {
        cyl(h=inches(5.5), d=holder_od+25*2);
        cyl(h=inches(7), d=holder_od); 
    }   
}

}


//holder_print();
//top_ring();
//bottom_ring();
/*
start = 5 + outer_bump_len + outer_width*2 + inner_width;
xrot(180)
    difference() {
      up(holder_h/2)
        tube(h=20, id1=inches(3), od1=holder_od, id2=inches(3), od2=holder_od - inches(5.5), align=V_UP);
      up(7)
        screws_long();
    }
   

*/
    
module sample() {
    xdistribute(inches(7)) {
        holder_print();
        xrot(180)
          top_ring();
        bottom_ring();
    }
}

sample();
