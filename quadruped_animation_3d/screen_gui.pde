class screen_gui
{
  HScrollbar[] hs = new HScrollbar[11];
  float[] slider_vals = new float[11];
  String[] labels = new String[]{"torso-pitch","front-left-hip",
                                 "front-left-knee","front-right-hip","front-right-knee","back-left-hip","back-left-knee","back-right-hip",
                                 "back-right-knee","CameraZ","CameraX"};
  
  screen_gui()
  {
    hs[0] = new HScrollbar(.8*width,(0+1)*height/20,180,8,1);

    for(int i=1;i<9;i++)
    {
      hs[i] = new HScrollbar(.8*width,(i+1)*height/20,180,8,4);
    }
    
    for(int i=0; i<2; i++)
    {
      hs[i+9] = new HScrollbar(0.1*width, (i+1)*height/20, 180, 8, 4);
    }
  }

  void update_sliders(float[][] list_pair_joint_angles_to_be_updated)
  {
    for(int i=0;i<9;i++)
    {
      text(labels[i],0.7*width,(i+1)*height/20);
      if(i==0 && list_pair_joint_angles_to_be_updated.length>0)  {hs[i].update(true,list_pair_joint_angles_to_be_updated[i][1]);}
      else  {hs[i].update(false,500.0000000005);}
      hs[i].display();
      if (i==0)
      {
        slider_vals[i] = hs[i].getPos()-90;
      }
      else
      {
        if (i!=6 && i!=8)
        {
          slider_vals[i] = hs[i].getPos()-180;
        }
        else
        {
          slider_vals[i] = hs[i].getPos();
        }
      }
      if(i==0)
     {text(-1*slider_vals[i],0.95*width,(i+1)*height/20);}
      else if (i!=6 && i!=8)
      {
        text(round(slider_vals[i]+90),0.95*width,(i+1)*height/20);
      }
      else
      {
        text(round(slider_vals[i]-90),0.95*width,(i+1)*height/20);
      }
    }
    println(list_pair_joint_angles_to_be_updated.length);
     
    for(int i=0;i<2;i++)
   {
     text(labels[i+9],0.01*width,(i+1)*height/20);
     hs[i+9].update(false,500);
     hs[i+9].display();
     slider_vals[i+9] = hs[i+9].getPos()-90;
     text(round(slider_vals[i+9]),0.3*width,(i+1)*height/20);
   }
  }
  
  float[] get_slider_pos()
  {
    return slider_vals;
  }
}
