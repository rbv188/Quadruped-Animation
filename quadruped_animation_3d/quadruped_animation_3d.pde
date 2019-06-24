import processing.serial.*;

Serial myPort;
robot new_robot;
screen_gui GUI;
int boot_delay_passed=0;
boolean bigger_angles_detected=false;
float[] orientation_matrix=new float[9];//Right now only one slider (pitch) is to be updated by reading from the serial port
float[] old_orientations=new float[4];

float[] slider_vals = new float[11];
double[][] Angle_Matrix = new double[10][3];
byte[]update=new byte[18];//This array will be passed by the serial port to the cat. It will store commands of type i.

//float[] pitch_memory=new float[50];
//int pitch_memory_pointer;
void setup() {
  size(1280, 768, P3D);
  new_robot = new robot(200.0d, 100.0d, 90.0d, 100.0d);
  GUI = new screen_gui();
  myPort = new Serial(this, "/dev/ttyUSB0", 57600);
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

  serialEvent();//this thing works fine
  
  GUI.update_sliders(orientation_matrix);//these two functions work fine

  slider_vals = GUI.get_slider_pos();//---->seems to be working
  Position_update();//--->seems to working
  new_robot.update(Angle_Matrix);//----->maybe works
  
  pushMatrix();
  translate(width*0.25, height/2, 0);
  rotateX(radians(slider_vals[9]-90));
  rotateZ(radians(slider_vals[10]));
  new_robot.display();
  popMatrix();
  
  if(boot_delay_passed==500){bigger_angles_detected=true;}
  boot_delay_passed+=1;
  if(!bigger_angles_detected)
  {
    myPort.write(update);
  }
}

/*
This array will update the Angle_Matrix and the update arrays with the new sloder values
 */
void Position_update()
{
  for (int i=0; i<9; i++)
  {
    if (i==0)
    {
      Angle_Matrix[i][1]=slider_vals[0];
    } else if (i==6 || i==8)
    {
      Angle_Matrix[i][1]=slider_vals[i];
      update[i*2]=(byte) int(slider_vals[i]-90);//Need to subtract -90 here to make things work
    } else
    {
      Angle_Matrix[i][1]=slider_vals[i];
      update[i*2]=(byte) int(slider_vals[i]+90);//Need to add a 90 here because a -180 was subtracted in screen_gui
    }
  }
}


/*
Reads string from the serial port to extract new updated positions
 */
void serialEvent()
{
  String message;
  byte[] message1;
  char inByte;
  int x=0;
  while (myPort.available()>0&&x!=1)
  {
    inByte = (char) myPort.read();
    message = myPort.readStringUntil('\n');
    if (inByte=='g'&&message!=null)
      {        
        String[] list = split(trim(message), " ");
        if(list.length==1)
        {
          orientation_matrix[0] = float(list[0]);
          x++;
        }
      }
  }
  inByte='y';
  x=0;
  while (myPort.available()>0&&((x==0)||(x>0&&inByte!='g')))
  {
    inByte = (char) myPort.read();
    if (inByte=='m')
    {
      message1 = myPort.readBytesUntil('~');
      if (message1!=null&&message1.length==3)
      {
        {orientation_matrix[message1[0]-7] = byte(-1*message1[1]);}
        x++;
      }
    }
  }
}
