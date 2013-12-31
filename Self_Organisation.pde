//Variables
final int Prey=1, Pred=2, Object=3;
final int Flocking=1, Evasion=2, Hunting=3, Feeding=4, Dead=5;
final int Target=1, Obstacle=2, Predator=3;
final int Max_Num_Obj=40, Prey_Vision=46, Pred_Vision=46, Evasion_Distance=100;
int minx = 50; int miny = 50; int maxx = 750; int maxy = 550;
int targetx = 0, targety=0, objectx=0, objecty=0, objectr=0; 
int mode = 0;
boolean targetOn=false, flockOn=false, displayOn=false;
int rad = 9, rad_s=12; int numBoids = 5; int numPreds =0; int numObj=0; int safedis = 10;
ParticleSystem ps, os, ss;

//GUI

//buttons
CircleButton boidButton, PredButton, objectButton, targetButton;  
boolean locked = false; 

//set the screen
void setup()
{
  size(800,600);
  frameRate(30);
  colorMode(RGB,255);
  ps = new ParticleSystem(numBoids, rad, Prey);
  os = new ParticleSystem(numObj,0,Object);
  ss = new ParticleSystem(numPreds,12,Pred);
  
  // Define and create circle button 
  int x = 25; 
  int y = 100; 
  int size = 30; 
  color buttoncolor = color(200); 
  color highlight = color(255); 
  ellipseMode(CENTER); 
  boidButton = new CircleButton(x, y, size, buttoncolor, highlight); 
  
  // Define and create rectangle button 
  x = 25; 
  y = 150; 
  size = 30; 
  buttoncolor = color(200, 0, 0); 
  highlight = color(255, 0, 0); 
  PredButton = new CircleButton(x, y, size, buttoncolor, highlight); 
  // Define and create rectangle button 
  x = 25; 
  y = 200; 
  size = 30; 
  buttoncolor = color(0, 200, 0); 
  highlight = color(0, 255, 0); 
  objectButton = new CircleButton(x, y, size, buttoncolor, highlight); 
  
  // Define and create rectangle button 
  x = 25; 
  y = 250; 
  size = 30; 
  buttoncolor = color(200, 200, 0); 
  highlight = color(255, 255, 0); 
  targetButton = new CircleButton(x, y, size, buttoncolor, highlight); 
}

//Main window
void draw()
{
  background(0);
  fill(37,56,114);
  stroke(0);
  rect(minx, miny, maxx-minx, maxy-miny);
  update(mouseX, mouseY); 
  boidButton.display(); 
  PredButton.display(); 
  objectButton.display();
  targetButton.display(); 
  if (targetOn) //Target mode on
  {
    color c_target = color(255, 255, 0); //This defines red colour
    fill(c_target);
    ellipseMode(CENTER);
    ellipse(targetx, targety, 8, 8);
  }
  if (mode==Object & objectx-objectr>minx && objectx+objectr<maxx && 
  objecty-objectr>miny && objecty+objectr<maxy && objectr>0)
  {
    color c_object = color(0, 170, 0); //
    fill(c_object);
    ellipseMode(CENTER);
    ellipse(objectx, objecty, objectr, objectr);
  }
  //flock button
  point(155,15);  point(156,15);  point(155,16);  point(156,16);
  point(165,25);  point(166,25);  point(165,26);  point(166,26);
  point(165,30);  point(166,30);  point(165,31);  point(166,31);
  ps.run();
  os.run();
  ss.run();
}

//Update buttons
void update(int x, int y) 
{ 
  if(locked == false) { 
    boidButton.update(); 
    PredButton.update(); 
    objectButton.update(); 
    targetButton.update();
  } else { 
    locked = false; 
  } 
} 

