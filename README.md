# Mapping thermal textures from point clouds to buildings

The implementation of the methodology and the access datasets are mentioned below:
* A refined CityGML LoD3 model is used. The modelling is done in [SketchUP](https://www.sketchup.com/) using plugin [CityEditor](https://www.3dis.de/cityeditor/).
* The CityGML LoD2 models are available from [LDBV Bavaria](https://geodaten.bayern.de/opengeodata/).
* Data integration, transformation and visualization is done in [FME](https://docs.safe.com/fme/html/FME_Desktop_Documentation/FME_Desktop/Welcome_to_FME_Workbench.htm)
* Programming and computation is performed using [MATLAB](https://mathworks.com/products/matlab.html)
* Mobile laserscanner pointcloud [datasets](https://www.iosb.fraunhofer.de/en/competences/image-exploitation/object-recognition/3d-data/datasets/tum-mls-2016.html) are recorded by Fraunhofer IOSB in 2016.
* Data pre-processing is mostly performed in FME. Building models and point clouds are accurately georeferenced and reprojected to standard coordinate systems, wherever necessary. Heavy point clouds are downsampled to reduce the size. Point cloud filetypes are changed using [CloudCompare](https://www.cloudcompare.org/main.html)/FME. Some clipping of point clouds are done in MATLAB/FME.
* Mask extraction and applying texture image to facade is done in SketchUp.
* MATLAB is used for:
   - Thermal mapping algorithm
   - Post-processing the generated texture image: Brighten and apply heat map to the image and then blended with the mask.
