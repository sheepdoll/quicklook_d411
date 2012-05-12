/*
 *  image.h
 *  Quicklook-PFM
 * 
 * Copyright (C) 2008-2012 Andreas Steinel
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 */

#import <Cocoa/Cocoa.h>

#define CHOP(x)     ((x < 0) ? 0 : ((x > 255) ? 255 : x))


// This class implements the Sony Mavica 411 preview files
// the known formats based on the ppm converter code located at
// http://alumnus.caltech.edu/~sla/411toppm.html
// 
@interface d411Reader : NSObject {

    uint8 **orig_y, **orig_cb, **orig_cr;
    uint8 **red, **green, **blue;
    int   **Y, **U, **V;

    int     width ;
    int     height;
    
    uint nx, ny;        // width and height
    uint8 spp;          // samples per pixel
    uint8 bps;          // bit per sample
    uint8 channels;     // channels
    uint  cp;           // color depth (#colors)
}


- (CGImageRef)load411;

- (void) FreeYCC;
- (void) AllocYCC;

// general case
- (CGImageRef)load:(CFStringRef)filename;



@end
