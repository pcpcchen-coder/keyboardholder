/* v0.5.0 — 螢幕前掛式鍵盤收納架，PLA 試作版
   三段調整位於上下掛框的搭接處，對應機身高 335/355/375 mm。
   托槽、下掛框及下框止擋一體列印，隨總長度一起移動。
   每側 2 支可抽換卡榫插銷；所有零件相同，不必為各段另印。
   座標 X 朝使用者，Y 從螢幕頂部往下，Z 沿螢幕寬度。單位 mm。
   尚未實體試配、承重或疲勞測試，沒有承重額定值。
*/
/* [輸出] */
part="assembly"; // [assembly,upper_left,upper_right,lower_left,lower_right,pin_joint,coupon_joint,joint_upper_coupon,joint_lower_coupon,top_fit_left,top_fit_right]
stage=1; // [0:短 335 mm 機身,1:中 355 mm 機身,2:長 375 mm 機身]
show_pins=true;
$fn=48;

/* [螢幕與鍵盤] */
height_positions=[335,355,375];
monitor_top_thickness=10;
bottom_bezel_height=15;
monitor_width=625; // 僅預覽；未確認實機寬度
curve_radius=1500; // 27HC5R 系列參考，後蓋仍須試配
keyboard_width=447.9;
keyboard_depth=149;
keyboard_thickness_envelope=45; // 預留包絡，非實測

/* [後傾托槽] */
recline_angle=12;
slot_width=61; // 硬壁間距，垂直於鍵盤背面量測
tray_floor_wall=10;
tray_back_wall=10;
tray_front_wall=10;
tray_front_height=24;
tray_back_height=115;
tray_side_height=28;
side_stop_wall=4;
keyboard_side_clearance=2;
seat_x=70;
seat_bottom_offset=55; // 托底內側後緣距機身底部

/* [可變長度掛框] */
arm_width=32;
rail_back=16;
rail_thickness=14;
hook_wall=10;
rear_hook_drop=30;
upper_end=201.5;
joint_tongue_length=80;
joint_clearance=0.35;
joint_pin_pitch=20;
joint_first_pin=10;
bezel_margin=3;

/* [可拆卡榫插銷] */
pin_shaft_width=5;
pin_thickness=8;
pin_hole_width=5.6;
pin_hole_height=8.6;
pin_head_width=11;
pin_head_length=4;
pin_split_width=2;
pin_split_root=6;
pin_barb=1;
pin_axial_clearance=0.4;
pin_ramp_length=4;
pin_tip_length=2;

/* [另備軟墊] */
top_pad=2;
rear_pad=2;
front_pad=2;
keyboard_pad=2;
hook_fit_clearance=0.6;

monitor_height=height_positions[stage];
extension=monitor_height-height_positions[0];
rail_front=rail_back+rail_thickness;
pin_x=rail_back+rail_thickness/2;
cup_width=arm_width;
pair_offset=keyboard_width+keyboard_side_clearance+2*side_stop_wall-cup_width;
function sag(u)=curve_radius-sqrt(curve_radius*curve_radius-u*u);
function fc(z)=sag(pair_offset/2+z-arm_width/2)-sag(pair_offset/2);
curve_min=min(fc(0),fc(arm_width));
curve_max=max(fc(0),fc(arm_width));
rear_inner=-monitor_top_thickness-rear_pad-hook_fit_clearance;
x_min=rear_inner-hook_wall+curve_min;
y_min=-top_pad-hook_wall;
upper_shoulder=upper_end-joint_tongue_length;
lower_start=upper_shoulder+joint_clearance; // 下掛框最短段的原點
lower_length=height_positions[0]-lower_start;
half_low=arm_width/2-joint_clearance/2;
half_high=arm_width/2+joint_clearance/2;
seat_local=lower_length-seat_bottom_offset;
seat=monitor_height-seat_bottom_offset;
bumper_local_y=lower_length-bottom_bezel_height+bezel_margin;
bumper_height=bottom_bezel_height-2*bezel_margin;
pin_rows=[for(i=[0:3]) lower_start+joint_first_pin+i*joint_pin_pitch];
active_rows=[lower_start+extension+joint_first_pin,
             lower_start+extension+joint_first_pin+joint_pin_pitch];
overlap=upper_end-(lower_start+extension);
function tx(u,v)=seat_x+u*cos(recline_angle)+v*sin(recline_angle);
function ty(u,v)= -u*sin(recline_angle)+v*cos(recline_angle);

