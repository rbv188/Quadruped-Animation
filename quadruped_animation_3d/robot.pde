import Jama.*;
import java.lang.*;

class robot
{
  
  Matrix torso, knee, toe;
  
  Matrix torso_transformed;
  Matrix knee_front_left_transformed, knee_front_right_transformed, knee_back_left_transformed, knee_back_right_transformed;
  Matrix toe_front_left_transformed, toe_front_right_transformed, toe_back_left_transformed, toe_back_right_transformed;
  
  double[] knee_position_front_left, knee_position_front_right, knee_position_back_left,knee_position_back_right;
  double[] toe_position;
  
  double[] torso_angles_, hip_angle_front_left_, hip_angle_front_right_, hip_angle_back_left_, hip_angle_back_right_, 
           knee_angle_front_left_, knee_angle_front_right_, knee_angle_back_left_, knee_angle_back_right_;
           
  double thigh_len_, foot_len_, torso_len_, torso_width_;
  
  robot(double torso_len, double torso_width, double thigh_len, double foot_len)
  {
    thigh_len_ = thigh_len;
    foot_len_ = foot_len;
    torso_len_ = torso_len;
    torso_width_ = torso_width;
    
    // end affector coords in local frames
    double[][] torso_coordinates = {{0.5*torso_len,   0.5*torso_len,    -0.5*torso_len,   -0.5*torso_len},
                                    {0.5*torso_width, -0.5*torso_width, 0.5*torso_width, -0.5*torso_width},
                                    {0.0,             0.0,              0.0,              0.0},
                                    {1.0d,            1.0d,             1.0d,             1.0d}};
    
    double[][] knee_coordinates = {{thigh_len},
                                    {0.0},
                                    {0.0},
                                    {1.0}};
                                    
    double[][] toe_coordinates = {{foot_len},
                                  {0.0},
                                  {0.0},
                                  {1.0}};    
   
    // position of coordinates w.r.t previous limb
    knee_position_front_left = new double[] {0.5*torso_len,0.5*torso_width,0.0};
    knee_position_front_right = new double[] {0.5*torso_len,-0.5*torso_width,0.0};
    knee_position_back_left = new double[] {-0.5*torso_len,0.5*torso_width,0.0};
    knee_position_back_right = new double[] {-0.5*torso_len,-0.5*torso_width,0.0};
    
    toe_position = new double[] {thigh_len,0.0,0.0};
    
    torso = new Matrix(torso_coordinates);
    knee = new Matrix(knee_coordinates);
    toe = new Matrix(toe_coordinates);
  }
  
  Matrix create_homogenous_transform(double[] angles, double[] position)
  {
    /*
    angles[0] = yaw
    angles[1] = pitch
    angles[2] = roll
    
    R = R(yaw)*R(pitch)*R(roll)
    
    position[0] = x
    position[1] = y
    position[2] = z
    */
    double alpha = Math.toRadians(angles[0]);
    double beta = Math.toRadians(angles[1]);
    double gamma = Math.toRadians(angles[2]);
    
    double [][] matrix = {{Math.cos(alpha)*Math.cos(beta), Math.cos(alpha)*Math.sin(beta)*Math.sin(gamma)-Math.sin(alpha)*Math.cos(gamma), Math.cos(alpha)*Math.sin(beta)*Math.cos(gamma)+Math.sin(alpha)*Math.sin(gamma), position[0]},
                          {Math.sin(alpha)*Math.cos(beta), Math.sin(alpha)*Math.sin(beta)*Math.sin(gamma)+Math.cos(alpha)*Math.cos(gamma), Math.sin(alpha)*Math.sin(beta)*Math.cos(gamma)-Math.cos(alpha)*Math.sin(gamma), position[1]},
                          {-Math.sin(beta),                Math.cos(beta)*Math.sin(gamma),                                                 Math.cos(beta)*Math.cos(gamma),                                                 position[2]},
                          {0,                              0,                                                                              0,                                                                              1}};
    Matrix ret = new Matrix(matrix);
    return ret;
  }
  
