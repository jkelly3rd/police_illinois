# Import required libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(stringi)

# Clear the workspace to avoid conflicts with existing variables
rm(list = ls())

# Define the root directory and the output directory
root_dir = getwd()
output_dir = "data/processed/"

# Files originally delivered by state of Florida as an accdb and manually exported to csv
# Define the paths to the input/raw csv files
persons_file = "data/source/Individuals.csv"
licenses_file = "data/source/Certificates.csv"
employment_file = "data/source/Employments.csv"
agencies_file = "data/source/Employers.csv"
decertifications_file = "data/source/Decertifications.csv"

# Define the paths to the output CSV files
il_index = "data/processed/il-2023-index.csv"
il_original_persons = "data/processed/il-2023-original-officers.csv"
il_original_licenses = "data/processed/il-2023-original-licenses.csv"
il_original_employment = "data/processed/il-2023-original-employment.csv"
il_original_agencies = "data/processed/il-2023-original-agencies.csv"
il_original_decertifications = "data/processed/il-2023-original-decertifications.csv"

# Create a template dataframe for the officers index. This will be used to ensure that the final dataframe has the correct structure.
template_index <- data.frame("person_nbr" = character(0),
                             "full_name" = character(0),
                             "first_name" = character(0),
                             "middle_name" = character(0),
                             "last_name" = character(0),
                             "suffix" = character(0),
                             "year_of_birth" = numeric(0),
                             "age" = numeric(0),
                             "agency" = character(0),
                             "type" = character(0),
                             "rank" = character(0),
                             "start_date" = as.Date(character(0)),
                             "end_date" = as.Date(character(0))
)

# Load each of the raw csv files with all columns defaulted to column type col_character
person_data <- read_csv(persons_file, col_types = cols(.default = col_character()))
colnames(person_data) <- c("person_nbr", "last_name", "first_name","middle_name","suffix","year_of_birth","certified")
#Repeat for employment, agencies, licenses, and decertifications
employment <- read_csv(employment_file, col_types = cols(.default = col_character()))
colnames(employment) <- c("row_nbr","person_nbr", "agency_nbr","active","start_date","end_date","full_part_time","type", "rank")
agencies <- read_csv(agencies_file, col_types = cols(.default = col_character()))
colnames(agencies) <- c("agency_nbr", "agency","status")
licenses <- read_csv(licenses_file, col_types = cols(.default = col_character()))
colnames(licenses) <- c("license_type","person_nbr","license_nbr","year_certified")
decertifications <- read_csv(decertifications_file, col_types = cols(.default = col_character()))
colnames(decertifications) <- c("officer_name","agency","person_nbr","year_of_birth","decertification_offense_date","decertification_reason")

# Convert relevant date columns to the YYYY-MM-DD format we are using in all indexes; using the ymd function from the lubridate package.
employment$start_date <- mdy(employment$start_date) %>% as.Date()
employment$end_date <- mdy(employment$end_date) %>% as.Date()
decertifications$decertification_offense_date <- mdy(decertifications$decertification_offense_date) %>% as.Date()

# Combine employment, agencies, person_data, and codes dataframes to create work history index
illinois_roster <- left_join(employment %>% select("person_nbr","agency_nbr","active","start_date","end_date","type","rank"),
                            agencies %>% select ("agency_nbr","agency"), 
                            by = "agency_nbr")

illinois_roster <- left_join(illinois_roster,
                            person_data, 
                            by = "person_nbr")

# convert year of birth columns to number
illinois_roster$year_of_birth <- as.numeric(illinois_roster$year_of_birth)

# Change all the name columns to title case
illinois_roster$first_name <- illinois_roster$first_name %>% str_to_title()
illinois_roster$middle_name <- illinois_roster$middle_name %>% str_to_title()
illinois_roster$last_name <- illinois_roster$last_name %>% str_to_title()

# If suffix == "Null" then change to NA
illinois_roster$suffix <- ifelse(illinois_roster$suffix == "NULL", NA, illinois_roster$suffix)
# Remove from suffix anything that is not a letter
illinois_roster$suffix <- illinois_roster$suffix %>% str_remove_all("[^a-zA-Z]")

# Create full name field
illinois_roster$full_name <- paste(illinois_roster$first_name, ifelse(is.na(illinois_roster$middle_name),"",illinois_roster$middle_name), illinois_roster$last_name, ifelse(is.na(illinois_roster$suffix),"",illinois_roster$suffix), sep=" ")
illinois_roster$full_name <- illinois_roster$full_name %>% str_squish()

# Add decertification offense date and decertification reason to the roster
illinois_roster <- left_join(illinois_roster,
                            decertifications %>% select("person_nbr","decertification_offense_date","decertification_reason"),
                            by = "person_nbr")
# Drop agency_nbr column
illinois_roster <- illinois_roster %>% select(-agency_nbr)

# Merge with template index and sort
il_officers_index <- bind_rows(template_index,illinois_roster)
il_officers_index <- il_officers_index %>% arrange(desc(person_nbr), desc(start_date), full_name)

# Export to csv
il_officers_index %>% write_csv(il_index)

# Export a series of csv files with the original data obtained from Illinois
write_csv(person_data, il_original_persons)
write_csv(employment, il_original_employment)
write_csv(licenses, il_original_licenses)
write_csv(agencies, il_original_agencies)
write_csv(decertifications, il_original_decertifications)



