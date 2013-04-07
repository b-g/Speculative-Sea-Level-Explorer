// for processing 1.5.1

/*
  Benedikt Gross Copyright (c) 2013 
  http://benedikt-gross.de/log/2013/04/speculative-sea-level-explorer/

  hillshade.pde is based on hillshade.cpp by Matthew Perry
  http://perrygeo.googlecode.com/svn/trunk/demtools/hillshade.cpp

  This sourcecode is free software; you can redistribute it and/or modify it under the terms 
  of the GNU Lesser General Public License as published by the Free Software Foundation; 
  either version 2.1 of the License, or (at your option) any later version.

  This Sourcecode is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License along with this 
  library; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, 
  Boston, MA 02110, USA
 */

import processing.opengl.*;
import codeanticode.glgraphics.*;

import java.nio.channels.FileChannel;
import java.nio.Buffer; 
import java.nio.ByteBuffer;
import java.nio.ShortBuffer;
import java.nio.ByteOrder;

import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;

import controlP5.*;

import java.awt.event.*;

int sealevelMinSetting = -2000;
int sealevelMaxSetting = 2000;

UnfoldingMap map;

ControlP5 cp5;
ControlGroup g1;
RadioButton radio;
Slider seaLevelChangeSlider;

int seaLevelChange = 0;
color seaHigh = color(110, 202, 223 );
color seaBottom = color(74, 148, 160 );
PImage colorMap;
PFont font, fontSmall;

float maxLat, minLat;
float maxLon, minLon;
int srtmResX = 4800;
int srtmResY = 6000;
float[][] srtmRaw = new float[srtmResX][srtmResY];// elevations in meters
int elevations[][];
int maxElevation;
int minElevation;

PGraphics buf;
boolean showOverlay = true;
boolean showSeaLevelAtCursor = false;

BicubicInterpolator bi = new BicubicInterpolator();

boolean doUpdate = true; // FIXME workaround -> buggy controlP5 event reflection
boolean savePng = false;

boolean saveSequence = false;
boolean animateUp = false;
boolean srtmLoaded = false;
int seaLevelChangeStepSize = 30;

String prefix = "";


void setup() {
  println("helo");
  frame.setTitle("Speculative Sea Level Explorer");

  size(1280, 720, GLConstants.GLGRAPHICS);
  cursor(CROSS);

  buf = createGraphics(width, height, P2D);
  colorMap = loadImage("color_map_bene_B_02.png");

  font = loadFont("Akkurat-Bold-35.vlw");
  fontSmall = loadFont("Akkurat-Bold-8.vlw");

  setupGUI();

  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      doUpdate = true;
    }
  }
  ); 

  // -- setup map --
  //map = new de.fhpotsdam.unfolding.Map(this, "map", 0, 0, width, height, true, false, new Microsoft.AerialProvider());
  map = new UnfoldingMap(this, new Microsoft.HybridProvider());
  map.setTweening(false);
  MapUtils.createDefaultEventDispatcher(this, map);

  // -- init elevation data --
  loadElevationData( new File( dataPath("w020n90.Bathymetry.srtm") ) );

  radio.activate(3);
}


void draw() {
  if (doUpdate) {
    updateElevationOverlay();
    doUpdate = false;
  }

  background(0);
  map.draw();
  noStroke();

  if (showOverlay) {
    if (mousePressed == false){
      drawOverlay();
    } else if (g1.isOpen() && mouseX < 200) {
      drawOverlay();
    }
  }

  if (!srtmLoaded){
    textAlign(CENTER);
    text("stringdata", width/2, height/2); 
  }

  if (showSeaLevelAtCursor) {
    String seaLevelAtCursor = elevations[mouseX][mouseY]+ "";
    fill(0);
    textFont(fontSmall);
    rect(mouseX+10, mouseY+13, textWidth(seaLevelAtCursor), -12);
    fill(255);
    text(seaLevelAtCursor, mouseX+10, mouseY+10);
  }

  if (saveSequence) {
    updateElevationOverlay();
    if (animateUp) {
      saveFrame(prefix+"_up_####.png");
      seaLevelChange = seaLevelChange + seaLevelChangeStepSize; 
    } else {
      saveFrame(prefix+"_down_####.png");
      seaLevelChange = seaLevelChange - seaLevelChangeStepSize;
    }
  }

  if (savePng) {
    saveFrame(timestamp()+".png");
    savePng = false;
  }

  cp5.draw();
}


void drawOverlay() {
  image(buf, 0, 0);
  // sealevel counter
  String txt;
  if (seaLevelChange > 0) txt = prefix+"+"+seaLevelChange;
  else if (seaLevelChange == 0) txt = prefix+"  "+seaLevelChange;
  else txt = prefix+" "+seaLevelChange;
  txt += " m ";
  textAlign(LEFT);
  textFont(font);
  fill(0);
  float txtWidth = textWidth(txt);
  rect(width-txtWidth, 37, txtWidth, -38);
  fill(255);
  text(txt, width-txtWidth, 30);
}


public void saveSnapshot() {
  savePng = true;
}


public void openSRTMFile() {
  String loadPath = selectInput("Please select a SRTM file");
  if (loadPath == null) {
    println("No file was selected...");
  } 
  else {
    loadElevationData( new File(loadPath) );
    doUpdate = true;
  }
}


void mouseReleased() {
  if (g1.isOpen()){
    if (mouseX > 200) doUpdate = true;
  } else {
    doUpdate = true;
  }
}


