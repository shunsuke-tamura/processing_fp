Player p1;

String lines[];
int[][] map = new int[576][2];
int[] goal = new int[2];
color[] map_pix = new color[500*500];

//int[][] map = {{250, 50, 50, 450}, {50, 450, 450, 450},
//               {450, 450, 250, 50}, {250, 100, 250, 250}, {-1}};

int scope_f = 0, flame_counter = 0;

int flame_timer = 0;

void setup(){
  size(1000, 500);
  background(255);
  frameRate(20);
  lines = loadStrings("map_data1.csv");
  int count = 0;
  for(int i = 0; i < 24; i++){
    for(int j = 0; j < 24; j++){
      if(int(lines[j+24*i]) == 1){
        map[count][0] = 20 * j + 10;
        map[count][1] = 20 * i + 10;
        count++;
      }
      else if(int(lines[j+24*i]) == 2){
        goal[0] = 20 * j + 10;
        goal[1] = 20 * i + 10;
      }
      else if(int(lines[j+24*i]) == 3){
        p1 = new Player(20 * j + 20, 20 * i + 20, 0);
      }
    }
  }
  map[count][0] = -1;
} //<>//

void draw(){
  flame_timer++;
  background(255);
  line(500, 0, 500,500);
  draw_2d_map();
  p1.draw_player();
  if (p1.goal_f == 0){
    draw_time(0);
  }
  else{
    draw_time(1);
  }
}



void draw_time(int goal_f){
  int time1 = (flame_timer * 5) / 100;
  int time2 = ((flame_timer * 5) % 100) / 10;
  if (goal_f == 0){
    stroke(1);
    textSize(20);
    text("Time:"+str(time1)+"."+str(time2), 700, 50); 
  }
  else {
    if (flame_timer % 30 < 20){
      time1 = (p1.goal_flame_timer * 5) / 100;
      time2 = ((p1.goal_flame_timer * 5) % 100) / 10;
      textSize(20);
      text("Time:"+str(time1)+"."+str(time2), 700, 50); 
    }
    else{
      text("", 700, 50);
    }
  }
}

void draw_2d_map(){
  int i = 0;
  while(map[i][0] != -1){
    rect(map[i][0], map[i][1], 20, 20);
    i++;
  }
  stroke(255, 0, 0);
  fill(255, 0, 0);
  rect(goal[0], goal[1], 20, 20);
  stroke(1);
  noFill();
  
}


class Player {
  int x, y, angle, scope_num, goal_f, goal_flame_timer;
  
  Player(int pos_x, int pos_y, int pos_angle){
    x = pos_x;
    y = pos_y;
    angle = pos_angle;
    scope_num = 0;
    goal_f = 0;
    goal_flame_timer = 0;
  }
  
