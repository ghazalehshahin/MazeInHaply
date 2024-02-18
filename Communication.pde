/**
 **********************************************************************************************************************
 * @file       Communication.pde
 * @author     Ghazaleh Shahin
 * @version    V1.0.0
 * @date       16-February-2023
 * @brief      Words Communication - Lab 3 - CPSC 543 adapted from the source code available on the instructions
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */



/* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import java.util.*;
import java.util.Random;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 



/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerCentimeter                 = 40.0;

/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0); 

/* World boundaries */
FWorld            world;
float             worldWidth                          = 25.0;  
float             worldHeight                         = 25.0; 

float             edgeTopLeftX                        = 0.0; 
float             edgeTopLeftY                        = 0.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

float             gravityAcceleration                 = 980; //cm/s2
/* Initialization of virtual tool */
HVirtualCoupling  s;


/* define background */
PImage          backgroundImage;
int             bgWidth                             =1000;
int             bgHeight                            =1000;
int             k                                   =0;
FBody             wall;

/* define sticky blocks */
Barrier         barrier                             = new Barrier();
List<FBody>      walls                              =new ArrayList<FBody>();

int[][] wallLocations = {
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, 
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, 
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  };
  
int[][] wallLocations2 = {
  {1,1,1,9,9,9,9,9,9,9,9,9,9,9,1,1,1}, 
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,2,9,2,9,2,9,2,9,2,9,2,9,2,9,2,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  };
  
int[][] wallLocations3 = {
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1}, 
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1}, 
  {1,1,3,9,3,9,3,9,3,9,3,9,3,9,3,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1}, 
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1}, 
  {1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  };
  
/* text font */
PFont             f;



/* end elements definition *********************************************************************************************/  



/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 1000);  

  
  /* set font type and size */
  f                   = createFont("Arial", 16, true);

  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */
  haplyBoard          = new Board(this, "COM4", 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);

  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);
 
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  
  widgetOne.device_set_parameters();
  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
  /* Set sticky barriers */
  walls = addWalls(wallLocations);
  k = 1;
  
  System.out.println(walls);
  //  /* Setup the Virtual Coupling Contact Rendering Technique */
  s                   = new HVirtualCoupling((0.75)); 
  s.h_avatar.setDensity(4); 
  s.h_avatar.setFill(255,255,255,0); 
  s.h_avatar.setNoStroke();
  s.h_avatar.setSensor(false);

  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
  
  /* World conditions setup */
  world.setGravity((0.0), gravityAcceleration); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
 
  world.draw();
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  /* setup simulation thread to run at 1kHz */
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}
/* end setup section ***************************************************************************************************/



/* draw section ********************************************************************************************************/
void draw(){
   if (renderingForce == false) {
    background(255);
    world.draw();

    textAlign(CENTER);
    text("Press keys 1, 2, or 3 to change mode.", width/2, 60);
    textAlign(CENTER);
    text("Before changing modes, return to callibration point to make sure you start in the same position.", width/2, 90);
    textAlign(LEFT);
  }
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(posEE.copy().mult(200));  
    }
    
    s.setToolPosition(edgeTopLeftX+worldWidth/2-(posEE).x, edgeTopLeftY+(posEE).y-7); 
    s.updateCouplingForce();
 
 
    fEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    fEE.div(100000); //dynes to newtons
    
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
    
    for (int i = 0; i < walls.size(); ++i)
    {
      if (s.h_avatar.isTouchingBody(walls.get(i)) && walls.get(i).getName().equals("sticky")){
        s.h_avatar.setDamping(900);
        break;
      } 
      //else if (s.h_avatar.isTouchingBody(walls.get(i)) && walls.get(i).getName().equals("bouncy")){
      //  float vy = s.getAvatarVelocityY();
      //  s.setAvatarVelocity(-vy * 0.09, 0);   
      //}
      else {
        s.h_avatar.setDamping(4);
      }   
    }

    
    
    world.step(1.0f/1000.0f);
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/