assert(stage>=0 && stage<=2 && floor(stage)==stage,"stage 必須為 0/1/2。");
assert(len(height_positions)==3 && height_positions[1]-height_positions[0]==joint_pin_pitch && height_positions[2]-height_positions[1]==joint_pin_pitch,"三段高度差須與定位孔距相同。");
assert(overlap>=39,"最長段搭接不足。");
assert(bottom_bezel_height>=12,"下框不足，請重新設計接觸點。");
assert(rail_back-curve_max>8,"掛框距面板空隙不足。");
assert(tx(-tray_back_wall,-tray_back_height)>rail_front+4,"後傾靠背與掛框過近。");
assert(tx(keyboard_pad,-keyboard_depth-keyboard_pad)>rail_front+6,"鍵盤包絡與掛框過近。");
assert(seat_local-70>joint_tongue_length+4,"托槽肋條與可調接頭衝突。");
assert(pin_rows[3]+pin_hole_height/2+5<upper_end,"末孔距端部不足。");
assert(pin_shaft_width>pin_split_width+2.4,"卡榫叉臂過薄。");
assert(slot_width>=keyboard_thickness_envelope+2*keyboard_pad+2,"托槽空間不足。");

module rect(x,y,w,h){translate([x,y]) square([w,h]);}
module xz_prism(points,y0,depth){
  translate([0,y0,0]) multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
    linear_extrude(height=depth) polygon(points);
}
module curved_strip(a,b,y0,depth){
  xz_prism(concat(
    [for(i=[0:16]) let(z=arm_width*i/16) [fc(z)+a,z]],
    [for(i=[16:-1:0]) let(z=arm_width*i/16) [fc(z)+b,z]]
  ),y0,depth);
}
module mirrored_width(){translate([0,0,arm_width]) mirror([0,0,1]) children();}
module through_slot(y){
  translate([pin_x-pin_hole_width/2,y-pin_hole_height/2,-1])
    cube([pin_hole_width,pin_hole_height,arm_width+2]);
}
module upper(){
  difference(){
    union(){
      linear_extrude(height=arm_width) union(){
        rect(x_min,y_min,rail_front-x_min,hook_wall);
        rect(rail_back,y_min,rail_thickness,upper_shoulder-y_min);
        polygon([[rail_back,-top_pad],[rail_back,6],[rail_back-6,-top_pad]]);
      }
      translate([rail_back,upper_shoulder-0.1,0])
        cube([rail_thickness,joint_tongue_length+0.1,half_low]);
      curved_strip(rear_inner-hook_wall,rear_inner,y_min,rear_hook_drop-y_min);
    }
    for(y=pin_rows) through_slot(y);
  }
}
module lower_rail(){
  difference(){
    union(){
      translate([rail_back,0,half_high]) cube([rail_thickness,joint_tongue_length+0.1,arm_width-half_high]);
      translate([rail_back,joint_tongue_length,0]) cube([rail_thickness,lower_length-joint_tongue_length,arm_width]);
      xz_prism(concat([for(i=[0:16]) let(z=arm_width*i/16) [fc(z)+front_pad,z]],
                     [[rail_front,arm_width],[rail_front,0]]),bumper_local_y,bumper_height);
    }
    for(y=[joint_first_pin,joint_first_pin+joint_pin_pitch]) through_slot(y);
  }
}
module reclined(seat_y){translate([seat_x,seat_y,0]) rotate([0,0,-recline_angle]) children();}
module backrest_window(seat_y){
  reclined(seat_y) hull()
    for(v=[-95,-28]) for(z=[11,cup_width-11])
      translate([-tray_back_wall-1,v,z]) rotate([0,90,0]) cylinder(h=tray_back_wall+2,r=3);
}
module cup(seat_y){
  difference(){
    union(){
      linear_extrude(height=cup_width) union(){
        reclined(seat_y) union(){
          rect(-tray_back_wall,0,slot_width+tray_front_wall+tray_back_wall,tray_floor_wall);
          rect(-tray_back_wall,-tray_back_height,tray_back_wall,tray_back_height+tray_floor_wall);
          rect(slot_width,-tray_front_height,tray_front_wall,tray_front_height+tray_floor_wall);
        }
        polygon([[rail_front-0.5,seat_y-70],[seat_x-6,seat_y-20],
                 [seat_x+5,seat_y+10],[seat_x+5,seat_y+25],[rail_front-0.5,seat_y-10]]);
      }
      translate([0,0,cup_width-side_stop_wall]) linear_extrude(height=side_stop_wall)
        reclined(seat_y) rect(-0.1,-tray_side_height,slot_width+tray_front_wall-0.1,tray_side_height+tray_floor_wall-0.2);
    }
    translate([0,0,-1]) linear_extrude(height=cup_width+2)
      polygon([[38,seat_y-50],[64,seat_y-15],[68,seat_y+10],[38,seat_y-14]]);
    backrest_window(seat_y);
  }
}
module lower(){union(){lower_rail();cup(seat_local);}}
module lower_in_place(){translate([0,lower_start+extension,0]) lower();}

