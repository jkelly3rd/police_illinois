# Illinois Officer Data Processing

This script processes data obtained from the state of Illinois that includes personnel information, license and certification information, and employment history for all officers certified in the state. It performs several operations to clean, standardize, and reformat the data. The original data is preserved in a csv format for reference, and a standardized index is created for further analysis.

## R Packages Used

- tidyverse: For data manipulation and visualization
- lubridate: For handling date-time data
- janitor: For cleaning data and managing the workspace

## Original Data

The raw data files are expected to be in CSV format and located in the `data/source/` directory. The files include:

- Individuals.csv
- Certificates.csv
- Employments.csv
- Employers.csv
- Decertifications.csv

## Output

The processed data is saved in the `data/processed/` directory. The output files include:

- il-2023-index.csv
- il-2023-original-officers.csv
- il-2023-original-licenses.csv
- il-2023-original-employment.csv
- il-2023-original-agencies.csv
- il-2023-original-decertifications.csv

## Processing Steps

- A template dataframe for the officers index is created to ensure the final dataframe has the correct structure.
- Relevant date columns are converted to the YYYY-MM-DD format to be consistent with other date fields throughout the project files from other states.
- The employment, agencies, person_data, and codes dataframes are combined on a unique ID (identified by the state of Illinois) to create a more complete work history index similar to those compiled for other states in the project.
- All the name columns are changed to title case and a full name field is created.
- Decertification offense date and decertification reason are added to the index file as a flag indicating that researchers can reference more detailed information about decertification in the decertification file. 
- Processed index plus a series of CSV files with the original data obtained from Illinois are also exported.

These files should be placed in a `data/source/` directory in the same location as the script.

The script will output processed data to the `data/processed/` directory.

The output files are stored in the `data/processed/` directory.

## Questions or suggestions for improvement?

Processing by John Kelly, CBS News at JohnL.Kelly@cbsnews.com.