//Mouse events
void mousePressed() 
{ 
  //For controlling the target in the working area
  if (mouseX>minx && mouseX<maxx && mouseY>miny && mouseY<maxy) //setting boundaries
  {
    if (mode==Target)
    {
      if (!targetOn) targetOn=true;
      targetx = mouseX;
      targety = mouseY;
    }
    if (mode==Object)
    {
      objectx = mouseX;
      objecty = mouseY;
    }
  }
  
  //Button control
  if(boidButton.pressed()) 
  { 
      if (numBoids+numPreds+numObj<Max_Num_Obj)
      {
        ps.addNewParticle(Prey, rad, numBoids);
        numBoids++;    
        draw();
      }
   } else if(PredButton.pressed()) { 
     if (numBoids+numPreds+numObj<Max_Num_Obj)
      {
        ss.addNewParticle(Pred, rad_s, numPreds);
        numPreds++;    
      } 
   } else if(objectButton.pressed()) { 
      if (mode==Target) targetButton.swapColor();
      if (mode!=Object) mode = Object;
      else mode = 0;
      objectButton.swapColor();
      println("object mode"); 
   } else if(targetButton.pressed()) { 
      if (mode==Object) objectButton.swapColor();
      if (mode!=Target) mode = Target;
      else mode = 0;
      targetButton.swapColor();
      println("target mode");
   } 
} 

//To draw the obstacle in Object mode
void mouseDragged() 
{
  if (mode==Object)
  {
    float r=sqrt(sq(mouseX-objectx)+sq(mouseY-objecty));
    objectr = round(r);
  }
} 

//The agents would be created only after the mouse release event happens.
//This is because, the mousedrag event would collide 
//if the agents are created before the mouse click is completed.

void mouseReleased() 
{ 
  if (mode==Object)
  {
    if (numBoids+numObj<Max_Num_Obj) //Only if the number of agents have not reached the limit yet
    {
      Vector3D ltemp = new Vector3D(objectx, objecty, 0); //Position is specified
      Vector3D vtemp = new Vector3D(0,0,0);
      Vector3D atemp = new Vector3D(0,0,0);
      Particle p = new Particle(ltemp,vtemp,atemp,Object, objectr,numObj);
      os.addParticle(p);
      numObj++;
      objectx=0; objecty=0; objectr=0;
    }
  }
} 

//particle

class Particle
{
  Vector3D loc; //Location
  Vector3D vel; //Velocity
  Vector3D acc; //Accelaration
  int type; //Type of agent
  int radius; 
  int id;
  int state;
  int flockID;
  float energy;
  
  Particle(Vector3D l, Vector3D v, Vector3D a, int t, int r, int i) //predator
  {
    loc = l.copy();  vel = v.copy();  acc = a.copy();
    radius = r;  id = i;  state = 0; type = t;  flockID=-1;  energy=100;
  }
  Particle(Vector3D l, Vector3D v, Vector3D a, int t, int r) //prey
  {
    numBoids++;
    loc = l.copy();  vel = v.copy();  acc = a.copy();
    radius = r;  id = numBoids;  state = 0;  type = t; flockID=-1;  energy=100;
  }
  
  void run()
  {
    if (type!=Object && state!=Dead) update();
    render();
  }
  
  //update location
  void update()
  {
    if (energy <=0) //When the agent is considered dead
    {
      state = Dead;
      vel.mult(0);
      return;
    }
    if (type==Prey && state!=Dead) updateV();
    else if(type==Pred && state!=Feeding) 
    {
      s_updateV();
      if (state==Hunting) 
          energy-=2; 
      else energy-=0.1;
    }
    if (state!=Feeding)
    {
      Vector3D tempv = vel.copy(); //Temp velocity
      tempv.mult((mouseX/200)+1); //relative to mouse movement
      loc.add(tempv);
      loc.add(acc);
    }
    else
    {
      if (energy<100) energy += 1;
      else state = 0;
      flockID = -1;
    }
    //boundary restriction
    if (loc.x<minx+radius)
    {
      loc.x = minx+radius;      
      vel.x *= -1;
    }
    else if (loc.x>maxx-radius)
    {
      loc.x = maxx-radius;      
      vel.x *= -1;
    }
    if (loc.y<miny+radius)
    {
      loc.y = miny+radius;      
      vel.y *= -1;
    }
    else if (loc.y>maxy-radius)
    {
      loc.y = maxy-radius;      
      vel.y *= -1;
    }
  }
  
