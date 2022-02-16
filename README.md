# ward_movement_plot

The R script ward_movement_plot.R uses R base graphics to plot patient visits to hospital wards (as coloured rectangles) in a timeline, along with sample collection dates (as circles). If a group of patients are suspected to be part of the same transmission chain (e.g. infected or colonised by the same bacterial clone), this script can be used to generate patient movement plots and visually identify visits to common wards/rooms as potential epidemiological links. See examples of usage, output plots and test data below.

## Required dependencies

### Software and R packages
* [R](https://www.r-project.org/) version >= 4.1.0
* [optparse](https://cran.r-project.org/web/packages/optparse/index.html) version >= 1.6.6
* [phytools](https://cran.r-project.org/web/packages/phytools/index.html) version >= 0.7-80
* [plotrix](https://cran.r-project.org/web/packages/plotrix/index.html) version >= 3.8-2
* [RColorBrewer](https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html) version >= 1.1-2


# Usage and output plots

Get list of all options available:
```console
Rscript ward_movement_plot.R --help

Usage: ward_movement_plot.R [options]
Options:
	-l LOCATIONS_FILE, --locations_file=LOCATIONS_FILE
		File with rooms/wards visited by patient (required)

	-i SAMPLE_INFO_FILE, --sample_info_file=SAMPLE_INFO_FILE
		File with sample information (required)

	-o OUTPUT_PLOT_FILE, --output_plot_file=OUTPUT_PLOT_FILE
		output plot file name (required)

	-t PHYLOGENTIC_TREE_FILE, --phylogentic_tree_file=PHYLOGENTIC_TREE_FILE
		phylogentic tree file (optional). Used to plot patients as samples ordered on the tree.

	-x, --institution_stripes
		whether to display different institution with stripes [default=TRUE]

	-c, --paint_common_wards_only
		whether to colour only wards visited by more than one patient [default=TRUE]

	-w, --display_ward_labels
		whether to display ward labels on plot [default=TRUE]

	-s, --display_sample_labels
		whether to display sample labels on plot [default=TRUE]

	-p BREWER_COLOR_PALETTE, --brewer_color_palette=BREWER_COLOR_PALETTE
		what RColorBrewer palette to use to colour wards [default= Set3]. See https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html

	-v SAMPLE_CIRCLE_SIZE, --sample_circle_size=SAMPLE_CIRCLE_SIZE
		size of circles used to indicate samples [default=2]

	-q SAMPLE_DOT_SIZE, --sample_dot_size=SAMPLE_DOT_SIZE
		size of dots used to indicate sequenced samples [default=0.5]

	-y SAMPLE_LABEL_OFFSET, --sample_label_offset=SAMPLE_LABEL_OFFSET
		offset of sample labels [default= 0.7]

	-z SAMPLE_LABEL_SIZE, --sample_label_size=SAMPLE_LABEL_SIZE
		size of sample labels [default= 0.6]

	-h, --help
		Show this help message and exit
```

Example of use with test data:
```console
Rscript --vanilla patient_movement_plot.R --locations_file visited_wards.csv --sample_info_file isolates_info.csv
```
By default, patients are ordered on the y-axis by collection dates of positive samples, wherein patients with earlier positive samples are plotted at the bottom. See resulting output plot below:

![Patient movement plot 1](https://github.com/francesccoll/ward_movement_plot/blob/main/images/out_plot.no_tree.png)
> NOTE: the data plotted was made up, in any case represents the exact ward visits of real patients

Example of use with test data and phylogenetic tree:
```console
Rscript --vanilla patient_movement_plot.R --locations_file visited_wards.csv --sample_info_file isolates_info.csv --phylogentic_tree_file isolates_tree.tree
```
If a phylogenetic tree is included, patients are ordered on the y-axis based on the order of isolates in the phylogeny. Useful when a rooted phylogeny with a strong temporal phylogenetic signal is available. See resulting output plot below:

![Patient movement plot 2](https://github.com/francesccoll/ward_movement_plot/blob/main/images/out_plot.with_tree.png)
> NOTE: the data plotted was made up, in any case represents the exact ward visits of real patients

# Formatting input data

The test data consists of:
- locations_file: a csv file containing ward/room visits. The following fields are required:
  - patient_id: unique patient identifier
  - from_date: date of admission to ward
  - to_date: date of discharge from ward
  - ward: unique hospital ward/room identifier
  - institution: unique institution/hospital identifier, where ward is contained
  
- sample_info_file: a csv file with sample information. The following fields are required:
  - sample_id: unique sample identifier. This must match the sample ids in phylogentic_tree_file. 
  - patient_id: unique patient identifier. This must match the one in locations_file.
  - status: whether sample is negative (for the organisms/clone of study), positive or positive_sequenced.
  - collection_date: date sample was collected.

- phylogentic_tree_file (optional): a phylogenetic tree file with sequenced samples in newick format.

# License

ward_movement_plot.R  is a free software, licensed under [GNU General Public License v3.0](https://github.com/francesccoll/ward_movement_plot/blob/main/LICENSE)

# Feedback/Issues

Use the [issues page](https://github.com/francesccoll/ward_movement_plot/issues) to report on any bugs or usage issues.

# Citations
If you make use of this script, please cite any of these two papers:

Coll, F. _et al_. Longitudinal genomic surveillance of MRSA in the UK reveals transmission patterns in hospitals and the community. _Science Translational Medicine_ 9, eaak9745 (2017). DOI: 10.1126/scitranslmed.aak9745

Gouliouris, T., Coll, F. _et al_. Quantifying acquisition and transmission of _Enterococcus faecium_ using genomic surveillance. _Nature Microbiology_ 6, 103–111 (2021). DOI: 10.1038/s41564-020-00806-7





