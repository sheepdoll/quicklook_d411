/*
 *  image.m
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
#include <stdio.h>
#import "image.h"


@implementation d411Reader


- (void) AllocYCC
{
    
    register int y;
    
    /*
     * first, allocate tons of memory
     */
    orig_y = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        orig_y[y] = (uint8 *) malloc(sizeof(uint8) * width);
    }
    
    orig_cr = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        orig_cr[y] = (uint8 *) malloc(sizeof(uint8) * width / 4);
    }
    
    orig_cb = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        orig_cb[y] = (uint8 *) malloc(sizeof(uint8) * width / 4);
    }
    
    /* allocate YUV memory */
    
    Y = (int **) malloc(sizeof(int *) * height);
    for (y = 0; y < height; y++) {
        Y[y] = (int *) malloc(sizeof(int) * width);
    }
    
    U = (int **) malloc(sizeof(int *) * height);
    for (y = 0; y < height; y++) {
        U[y] = (int *) malloc(sizeof(int) * width / 4);
    }
    
    V = (int **) malloc(sizeof(int *) * height);
    for (y = 0; y < height; y++) {
        V[y] = (int *) malloc(sizeof(int) * width / 4);
    }
    
   
    /* allocate rgb memory */
    
    red = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        red[y] = (uint8 *) malloc(sizeof(uint8) * width);
    }
    
    green = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        green[y] = (uint8 *) malloc(sizeof(uint8) * width);
    }
    
    blue = (uint8 **) malloc(sizeof(uint8 *) * height);
    for (y = 0; y < height; y++) {
        blue[y] = (uint8 *) malloc(sizeof(uint8) * width);
    }


    
}

- (void) FreeYCC
{
    
    register int y;
    
    /*
     * last, clean up tons of memory
     */
    for (y = 0; y < height; y++) {
        free(orig_y[y]);
    }
    free(orig_y);
    for (y = 0; y < height; y++) {
        free(orig_cr[y]);
    }
    free(orig_cr);

    for (y = 0; y < height; y++) {
        free(orig_cb[y]);
    }
    free(orig_cb);
    
    /* deallocate YUV memory */
    
    for (y = 0; y < height; y++) {
        free(Y[y]);
    }
    free(Y);
    
    for (y = 0; y < height; y++) {
        free(U[y]);
    }
    free(U);

    for (y = 0; y < height; y++) {
        free(V[y]);
    }
    free(V);

    
    /* deallocate rgb memory */
    
    for (y = 0; y < height; y++) {
        free(red[y]);
    }
    free(red);
    
    for (y = 0; y < height; y++) {
        free(green[y]);
    }
    free(green);
    
    for (y = 0; y < height; y++) {
        free(blue[y]);
    }
    free(blue);
}


- (CGImageRef)load411
{
    
    // resetting dimensions and counters
    channels = 3;
 
    long   tempR, tempG, tempB;
    int     r, g, b;
    int     x, y;
    
    unsigned char *imageDataPtr;
    


    NSLog(@"Image has been read and has size %dx%dx%d\n",width, height, channels);

    spp = channels;
    bps = 8;
    
    NSString* csp = NSDeviceRGBColorSpace;
    
    
    
    NSBitmapImageRep *image2 = NULL;
    image2 = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
              pixelsWide:nx pixelsHigh:ny bitsPerSample:bps
              samplesPerPixel:spp hasAlpha:NO isPlanar:NO
              colorSpaceName:csp
              bytesPerRow:nx*spp*(bps/8) bitsPerPixel:spp*bps ];
    
    if (image2 == NULL)
    {
        NSLog(@"Image cannot be constructed by NSBitmapImageRep!");
        return NULL;
    }
    
    imageDataPtr = (unsigned char *) [image2 bitmapData];
   
    NSLog(@"converting data from YCC to YUV");
    
    // normalize colorspace from YCC to YUV (-128 to 128)
    
    for ( y = 0; y < height; y ++ )
        for ( x = 0; x < width/4; x ++ )
            {
                U[y][x] = orig_cb[y][x] - 128;
                V[y][x] = orig_cr[y][x] - 128;
            }
        
    for ( y = 0; y < height; y ++ )
        for ( x = 0; x < width; x ++ )
        {
            Y[y][x] = orig_y[y][x] - 16;
        }
    
    for ( y = 0; y < height; y++ )
        for ( x = 0; x < width; x++ )
        {
            /* look at yuvtoppm source for explanation */
            // basically this does a color vector translation
            // there should be a Quartz colorspace that does this
            // as part of the device space, like in postscript
            // but docs are sketcy on that
            
            
            tempR = 104635*V[y][x/4];
            tempG = -25690*U[y][x/4] + -53294 * V[y][x/4];
            tempB = 132278*U[y][x/4];
                
            tempR += (Y[y][x]*76310);
            tempG += (Y[y][x]*76310);
            tempB += (Y[y][x]*76310);
                
            r = CHOP((int)(tempR >> 16));
            g = CHOP((int)(tempG >> 16));
            b = CHOP((int)(tempB >> 16));
                
            red[y][x] = r;  green[y][x] = g;    blue[y][x] = b;
        }
     
    NSLog(@"Constructing RGB image");

    for ( y = 0; y < height; y++ )
        for ( x = 0; x < width; x++ )
        {
            *imageDataPtr++ = red[y][x];
            *imageDataPtr++ = green[y][x];
            *imageDataPtr++ = blue[y][x];
         }
 
    NSLog(@"Image constructed and image pointer is %p\n", image2);
    
    [ self FreeYCC ]; 
    
    return [image2 CGImage];
}


- (CGImageRef)load:(CFStringRef)filenameCF
{
    FILE   *inimage;        // input file
    int i;
    
    // const char *filename = CFStringGetCStringPtr(filenameCF, CFStringGetSystemEncoding());
    char *fullPath;
    char filename[512];;
    
    Boolean conversionResult;
    CFStringEncoding encodingMethod;

    
    NSLog(@"ImageClass for mavica 411 preview files");
    
    height = 48;
    width = 64;

    // This is for ensuring safer operation. When CFStringGetCStringPtr() fails,
    // it tries CFStringGetCString().
     
    encodingMethod = CFStringGetFastestEncoding(filenameCF);
     
    // 1st try for English system
    fullPath = (char*)CFStringGetCStringPtr(filenameCF, encodingMethod);

    // for safer operation.
    if( fullPath == NULL )
    {
        CFIndex length = CFStringGetMaximumSizeOfFileSystemRepresentation(filenameCF);
        fullPath = (char *)malloc( length + 1 );
        conversionResult = CFStringGetFileSystemRepresentation(filenameCF, fullPath, length);
        
        strcpy( filename, fullPath );
        
        free( fullPath );
    }
    else
        strcpy( filename, fullPath );
    
    
    // open image read-only
    inimage = fopen( filename,"r");
    
    // file cannot be opened
    if ( inimage == NULL )
    {
        NSLog(@"ERROR: The file '%@' cannot be opened!\n", filenameCF);
        return NULL;
    }
    
    [ self AllocYCC ];
 
    // from ReadYUV(FILE *fp); 
            
    for (ny = 0; ny < height; ny++)
    {
        for (nx = 0, i = 0; nx < width; nx+=4, i++)
        {
            fread(orig_y[ny]+nx , 1, 4, inimage);
            fread(orig_cb[ny]+i, 1, 1, inimage);
            fread(orig_cr[ny]+i, 1, 1, inimage);
        }
    }
    
    // close image
    fclose(inimage);
    
    // how do we check for invalid file?
    return [self load411 ];

    //return NULL;
}

@end
