robot new_robot;

float[] slider_vals = new float[12];

screen_gui GUI;

double[] angles_torso = new double[3];
double[] angles_hip_front_left = new double[3];
double[] angles_knee_front_left = new double[3];
double[] angles_hip_front_right = new double[3];
double[] angles_knee_front_right = new double[3];
double[] angles_hip_back_left = new double[3];
double[] angles_knee_back_left = new double[3];
double[] angles_hip_back_right = new double[3];
double[] angles_knee_back_right = new double[3];
double[] pos = new double[3];

void setup(){
  size(1280,768,P3D);
  new_robot = new robot(200.0d,100.0d,50.0d,50.0d);
  GUI = new screen_gui();
}

void draw()
{
  background(50);
  stroke(255);
  lights();
  GUI.update_sliders();
  slider_vals = GUI.get_slider_pos();
  angles_torso[1] = slider_vals[0];
  angles_hip_front_left[1] = slider_vals[1];
  angles_knee_front_left[1] = slider_vals[2];
  angles_hip_front_right[1] = slider_vals[3];
  angles_knee_front_right[1] = slider_vals[4];
  angles_hip_back_left[1] = slider_vals[5];
  angles_knee_back_left[1] = slider_vals[6];
  angles_hip_back_right[1] = slider_vals[7];
  angles_knee_back_right[1] = slider_vals[8];
  new_robot.update(angles_torso,pos,angles_hip_front_left,angles_hip_front_right,angles_hip_back_left,angles_hip_back_right,angles_knee_front_left,angles_knee_front_right,angles_knee_back_left,angles_knee_back_right);
  pushMatrix();
  translate(width*0.25,height/2,0);
  rotateX(radians(slider_vals[9]-90));
  rotateZ(radians(slider_vals[10]));
  new_robot.display();
  popMatrix();
}
