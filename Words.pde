class Barrier{
  /**
  * Creates an Actuator using motor port position 1
  */  
  
  public Barrier(){
    
  }
  
  public FBox createBox(float w, float h, float x, float y, float red, float green, float blue, float alpha, float density, boolean staticbody, boolean beingstatic, boolean sensor, float rotation, String name){
    FBox wall = new FBox (w, h);
    wall.setPosition(x, y);    
    wall.setFill(red, green, blue, alpha);
    wall.setDensity(density);
    wall.setStaticBody(staticbody);
    wall.setStatic(beingstatic);
    wall.setSensor(sensor);
    wall.setNoStroke();
    wall.setName(name);
    wall.setRotation(rotation);
    
    world.add(wall);
    return wall;
  }  
  
  public FCircle createCircle(float radius, float x, float y, float red, float green, float blue, float alpha, float density, float restitution, boolean beingstatic, boolean sensor, String name){
    FCircle wall = new FCircle (radius);
    wall.setPosition(x, y);    
    wall.setFill(red, green, blue, alpha);
    wall.setDensity(density);
    wall.setRestitution(restitution);
    wall.setStatic(beingstatic);
    wall.setSensor(sensor);
    wall.setNoStroke();
    wall.setName(name);
    
    
    world.add(wall);
    return wall;
  }   
  
  
  public FBox createWall(float w, float h, float x, float y, float red, float green, float blue, float alpha, float density, float rotation){
    return this.createBox(w, h, x, y, red, blue, green, alpha, density, true, false, false, rotation, "wall");
  }
  
  public FBox createSticky(float w, float h, float x, float y, float red, float green, float blue, float alpha, float density, float rotation){
    return this.createBox(w, h, x, y, red, blue, green, alpha, density, false, true, true, rotation, "sticky");
  }
  
  public FCircle createBouncy(float radius, float x, float y, float red, float green, float blue, float alpha, float density){
    return this.createCircle(radius, x, y, red, blue, green, alpha, density, 0.8, true, false, "bouncy");
  }
}
