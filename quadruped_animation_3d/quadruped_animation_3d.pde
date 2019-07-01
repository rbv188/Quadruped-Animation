import processing.serial.*;

Serial myPort;
robot new_robot;
screen_gui GUI;
int boot_delay_passed=0;
boolean bigger_angles_detected;
float[][] orientation_matrix=new float[9][2];//Right now only one slider (pitch) is to be updated by reading from the serial port
float[] orientation_arr=new float[9];
float[] slider_vals = new float[11];
double[][] Angle_Matrix = new double[10][3];
byte[]update=new byte[18];//This array will be passed by the serial port to the cat. It will store commands of type i.
int check=0;
int check_counter=0;
float[] pitch_vals=new float[4];

void setup() {
  size(1280, 768, P3D);
  new_robot = new robot(400.0d, 200.0d, 180.0d, 200.0d);
  GUI = new screen_gui();
  myPort = new Serial(this, "/dev/ttyUSB0", 57600);
  //delay(1000);
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
  
  bigger_angles_detected=false;
}

void draw()
{  
  if(boot_delay_passed==500){bigger_angles_detected=true;}
  boot_delay_passed+=1;
  if(!bigger_angles_detected)//Setup...to make sure the robot is set up properly
  {
    graphic_update();
    myPort.write(update);
  }
  else
  {
    serialEvent();//this thing works fine
    int start=millis();
    Update_determinator();
    println("Graphic Processing: "+(millis()-start));  
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

void Update_determinator()
{
  //if(abs(orientation_matrix[0][1]-orientation_matrix[0][0])>5)
  //{
  //  check=orientation_matrix[0][1];
  //  check_counter++;
  //  orientation_matrix[0][1]=orientation_matrix[0][0];
  //}
  //if(check_counter==2)
  //{
  //  orientation_matrix[0][1]=check;
  //  orientation_matrix[0][0]=check;
  //  check_counter=0;
  //}

  int x=0;
  while(x==0)
  {
    if(abs(orientation_matrix[0][0]-orientation_matrix[0][1])>10)
    {
      while(myPort.read()!='g');
      String message = myPort.readStringUntil('\n');
      if(message!=null)
      {
        String[] list = split(trim(message), " ");
        if(list.length==1)
        {
            if(abs(float(list[0])-orientation_matrix[0][1])<=10)
              {orientation_matrix[0][1] = float(list[0]);}
            else
            {orientation_matrix[0][1]=orientation_matrix[0][0];}
            x++;
        }    
      }
    }
    else{x=1;}
  }
  
  //if(check_counter==0||check_counter==1)
  //{check=2+check_counter;}
  //else{check=check_counter-2;}
  
  //if(abs(pitch_vals[check]-pitch_vals[check_counter])>1)
  //{
  //  int average=0;
  //  for(float d:pitch_vals) average+=d/4;
    
  //  if(abs(pitch_vals[check]-average)>abs(pitch_vals[check_counter]-average))
  //  {    orientation_matrix[0][1]=pitch_vals[check_counter];}
  //  else
  //  {orientation_matrix[0][1]=pitch_vals[check];}
  //}
  //else
  //{orientation_matrix[0][1]=pitch_vals[check_counter];}

  for(int i=0;i<9;i++)
  {
    if(abs(orientation_matrix[i][1]-orientation_matrix[i][0])>0)
    {
      graphic_update();
      for(int j=0;j<9;j++) {orientation_matrix[j][0]=orientation_matrix[j][1];}
      break;
    }
  }
}

void graphic_update()
{
  background(100);
  stroke(255);
  lights();
  for(int i=0;i<9;i++)
  {orientation_arr[i]=orientation_matrix[i][1];}

  GUI.update_sliders(orientation_arr);//these two functions work fine
  slider_vals = GUI.get_slider_pos();//---->seems to be working
  Position_update();//--->seems to working
  new_robot.update(Angle_Matrix);//----->maybe works
  
  pushMatrix();
  translate(width*0.4, .8*height/2, 0);
  rotateX(radians(slider_vals[9]-90));
  rotateZ(radians(slider_vals[10]));
  new_robot.display();
  popMatrix();
}

/*
Reads string from the serial port to extract new updated positions
 */
void serialEvent()
{
  int start=millis();
  String message;
  byte[] message1;
  char inByte;
  int x=0;
  while (myPort.available()>0&&x<6)
  {
    inByte = (char) myPort.read();
    if(inByte=='g')
    {
      message = myPort.readStringUntil('\n');
      if(message!=null)
      {        
        String[] list = split(trim(message), " ");
        if(list.length==1)
        {
    //      pitch_vals[check_counter] = float(list[0]);
      //    check_counter=(check_counter+1)%4;
          orientation_matrix[0][1]=float(list[0]);
          x++;
        }
      }
    }
    else if(inByte=='l')
    {
      message1 = myPort.readBytesUntil('~');
      if(message1!=null&&message1.length==17)
        {
          for(int i=0;i<15;i+=2)
            {orientation_matrix[message1[i]-7][1] = byte(-1*message1[i+1]);}
          x++;
        }
    }
    else if (inByte=='m')
    {
      //after update...
      break;
    }
  }
  //  if (inByte=='g'&&message!=null)
  //    {
  //      String[] list = split(trim(message), " ");
  //      if(list.length==1)
  //      {
  //        orientation_matrix[0] = float(list[0]);
  //        x++;
  //      }
  //    }
  //}
  //inByte='y';
  //x=0;
  //while (myPort.available()>0&&((x==0)||(x>0&&inByte!='g')))
  //{
  //  inByte = (char) myPort.read();
  //  if (inByte=='l')
  //  {
  //    message1 = myPort.readBytesUntil('~');
  //    if (message1!=null&&message1.length==17)
  //    {
  //      for(int i=0;i<15;i+=2)
  //        {orientation_matrix[message1[i]-7] = byte(-1*message1[i+1]);}
  //      x++;
  //    }
  //  }
  //}
//  myPort.clear();
  println("Serialevent time consumed: "+(millis()-start));
}