  void draw_player(){
    ellipse(x, y, 14, 14);
    stroke(255, 0, 0, 128);
    fill(255, 0, 0, 128);
    arc(x, y, 100, 100, radians(angle-50), radians(angle+50));
    noFill();
    stroke(1);
    for (int i = -50; i < 52; i += 2){
      //line(x, y, 50*cos(radians(angle+i))+x, 50*sin(radians(angle+i))+y);
      draw_3d_view(i);
      draw_3d_goal(i);
    }
    draw_compass();
    goal_judge();
    
    loadPixels();
    for (int i = 0; i < 500; i++){
      for (int j = 0; j < 500; j++){
        map_pix[500*i + j] = pixels[1000*i + j];
      }
    }
    
    fill(128);
    quad(5, 5, 495, 5, 495, 495, 5, 495);
    noFill();
    
    if (scope_f == 1){
      scope(30);
      if (flame_counter > 30){
        for (int r = 0; r <= flame_counter; r += 40)
        flame_counter = 0;
        scope_f = 0;
      }
    }
  }
  void draw_3d_view(int i){
    int j = 0;
    int line_width = 8;
    float px1, py1, px2, py2;
    float wx1, wy1, wx2, wy2;
    float hit_x, hit_y, wt, pt;
    float hit_point_length = 100;
    float min_dist = 100, min_dist_x = 0, min_dist_y = 0;
    int color_f = 0, axis_f = 0;
    
    while(map[j][0] != -1){
      px1 = x; py1 = y; px2 = 50*cos(radians(angle+i))+x; py2 = 50*sin(radians(angle+i))+y;
      
      for(int n = 0; n < 4; n++){
        wx1 = 0; wy1 = 0; wx2 = 0; wy2 = 0;
        if(n == 0){
          wx1 = map[j][0]; wy1 = map[j][1]; wx2 = map[j][0]+20; wy2 = map[j][1];
        }
        else if(n == 1){
          wx1 = map[j][0]; wy1 = map[j][1]; wx2 = map[j][0]; wy2 = map[j][1]+20;
        }
        else if(n == 2){
          wx1 = map[j][0]+20; wy1 = map[j][1]; wx2 = map[j][0]+20; wy2 = map[j][1]+20;
        }
        else{
          wx1 = map[j][0]; wy1 = map[j][1]+20; wx2 = map[j][0]+20; wy2 = map[j][1]+20;
        }
        wt = (wy2 - wy1) / (wx2 - wx1);
        pt = (py2 - py1) / (px2 - px1);
        hit_x = (wt*wx2 - pt*px2 - wy2 + py2) / (wt - pt);
        hit_y = wt * (hit_x - wx2) + wy2;
        if(wx2 == wx1 || px2 == round(px1)){
          axis_f = 1;
          if(wx2 == wx1){
            hit_x = wx2;
            hit_y = pt * (hit_x - px2) + py2;
            if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
               hit_y <= max(round(wy1), round(wy2)) && hit_y >= min(round(wy1), round(wy2))){
                 hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
             }
          }
          else{
            hit_x = px2;
            hit_y = wt * (hit_x - wx2) + wy2;
            if(hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2)) &&
               hit_y <= max(round(py1), round(py2)) && hit_y >= min(round(py1), round(py2))){
                 hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
             }
          }
        }
        else if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
           hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2))){
             axis_f = 0;
             hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
         }
         if(min_dist > hit_point_length){
           min_dist = hit_point_length;
           min_dist_x = hit_x;
           min_dist_y = hit_y;
           if(axis_f == 1){
             if(int(hit_y) % 10 < 5){
               color_f = 1;
             }
           }
           else{
             if(int(hit_x) % 10 < 5){
               color_f = 1;
             }
           }
         }
       }
      j++;
    }
    if(min_dist != 100){
      ellipse((int)min_dist_x, (int)min_dist_y, 5, 5);
      strokeWeight(line_width);
      strokeCap(SQUARE);
      if(color_f == 1){
        stroke(128);
      }
      //line(750+(10*i/2), (250-(250*(1-min_dist/50))), 750+(10*i/2), (250+(250*(1-min_dist/50))));
      line(750+(8*i/2), (250 - (250-min_dist*5)), 750+(8*i/2), (250 + (250-min_dist*5)));
      strokeWeight(1);
      stroke(1);
    }
  }
  
  void draw_3d_goal(int i){
    int line_width = 8;
    float px1, py1, px2, py2;
    float wx1, wy1, wx2, wy2;
    float hit_x, hit_y, wt, pt;
    float hit_point_length = 100;
    float min_dist = 100, min_dist_x = 0, min_dist_y = 0;
    
    px1 = x; py1 = y; px2 = 50*cos(radians(angle+i))+x; py2 = 50*sin(radians(angle+i))+y;
    
    for(int n = 0; n < 4; n++){
      wx1 = 0; wy1 = 0; wx2 = 0; wy2 = 0;
      if(n == 0){
        wx1 = goal[0]; wy1 = goal[1]; wx2 = goal[0]+20; wy2 = goal[1];
      }
      else if(n == 1){
        wx1 = goal[0]; wy1 = goal[1]; wx2 = goal[0]; wy2 = goal[1]+20;
      }
      else if(n == 2){
        wx1 = goal[0]+20; wy1 = goal[1]; wx2 = goal[0]+20; wy2 = goal[1]+20;
      }
      else{
        wx1 = goal[0]; wy1 = goal[1]+20; wx2 = goal[0]+20; wy2 = goal[1]+20;
      }
      wt = (wy2 - wy1) / (wx2 - wx1);
      pt = (py2 - py1) / (px2 - px1);
      hit_x = (wt*wx2 - pt*px2 - wy2 + py2) / (wt - pt);
      hit_y = wt * (hit_x - wx2) + wy2;
      if(wx2 == wx1 || px2 == round(px1)){
        if(wx2 == wx1){
          hit_x = wx2;
          hit_y = pt * (hit_x - px2) + py2;
          if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
             hit_y <= max(round(wy1), round(wy2)) && hit_y >= min(round(wy1), round(wy2))){
               hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
           }
        }
        else{
          hit_x = px2;
          hit_y = wt * (hit_x - wx2) + wy2;
          if(hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2)) &&
             hit_y <= max(round(py1), round(py2)) && hit_y >= min(round(py1), round(py2))){
               hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
           }
        }
      }
      else if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
         hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2))){
           hit_point_length = dist(px1, py1, hit_x, hit_y) * cos(radians(i));
       }  
       if(min_dist > hit_point_length){
         min_dist = hit_point_length;
         min_dist_x = hit_x;
         min_dist_y = hit_y;
       }
      }
    if(min_dist != 100){
      ellipse((int)min_dist_x, (int)min_dist_y, 5, 5);
      strokeWeight(line_width);
      strokeCap(SQUARE);
      float A = 1.0 / abs((500 - min_dist * 10));
      //println(min_dist*10, A);
      float l_pos = 250 + (250 - min_dist*5);
      for ( float a = 0; a <= 1.0; a = a + A) {
        color c = lerpColor(color(255, 0, 0, 255), color(255, 0, 0, 0), a);
        stroke(c);
        line(750+(8*i/2), l_pos, 750+(8*i/2), l_pos-1);
        l_pos--;
      }
      strokeWeight(1);
      noFill();
      stroke(1);
    }
  }
  
  void goal_judge() {
    if (dist(x, y, goal[0]+10, goal[1]+10) < 6){
      println("goal!");
      fill(0);
      if (goal_f == 0){
        goal_f = 1;
        goal_flame_timer = flame_timer;
      }
      noFill();
    }
    if (goal_f == 1){
      textSize(40);
      text("GOAL!!", 670, 100);
    }
  }
  
  void draw_compass(){
    //絶対角度、相対角度
    float px2 = 50*cos(radians(angle))+x, py2 = 50*sin(radians(angle))+y;
    float gt = 0, pt = 0;
    float abs_angle = 0, p_angle = 0, compass_angle = 0;
    float b;
    if(goal[0]+10 == x){
      if(goal[0]+10 == x){
        if(goal[0]+10 >= y){
          gt = tan(radians(90));
          abs_angle = radians(90);
        }
        else{
          gt = tan(radians(270));
          abs_angle = radians(270);
        }
      }
    }
    else if (goal[1]+10 == y){
      if (goal[1]+10 >= x){
        gt = tan(radians(0));
        abs_angle = radians(0);
      }
      else{
        gt = tan(radians(0));
        abs_angle = radians(180);
      }
    }
    else{
      gt = (float(goal[1]+10) - float(y)) / (float(goal[0]+10) - float(x));
      //compass_angle = atan((tan(gt) - tan(pt)) / (1 + tan(gt)*tan(pt)));
      abs_angle = atan(gt);
      if (x >= goal[0]+10) {
        abs_angle += radians(180);
      }
    }
    if (px2 == x){
      if (py2 >= y){
        p_angle = radians(90);
      }
      else{
        p_angle = radians(270);
      }
    }
    else{
      p_angle = radians(angle);
    }
    //compass_angle = gt;
    b = y - gt*x;
    compass_angle = abs_angle - p_angle - radians(90);
    ellipse(975, 475, 50, 50);
    float gain = 1.0 / 30;
    for (float a = 0; a < 1.0; a += gain){
      color c = lerpColor(color(255, 0, 0, 255), color(255, 0, 0, 0), a);
      stroke(c);
      line(975, 475, 25*cos(compass_angle)+975, 25*sin(compass_angle)+475);
      compass_angle += radians(1);
    }
    compass_angle = abs_angle - p_angle - radians(90);
    for (float a = 0; a < 1.0; a += gain){
      color c = lerpColor(color(255, 0, 0, 255), color(255, 0, 0, 0), a);
      stroke(c);
      line(975, 475, 25*cos(compass_angle)+975, 25*sin(compass_angle)+475);
      compass_angle -= radians(1);
    }
    stroke(1);
  }
  
  
  int hit_judge(float after_x, float after_y){
    int j = 0;
    //int hit_f = 1;
    while(map[j][0] != -1){
      for(int n = 0; n < 4; n++){
        //hit_f = 1;
        float wx1 = 0, wy1 = 0, wx2 = 0, wy2 = 0;
        if(n == 0){
          wx1 = map[j][0]; wy1 = map[j][1]; wx2 = map[j][0]+20; wy2 = map[j][1];
        }
        else if(n == 1){
          wx1 = map[j][0]; wy1 = map[j][1]; wx2 = map[j][0]; wy2 = map[j][1]+20;
        }
        else if(n == 2){
          wx1 = map[j][0]+20; wy1 = map[j][1]; wx2 = map[j][0]+20; wy2 = map[j][1]+20;
        }
        else{
          wx1 = map[j][0]; wy1 = map[j][1]+20; wx2 = map[j][0]+20; wy2 = map[j][1]+20;
        }
        if(wx2 == wx1 || wy2 == wy1){
          if(wx2 == wx1){
            if(wy1 <= after_y && after_y <= wy2){
              if(abs(wx1-after_x) <= 7){
                return 0;
              }
            }
          }
          else{
            if(wx1 <= after_x && after_x <= wx2){
              if(abs(wy1-after_y) <= 7){
                return 0;
              }
            }
          }
        }
        else{
          float wt = (wy2 - wy1) / (wx2 - wx1);
          float b = wy1 - wt * wx1;
          float p_w_distance = abs(wt*after_x - after_y + b) / sqrt(wt*wt + 1);
          if(p_w_distance <= 7){
            //hit_f = 0;
            //println(wx1, wy1, wx2, wy2);
            ellipse(wx1, wy1, 5, 5);
            ellipse(wx2, wy2, 5, 5);
            return 0;
            //break;
          }
        }
      }
      j++;
    }
    //return hit_f;
    return 1;
  }
  
  void scope(int gain_r) {
    flame_counter++;
    noStroke();
    fill(255, 255, 255);
    ellipse(x, y, flame_counter*gain_r, flame_counter*gain_r);
    loadPixels();
    for (int i = 0; i < 500; i++){
      for (int j = 0; j < 500; j++){
        if (pixels[1000*i + j] == color(255, 255, 255)){
          pixels[1000*i + j] = map_pix[500*i + j];
        }
      }
    }
    updatePixels();
    float gain = 1.0 / flame_counter;
    int r = flame_counter * gain_r;
    for (float a = 0; a <= 1.0; a += gain){
      color c = lerpColor(color(128, 128, 128, 0), color(128, 128, 128, 128), a);
      noStroke();
      fill(c);
      ellipse(x, y, r, r);
      r -= gain_r;
    }
    noFill();
    stroke(1);
  }
  
  void move(int key_num){
    // 1=w 2=a 3=s 4=d 5=→ 6=←
    int f = 1;
    float after_x, after_y;
    switch(key_num){
      case 1:
        after_x = x + 5 * cos(radians(angle));
        after_y = y + 5 * sin(radians(angle));
        f = hit_judge(after_x, after_y);
        if(f == 1){
          x = (int)after_x;
          y = (int)after_y;
        }
        break;
      case 2:
        after_x = x + 5 * sin(radians(angle));
        after_y = y + 5 * -cos(radians(angle));
        f = hit_judge(after_x, after_y);
        if(f == 1){
          x = (int)after_x;
          y = (int)after_y;
        }
        break;
      case 3:
        after_x = x + 5 * -cos(radians(angle));
        after_y = y + 5 * -sin(radians(angle));
        f = hit_judge(after_x, after_y);
        if(f == 1){
          x = (int)after_x;
          y = (int)after_y;
        }
        break;
      case 4:
        after_x = x + 5 * -sin(radians(angle));
        after_y = y + 5 * cos(radians(angle));
        f = hit_judge(after_x, after_y);
        if(f == 1){
          x = (int)after_x;
          y = (int)after_y;
        }
        break;
      case 5:
        angle += 5;
        break;
      case 6:
        angle -= 5;
        break;
      default:
        break;
    }
  }
}


void keyPressed(){
  switch(key){
   case 'w':
     p1.move(1);
     break;
   case 'a':
     p1.move(2);
     break;
   case 's':
     p1.move(3);
     break;
   case 'd':
     p1.move(4);
     break;
   case CODED:
     switch(keyCode){
       case RIGHT:
         p1.move(5);
         break;
       case LEFT:
         p1.move(6);
         break;
       case DOWN:
         p1.scope_num++;
         if (p1.scope_num <= 3){
           scope_f = 1;
         }
       default:
         break;
     }
   default:
     break;
  }
  
}