  void update(double[] torso_angles, double[] torso_pos, double[] hip_angle_front_left, double[] hip_angle_front_right, double[] hip_angle_back_left, double[] hip_angle_back_right,
              double[] knee_angle_front_left, double[] knee_angle_front_right, double[] knee_angle_back_left, double[] knee_angle_back_right)
  {
    
    torso_angles_ = torso_angles;
    hip_angle_front_left_ = hip_angle_front_left;
    hip_angle_front_right_ = hip_angle_front_right;
    hip_angle_back_left_ = hip_angle_back_left;
    hip_angle_back_right_ = hip_angle_back_right; 
    knee_angle_front_left_ = knee_angle_front_left;
    knee_angle_front_right_ = knee_angle_front_right;
    knee_angle_back_left_ = knee_angle_back_left;
    knee_angle_back_right_ = knee_angle_back_right;
    
    Matrix torso_transformation = create_homogenous_transform(torso_angles, torso_pos);
    
    Matrix knee_transformation_front_left = create_homogenous_transform(hip_angle_front_left, knee_position_front_left);
    Matrix knee_transformation_front_right = create_homogenous_transform(hip_angle_front_right, knee_position_front_right);
    Matrix knee_transformation_back_left = create_homogenous_transform(hip_angle_back_left, knee_position_back_left);
    Matrix knee_transformation_back_right = create_homogenous_transform(hip_angle_back_right, knee_position_back_right);
    
    knee_transformation_front_left = torso_transformation.times(knee_transformation_front_left);
    knee_transformation_front_right = torso_transformation.times(knee_transformation_front_right);
    knee_transformation_back_left = torso_transformation.times(knee_transformation_back_left);
    knee_transformation_back_right = torso_transformation.times(knee_transformation_back_right);
    
    Matrix toe_transformation_front_left = create_homogenous_transform(knee_angle_front_left, toe_position);
    toe_transformation_front_left = knee_transformation_front_left.times(toe_transformation_front_left);
    
    Matrix toe_transformation_front_right = create_homogenous_transform(knee_angle_front_right, toe_position);
    toe_transformation_front_right = knee_transformation_front_right.times(toe_transformation_front_right);
    
    Matrix toe_transformation_back_left = create_homogenous_transform(knee_angle_back_left, toe_position);
    toe_transformation_back_left = knee_transformation_back_left.times(toe_transformation_back_left);
 
    Matrix toe_transformation_back_right = create_homogenous_transform(knee_angle_back_right, toe_position);
    toe_transformation_back_right = knee_transformation_back_right.times(toe_transformation_back_right);      
    
    torso_transformed = torso_transformation.times(torso);
    knee_front_left_transformed = knee_transformation_front_left.times(knee);
    toe_front_left_transformed = toe_transformation_front_left.times(toe); 
    knee_front_right_transformed = knee_transformation_front_right.times(knee);
    toe_front_right_transformed = toe_transformation_front_right.times(toe);
    knee_back_left_transformed = knee_transformation_back_left.times(knee);
    toe_back_left_transformed = toe_transformation_back_left.times(toe);
    knee_back_right_transformed = knee_transformation_back_right.times(knee);
    toe_back_right_transformed = toe_transformation_back_right.times(toe); 
  }
  