// 薄叉臂只負責卡住；插銷穿過搭接片承受剪力。四支相同。
module snap_pin(){
  shoulder=arm_width+pin_axial_clearance;
  tip=shoulder+pin_ramp_length+pin_tip_length;
  w=pin_shaft_width/2;
  linear_extrude(height=pin_thickness) difference(){
    union(){
      polygon([[0,-w],[shoulder,-w],[shoulder,-w-pin_barb],
               [shoulder+pin_ramp_length,-w],[tip,-w],[tip,w],
               [shoulder+pin_ramp_length,w],[shoulder,w+pin_barb],[shoulder,w],[0,w]]);
      rect(-pin_head_length,-pin_head_width/2,pin_head_length,pin_head_width);
    }
    rect(pin_split_root,-pin_split_width/2,tip-pin_split_root+1,pin_split_width);
    translate([pin_split_root,0]) circle(d=pin_split_width);
  }
}
module pin_at(y){
  multmatrix([[0,1,0,pin_x],[0,0,1,y-pin_thickness/2],[1,0,0,0],[0,0,0,1]]) snap_pin();
}
module pins(){mirrored_width() for(y=active_rows) pin_at(y);}
module one_arm(){
  color([0.2,0.45,0.65]) upper();
  color([0.2,0.6,0.65]) lower_in_place();
  if(show_pins) color([0.95,0.65,0.15]) pins();
}
module pair(){mirrored_width() one_arm();translate([0,0,pair_offset]) one_arm();}
module monitor(){
  xz_prism(concat(
    [for(i=[0:80]) let(u=-monitor_width/2+monitor_width*i/80) [sag(u)-sag(pair_offset/2),u+(pair_offset+arm_width)/2]],
    [for(i=[80:-1:0]) let(u=-monitor_width/2+monitor_width*i/80) [sag(u)-sag(pair_offset/2)-monitor_top_thickness,u+(pair_offset+arm_width)/2]]
  ),0,monitor_height);
}
module keyboard(){
  reclined(seat) translate([keyboard_pad,-keyboard_depth-keyboard_pad,side_stop_wall+keyboard_side_clearance/2])
    cube([keyboard_thickness_envelope,keyboard_depth,keyboard_width]);
}
module assembly(){
  multmatrix([[0,0,1,0],[1,0,0,0],[0,-1,0,0],[0,0,0,1]]){
    pair(); %monitor(); %keyboard();
  }
}
module coupon_joint(){difference(){cube([rail_thickness,24,arm_width]);translate([-rail_back,0,0]) through_slot(12);}}
module joint_upper_coupon(){intersection(){upper();translate([rail_back,upper_shoulder-6,0]) cube([rail_thickness,joint_tongue_length+6,arm_width]);}}
module joint_lower_coupon(){intersection(){lower_rail();translate([rail_back,0,0]) cube([rail_thickness,joint_tongue_length+6,arm_width]);}}
module top_fit(){intersection(){upper();translate([x_min-1,y_min-1,0]) cube([rail_front-x_min+2,rear_hook_drop-y_min+1,arm_width]);}}

if(part=="assembly") assembly();
else if(part=="upper_right") translate([-x_min,-y_min,0]) upper();
else if(part=="upper_left") translate([rail_front,-y_min,arm_width]) rotate([0,180,0]) mirrored_width() upper();
else if(part=="lower_right") translate([150,0,arm_width]) rotate([0,180,0]) lower();
else if(part=="lower_left") translate([-front_pad-curve_min,0,0]) mirrored_width() lower();
else if(part=="pin_joint") translate([pin_head_length,pin_head_width/2,0]) snap_pin();
else if(part=="coupon_joint") coupon_joint();
else if(part=="joint_upper_coupon") translate([-rail_back,-upper_shoulder+6,0]) joint_upper_coupon();
else if(part=="joint_lower_coupon") translate([rail_front,0,arm_width]) rotate([0,180,0]) joint_lower_coupon();
else if(part=="top_fit_right") translate([-x_min,-y_min,0]) top_fit();
else if(part=="top_fit_left") translate([rail_front,-y_min,arm_width]) rotate([0,180,0]) mirrored_width() top_fit();
else if(part=="test_joint_overlap") intersection(){upper();lower_in_place();}
else if(part=="test_keyboard_overlap") intersection(){pair();keyboard();}
else if(part=="test_pins_overlap") intersection(){union(){upper();lower_in_place();}pins();}
else if(part=="test_monitor_overlap") intersection(){union(){pair();keyboard();}monitor();}
else assert(false,"未知零件名稱。");

echo("機身高度",monitor_height,"掛架外部總高",monitor_height-y_min,"搭接長度",overlap);
echo("有效定位孔",active_rows,"托底後緣高度",seat,"掛臂中心距",pair_offset);
echo("本版改為調整上下掛框接頭，托槽及下框止擋隨整個下掛框移動。");
