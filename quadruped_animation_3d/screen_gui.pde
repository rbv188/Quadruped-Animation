class screen_gui
{
  HScrollbar[] hs = new HScrollbar[11];
  float[] slider_vals = new float[11];
  String[] labels = new String[]{"torso-pitch","front-left-hip",
                                 "front-left-knee","front-right-hip","front-right-knee","back-left-hip","back-left-knee","back-right-hip",
                                 "back-right-knee","CameraX","CameraZ"};
  int displacement=0;
  int Update_neeeded=0;
  screen_gui()
  {
    hs[0] = new HScrollbar(.8*width,(0+1)*height/20,180,8,1);//the loose parameter had to be 1 here 
    for(int i=1;i<9;i++) {hs[i] = new HScrollbar(.8*width,(i+1)*height/20,180,8,4);}
    for(int i=0; i<2; i++) {hs[i+9] = new HScrollbar(0.1*width, (i+1)*height/20, 180, 8, 4);}
  }

  int update_sliders(float[] list_pair_joint_angles_to_be_updated)//y is supposed to be a boolean here to tell that the bars have been modified by a human
  {
    Update_neeeded=0;
    for(int i=0;i<9;i++)
    {
      text(labels[i],0.7*width,(i+1)*height/20);
      if (i==0||i==1) {displacement=0;}
      else if(i==3||i==5||i==8) {displacement=-1;}
      else if(i==4||i==6) {displacement=2;}
      else if(i==2) {displacement=3;}      
      else if(i==7) {displacement=-4;}
      int y=hs[i].update(true,list_pair_joint_angles_to_be_updated[i+displacement]);
      if(Update_neeeded!=1) {Update_neeeded=y;}//the conditional to make sure that once the Update_needed becomes a 1 it can't be reverted back. 

      if (i==0) {slider_vals[i] = hs[i].getPos()-90;}
      else {if (i!=6 && i!=8) {slider_vals[i] = hs[i].getPos()-180;}
            else {slider_vals[i] = hs[i].getPos();}}
      hs[i].display();
      if(i==0) {text(-1*slider_vals[i],0.95*width,(i+1)*height/20);}
      else if (i!=6 && i!=8) {text(round(slider_vals[i]+90),0.95*width,(i+1)*height/20);}
      else {text(round(slider_vals[i]-90),0.95*width,(i+1)*height/20);}
    }
     
   for(int i=0;i<2;i++)
   {
//     text(labels[i+9],0.01*width,(i+1)*height/20);
     hs[i+9].update(false,500);
  //   hs[i+9].display();
     slider_vals[i+9] = hs[i+9].getPos()-90;
    // text(round(slider_vals[i+9]),0.3*width,(i+1)*height/20);
   }
   return Update_neeeded;
  }
  
  float[] get_slider_pos()
  {
    return slider_vals;
  }
}
