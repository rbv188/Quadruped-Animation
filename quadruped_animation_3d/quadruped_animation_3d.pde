import processing.serial.*;

Serial myPort;
robot new_robot;
screen_gui GUI;

float[] orientation_matrix=new float[1];

float[] slider_vals = new float[12];
double[][] Angle_Matrix = new double[10][3];
byte[]update=new byte[18];//This array will be passed by the serial port to the cat. It will store commands of type i.

void setup(){
  size(1280,768,P3D);
  new_robot = new robot(200.0d,100.0d,90.0d,100.0d);
  GUI = new screen_gui();
  myPort = new Serial(this, "/dev/rfcomm0", 57600);
  update[0]='i';//Update needs to start by this element
  update[17]='~';//Update needs to end by this element
  
  //Storing the motor numbers
  update[1]=(byte) 8;
  update[3]=(byte) 12;
  update[5]=(byte) 9;
  update[7]=(byte) 13;
  update[9]=(byte) 11;
  update[11]=(byte) 15;
  update[13]=(byte) 10;
  update[15]=(byte) 14;
}

void draw()
{
  background(100);
  stroke(255);
  lights();
  
  serialEvent();
  
  GUI.update_sliders(OrientationCalculator());

  slider_vals = GUI.get_slider_pos();

  //A function below to deal with the updating of update[] and Angle_Matrix[][] with the new slider values.
  Position_update(Angle_Matrix);
  new_robot.update(Angle_Matrix);

  pushMatrix();
  translate(width*0.25,height/2,0);
  rotateX(radians(slider_vals[9]-90));
  rotateZ(radians(slider_vals[10]));
  new_robot.display();
  popMatrix();
  myPort.write(update);
  delay(50);
//  myPort.clear();
}


/*
This array will update the Angle_Matrix and the update arrays with the new sloder values
*/
void Position_update(double[][] AngleMatrix)
{
  for(int i=0;i<=8;i++)
  {
    if(i==0)
    {
//      println("ANgle on the slilder: "+slider_vals[0]);
      AngleMatrix[i][1]=slider_vals[0];
    }
    else if(i==6 || i==8)
    {
      AngleMatrix[i][1]=slider_vals[i];
      update[i*2]=(byte) int(slider_vals[i]-90);//Need to subtract -90 here to make things work
    }
    else
    {
      AngleMatrix[i][1]=slider_vals[i];
      update[i*2]=(byte) int(slider_vals[i]+90);//Need to add a 90 here because a -180 was subtracted in screen_gui
    }
  }
}


/*
Reads string from the serial port to extract new updated positions
*/
void serialEvent()
{
  int newLine = 13; // new line character in ASCII
  String message;
  do {
    message = myPort.readStringUntil(newLine); // read from port until new line
    if (message != null) {
      print(message);
      String[] list = split(trim(message), " ");
      if (list.length >= 2 && list[0].equals("A")) {
        orientation_matrix[0] = float(list[1]); // convert to float pitch
      }
    }
  } while (message != null);
}


float[][] OrientationCalculator()
{
  ArrayList<float[]> New_angles=new ArrayList<float[]>();
  
  for(int i=0;i<orientation_matrix.length;i++)
  {
    float[] adden={i,orientation_matrix[0]};
    {New_angles.add(adden);}
  }
  

  //dont know whether if the output format is right
  float new_angles[][]=new float[New_angles.size()][2];
  new_angles=New_angles.toArray(new_angles);
  
  println("OrientationCalculator start");
  for(int i=0;i<New_angles.size();i++)  
  {printArray(new_angles[i]);}
  println("SHould be something above");
  return new_angles;
}
