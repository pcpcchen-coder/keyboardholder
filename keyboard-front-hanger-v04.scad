/* 27HC5R / Keychron V6 Max / PLA — v0.4 試作版
   修改：後傾 12°、61 mm 深托槽、免金屬螺絲卡榫插銷、三段垂直高度。
   固定框長度仍配合 355 mm 螢幕；只有鍵盤托座上下滑動，止擋始終抵下框。
   原始座標：X 向使用者、Y 向下、Z 沿螢幕寬度。單位 mm。
   短插銷 pin_joint ×4；長插銷 pin_tray ×2。彈性卡扣只用於防止插銷退出。
   使用者尚未提供印表機型號。需試配、試印、實體負載及卡扣循環驗證。
*/
/* [輸出] */
part="assembly"; // [assembly,upper_left,upper_right,lower_left,lower_right,tray_left,tray_right,pin_joint,pin_tray,coupon_joint,coupon_rail,coupon_slider,top_fit_left,top_fit_right]
stage=1; // [0:高 285,1:中 300,2:低 315]
show_pins=true;
$fn=48;

/* [已知尺寸] */
monitor_height=355;
monitor_top_thickness=10;
bottom_bezel_height=15;
monitor_width=625; // 只供預覽，非已確認機身寬
curve_radius=1500; // 系列規格；後蓋外形仍需試配
keyboard_width=447.9;
keyboard_depth=149;
keyboard_thickness_envelope=45; // 設計包絡，非實測厚度

/* [收納托座] */
recline_angle=12; // 相對垂直線，鍵盤上端朝螢幕傾斜
slot_width=61; // 垂直於鍵盤背面的硬壁間距
tray_floor_wall=10;
tray_back_wall=10;
tray_front_wall=10;
tray_front_height=24;
tray_back_height=115;
tray_side_height=28;
side_stop_wall=4;
keyboard_side_clearance=2;
seat_x=70;
seat_positions=[285,300,315]; // 螢幕頂部到托底後緣基準点

/* [固定掛框] */
arm_width=32;
rail_back=16;
rail_thickness=14;
hook_wall=10;
rear_hook_drop=30;
joint_overlap=40;
joint_clearance=0.3;
joint_pin_pitch=20;
bezel_margin=3;
stop_y=325;
stop_height=8;

/* [滑套與卡榫] */
slide_clearance=0.35; // 導槽單側間隙，試配後可調
carriage_wall=4;
carriage_top_offset=-80;
carriage_bottom_offset=-10;
tray_pin_offset=-45;
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

/* [軟墊，另行準備] */
top_pad=2;
rear_pad=2;
front_pad=2;
keyboard_pad=2;
hook_fit_clearance=0.6;

rail_front=rail_back+rail_thickness;
pin_x=rail_back+rail_thickness/2;
sleeve_extra=slide_clearance+carriage_wall;
cup_width=arm_width+2*sleeve_extra;
cup_zmin=-sleeve_extra;
cup_zmax=arm_width+sleeve_extra;
sleeve_back=rail_back-slide_clearance-carriage_wall;
sleeve_front=rail_front+slide_clearance+carriage_wall;
pair_offset=keyboard_width+keyboard_side_clearance+2*side_stop_wall-cup_width;
function sag(u)=curve_radius-sqrt(curve_radius*curve_radius-u*u);
function fc(z)=sag(pair_offset/2+z-arm_width/2)-sag(pair_offset/2);
curve_min=min(fc(0),fc(arm_width));
curve_max=max(fc(0),fc(arm_width));
rear_inner=-monitor_top_thickness-rear_pad-hook_fit_clearance;
x_min=rear_inner-hook_wall+curve_min;
y_min=-top_pad-hook_wall;
y_bumper=monitor_height-bottom_bezel_height+bezel_margin;
bumper_height=bottom_bezel_height-2*bezel_margin;
joint_y=monitor_height/2;
joint_a=joint_y-joint_overlap/2;
joint_b=joint_y+joint_overlap/2;
seat=seat_positions[stage];
tray_print_y_shift=tray_back_height*cos(recline_angle);
function tx(u,v)=seat_x+u*cos(recline_angle)+v*sin(recline_angle);
function ty(u,v)= -u*sin(recline_angle)+v*cos(recline_angle);

assert(stage>=0 && stage<=2 && floor(stage)==stage,"stage 必須是 0、1、2。");
assert(bottom_bezel_height>=12,"下框不足，必須重設支撐。");
assert(sleeve_back-curve_max>8,"滑套與螢幕的空隙不足。");
assert(tx(-tray_back_wall,-tray_back_height)>sleeve_front,
       "傾斜靠背與導槽外壁干涉。");
assert(tx(keyboard_pad,-keyboard_depth-keyboard_pad)>rail_front+6,
       "鍵盤上端離掛框太近。");
assert(seat_positions[0]+carriage_top_offset>joint_y+joint_pin_pitch/2+pin_thickness/2+4,
       "最高段滑套與固定接頭卡銷干涉。");
