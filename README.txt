# Overview
This piece of code enables [Apple QuickLook](http://en.wikipedia.org/wiki/Quick_Look) to open

Sony Mavica *.411 files

from http://alumnus.caltech.edu/~sla/411toppm.html

« Sony Mavica 411 to PPM file converter

This camera produces standard MPEG and JPEG files, but it also creates 64x48 pixel thumbnails for preview/index on its own tiny LCD screen. These files are named with an extension that is ".411".

Sony appears not to want to document the ".411" file format, but it is clear from various web pages that it is a variant of the CCIR.601 standard YUV encoding used in MPEG. The name indicates that the file content consists of chunks of 6 bytes: 4 bytes of image Y values, followed by 1 bytes of U and one byte of V values that apply to the previous 4 Y pixel values. »

To debug the project needs to find qlmanage command line application


#Installation
Copy the Quicklook_d411 target into the following directory
    ~/Library/Quicklook
(maybe, you have to create this folder). Finder has to be restarted in order to be able to use this QuickLook plugin. This can be done by either killing Finder in the terminal (killall Finder) or logout/login.

#Credits
This code is based on Andreas Steinel's PCM viewer  The "Generate(*)ForURL source is only slightly modified from lnxbil-quicklook-pfm-23d2205

