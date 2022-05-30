Player p1;

int[][] map = {{250, 50, 50, 450}, {50, 450, 450, 450},
               {450, 450, 250, 50}, {250, 100, 250, 250}, {-1}};

void setup(){
  size(1000, 500);
  background(255);
  frameRate(20);
  p1 = new Player(20, 20, 0);
}

void draw(){
  background(255);
  line(500, 0, 500,500);
  draw_2d_map();
  p1.draw_player();
  
}




void draw_2d_map(){
  int i = 0;
  while(map[i][0] != -1){
    line(map[i][0], map[i][1], map[i][2], map[i][3]);
    i++;
  }
}


class Player {
  int x, y, angle;
  
  Player(int pos_x, int pos_y, int pos_angle){
    x = pos_x;
    y = pos_y;
    angle = pos_angle;
  }
  
  void draw_player(){
    ellipse(x, y, 20, 20);
    for (int i = -40; i < 42; i += 2){
      line(x, y, 50*cos(radians(angle+i))+x, 50*sin(radians(angle+i))+y);
      hit_judg(i);
    }
  }
  
  void hit_judg(int i){
    int j = 0;
    while(map[j][0] != -1){
      float px1 = 10*cos(radians(angle+i))+x, py1 = 10*sin(radians(angle+1))+y, px2 = 50*cos(radians(angle+i))+x, py2 = 50*sin(radians(angle+i))+y;
      float wx1 = map[j][0], wy1 = map[j][1], wx2 = map[j][2], wy2 = map[j][3];
      float wt = (wy2 - wy1) / (wx2 - wx1);
      float pt = (py2 - py1) / (px2 - px1);
      float hit_x = (wt*wx2 - pt*px2 - wy2 + py2) / (wt - pt);
      float hit_y = wt * (hit_x - wx2) + wy2;
      
      //println(wt, pt, hit_x, hit_y);
      int line_width = 5;
      if(wx2 == wx1 || px2 == px1){
        if(wx2 == wx1){
          hit_x = wx2;
          hit_y = pt * (hit_x - px2) + py2;
          if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
             hit_y <= max(round(wy1), round(wy2)) && hit_y >= min(round(wy1), round(wy2))){
               ellipse((int)hit_x, (int)hit_y, 5, 5);
               float hit_point_length = dist(px1, py1, hit_x, hit_y) * abs(cos(radians(i)));
               println(hit_point_length);
               strokeWeight(line_width);
               line(750+(10*i/2), (250-(250*(1-hit_point_length/50))-10), 750+(10*i/2), (250+(250*(1-hit_point_length/50))+10));
               strokeWeight(1);
             }
        }
        else{
          hit_x = px2;
          hit_y = wt * (hit_x - wx2) + wy2;
          if(hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2)) &&
             hit_y <= max(round(py1), round(py2)) && hit_y >= min(round(py1), round(py2))){
               ellipse((int)hit_x, (int)hit_y, 5, 5);
               float hit_point_length = dist(px1, py1, hit_x, hit_y) * abs(cos(radians(i)));
               println(hit_point_length);
               strokeWeight(line_width);
               line(750+(10*i/2), (250-(250*(1-hit_point_length/50))-10), 750+(10*i/2), (250+(250*(1-hit_point_length/50))+10));
               strokeWeight(1);
             }
        }
      }
      else if(hit_x <= max(round(px1), round(px2)) && hit_x >= min(round(px1), round(px2)) &&
         hit_x <= max(round(wx1), round(wx2)) && hit_x >= min(round(wx1), round(wx2))){
           ellipse((int)hit_x, (int)hit_y, 5, 5);
           float hit_point_length = dist(px1, py1, hit_x, hit_y) * abs(cos(radians(i)));
           println(hit_point_length);
           strokeWeight(line_width);
           line(750+(10*i/2), (250-(250*(1-hit_point_length/50))-10), 750+(10*i/2), (250+(250*(1-hit_point_length/50))+10));
           strokeWeight(1);
       }
       j++;
    }
  }
  
  void move(int key_num){
    // 1=w 2=a 3=s 4=d 5=→ 6=←
    switch(key_num){
      case 1:
        x += 5 * cos(radians(angle));
        y += 5 * sin(radians(angle));
        break;
      case 2:
        x += 5 * sin(radians(angle));
        y += 5 * -cos(radians(angle));
        break;
      case 3:
        x += 5 * -cos(radians(angle));
        y += 5 * -sin(radians(angle));
        break;
      case 4:
        x += 5 * -sin(radians(angle));
        y += 5 * cos(radians(angle));
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
       default:
         break;
     }
   default:
     break;
  }
  
}
