// based on hillshade.cpp by Matthew Perry
// http://perrygeo.googlecode.com/svn/trunk/demtools/hillshade.cpp

int[][] hillshade(int[][] elevations, float ewres, float nsres, int nXSize, int nYSize) {

  int[][] shadeBuf = new int[nXSize][nYSize];

  int nullValue = 0; // could be any number

  float z = 1.0;
  float scale = 1.0;
  float az = 315-270;
  float alt = 65.0;
  float radiansToDegrees = 180.0 / 3.14159;
  float degreesToRadians = 3.14159 / 180.0;

  // tmp vars all used in for loop
  float[] win = new float[9];
  boolean containsNull;
  float cang;
  float x, y;
  float slope, aspect;

  for (int i = 0; i < nYSize; i++) {
    for (int j = 0; j < nXSize; j++) {
      containsNull = false;

      // Exclude the edges
      if (i == 0 || j == 0 || i == nYSize-1 || j == nXSize-1 )
      {
        // We are at the edge so write nullValue and move on
        shadeBuf[j][i] = nullValue;
        containsNull = true;
        continue;
      }

      // Read in 3x3 window
      /* ------------------------------------------
       * Move a 3x3 window over each cell 
       * (where the cell in question is #4)
       *
       *                 0 1 2
       *                 3 4 5
       *                 6 7 8
       */
      win[0] = elevations[j-1][i-1];
      win[1] = elevations[j  ][i-1];
      win[2] = elevations[j+1][i-1];

      win[3] = elevations[j-1][i  ];
      win[4] = elevations[j  ][i  ];
      win[5] = elevations[j+1][i  ];

      win[6] = elevations[j-1][i+1];
      win[7] = elevations[j  ][i+1];
      win[8] = elevations[j+1][i+1];

      if (containsNull) {
        // We have nulls so write nullValue and move on
        shadeBuf[j][i] = nullValue;
        continue;
      } 
      else {        
        // We have a valid 3x3 window.

        /* ---------------------------------------
         * Compute Hillshade
         */

        // First Slope ...
        x = ((z*win[0] + z*win[3] + z*win[3] + z*win[6]) -
          (z*win[2] + z*win[5] + z*win[5] + z*win[8])) /
          (8.0 * ewres * scale);

        y = ((z*win[6] + z*win[7] + z*win[7] + z*win[8]) -
          (z*win[0] + z*win[1] + z*win[1] + z*win[2])) /
          (8.0 * nsres * scale);

        slope = 90.0 - atan(sqrt(x*x + y*y))*radiansToDegrees;

        // ... then aspect...
        aspect = atan2(x, y);

        // ... then the shade value
        cang = sin(alt*degreesToRadians) * sin(slope*degreesToRadians) +
          cos(alt*degreesToRadians) * cos(slope*degreesToRadians) *
          cos((az-90.0)*degreesToRadians - aspect);

        if (cang <= 0.0) cang = nullValue;
        else cang = 255.0 * cang;

        shadeBuf[j][i] = (int)cang;
      }
    }
  }
  
  return shadeBuf;
}

