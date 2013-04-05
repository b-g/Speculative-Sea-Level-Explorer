void setupGUI() {
  color activeColor = color(157,165,15);

  // -- setup gui --
  cp5 = new ControlP5(this);
  cp5.setColorActive(activeColor);
  cp5.setColorBackground(color(70));
  cp5.setColorForeground(color(128));
  cp5.setColorLabel(color(255));
  cp5.setColorValue(color(255));
  cp5.setAutoDraw(false);

  g1 = cp5.addGroup("g1")
    .setPosition(0,10)
    .setWidth(140)
    .setBackgroundHeight(height)
    .setBackgroundColor(color(0))
    .setLabel("CTRL")
    ;
    
  seaLevelChangeSlider = cp5.addSlider("seaLevelChange")
   .setRange(sealevelMinSetting,sealevelMaxSetting)
   .setValue(0)
   .setPosition(5,10)
   .setTriggerEvent(Slider.RELEASE)
   .setSize(50,345)
   .setGroup(g1)
   .setLabel("Sea-Level Change (Meters)")
   ;

  radio = cp5.addRadioButton("radioButton")
   .setPosition(5,380)
   .setSize(15,15)
   .setItemsPerRow(1)
   .setSpacingColumn(50)
   .addItem("+1000  Waterworld",0)
   .addItem("+150  The Hunger Games",1)
   .addItem("+6  Melting of Ice Sheets",2)
   .addItem("0  Current Sea-Level",3)
   .addItem("-60  Early Holocene",4)
   .addItem("-130  Last Glacial Maximum",5)
   .setGroup(g1)
   ;
   
  cp5.addToggle("showOverlay")
   .setPosition(5,490)
   .setSize(50,20)
   .setValue(true)
   .setMode(ControlP5.SWITCH)
   .setGroup(g1)
   .setLabel("Show Bing Map Only")
   ;
   
  cp5.addToggle("showSeaLevelAtCursor")
   .setPosition(5,530)
   .setSize(50,20)
   .setValue(false)
   .setMode(ControlP5.SWITCH)
   .setGroup(g1)
   .setLabel("Show Sea-Level at Cursor")
   ;
   
  cp5.addBang("openSRTMFile")
   .setPosition(5, 570)
   .setSize(50, 50)
   .setTriggerEvent(Bang.RELEASE)
   .setGroup(g1)
   .setLabel("Load SRTM File")
   ;

  cp5.addBang("saveSnapshot")
   .setPosition(5, 640)
   .setSize(50, 50)
   .setTriggerEvent(Bang.RELEASE)
   .setGroup(g1)
   .setLabel("Save Image")
   ;
}