void radioButton(int index) {
  if (index != -1){
    if (index == 0) {
      seaLevelChange = +1000;
    } else if (index == 1) {
      seaLevelChange = +150;
    } else if (index == 2) {
      seaLevelChange = +6;
    } else if (index == 3) {
      seaLevelChange = 0;
    } else if (index == 4) {
      seaLevelChange = -60;
    } else if (index == 5) {
      seaLevelChange = -130;
    }
    seaLevelChangeSlider.setValue(seaLevelChange);
    doUpdate = true;
  }
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("seaLevelChange"))) {
    doUpdate = true;
    radio.activate(-1);
  }
}


// -- load elevation data --
void loadElevationData(File srtmFile) {
  println("loadElevationData() ->" + srtmFile);
  File file = srtmFile;

  // reset globals
  maxLat=0;
  minLat=0;
  maxLon=0;
  minLon=0;
  maxElevation = Integer.MIN_VALUE;
  minElevation = Integer.MAX_VALUE;

  // load srtm bounds
  String[] loadTxt = loadStrings("SRTM_gridraster_info.txt");
  boolean srtmFound = false;
  for (int i=0; i<loadTxt.length; i++) {
    String[] tokens = trim(split(loadTxt[i], ','));
    if (file.getName().equals(tokens[0])) {
      maxLat = float(tokens[4]);
      minLat = float(tokens[3]);
      maxLon = float(tokens[2]);
      minLon = float(tokens[1]);
      srtmFound = true;
    }
  }
  if (!srtmFound) println("### ERROR –> no srtm file found ###");

  // read srtm binary file
  try {
    FileChannel fc = new FileInputStream(file).getChannel();
    ByteBuffer bb = ByteBuffer.allocateDirect((int) fc.size());

    while (bb.remaining () > 0) fc.read(bb);
    fc.close();
    bb.flip();

    // choose the right endianness
    ShortBuffer sb = bb.order(ByteOrder.BIG_ENDIAN).asShortBuffer();

    int counterX = 0;
    int counterY = 0;

    while (sb.hasRemaining ()) {
      int ele = sb.get();
      srtmRaw[counterX][counterY] = ele;
      maxElevation = max(maxElevation, ele);
      minElevation = min(minElevation, ele);
      counterX++;
      if (counterX == srtmResX) {
        counterX = 0;
        counterY++;
      }
    }
    srtmLoaded = true;
  } 
  catch (Exception e) {
    srtmLoaded = false;
    println("### ERROR –> data loading ###");
  }

  println("maxElevation: "+maxElevation);
  println("minElevation: "+minElevation);

  map.zoomToLevel(4);
  map.panTo(new Location( minLat+(maxLat-minLat)/2, minLon+(maxLon-minLon)/2 ));
}


void updateElevationOverlay() {
  Location topLeft = map.getLocationFromScreenPosition(0, 0);
  int[] topLeftIndex = locToSRTMIndex(topLeft);
  Location botRight = map.getLocationFromScreenPosition(width, height);
  int[] botRightIndex = locToSRTMIndex(botRight);

  float top = topLeft.getLat();
  float bottom = botRight.getLat();
  float left = topLeft.getLon(); 
  float right = botRight.getLon();
  println("top: "+top +"  bottom: "+bottom+"  left: "+left+"  right: "+right);

  int localResX = botRightIndex[0] - topLeftIndex[0]; 
  int localResY = botRightIndex[1] - topLeftIndex[1];
  println("localResX: "+localResX +"  localResY: "+localResY);

  // interpolate big srtm array to smaller one
  elevations = new int[width][height];
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      float indexX = map(x, 0, width-1, topLeftIndex[0], botRightIndex[0]);
      float indexY = map(y, 0, height-1, topLeftIndex[1], botRightIndex[1]);
      indexX = constrain(indexX, 0, srtmResX-1);
      indexY = constrain(indexY, 0, srtmResY-1);
      elevations[x][y] = round( bi.getValue(srtmRaw, indexX, indexY) );
    }
  }

  // hillshades
  int[][] hillshades = hillshade(elevations, (maxLat-minLat), (maxLon-minLon), width, height);

  // draw
  buf.beginDraw();
  buf.background(255, 0);
  buf.noStroke();

  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      int ele = elevations[x][y];
      color col = colorMap.get(0, constrain(ele+100-seaLevelChange, 0, colorMap.height-1));
      int hillshadeVal = (int) map(hillshades[x][y], 0, 255, 90, 255);
      color hillshade = color(hillshadeVal);
      if (ele > seaLevelChange) {
        col = blendColor(hillshade, col, MULTIPLY);
      } 
      else {
        if (ele < -300) {
          color tmp;
          float amt = map(ele, -300, -10000, 0, 1);
          amt = constrain(amt, 0, 1);
          tmp = lerpColor(seaHigh, seaBottom, amt);
          col = blendColor(hillshade, tmp, MULTIPLY);
        } 
        else {
          col = blendColor(hillshade, seaHigh, MULTIPLY);
        }
      }   
      buf.fill( col );
      buf.rect(x, y, 1, 1);
    }
  }

  buf.endDraw();
}


int[] locToSRTMIndex(Location loc) {
  float lat = loc.getLat();
  float lon = loc.getLon();
  int y = round( map(lat, maxLat, minLat, 0, srtmResY) );
  int x = round( map(lon, minLon, maxLon, 0, srtmResX) );
  int[] xy = {
    x, y
  };
  return xy;
}


String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