  //Updating velocity
  void s_updateV() 
  {
    float speed = vel.magnitude();
    Vector3D avoidCollisionV = new Vector3D(0,0,0);
    Vector3D targetV = new Vector3D(0,0,0);
    if (state!=Hunting)
    {
      vel.normalize();
      vel.mult(0.2);    
    }
    if (energy<50)
    {
      if (state!=Hunting) 
      {
        targetV = s_getTarget();
      }
      else targetV = s_getTarget(flockID);
      if (state!=Feeding && targetV.magnitude()!=0)
      {
        vel = targetV.copy();
        vel.normalize();
        vel.mult(0.2);
      }  
    }
    avoidCollisionV = s_getAvoid();
    avoidCollisionV.mult(0.8);
    vel.add(avoidCollisionV);
    vel.normalize();
    vel.mult(speed);
    if (state==Hunting)
    {
      acc = vel.copy();
      acc.normalize();
      acc.mult(0.2);
    }
  }
 
  Vector3D s_getAvoid() 
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Vector3D tresultV = new Vector3D(0,0,0);
   
    for (int i = os.particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle) os.particles.get(i);
      float dis = loc.distance(loc, p.loc);
      if (dis<radius/2+p.radius/2+5)
      {
        tresultV.x = loc.x - p.loc.x;
        tresultV.y = loc.y - p.loc.y;
        tresultV.normalize();
        resultV.add(tresultV);
      }
    }
    resultV.z = 0;
    resultV.normalize();
    return resultV;
  }
  
  Vector3D s_getTarget()
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Vector3D tresultV = new Vector3D(0,0,0);
    float temp_dis=1500;
    for (int i = ps.particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle) ps.particles.get(i);
      float dis = loc.distance(loc, p.loc);
      if (dis<temp_dis && p.state!=Dead)
      {
        temp_dis=dis;
        flockID=p.id;
      }
      if (dis<radius && p.state!= Dead)
      {
        state=Feeding;
        p.energy = 0;
        p.state = Dead;
        p.vel.mult(0);
        return resultV;
      }
    }
    if (flockID != -1) resultV=s_getTarget(flockID);
    return resultV;
  }
  Vector3D s_getTarget(int i)
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Particle p = (Particle) ps.particles.get(i);
    resultV = p.loc.copy();
    resultV.sub(loc);
    resultV.normalize();
    return resultV;
  }
  
  void updateV()
  {
    float speed = vel.magnitude();
    Vector3D avoidCollisionV = new Vector3D(0,0,0);
    Vector3D targetV = new Vector3D(0,0,0);
    Vector3D flockV = new Vector3D(0,0,0);
    Vector3D evasionV = new Vector3D(0,0,0);
    evasionV = getEvasion();
   if (state!=Evasion)
   {
    avoidCollisionV = getAvoid();
    vel.normalize();
    //to target
    if (targetOn)
    {
      targetV = getTarget();
      vel = targetV.copy();
    }
    //collision avoidance
    vel.mult(0.2);
    avoidCollisionV.mult(0.8);
    vel.add(avoidCollisionV);
    //flocking
    if (flockOn && type==Prey && flockID==-1)
    {
      flockV = getFlock();
      vel.mult(0.9);
      flockV.mult(0.1);
      vel.add(flockV);
    }
    else if (flockOn && type==Prey)
    {
      flockV = getFlock(flockID);
      vel.mult(0.9);
      flockV.mult(0.1);
      vel.add(flockV);
    }
   }
   else 
   {
     vel=evasionV.copy();
     flockID=-1;
   }
    vel.normalize();
    if (state==Evasion)
    {
      acc=vel.copy();
      acc.normalize();
      acc.mult(0.7);
      energy-=0.1;
    }
    else
    {
      acc.mult(0);
      if (energy<100) energy+=0.1;
    }
    vel.mult(speed);
  }
  //get collision avoidance vector
  Vector3D getAvoid()
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Vector3D tresultV = new Vector3D(0,0,0);
    for (int i = ps.particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle) ps.particles.get(i);
      float dis = loc.distance(loc, p.loc);
      if (dis<(radius+p.radius+safedis) && p.state!=Dead )
      {
        tresultV.x = loc.x - p.loc.x;
        tresultV.y = loc.y - p.loc.y;
        tresultV.normalize();
        resultV.add(tresultV);
      }
    }
    for (int i = os.particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle) os.particles.get(i);
      float dis = loc.distance(loc, p.loc);
      if (dis<radius/2+p.radius/2+5 && p.state!= Dead)
      {
        tresultV.x = loc.x - p.loc.x;
        tresultV.y = loc.y - p.loc.y;
        tresultV.normalize();
        resultV.add(tresultV);
      }
    }
    resultV.z = 0;
    resultV.normalize();
    return resultV;
  }
  //get target vector
  Vector3D getTarget()
  {
    Vector3D resultV = new Vector3D(0,0,0);
    if (targetOn)
    {
      resultV.x = targetx - loc.x;
      resultV.y = targety - loc.y;
      resultV.normalize();
    }
    return resultV;
  }
  //get flocking vector
  Vector3D getFlock()
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Vector3D tempV = new Vector3D(0,0,0);
    Vector3D vcenter = new Vector3D(0,0,0);
    tempV = vel.copy();
    vcenter = loc.copy();
    tempV.normalize();
    tempV.mult(Prey_Vision);
    vcenter.add(tempV);
    int boidID = -1;
    float temp_dis = 100;
    float dis = Prey_Vision;
    for (int i = ps.particles.size()-1; i>=0; i--)
    {
      if (i!=id)
      {
        Particle p = (Particle) ps.particles.get(i);
        dis = vcenter.distance(vcenter, p.loc);
        if (dis<Prey_Vision && p.type==Prey && p.flockID!=id && p.state!=Dead)
        {
          dis =p.loc.distance(p.loc, loc);
          if (dis<temp_dis)
          {
            temp_dis=dis;
            boidID=p.id;
          }
        }
      }
    }
    if (boidID>=0 && boidID<ps.particles.size())
    {
      flockID = boidID;
      //println(id);
      //println(flockID);
      state = Flocking;
      resultV = getFlock(boidID);
    }
    return resultV;
  }
  Vector3D getFlock(int boidID)
  {
    Vector3D resultV = new Vector3D(0,0,0);
    //print(boidID);
    Particle p = (Particle) ps.particles.get(boidID);
    resultV = p.loc.copy();//get close to flock
    resultV.sub(loc);
    resultV.normalize();
    return resultV;
  }
  //get evasion vector from predator
  Vector3D getEvasion()
  {
    Vector3D resultV = new Vector3D(0,0,0);
    Vector3D tempV = new Vector3D(0,0,0);
    Vector3D vcenter = new Vector3D(0,0,0);
    tempV = vel.copy();
    vcenter = loc.copy();
    tempV.normalize();
    tempV.mult(Prey_Vision-radius);
    vcenter.add(tempV);
    float dis = Prey_Vision;
    if (state!=Evasion)
    {
      for (int i = ss.particles.size()-1; i>=0; i--)
      {
        Particle p = (Particle) ss.particles.get(i);
        dis = vcenter.distance(vcenter, p.loc);
        if (dis<Prey_Vision && p.state!=Dead)
        {
          state=Evasion;
          tempV=loc.copy();
          tempV.sub(p.loc);
          tempV.normalize();
          resultV.add(tempV);
        }
      }
    }
    else
    {
      for (int i = ss.particles.size()-1; i>=0; i--)
      {
        state=0;
        Particle p = (Particle) ss.particles.get(i);
        dis = loc.distance(loc, p.loc);
        if (dis<Evasion_Distance+radius+p.radius)
        {
          state=Evasion;
          tempV=loc.copy();
          tempV.sub(p.loc);
          tempV.normalize();
          resultV.add(tempV);
        }
      }
    }
    return resultV;
  }
  //display
  void render()
  {
    Vector3D tempV = new Vector3D(0,0,0);
    Vector3D vcenter = new Vector3D(0,0,0);
    tempV = vel.copy();
    vcenter = loc.copy();
    color c_boid;
    switch (type)
    {
      case Prey:
      //Colour changes as the energy dies away
        c_boid = color(255*energy/100,255*energy/100,255*energy/100); 
        break;
      case Object:
        c_boid = color(0,150,0);
        break;
      case Pred:
      //Colour changes as the enrgy dies away
        c_boid = color(255*energy/100,0,0);
        break;
      default:
        c_boid = color(255,255,255);
    }
    
    if (displayOn && tempV.magnitude()>0)
    {
      tempV.normalize();
      tempV.mult(Prey_Vision-radius*2);
      vcenter.add(tempV);
      fill(c_boid);
      ellipseMode(CENTER);
      ellipse(vcenter.x,vcenter.y,Prey_Vision*2,Prey_Vision*2);
    }
    tempV.normalize();
    tempV.mult(radius*0.8);
    fill(c_boid);
    ellipseMode(CENTER);
    ellipse(loc.x,loc.y,radius,radius);
    line(loc.x, loc.y, loc.x+tempV.x, loc.y+tempV.y);
  }
}  

