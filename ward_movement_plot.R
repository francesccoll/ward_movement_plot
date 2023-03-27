#!/usr/bin/env Rscript

library(optparse)


##############################################################################################################
######						                      PARSING ARGUMENTS AND OPTIONS			                           		######
##############################################################################################################

option_list = list(
  make_option(c("-l", "--locations_file"), type="character", action="store", default=NULL, help="File with rooms/wards visited by patient (required)"),
  make_option(c("-i", "--sample_info_file"), type="character", action="store", default=NULL, help="File with sample information (required)"),
  make_option(c("-o", "--output_plot_file"), type="character", action="store", default="out_plot.eps", help="output plot file name (required)"),
  make_option(c("-t", "--phylogenetic_tree_file"), type="character", action="store", default=NULL, help="phylogenetic tree file (optional). Used to plot patients as samples ordered on the tree."),
  make_option(c("-x", "--institution_stripes"), type="logical", action="store_true", default=TRUE, help="whether to display different institution with stripes [default=%default]"),
  make_option(c("-c", "--paint_common_wards_only"), type="logical", action="store_true", default=TRUE, help="whether to colour only wards visited by more than one patient [default=%default]"),
  make_option(c("-w", "--display_ward_labels"), type="logical", action="store_true", default=TRUE, help="whether to display ward labels on plot [default=%default]"),
  make_option(c("-s", "--display_sample_labels"), type="logical", action="store_true", default=TRUE, help="whether to display sample labels on plot [default=%default]"),
  make_option(c("-p", "--brewer_color_palette"), type="character", action="store", default="Set3", help="what RColorBrewer palette to use to colour wards [default= %default]. See https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html"),
  make_option(c("-v", "--sample_circle_size"), type="double", action="store", default=2, help="size of circles used to indicate samples [default=%default]"),
  make_option(c("-q", "--sample_dot_size"), type="double", action="store", default=0.5, help="size of dots used to indicate sequenced samples [default=%default]"),
  make_option(c("-y", "--sample_label_offset"), type="double", action="store", default=0.7, help="offset of sample labels [default= %default]"),
  make_option(c("-z", "--sample_label_size"), type="double", action="store", default=0.6, help="size of sample labels [default= %default]")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

##############################################################################################################
######						                        LOADING REQUIRED LIBRARIES			                           		######
##############################################################################################################

library(phytools)
library(plotrix)
library(RColorBrewer)

# Files:
patient_loc = opt$locations_file
isolate_info = opt$sample_info_file
tree_file = opt$phylogenetic_tree_file
plot_file = opt$output_plot_file
if(!file.exists(patient_loc)){ print(paste("Error: file ", patient_loc, " not found", sep="")); }
if(!file.exists(isolate_info)){ print(paste("Error: file ", isolate_info, " not found", sep="")); }
if(!is.null(tree_file)){ if(!file.exists(tree_file)){ print(paste("Error: file ", tree_file, " not found", sep="")); }}

# Options:
institution_stripes = opt$institution_stripes
paint_common_wards_only = opt$paint_common_wards_only
display_ward_labels = opt$display_ward_labels
display_sample_labels = opt$display_sample_labels
brewer_color_palette = opt$brewer_color_palette
sample_circle_size = opt$sample_circle_size
sample_dot_size = opt$sample_dot_size
sample_label_offset = opt$sample_label_offset
sample_label_size = opt$sample_label_size
# institution_stripes = TRUE
# paint_common_wards_only = TRUE
# display_ward_labels = TRUE
# display_sample_labels = FALSE
# brewer_color_palette = "Set3"
# sample_circle_size = 2
# sample_dot_size = 0.5
# sample_label_offset = 0.60
# sample_label_size = 0.7

dfpl = data.frame(read.delim(patient_loc,sep="\t",header=T))
dfif = data.frame(read.delim(isolate_info,sep="\t",header=T))
max_brewer_color_palette = brewer.pal.info$maxcolors[which(row.names(brewer.pal.info)==brewer_color_palette)];
# NOTE: will only be used if number of wards below the number of colors in palette. Otherwise colours from rainbow() will be used
# https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html

# Time range to be plotted
ldStart = dfpl$from_date[order(as.Date(dfpl$from_date, format = "%Y-%m-%d"))][1];
ldEnd = dfpl$from_date[order(as.Date(dfpl$from_date, format = "%Y-%m-%d"))][nrow(dfpl)];
liStart = 1;
liEnd = as.numeric(as.Date(ldEnd,"%Y-%m-%d") - as.Date(ldStart,"%Y-%m-%d"))+1;

# If no tree is available, patients are ordered based on collection_date of non-negative samples
dfif_pos = subset(dfif, status != "negative")
laPtu = unique(dfif_pos$patient_id[order(as.Date(dfif_pos$collection_date, format = "%Y-%m-%d"))])

# If a tree is provided, patients are ordered as samples are ordered in the tree
if(!is.null(tree_file))
{
  tree = read.tree(file = tree_file, text = NULL, tree.names = NULL, skip = 0, comment.char = "&")
  laSam = as.character(tree$tip.label)
  laSam = gsub("\'", "", laSam); laSam = gsub("\"", "", laSam);
  laPt = vector()
  for(i in 1:length(laSam))
  {
  	ii = which(as.vector(dfif$sample_id) == as.character(laSam[i]))
  	if(length(ii)>0)
  	{
  		laPt = c(laPt,dfif$patient_id[ii])
  	} else
  	{
  		laPt = c(laPt,"NA")
  	}
  }
  laPtu = unique(laPt)
}


# Collecting all observed rooms/wards for patients
laW = vector()
for(p in 1:length(laPtu)) # for each patient
{
	jj = which(dfpl$patient_id == laPtu[p]); laWp = unique(as.character(dfpl$ward[jj])); laW = c(laW,laWp);
}
laW = sort(laW)
laWCol = rainbow(length(laW))
if(length(laW) <= max_brewer_color_palette){ laWCol = brewer.pal(length(laW), brewer_color_palette); }

# commond wards (i.e. visited by at least two patients) will be given a colour
if(paint_common_wards_only == TRUE)
{
  tmp = which(duplicated(laW)==TRUE);
  if(length(tmp)==0){ print("Warning: no common wards found, wards will not be coloured.")}
  laW = unique(laW[tmp]);
  laWCol = rainbow(length(laW));
  if(length(laW) <= max_brewer_color_palette){ laWCol = brewer.pal(length(laW), brewer_color_palette); }
}

# Collecting all observed institutions/hospitals for patients
laH = unique(dfpl$institution[which(!is.na(match(dfpl$patient_id, laPtu)))])
laHa = rep(45, length(laH))
if(length(laH)<=4){ angles = c(45, 135, 90, 0); laHa = angles[1:length(laH)]; }

# Adding months to x-axis
laMnAbb = c("Jan.","Feb.","Mar.","Apr.","May","June","July","Aug.","Sept.","Oct.","Nov.","Dec.")
laXat = vector()
laXlabels = vector()
date = as.Date(ldStart,"%Y-%m-%d")

for(i in liStart:liEnd)
{
	aa = strsplit(as.character(date),"-")
	year = as.numeric(aa[[1]][1]); month = as.numeric(aa[[1]][2]); day = as.numeric(aa[[1]][3]);
	if(day == 1)
	{
		lab = paste(laMnAbb[month],year)
		laXat = c(laXat,i)
		laXlabels = c(laXlabels,lab)
	}
	date = date+1
}


# One row per patient will be produced
liWidth = 6000
liHeight = length(laPtu)*100
postscript(file=plot_file,width=liWidth,height=liHeight,bg="white")
par(mar=c(5,5,10,5))
plot(c(liStart, liEnd), c(0, (length(laPtu)+1)*2), type = "n", axes = F,xlim=c(liStart,liEnd),xlab="", ylab="")
axis(side = 1,at=laXat,labels=laXlabels,cex=0.5)
axis(side = 2,at=seq(2,(length(laPtu)+1)*2,2),labels=c(laPtu,""),cex=0.7,las=1)

title("Patient location information", xlab="Time (days)", ylab="Patient ID")
for(i in 1:length(laPtu)) # for each patient
{
	y = (i)*2
	abline(h = y, lty = 3,col="lightgrey",untf = FALSE)
	ii = which(as.vector(dfpl$patient_id) == laPtu[i])

	# 1. Adding patient location data
	laWardAbr = vector(); # vector to store ward abbreviations
	laWardAbrX = vector(); # vector to store ward abbreviation X coordinates
	laWardAbrY = vector(); # vector to store ward abbreviation Y coordinates
	laWardAbrYlevel = vector(); # vector to store ward abbreviation Y level coordinates

	if(length(ii)>0) # if patient locations entries available for patient
	{
		dfplp = dfpl[ii,]

		# 1.3 Plotting rectangles
		for(j in 1:nrow(dfplp)) # for each patient location data
		{
			xleft = as.numeric(as.Date(dfplp$from_date[j],"%Y-%m-%d") - as.Date(ldStart,"%Y-%m-%d"))+1;
			xright = as.numeric(as.Date(dfplp$to_date[j],"%Y-%m-%d") - as.Date(ldStart,"%Y-%m-%d"))+1;
			ybottom = y - 0.5
			ytop = y + 0.5
			# Colour
			cc = which(laW==as.character(dfplp$ward[j]))
			hos = as.character(dfplp$institution[j])
			
			# ward not visited by at least two different patients are not colour-coded
			if(length(cc)>0){ lsWCol = laWCol[cc]; } else { lsWCol = "#D3D3D3"; }
			rect(xleft, ybottom, xright, ytop, density = NULL, angle = 45, col = lsWCol, border = lsWCol)
			# adding stripes to rectangle based on institution
			if(institution_stripes == TRUE)
			{
  			hh = which(laH == hos); angle = laHa[hh];
  		  rect(xleft, ybottom, xright, ytop, density = 20, angle = angle, col = "black", border = NULL, lwd=0.10)
			}
			laWardAbr = c(laWardAbr,dfplp$ward[j])
			liX = (xleft+xright)/2
			laWardAbrX = c(laWardAbrX,liX)
			laWardAbrY = c(laWardAbrY,(y-0.9))
		}
		# adding ward labels
    if (display_ward_labels == TRUE)
    {
      if(length(laWardAbrX)>0){ thigmophobe.labels(x=laWardAbrX,y=laWardAbrY, labels = laWardAbr, cex=0.8, offset=0.2); }
    }
	}

	
	# 2. Adding sample information
	ii = which(as.vector(dfif$patient_id) == laPtu[i])
	if(length(ii)>0) # if patient has isolates
	{
	  dfifp = dfif[ii,]
		laIsIdLab = vector(); # Isolate ID label
		laIsIdX = vector(); # Isolate ID x coordinate

		for(j in 1:nrow(dfifp))
		{
			x = as.numeric(as.Date(dfifp$collection_date[j],"%Y-%m-%d") - as.Date(ldStart,"%Y-%m-%d"))+1

			if(dfifp$status[j] == "positive_sequenced")
			{
				symbols(x, y, circles=sample_circle_size,add = TRUE, inches = F, bg="gray");
				symbols(x, y, circles=sample_dot_size,add = TRUE, inches = F, bg="black");
			}
			if(dfifp$status[j] == "negative")
			{
			  symbols(x, y, circles=sample_circle_size, add = TRUE, inches = F, bg="white");
			}
			if(dfifp$status[j] == "positive")
			{
			  symbols(x, y, circles=sample_circle_size, add = TRUE,inches = F, bg="white");
			  symbols(x, y, circles=sample_dot_size, add = TRUE,inches = F, bg="black");
			}
			
			laIsIdLab = c(laIsIdLab, as.character(dfifp$sample_id[j]))
			laIsIdX = c(laIsIdX,x)
		}

		laIsIdY = rep(y+sample_label_offset,length(laIsIdX))

		# Placing Isolate ID labels on the plot
		if(display_sample_labels == TRUE)
		{
			thigmophobe.labels(x=laIsIdX,y=laIsIdY, labels = laIsIdLab, cex=sample_label_size, text.pos=NULL, offset=0)	
		}
	} # end of each sample
} # end of for each patient
dev.off()