  void display()
  {
    double[][] torso_coordinates = torso_transformed.getArrayCopy();
    double[][] knee_coordinates_front_left = knee_front_left_transformed.getArrayCopy();
    double[][] toe_coordinates_front_left = toe_front_left_transformed.getArrayCopy();
    double[][] knee_coordinates_front_right = knee_front_right_transformed.getArrayCopy();
    double[][] toe_coordinates_front_right = toe_front_right_transformed.getArrayCopy();
    double[][] knee_coordinates_back_left = knee_back_left_transformed.getArrayCopy();
    double[][] toe_coordinates_back_left = toe_back_left_transformed.getArrayCopy();
    double[][] knee_coordinates_back_right = knee_back_right_transformed.getArrayCopy();
    double[][] toe_coordinates_back_right = toe_back_right_transformed.getArrayCopy();
    
    for(int i=0;i<4;i++)
      {
        pushMatrix();
        translate((float)torso_coordinates[0][i], (float)torso_coordinates[1][i], (float)torso_coordinates[2][i]);
        sphere(5);
        popMatrix();
      }

///////////////////////////Torso
      fill(0,255,0,255);
      beginShape();
      vertex((float)torso_coordinates[0][0], (float)torso_coordinates[1][0], (float)torso_coordinates[2][0]);
      vertex((float)torso_coordinates[0][2], (float)torso_coordinates[1][2], (float)torso_coordinates[2][2]);
      vertex((float)torso_coordinates[0][3], (float)torso_coordinates[1][3], (float)torso_coordinates[2][3]);
      vertex((float)torso_coordinates[0][1], (float)torso_coordinates[1][1], (float)torso_coordinates[2][1]);
      endShape(CLOSE);

////////////////////////head

      fill(0,0,0);
      pushMatrix();
      translate((0.6)*(float)(torso_coordinates[0][2]+torso_coordinates[0][3]), (0.6)*(float)(torso_coordinates[1][2]+torso_coordinates[1][3]), (0.6)*(float)(torso_coordinates[2][2]+torso_coordinates[2][3]));
      sphere(10);
      popMatrix();
      
//////////////////////////////Thigh front left 
      fill(255,0,0);
      beginShape();
      vertex((float)((0.85)*torso_coordinates[0][0]+(0.15)*torso_coordinates[0][1]), (float)((0.85)*torso_coordinates[1][0]+(0.15)*torso_coordinates[1][1]), (float)((0.85)*torso_coordinates[2][0]+(0.15)*torso_coordinates[2][1]));
      vertex((float)torso_coordinates[0][0], (float)torso_coordinates[1][0], (float)torso_coordinates[2][0]);
      vertex((float)knee_coordinates_front_left[0][0], (float)knee_coordinates_front_left[1][0], (float)knee_coordinates_front_left[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.9)*torso_coordinates[0][0]+(0.1)*torso_coordinates[0][2]), (float)((0.9)*torso_coordinates[1][0]+(0.1)*torso_coordinates[1][2]), (float)((0.9)*torso_coordinates[2][0]+(0.1)*torso_coordinates[2][2]));
      vertex((float)torso_coordinates[0][0], (float)torso_coordinates[1][0], (float)torso_coordinates[2][0]);
      vertex((float)knee_coordinates_front_left[0][0], (float)knee_coordinates_front_left[1][0], (float)knee_coordinates_front_left[2][0]);
      endShape(CLOSE);
      
///////////////////////////////lower leg front left
      fill(0,0,255);
      beginShape();
      vertex((float)((0.95)*knee_coordinates_front_left[0][0]+(0.05)*torso_coordinates[0][1]), (float)((0.95)*knee_coordinates_front_left[1][0]+(0.05)*torso_coordinates[1][1]), (float)((0.95)*knee_coordinates_front_left[2][0]+(0.05)*torso_coordinates[2][1]));
      vertex((float)knee_coordinates_front_left[0][0], (float)knee_coordinates_front_left[1][0], (float)knee_coordinates_front_left[2][0]);
      vertex((float)toe_coordinates_front_left[0][0], (float)toe_coordinates_front_left[1][0], (float)toe_coordinates_front_left[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.95)*knee_coordinates_front_left[0][0]+(0.05)*torso_coordinates[0][2]), (float)((0.95)*knee_coordinates_front_left[1][0]+(0.05)*torso_coordinates[1][2]), (float)((0.95)*knee_coordinates_front_left[2][0]+(0.05)*torso_coordinates[2][2]));
      vertex((float)knee_coordinates_front_left[0][0], (float)knee_coordinates_front_left[1][0], (float)knee_coordinates_front_left[2][0]);
      vertex((float)toe_coordinates_front_left[0][0], (float)toe_coordinates_front_left[1][0], (float)toe_coordinates_front_left[2][0]);
      endShape(CLOSE);

