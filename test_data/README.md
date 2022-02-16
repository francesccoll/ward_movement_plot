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

- phylogentic_tree_file (optional): a phylogenetic file with sequenced samples

NOTE: the data included here was made up, in any case represents the exact ward visits of real patients

