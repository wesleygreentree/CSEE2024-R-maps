# Making maps in R: applications to ecology and evolution

Workshop at 2024 meeting of the Canadian Society for Ecology and Evolution
Vancouver, BC. 26 May 2024
Wesley Greentree, wgreentree@outlook.com

Thank you for attending this workshop on using the R programming language to make beautiful maps to communicate science! This workshop covers the range of standard study area maps to animated maps with satellite images ([examples here](https://wesleygreentree.github.io/animations/)) This Github repository includes code, data, and slides for the workshop.

![study-area-map](figures/study-area-with-inset.PNG)

**Before the workshop**

Please download this Github repository. If you are new to GitHub,
click the green <code> button, and select "Download ZIP".

![github](figures/screenshots-for-readme/github-screenshot.PNG)

Unzip the folder and move it to a desired location on your computer.

**Please run [scripts/00-packages.R](https://github.com/wesleygreentree/CSEE2024-R-maps/blob/main/scripts/00-packages.R) before the workshop.** This scripts installs the necessary R packages for the workshop. 
If you haven't run an R script before, you can highlight all code in this script and select Code > Run Selected Line(s) in RStudio.


** Technical details*

Using R 4.4 with packages installed May 2024. 
The leaflet package has not been updated to R 4.4, so version 4.3.1 was used for [scripts/07-interactive-maps.R](https://github.com/wesleygreentree/CSEE2024-R-maps/blob/main/scripts/07-interactive-maps.R).