//////////////////////////////Thigh front right
      
      fill(255,0,0);
      beginShape();
      vertex((float)((0.15)*torso_coordinates[0][0]+(0.85)*torso_coordinates[0][1]), (float)((0.15)*torso_coordinates[1][0]+(0.85)*torso_coordinates[1][1]), (float)((0.15)*torso_coordinates[2][0]+(0.85)*torso_coordinates[2][1]));
      vertex((float)torso_coordinates[0][1], (float)torso_coordinates[1][1], (float)torso_coordinates[2][1]);
      vertex((float)knee_coordinates_front_right[0][0], (float)knee_coordinates_front_right[1][0], (float)knee_coordinates_front_right[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.1)*torso_coordinates[0][3]+(0.9)*torso_coordinates[0][1]), (float)((0.1)*torso_coordinates[1][3]+(0.9)*torso_coordinates[1][1]), (float)((0.1)*torso_coordinates[2][3]+(0.9)*torso_coordinates[2][1]));
      vertex((float)torso_coordinates[0][1], (float)torso_coordinates[1][1], (float)torso_coordinates[2][1]);
      vertex((float)knee_coordinates_front_right[0][0], (float)knee_coordinates_front_right[1][0], (float)knee_coordinates_front_right[2][0]);
      endShape(CLOSE);

///////////////////////////////lower leg front right
      fill(0,0,255);
      beginShape();
      vertex((float)((0.95)*knee_coordinates_front_right[0][0]+(0.05)*torso_coordinates[0][0]), (float)((0.95)*knee_coordinates_front_right[1][0]+(0.05)*torso_coordinates[1][0]), (float)((0.95)*knee_coordinates_front_right[2][0]+(0.05)*torso_coordinates[2][0]));
      vertex((float)knee_coordinates_front_right[0][0], (float)knee_coordinates_front_right[1][0], (float)knee_coordinates_front_right[2][0]);
      vertex((float)toe_coordinates_front_right[0][0], (float)toe_coordinates_front_right[1][0], (float)toe_coordinates_front_right[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.95)*knee_coordinates_front_right[0][0]+(0.05)*torso_coordinates[0][3]), (float)((0.95)*knee_coordinates_front_right[1][0]+(0.05)*torso_coordinates[1][3]), (float)((0.95)*knee_coordinates_front_right[2][0]+(0.05)*torso_coordinates[2][3]));
      vertex((float)knee_coordinates_front_right[0][0], (float)knee_coordinates_front_right[1][0], (float)knee_coordinates_front_right[2][0]);
      vertex((float)toe_coordinates_front_right[0][0], (float)toe_coordinates_front_right[1][0], (float)toe_coordinates_front_right[2][0]);
      endShape(CLOSE);
      
///////////////////////////////////Thigh back left

      fill(255,0,0);
      beginShape();
      vertex((float)((0.85)*torso_coordinates[0][2]+(0.15)*torso_coordinates[0][3]), (float)((0.85)*torso_coordinates[1][2]+(0.15)*torso_coordinates[1][3]), (float)((0.85)*torso_coordinates[2][2]+(0.15)*torso_coordinates[2][3]));
      vertex((float)torso_coordinates[0][2], (float)torso_coordinates[1][2], (float)torso_coordinates[2][2]);
      vertex((float)knee_coordinates_back_left[0][0], (float)knee_coordinates_back_left[1][0], (float)knee_coordinates_back_left[2][0]);
      endShape(CLOSE);

      beginShape();
      vertex((float)((0.9)*torso_coordinates[0][2]+(0.1)*torso_coordinates[0][0]), (float)((0.9)*torso_coordinates[1][2]+(0.1)*torso_coordinates[1][0]), (float)((0.9)*torso_coordinates[2][2]+(0.1)*torso_coordinates[2][0]));
      vertex((float)torso_coordinates[0][2], (float)torso_coordinates[1][2], (float)torso_coordinates[2][2]);
      vertex((float)knee_coordinates_back_left[0][0], (float)knee_coordinates_back_left[1][0], (float)knee_coordinates_back_left[2][0]);
      endShape(CLOSE);