assert(seat_positions[2]+carriage_bottom_offset<stop_y,"最低段超過止擋。");
assert(pin_shaft_width>pin_split_width+2.4,"彈性叉臂過薄。");
assert(slot_width>=keyboard_thickness_envelope+2*keyboard_pad+2,"托槽不足。");

module rect(x,y,w,h){translate([x,y]) square([w,h]);}
module xz_prism(points,y0,depth){
  translate([0,y0,0]) multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
    linear_extrude(height=depth) polygon(points);
}
module curved_strip(a,b,y0,depth,z0=0,z1=arm_width){
  xz_prism(concat(
    [for(i=[0:16]) let(z=z0+(z1-z0)*i/16) [fc(z)+a,z]],
    [for(i=[16:-1:0]) let(z=z0+(z1-z0)*i/16) [fc(z)+b,z]]
  ),y0,depth);
}
module mirrored_width(){translate([0,0,arm_width]) mirror([0,0,1]) children();}
module through_slot(y,z0=-10,depth=arm_width+20){
  translate([pin_x-pin_hole_width/2,y-pin_hole_height/2,z0])
    cube([pin_hole_width,pin_hole_height,depth]);
}
module bumper(){
  xz_prism(concat([for(i=[0:16]) let(z=arm_width*i/16) [fc(z)+front_pad,z]],
                 [[rail_front,arm_width],[rail_front,0]]),y_bumper,bumper_height);
}
module frame_body(){
  difference(){
    union(){
      linear_extrude(height=arm_width) union(){
        rect(x_min,y_min,rail_front-x_min,hook_wall);
        rect(rail_back,y_min,rail_thickness,monitor_height-y_min);
        polygon([[rail_back,-top_pad],[rail_back,6],[rail_back-6,-top_pad]]);
        rect(rail_front-0.1,stop_y,5.1,stop_height);
      }
      curved_strip(rear_inner-hook_wall,rear_inner,y_min,rear_hook_drop-y_min);
      bumper();
    }
    for(dy=[-joint_pin_pitch/2,joint_pin_pitch/2]) through_slot(joint_y+dy);
    for(s=seat_positions) through_slot(s+tray_pin_offset);
  }
}
module region(ya,yb,za,zb){
  translate([x_min-2,ya,za]) cube([rail_front+8-x_min,yb-ya,zb-za]);
}
module upper(){
  intersection(){
    frame_body();
    union(){
      region(y_min-1,joint_a-joint_clearance/2,0,arm_width);
      region(joint_a-joint_clearance/2,joint_b-joint_clearance/2,0,arm_width/2-joint_clearance/2);
    }
  }
}
module lower(){
  intersection(){
    frame_body();
    union(){
      region(joint_a+joint_clearance/2,joint_b+joint_clearance/2,arm_width/2+joint_clearance/2,arm_width);
      region(joint_b+joint_clearance/2,monitor_height+1,0,arm_width);
    }
  }
}

module guide_clearance(y0,depth){
  translate([rail_back-slide_clearance,y0,-slide_clearance])
    cube([rail_thickness+2*slide_clearance,depth,arm_width+2*slide_clearance]);
}
module sleeve_block(y0,depth){
  translate([sleeve_back,y0,cup_zmin]) cube([sleeve_front-sleeve_back,depth,cup_width]);
}
module reclined(seat_y=0){translate([seat_x,seat_y,0]) rotate([0,0,-recline_angle]) children();}
module backrest_window(seat_y){
  reclined(seat_y) hull()
    for(v=[-95,-28]) for(z=[cup_zmin+11,cup_zmax-11])
      translate([-tray_back_wall-1,v,z]) rotate([0,90,0]) cylinder(h=tray_back_wall+2,r=3);
}
module tray(seat_y=0){
  difference(){
    union(){
      sleeve_block(seat_y+carriage_top_offset,carriage_bottom_offset-carriage_top_offset);
      translate([0,0,cup_zmin]) linear_extrude(height=cup_width) union(){
        reclined(seat_y) union(){
          rect(-tray_back_wall,0,slot_width+tray_front_wall+tray_back_wall,tray_floor_wall);
          rect(-tray_back_wall,-tray_back_height,tray_back_wall,tray_back_height+tray_floor_wall);
          rect(slot_width,-tray_front_height,tray_front_wall,tray_front_height+tray_floor_wall);
        }
        polygon([[sleeve_front-0.5,seat_y-70],[seat_x-6,seat_y-20],
                 [seat_x+5,seat_y+10],[seat_x+5,seat_y+25],[sleeve_front-0.5,seat_y-10]]);
      }
      translate([0,0,cup_zmax-side_stop_wall]) linear_extrude(height=side_stop_wall)
        reclined(seat_y) rect(-0.1,-tray_side_height,slot_width+tray_front_wall-0.1,tray_side_height+tray_floor_wall-0.2);
    }
    guide_clearance(seat_y-150,200);
    through_slot(seat_y+tray_pin_offset,cup_zmin-1,cup_width+2);
    // 保留周邊肋條的減料窗；不改托底、卡銷孔及導槽。
    translate([0,0,cup_zmin-1]) linear_extrude(height=cup_width+2)
      polygon([[42,seat_y-50],[64,seat_y-15],[68,seat_y+10],[42,seat_y-11]]);
    backrest_window(seat_y);
  }
}

