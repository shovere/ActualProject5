import java.io.*;    // Needed for BufferedReader
import queasycam.*;
import controlP5.*;

QueasyCam cam;
ControlP5 cp5;
float xPos = 150;
float zPos = 300;
float speed = 1.0f;

ArrayList<Scene> scenes = new ArrayList<Scene>();

class Scene{
  String sceneName;
  color backgroundColor;
  ArrayList<Mesh> meshes = new ArrayList<Mesh>();
  ArrayList<Light> lights = new ArrayList<Light>();
  Scene(String sceneName){
     this.sceneName = sceneName;
     this.importScene();
  }
  
  void importScene(){
    BufferedReader reader = createReader(sceneName);
    try {
       String line = reader.readLine();
       int counter = 0;
       while(line != null){
         String[] pieces = split(line, ',');
         switch(counter){
           case 0: 
             this.backgroundColor = color(Float.parseFloat(pieces[0]), Float.parseFloat(pieces[1]), Float.parseFloat(pieces[2]));
             break;
           case 1: 
             int numMeshes = Integer.parseInt(line);
             for(int i = 0; i < numMeshes; i++){
               line = reader.readLine();
               pieces = split(line, ',');
               PVector meshPos = new PVector(Float.parseFloat(pieces[1]), Float.parseFloat(pieces[2]), Float.parseFloat(pieces[3]));
               color meshColor = color(Float.parseFloat(pieces[4]), Float.parseFloat(pieces[5]), Float.parseFloat(pieces[6]));
               Mesh tmpMesh = new Mesh(pieces[0], meshPos, meshColor);
               this.meshes.add(tmpMesh);
             }
             break;
           case 2:
             int numLights = Integer.parseInt(line);
             for(int i = 0; i < numLights; i++){
               line = reader.readLine();
               pieces = split(line, ',');
               PVector lightPos = new PVector(Float.parseFloat(pieces[0]), Float.parseFloat(pieces[1]), Float.parseFloat(pieces[2]));
               color lightColor = color(Float.parseFloat(pieces[3]), Float.parseFloat(pieces[4]), Float.parseFloat(pieces[5]));
               Light tmpLight = new Light(lightPos, lightColor);
               this.lights.add(tmpLight);
             }
             break;
            default:
              println("issue with structure of reader");
         }
         line = reader.readLine();
         counter++;
       }
    }
    catch (IOException e){
      e.printStackTrace();
    }
  }
  
  int GetShapeCount(){
    return meshes.size();
  }
  
  int GetLightCount(){
    return lights.size();
  }
  
  void DrawScene(){
    background(backgroundColor);
    for(Light val : lights){
      pointLight(red(val.lightColor),green(val.lightColor),blue(val.lightColor),val.lightPos.x, val.lightPos.y, val.lightPos.z);
    }
    for(Mesh val : meshes){
      pushMatrix();
      translate(val.meshPos.x, val.meshPos.y, val.meshPos.z);
      val.object.setFill(val.meshColor);
      shape(val.object);
      popMatrix();
    }
    
  }
}

class Mesh{
  PShape object; 
  PVector meshPos;
  color meshColor;
  Mesh(String fileName,PVector meshPos, color meshColor){
    this.object = loadShape("models/"+fileName + ".obj");
    this.meshPos = meshPos;
    this.meshColor = meshColor;
  }
}

class Light{
  PVector lightPos;
  color lightColor;
  Light(PVector lightPos, color lightColor){
    this.lightPos = lightPos;
    this.lightColor = lightColor;
  }
}

int currentScene = 0;
void setup()
{
  size(1200, 1000, P3D);
  pixelDensity(2);
  perspective(radians(60.0f), width/(float)height, 0.1, 1000);
  
  cp5 = new ControlP5(this);
  cp5.addButton("ChangeScene").setPosition(10, 10);
  
  cam = new QueasyCam(this);
  cam.speed = 0;
  cam.sensitivity = 0;
  cam.position = new PVector(0, -50, 100);
  scenes.add(new Scene("scenes/scene1.txt"));
  scenes.add(new Scene("scenes/scene2.txt"));
  lights(); // Lights turned on once here
}


void draw()
{
  // Use lights, and set values for the range of lights. Scene gets REALLY bright with this commented out...
  lightFalloff(1.0, 0.001, 0.0001);
  perspective(radians(60.0f), width/(float)height, 0.1, 1000);
  pushMatrix();
  background(0);
  rotateZ(radians(180)); // Flip everything upside down because Processing uses -y as up
  scenes.get(1).DrawScene();

  popMatrix();

  camera();
  perspective();
  noLights(); // Turn lights off for ControlP5 to render correctly
  DrawText();
}

void mousePressed()
{
  if (mouseButton == RIGHT)
  {
    // Enable the camera
    cam.sensitivity = 1.0f; 
    cam.speed = 2;
  }

}

void mouseReleased()
{  
  if (mouseButton == RIGHT)
  {
    // "Disable" the camera by setting move and turn speed to 0
    cam.sensitivity = 0; 
    cam.speed = 0;
  }
}

void ChangeScene()
{
  currentScene++;
  if (currentScene >= scenes.size())
    currentScene = 0;
}

void DrawText()
{
  textSize(30);
  text("PShapes: " + scenes.get(currentScene).GetShapeCount(), 0, 30);
  text("Lights: " + scenes.get(currentScene).GetLightCount(), 0, 60);
}