///////////////////////////////lower back left

      fill(0,0,255);
      beginShape();
      vertex((float)((0.95)*knee_coordinates_back_left[0][0]+(0.05)*torso_coordinates[0][0]), (float)((0.95)*knee_coordinates_back_left[1][0]+(0.05)*torso_coordinates[1][0]), (float)((0.95)*knee_coordinates_back_left[2][0]+(0.05)*torso_coordinates[2][0]));
      vertex((float)knee_coordinates_back_left[0][0], (float)knee_coordinates_back_left[1][0], (float)knee_coordinates_back_left[2][0]);
      vertex((float)toe_coordinates_back_left[0][0], (float)toe_coordinates_back_left[1][0], (float)toe_coordinates_back_left[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.95)*knee_coordinates_back_left[0][0]+(0.05)*torso_coordinates[0][3]), (float)((0.95)*knee_coordinates_back_left[1][0]+(0.05)*torso_coordinates[1][3]), (float)((0.95)*knee_coordinates_back_left[2][0]+(0.05)*torso_coordinates[2][3]));
      vertex((float)knee_coordinates_back_left[0][0], (float)knee_coordinates_back_left[1][0], (float)knee_coordinates_back_left[2][0]);
      vertex((float)toe_coordinates_back_left[0][0], (float)toe_coordinates_back_left[1][0], (float)toe_coordinates_back_left[2][0]);
      endShape(CLOSE);

////////////////////////////////////Thigh back right

      fill(255,0,0);
      beginShape();
      vertex((float)((0.15)*torso_coordinates[0][2]+(0.85)*torso_coordinates[0][3]), (float)((0.15)*torso_coordinates[1][2]+(0.85)*torso_coordinates[1][3]), (float)((0.15)*torso_coordinates[2][2]+(0.85)*torso_coordinates[2][3]));
      vertex((float)torso_coordinates[0][3], (float)torso_coordinates[1][3], (float)torso_coordinates[2][3]);
      vertex((float)knee_coordinates_back_right[0][0], (float)knee_coordinates_back_right[1][0], (float)knee_coordinates_back_right[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.1)*torso_coordinates[0][1]+(0.9)*torso_coordinates[0][3]), (float)((0.1)*torso_coordinates[1][1]+(0.9)*torso_coordinates[1][3]), (float)((0.1)*torso_coordinates[2][1]+(0.9)*torso_coordinates[2][3]));
      vertex((float)torso_coordinates[0][3], (float)torso_coordinates[1][3], (float)torso_coordinates[2][3]);
      vertex((float)knee_coordinates_back_right[0][0], (float)knee_coordinates_back_right[1][0], (float)knee_coordinates_back_right[2][0]);
      endShape(CLOSE);
      
      
///////////////////////////////lower back right

      fill(0,0,255);
      beginShape();
      vertex((float)((0.95)*knee_coordinates_back_right[0][0]+(0.05)*torso_coordinates[0][1]), (float)((0.95)*knee_coordinates_back_right[1][0]+(0.05)*torso_coordinates[1][1]), (float)((0.95)*knee_coordinates_back_right[2][0]+(0.05)*torso_coordinates[2][1]));
      vertex((float)knee_coordinates_back_right[0][0], (float)knee_coordinates_back_right[1][0], (float)knee_coordinates_back_right[2][0]);
      vertex((float)toe_coordinates_back_right[0][0], (float)toe_coordinates_back_right[1][0], (float)toe_coordinates_back_right[2][0]);
      endShape(CLOSE);
      
      beginShape();
      vertex((float)((0.95)*knee_coordinates_back_right[0][0]+(0.05)*torso_coordinates[0][2]), (float)((0.95)*knee_coordinates_back_right[1][0]+(0.05)*torso_coordinates[1][2]), (float)((0.95)*knee_coordinates_back_right[2][0]+(0.05)*torso_coordinates[2][2]));
      vertex((float)knee_coordinates_back_right[0][0], (float)knee_coordinates_back_right[1][0], (float)knee_coordinates_back_right[2][0]);
      vertex((float)toe_coordinates_back_right[0][0], (float)toe_coordinates_back_right[1][0], (float)toe_coordinates_back_right[2][0]);
      endShape(CLOSE);
  }
  
}

