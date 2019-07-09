import processing.serial.*;

Serial myPort;
robot new_robot;
screen_gui GUI;

int boot_delay_timer=0;
boolean boot_delay_passed;

int x, y;
float rotX, rotY, rotX0, rotY0;
boolean click=false;

float[][] orientation_matrix=new float[9][2];//Right now only one slider (pitch) is to be updated by reading from the serial port
double[][] Angle_Matrix = new double[10][3];//what gets sent to the robot.ino file
byte[]update=new byte[18];//This array will be passed by the serial port to the cat. It will store commands of type i.x

float[] orientation_arr=new float[9];
float[] slider_vals = new float[11];

int correct_serial_reads;//counts of correct serial reads

String message;//for gyroreadings
byte[] message1;//for motor readings

void setup() {
  size(1350, 700, P3D);
  new_robot = new robot(400.0d, 200.0d, 180.0d, 200.0d);
  GUI = new screen_gui();
  myPort = new Serial(this, "/dev/ttyUSB0", 57600);
  update[0]='i';  //Update needs to start by this element
  update[17]='~';//Update needs to end by this element
  //Storing the motor numbers and beginning angles
  update[1]=(byte) 8;    orientation_matrix[1][1]=(byte) -60;//to make sure that the cat starts out in the rest position
  update[3]=(byte) 12;   orientation_matrix[2][1]=(byte)  -60;
  update[5]=(byte) 9;    orientation_matrix[3][1]=(byte) 60;
  update[7]=(byte) 13;   orientation_matrix[4][1]=(byte) 60;
  update[9]=(byte) 11;   orientation_matrix[5][1]=(byte)  45;
  update[11]=(byte) 15;  orientation_matrix[6][1]=(byte)  45;
  update[13]=(byte) 10;  orientation_matrix[7][1]=(byte) -45;
  update[15]=(byte) 14;  orientation_matrix[8][1]=(byte) -45;
  boot_delay_passed=false;
}

void draw()
{  
  if (boot_delay_timer==500) {boot_delay_passed=true;}
  boot_delay_timer+=1;
  
  if (!boot_delay_passed)//Setup...to make sure the robot is set up properly in the proper 'c' position
  {graphic_update();myPort.write(update);} 
  else {thread("serialEvent");Update_determinator();}
}

//just moved over the stuff from the draw to here for code simplification
void graphic_update()
{
  background(100);
  stroke(255);
  lights();

  //had to copy over the latest elements of the orientation_matrix to a 1D array to be passed on
  for (int i=0; i<9; i++)  {orientation_arr[i]=orientation_matrix[i][1];}
  
  int y=GUI.update_sliders(orientation_arr);//sending the new values to the update sliders
  slider_vals = GUI.get_slider_pos();//getting the new slider positions
  Position_update(y);

  //moving the robot to the new slider positions
  new_robot.update(Angle_Matrix);
  pushMatrix();
  translate(width*0.4, .8*height/2, 0);
  
  prespectiva();
  
  new_robot.display();
  popMatrix();
}

/*
This array will update the Angle_Matrix and the update arrays with the new sloder values
 */
void Position_update(int slider_changed)
{
  for (int i=0; i<9; i++)
  {
    Angle_Matrix[i][1]=slider_vals[i];
    if (i==6 || i==8)
    {update[i*2]=(byte) int(slider_vals[i]-90);}//Need to subtract -90 here to make things work 
    else if(i!=0)
    {update[i*2]=(byte) int(slider_vals[i]+90);}//Need to add a 90 here because a -180 was subtracted in screen_gui
  }
  if(slider_changed==1)
  {myPort.write(update);//should stop stuff being written
  //to make sure it gets to the right initial angles...-1 for fixing the negatives (again the double negative problem as discussed before).
  orientation_matrix[1][1]=-1*update[2];
  orientation_matrix[2][1]=-1*update[6];
  orientation_matrix[3][1]=-1*update[14];
  orientation_matrix[4][1]=-1*update[10];
  orientation_matrix[5][1]=-1*update[4];
  orientation_matrix[6][1]=-1*update[8];
  orientation_matrix[7][1]=-1*update[16];
  orientation_matrix[8][1]=-1*update[12];
  }
}

/*
Determines whether an update is needed or not
*/
void Update_determinator()
{
  for (int i=0; i<9; i++)
  {
    if (abs(orientation_matrix[i][1]-orientation_matrix[i][0])>0.00025)//0.00025 to take care of the noise and to make sure that a change took place
    {
      graphic_update();
      for (int j=0; j<9; j++) {orientation_matrix[j][0]=orientation_matrix[j][1];}break;}}//breaking it caz further iteration is not needed
}

/*
Reads string from the serial port to extract new updated positions
 */
void serialEvent()
{
  char inByte;
  correct_serial_reads=0;
  while (myPort.available()>0&&correct_serial_reads<6)//the x is there to make sure that a certain numer of lines commands are read from the serial port. 
                                                      //It only gets updated once a line from the serial port is successfull in updating the orientation_matrix..if lines
                                                     //if some lines are not skipped, then we might run into some issues with too much deatil and lagness
  {
    inByte = (char) myPort.read();
    if (inByte=='g') {findG(false);} 
    else if (inByte=='l') {findMotors();}
  }
}


/*
finds the orientation
*/
void findG(boolean recursive_call)//reading for the gyroscope values   //the recursive call is there to help with the noise in the gyro values.
{ 
    message = myPort.readStringUntil('\n');
    if (message!=null)
    {
        String[] list = split(trim(message), " ");
        if (list.length==1)
       {if (abs(float(list[0])-orientation_matrix[0][1])<=10||recursive_call){orientation_matrix[0][1] = float(list[0]);} 
        else{while (myPort.read()!='g');findG(true);}correct_serial_reads++;
       }
    }
}

/*
Find the motor angles
*/
void findMotors()//reading for the motor angles
{
  message1 = myPort.readBytesUntil('~');
  if (message1!=null&&message1.length==17) {
    for (int i=0; i<15; i+=2) {orientation_matrix[message1[i]-7][1] = byte(-1*message1[i+1]);//println(orientation_matrix[message1[i]-7][1]);
  }
    correct_serial_reads++;
  }
}

void prespectiva()
{
  if (mousePressed) {
    if (!click) {
      x=mouseX;
      y=mouseY;
      click=true;
      rotX0=rotX;
      rotY0=rotY;
    }
    rotX=(y-mouseY)/float(height) * PI+rotX0;
    rotY=(mouseX-x)/float(height) * PI+rotY0;
  } else 
  {
    click=false;
  }
  rotateX(rotX-PI/2);
  rotateY(0);
  rotateZ(rotY);
}