//particle system
class ParticleSystem
{ //initial positions of the particles evolved by mouse click (Random)
  ArrayList particles = new ArrayList();
  ParticleSystem(int num, int radius, int type)
  {
    for (int i=0; i<num; i++)
    {
      Vector3D ltemp = new Vector3D(random(minx+rad,maxx-rad),random(miny+rad,maxy-rad),0);
      Vector3D vtemp = new Vector3D(random(-1,1),random(-1,1),0);
      vtemp.normalize();
      if (type==Pred) vtemp.mult(1.1);
      Vector3D atemp = new Vector3D(0,0,0);
      particles.add(new Particle(ltemp,vtemp,atemp,type,radius,i));
    }
  }
  
  void run()//cycle through the arraylist
  {
    for (int i=particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle) particles.get(i);
      p.run();
    }
  }
  
  void addParticle(Particle p)
  {
    particles.add(p);
  }
  
  void addNewParticle(int type, int radius, int id)
  {
    Vector3D ltemp = new Vector3D(0,0,0);
    Vector3D vtemp = new Vector3D(0,0,0);
    if (type != Object)
    { //Position of new particle
      ltemp.x=random(minx+rad,maxx-rad); ltemp.y=random(miny+rad,maxy-rad);
      vtemp.x=random(-1,1); vtemp.y=random(-1,1);
      vtemp.normalize();
      if (type==Pred) vtemp.mult(1.1);
    }
    
    Vector3D atemp = new Vector3D(0,0,0);
    particles.add(new Particle(ltemp,vtemp,atemp,type, radius, id));
  }
  
  void tail()
  {
    particles.remove(numBoids-1);
  }
  void tail(int id)
  {
    particles.remove(id);
  }
}

