public enum AI { WANDER, CHASE } 

int wide = 800;
int high = 600;
float decreaseMultiplier = 0.995;
int targetSpawnTimer = 0;

class Piece
{
  PVector position;
  PVector velocity;
  float radius;
  float angle;
  Piece()
  {
    radius = 8;
    angle = random(0, 359);    
    position = new PVector(random(0, width-1), random(0, height-1));
    velocity = new PVector(cos(radians(angle)) * 0.1, sin(radians(angle)) * 0.1);
  }
}

class Agent extends Piece
{
  int frozen_timer;
  Agent()
  {
    radius = 12;
    angle = 270;    
    position = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);    
   }
}

class Enemy extends Agent
{
  int state;
  int switchTime;
  Enemy()
  {
    state = 1;
    switchTime = int(random(20,90));
    radius = 4;
    angle = random(0, 359);    
    position = new PVector(random(0, width-1), random(0, height-1));
    velocity = new PVector(0, 0);
  }
  void toggleState(){
    if(state == 1){
      state = -1;
    }
    else{
      state = 1;
    }
  }
  void resetTimer(){
    switchTime = int(random(20,120));
  }
}


Agent avatar;

Enemy[] enemys;

Piece[] pieces;
int num_pieces;

PVector displacement;
float magnitude;
PVector unit_vector_to_target;

float dx, dy;
float distance;
float distance_squared;


void setup()
{

  size(800, 600);
  ellipseMode(CENTER);
  noStroke();
  
  avatar = new Agent();
  
  enemys = new Enemy[4];
  for (int i = 0; i < enemys.length; i++)
  {
    enemys[i] = new Enemy();
  }

  pieces = new Piece[100];
  num_pieces = 20;
  for (int i = 0; i < num_pieces; i++)
  {
    pieces[i] = new Piece();
  }
  
  displacement = new PVector(0, 0);
  
  unit_vector_to_target = new PVector(0, 0);
  
}


void draw()
{

  // -------------------- inputs phase -------------------- 
  
  if (mouseX >= 0 && mouseX <= width-1 && mouseY >= 0 && mouseY <= height-1 && avatar.frozen_timer == 0)
  {
    dx = mouseX - avatar.position.x;
    dy = mouseY - avatar.position.y;
    distance = sqrt(pow(dx, 2) + pow(dy, 2));
    if (distance > 10)
    {
      avatar.velocity.x = dx / distance * 4;
      avatar.velocity.y = dy / distance * 4;
    }
  }

  // -------------------- update phase -------------------- 

  // update the position of the avatar
  avatar.position.x += avatar.velocity.x;
  avatar.position.y += avatar.velocity.y;
  if (avatar.frozen_timer > 0)
  {
    avatar.frozen_timer--;
  }
  if(avatar.radius >= 3){
    avatar.radius = avatar.radius*decreaseMultiplier;
  }
  
  // update the position of the enemies
  for (int i = 0; i < enemys.length; i++)
  {
    print(avatar.radius+" ");
    if(avatar.radius <= 10){
      enemys[i].state = 1;
    }
    else if(avatar.radius >= 25){
      enemys[i].state = -1;
    }
    else{
      if(enemys[i].switchTime == 0){
        enemys[i].toggleState();
        enemys[i].resetTimer();
      }
      enemys[i].switchTime--;
    }
    
    // ----- try using this code for your new behaviour -----
    
    // this computes the displacement vector between the enemy and the avatar 
    displacement.x = avatar.position.x - enemys[i].position.x;
    displacement.y = avatar.position.y - enemys[i].position.y;
    
    // this computes the magnitude
    magnitude = sqrt(pow(displacement.x, 2) + pow(displacement.y, 2));
    
    // this create a unit vector (i.e., the direction only) towards the player
    unit_vector_to_target.x = displacement.x / magnitude;
    unit_vector_to_target.y = displacement.y / magnitude;
    
    // multiply the direction by 2 (which is the speed of the enemy) to get the new velocity
    enemys[i].velocity.x = unit_vector_to_target.x * 2 * enemys[i].state;
    enemys[i].velocity.y = unit_vector_to_target.y * 2 * enemys[i].state;
    
    // ------------------------------------------------------
    
    // now the standard vector math for updating position
    enemys[i].position.x += enemys[i].velocity.x;
    enemys[i].position.y += enemys[i].velocity.y;
    enemys[i].frozen_timer--;
    if (enemys[i].frozen_timer > 0)
    {
      enemys[i].frozen_timer--;
    }    
    
  } 
  
  // update the position of the pieces
  for (int i = 0; i < num_pieces; i++)
  {
    pieces[i].position.x += pieces[i].velocity.x;
    pieces[i].position.y += pieces[i].velocity.y;
  }
  
  // perform player/enemy collision detection
  for (int i = 0; i < enemys.length; i++)
  {
    dx = enemys[i].position.x - avatar.position.x;
    dy = enemys[i].position.y - avatar.position.y;
    distance_squared = pow(dx, 2) + pow(dy, 2);
    if (distance_squared < pow(enemys[i].radius + avatar.radius, 2))
    {
      avatar.frozen_timer = 180;
      enemys[i].frozen_timer = 180;
    }
  }
  
  
  // perform player/piece collision detection
  for (int i = 0; i < num_pieces; i++)
  {
    dx = pieces[i].position.x - avatar.position.x;
    dy = pieces[i].position.y - avatar.position.y;
    distance_squared = pow(dx, 2) + pow(dy, 2);
    if (distance_squared < pow(pieces[i].radius + avatar.radius, 2))
    {
      num_pieces--;
      pieces[i] = pieces[num_pieces];
      avatar.radius += 4;
    }
  }  
 
 if(targetSpawnTimer >= 50){
    num_pieces++;
    if(num_pieces <= 50){
      pieces[num_pieces-1] = new Piece();
      targetSpawnTimer = 0; 
    }
  }
  
  targetSpawnTimer++;
  // -------------------- render phase -------------------- 
  
  background(0);
  
  // render the avatar
  if (avatar.frozen_timer > 0)
  {
    fill(0, 255, 255);
  }
  else
  {
    fill(0, 0, 255);
  }
  ellipse(avatar.position.x, avatar.position.y, avatar.radius * 2, avatar.radius * 2);
  
  // render the enemies
  for (int i = 0; i < enemys.length; i++)
  {
    if (enemys[i].frozen_timer > 0)
    {
      fill(0, 255, 255);
    }
    else
    {
      fill(255, 0, 0);
    }
    ellipse(enemys[i].position.x, enemys[i].position.y, enemys[i].radius * 2, enemys[i].radius * 2);
  } 
  
  // render the pieces
  fill(0, 255, 0);
  for (int i = 0; i < num_pieces; i++)
  {
    ellipse(pieces[i].position.x, pieces[i].position.y, pieces[i].radius * 2, pieces[i].radius * 2);
  }
  
}