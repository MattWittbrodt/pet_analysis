function [BBOX_OUT, NUM_BLOBS, LABEL] = CCA(Image)
    BBOX_OUT = [];
    NUM_BLOBS = [];
    LABEL = [];
%%connected component analisys
    hblob = vision.BlobAnalysis;
    hblob.CentroidOutputPort = false;
    hblob.MaximumCount = 3500;
    hblob.Connectivity = 4;
    hblob.MaximumBlobArea = 6500;
    hblob.MinimumBlobArea = 200;
    hblob.LabelMatrixOutputPort = true;
    hblob.OrientationOutputPort = true;
    hblob.MajorAxisLengthOutputPort = true;
    hblob.MinorAxisLengthOutputPort = true;
    hblob.EccentricityOutputPort = true;
    hblob.ExtentOutputPort = true;
    hblob.BoundingBoxOutputPort = true;
      [AREA,BBOX,MAJOR,MINOR,ORIENT,ECCEN,EXTENT,LABEL] = step(hblob,Image);
      imshow(LABEL*2^16)
      numberOfBlobs = length(AREA);
     allowableAxis = (((MAJOR./MINOR) > 3.8) & (AREA > 200) & (abs(rad2deg(ORIENT))<10) & (EXTENT> 0.6));
      idx = find(allowableAxis);
      keeperBlobsImage = ismember(LABEL, idx);
      imshow(keeperBlobsImage)
      LABEL = bwlabel(keeperBlobsImage, 4);
     for i =1:length(idx)
         BBOX_OUT((i),1:4) = BBOX(idx(i),1:4);
     end
     NUM_BLOBS = length(idx);
  end