List<FBody> addWalls (int [][] walls){
  List<FBody> wallsList  = new ArrayList<FBody>();
  FBody wall;
  float x = 0;
  float y = 0;
  int side = walls.length / 2;
  for(int i = 0; i < walls.length; ++i) {
    if(i <= side){
      y = edgeTopLeftY + worldHeight/2.0 - (side - i);
    }
    else{
      y = edgeTopLeftY + worldHeight/2.0 + (i - side); 
    }
      for(int j = 0; j < walls[i].length; ++j) {
        if(j <= side){
          x = edgeTopLeftX + worldWidth/2.0 - (side - j);
        }
        else{
          x = edgeTopLeftX + worldWidth/2.0 + (j - side); 
        }
        
        if(walls[i][j] == 1){
          wall = barrier.createWall(1.0 ,1.0 ,x, y, 10, 10, 10, 0, 0, 0);
          wallsList.add(wall);            
        }
        else if(walls[i][j] == 2){
          wall = barrier.createBouncy(3.0, x, y, 50, 50, 50, 0, 0);
          wallsList.add(wall);
        }
        else if(walls[i][j] == 0){
          wall = barrier.createSticky(1.0, 1.0, x, y, 100, 100 ,100, 0, 800, 0);
          wallsList.add(wall);             
        }
        else if (walls[i][j] == 3){
          wall = barrier.createWall(3.0, 3.0, x, y, 200, 200, 200, 0, 0, 150);
          wallsList.add(wall);
        } 
        //else {
        //  wall = barrier.createWall(0, 0, x, y, 0, 0, 0, 0, 0, 0);
        //  wallsList.add(wall);
        //}
        //world.add(wall);
       }
  }
  //world.draw();
  return wallsList;
}

//void clearWalls(List<FBody> walls){
// ArrayList<FBody> bodies = world.getBodies();
//   for (FBody w : walls) {   
//    for (FBody b : bodies) {
//      try{
//        if (b.getName() != null && b.getName().equals(w.getName())) world.remove(b);
//            System.out.println("cleared"); 

//      } catch (Exception e) {
//    System.out.println(e.getMessage()); 
//}
//    }
//   }
//}

/* keyboard inputs ********************************************************************************************************/
void keyPressed() {
  System.out.println("keyPressed");
  
  /*reset*/
  if (key == '1') { //<>//
    if (k == 1){
      System.out.println("You are in the first world");
      return;
    } else if (k == 2){
      removeBodyByName ("wall");
      removeBodyByName ("bouncy");
    } else {
      removeBodyByName ("wall");
    }
    k = 1;
    walls.removeAll(walls);
    walls = addWalls(wallLocations);
  }
  if (key == '2') {
    if (k == 2){
      System.out.println("You are in the second world");
      return;
    } else if (k == 1){
      removeBodyByName ("wall");
      removeBodyByName ("sticky");
    } else {
      removeBodyByName ("wall");
    }
    k = 2;
    walls.removeAll(walls);
    walls = addWalls(wallLocations2);
  }
  if (key == '3'){
    if (k == 3){
      System.out.println("You are in the third world");
      return;
    } else if (k == 1){
      removeBodyByName ("wall");
      removeBodyByName ("sticky");
    } else {
      removeBodyByName ("wall");
      removeBodyByName ("bouncy");
    }
    k = 3;
    walls.removeAll(walls);
    walls = addWalls(wallLocations3);  
  }
}

void removeBodyByName(String bodyName) {
  ArrayList<FBody> bodies = world.getBodies();
  for (FBody b : bodies) {
    try {
      if (b.getName().equals(bodyName)) {
        world.remove(b);
      }
    } 
    catch(NullPointerException e) {
      // do nothing
    }
  }
}


/* end helper functions section ****************************************************************************************/