// Simple Vector3D Class 
public class Vector3D { 
  public float x; 
  public float y; 
  public float z; 
 
  Vector3D(float x_, float y_, float z_) { 
    x = x_; 
    y = y_; 
    z = z_; 
  } 
 
  Vector3D(float x_, float y_) { 
    x = x_; 
    y = y_; 
    z = 0f; 
  } 
 
  Vector3D() { 
    x = 0f; 
    y = 0f; 
    z = 0f; 
  } 
 
  void setX(float x_) { 
    x = x_; 
  } 
 
  void setY(float y_) { 
    y = y_; 
  } 
 
  void setZ(float z_) { 
    z = z_; 
  } 
  
  void setXY(float x_, float y_) { 
    x = x_; 
    y = y_; 
  } 
  
  void setXYZ(float x_, float y_, float z_) { 
    x = x_; 
    y = y_; 
    z = z_; 
  } 
 
  void setXYZ(Vector3D v) { 
    x = v.x; 
    y = v.y; 
    z = v.z; 
  } 
  public float magnitude() { 
    return (float) Math.sqrt(x*x + y*y + z*z); 
  } 
 //Duplicating the vector
  public Vector3D copy() { 
    return new Vector3D(x,y,z); 
  } 
 
  public Vector3D copy(Vector3D v) { 
    return new Vector3D(v.x, v.y,v.z); 
  } 
  //new vector with new velocities, with mathematical operations performed
  public void add(Vector3D v) { 
    x += v.x; 
    y += v.y; 
    z += v.z; 
  } 
 
