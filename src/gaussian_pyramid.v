/*
    SCRATCH PAD
    This filters and then downsamples several times (depending on scale??). 
    I am wondering if I need to maintain the image size this time?. In which 
    case I would need to change the image buffer. I think for now I'll just skip
    that. therefore...

    TODO: 
      1. Figure out what scales to support
      -   increments of 0.05 from 1.10 to 1.5
      2. Figure out how many scales to output, either constant or depends on scale 
      - 1.10 (15), 1.15 (10), 1.20 (8), 1.25(7), 1.30(6), 1.35(5), 1.40(4), 1.45(5), 1.50(5)
      3. Find the skip count value for each scale and how it changes in levels.
      - 1.10 (mod9), 1.15(6), 1.2(5), 1.25(4), 1.3(3), 1.35(2), 1.40(2), 1.45(2), 1.5(1)
*/