// 雙叉卡榫插銷：長叉臂、圓形開槽根部；承重方向垂直於薄叉臂的彎曲方向。
module snap_pin(span){
  shoulder=span+pin_axial_clearance;
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
module pin_at(y,span,z0){
  multmatrix([[0,1,0,pin_x],[0,0,1,y-pin_thickness/2],[1,0,0,z0],[0,0,0,1]]) snap_pin(span);
}
module right_frame(){upper();lower();}
module one_arm(){
  color([0.2,0.45,0.65]) right_frame();
  color([0.2,0.6,0.65]) tray(seat);
  if(show_pins) color([0.95,0.65,0.15]) mirrored_width(){
    for(dy=[-joint_pin_pitch/2,joint_pin_pitch/2]) pin_at(joint_y+dy,arm_width,0);
    pin_at(seat+tray_pin_offset,cup_width,cup_zmin);
  }
}
module monitor(){
  xz_prism(concat(
    [for(i=[0:80]) let(u=-monitor_width/2+monitor_width*i/80) [sag(u)-sag(pair_offset/2),u+(pair_offset+arm_width)/2]],
    [for(i=[80:-1:0]) let(u=-monitor_width/2+monitor_width*i/80) [sag(u)-sag(pair_offset/2)-monitor_top_thickness,u+(pair_offset+arm_width)/2]]
  ),0,monitor_height);
}
module keyboard(){
  reclined(seat) translate([keyboard_pad,-keyboard_depth-keyboard_pad,cup_zmin+side_stop_wall+keyboard_side_clearance/2])
    cube([keyboard_thickness_envelope,keyboard_depth,keyboard_width]);
}
module assembly(){
  multmatrix([[0,0,1,0],[1,0,0,0],[0,-1,0,0],[0,0,0,1]]){
    mirrored_width() one_arm();
    translate([0,0,pair_offset]) one_arm();
    %monitor();
    %keyboard();
  }
}
module top_fit(){intersection(){frame_body();region(y_min-1,rear_hook_drop,0,arm_width);}}
module coupon_joint(){difference(){translate([rail_back,-12,0]) cube([rail_thickness,24,arm_width]);through_slot(0);}}
module coupon_rail(){difference(){translate([rail_back,-30,0]) cube([rail_thickness,60,arm_width]);through_slot(0);}}
module coupon_slider(){difference(){sleeve_block(-15,30);guide_clearance(-16,32);through_slot(0,cup_zmin-1,cup_width+2);}}

if(part=="assembly") assembly();
else if(part=="upper_right") translate([-x_min,-y_min,0]) upper();
else if(part=="upper_left") translate([rail_front,-y_min,arm_width]) rotate([0,180,0]) mirrored_width() upper();
else if(part=="lower_right") translate([rail_front+5,-joint_a-joint_clearance/2,arm_width]) rotate([0,180,0]) lower();
else if(part=="lower_left") translate([-front_pad-curve_min,-joint_a-joint_clearance/2,0]) mirrored_width() lower();
else if(part=="tray_left") translate([-sleeve_back,tray_print_y_shift,-cup_zmin]) mirrored_width() tray();
else if(part=="tray_right") translate([150,tray_print_y_shift,cup_zmax]) rotate([0,180,0]) tray();
else if(part=="pin_joint") translate([pin_head_length,pin_head_width/2,0]) snap_pin(arm_width);
else if(part=="pin_tray") translate([pin_head_length,pin_head_width/2,0]) snap_pin(cup_width);
else if(part=="coupon_joint") translate([-rail_back,12,0]) coupon_joint();
else if(part=="coupon_rail") translate([-rail_back,30,0]) coupon_rail();
else if(part=="coupon_slider") translate([-sleeve_back,15,-cup_zmin]) coupon_slider();
else if(part=="top_fit_right") translate([-x_min,-y_min,0]) top_fit();
else if(part=="top_fit_left") translate([rail_front,-y_min,arm_width]) rotate([0,180,0]) mirrored_width() top_fit();
else if(part=="test_frame_tray_overlap") intersection(){right_frame();tray(seat);}
else if(part=="test_keyboard_overlap") intersection(){union(){mirrored_width(){right_frame();tray(seat);} translate([0,0,pair_offset]){right_frame();tray(seat);}}keyboard();}
else if(part=="test_pins_overlap") intersection(){union(){right_frame();tray(seat);} mirrored_width(){for(dy=[-joint_pin_pitch/2,joint_pin_pitch/2]) pin_at(joint_y+dy,arm_width,0);pin_at(seat+tray_pin_offset,cup_width,cup_zmin);}}
else if(part=="test_monitor_overlap") intersection(){union(){mirrored_width() one_arm();translate([0,0,pair_offset]) one_arm();keyboard();}monitor();}
else assert(false,"未知零件名稱。");

echo("後傾角",recline_angle,"托槽內寬",slot_width,"三段基準",seat_positions);
echo("左右掛臂中心距",pair_offset,"滑套最小面板空隙",sleeve_back-curve_max);
echo("卡榫為試作尺寸；無實體承重額定值。");