  public void sub(Vector3D v) { 
    x -= v.x; 
    y -= v.y; 
    z -= v.z; 
  } 
 
  public void mult(float n) { 
    x *= n; 
    y *= n; 
    z *= n; 
  } 
 
  public void div(float n) { 
    x /= n; 
    y /= n; 
    z /= n; 
  } 
 
  public void normalize() { 
    float m = magnitude(); 
    if (m > 0) { 
       div(m); 
    } 
  } 
 
  public void limit(float max) { 
    if (magnitude() > max) { 
      normalize(); 
      mult(max); 
    } 
  } 
 
  public float heading2D() { 
    float angle = (float) Math.atan2(-y, x); 
    return -1*angle; 
  } 
 //Defining vector operations of addition, sub, division and multiplication
  public Vector3D add(Vector3D v1, Vector3D v2) { 
    Vector3D v = new Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z); 
    return v; 
  } 
 
  public Vector3D sub(Vector3D v1, Vector3D v2) { 
    Vector3D v = new Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z); 
    return v; 
  } 
 
  public Vector3D div(Vector3D v1, float n) { 
    Vector3D v = new Vector3D(v1.x/n,v1.y/n,v1.z/n); 
    return v; 
  } 
 
  public Vector3D mult(Vector3D v1, float n) { 
    Vector3D v = new Vector3D(v1.x*n,v1.y*n,v1.z*n); 
    return v; 
  } 
 //To calculate distance, subtracting the velocities with respect to x,y, and z
  public float distance (Vector3D v1, Vector3D v2) { 
    float dx = v1.x - v2.x; 
    float dy = v1.y - v2.y; 
    float dz = v1.z - v2.z; 
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz); 
  } 
 
} 

class Button //For GUI
{ 
  int x, y; 
  int size; 
  color basecolor, highlightcolor; 
  color currentcolor; 
  boolean over = false; 
  boolean pressed = false;   
  
  void update() 
  { 
    if(over()) { 
      currentcolor = highlightcolor; 
    } else { 
      currentcolor = basecolor; 
    } 
  } 
  
  void swapColor()
  {
  color tempc1 = color(0,0,0);
  tempc1 = basecolor;
  basecolor = highlightcolor;
  highlightcolor = tempc1;
  }
  
  boolean pressed() 
  { 
    if(over) { 
      locked = true; 
      return true; 
    } else { 
      locked = false; 
      return false; 
    }    
  } 
  
  boolean over() 
  { 
    return true; 
  } 
  
  void display() 
  { 
  
  } 
} 
 
class CircleButton extends Button 
{ 
  CircleButton(int ix, int iy, int isize, color icolor, color ihighlight) 
  { 
    x = ix; 
    y = iy; 
    size = isize; 
    basecolor = icolor; 
    highlightcolor = ihighlight; 
    currentcolor = basecolor; 
  } 
 
  boolean over() 
  { 
    if( overCircle(x, y, size) ) { 
      over = true; 
      return true; 
    } else { 
      over = false; 
      return false; 
    } 
  } 
 
  void display() 
  { 
    stroke(0); 
    fill(currentcolor); 
    ellipse(x, y, size, size); 
  } 
} 
 
class RectButton extends Button //For GUI
{ 
  RectButton(int ix, int iy, int isize, color icolor, color ihighlight) 
  { 
    x = ix; 
    y = iy; 
    size = isize; 
    basecolor = icolor; 
    highlightcolor = ihighlight; 
    currentcolor = basecolor; 
  } 
  
  boolean over() 
  { 
    if( overRect(x, y, size, size) ) { 
      over = true; 
      return true; 
    } else { 
      over = false; 
      return false; 
    } 
  } 
  
  void display() 
  { 
    stroke(0); 
    fill(currentcolor); 
    rect(x, y, size, size); 
  } 
} 
 
boolean overRect(int x, int y, int width, int height) //For GUI
{ 
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) { 
    return true; 
  } else { 
    return false; 
  } 
} 
 
boolean overCircle(int x, int y, int diameter) //For GUI
{ 
  float disX = x - mouseX; 
  float disY = y - mouseY; 
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) { 
    return true; 
  } else { 
    return false; 
  } 
} 
