# World Demographics Analysis and Visualization

## Overview
This repository contains a comprehensive data analysis and visualization project focused on world demographics. The project involves extracting, cleaning, and visualizing various demographic and socioeconomic indicators across 115 countries spanning from 1955 to 2023.

The key features of this project include:
- **Data Extraction & Cleaning:** Automated web scraping of demographic, economic, and health indicators from diverse sources (such as Worldometers, Wikipedia, and Numbeo) using R.
- **Interactive Visualization:** An interactive R Shiny application that enables users to dynamically explore the processed demographic dataset through line charts, summary tables, and heatmaps.

## Project Structure
- `Data/`: Contains the main R script (`DATA_EXTRACTION_AND_CLEANING`) responsible for scraping, processing, and standardizing the data. It also houses the intermediate and final cleaned datasets in `.Rdata` and `.csv` formats.
- `Shiny App/`: Contains the R Shiny application code (`Shiny_App_code`) and necessary integrated data (`Combined_data.RData`) for running the interactive visualization dashboard.
- `Project Report/`: Contains a detailed PDF report (`Project_Report.pdf`) documenting the methodology, data sources, and analytical findings of the project.

## Key Demographic Indicators
The final cleaned dataset integrates multiple demographic parameters normalized for comparative analysis, including:
- Total Population
- Fertility Rate
- Urban Population (Absolute and Percentage)
- Yearly Population Change
- Net Migration
- Median Age
- Population Density
- Country's Percentage of World Population
- Mortality Rate

## Technologies Used
- **Programming Language:** R
- **Data Extraction & Processing:** `rvest`, `dplyr`, `tidyverse`, `tidyr`
- **Data Visualization & App:** `shiny`, `ggplot2`, `plotly`, `heatmaply`, `viridis`, `hrbrthemes`

## How to Run the Shiny Application
1. Ensure you have R and RStudio installed on your local machine.
2. Install the required R packages by running the following command in your R console:
   ```R
   install.packages(c("shiny", "dplyr", "ggplot2", "tidyr", "tidyverse", "hrbrthemes", "viridis", "plotly", "heatmaply"))
   ```
3. Set your R working directory to the `Shiny App/` folder inside this repository.
4. Run the application by opening the `Shiny_App_code` script and clicking "Run App" in RStudio, or by executing:
   ```R
   shiny::runApp("Shiny_App_code")
   ```

## Dashboard Features
The Shiny application provides an intuitive interface with three main tabs for comprehensive data exploration:
- **Data Viewer:** Generate interactive line plots to compare a specific demographic parameter across multiple countries over time, or contrast various demographic factors for a single selected country (from 1955 to 2023).
- **Summary:** Access raw data tables and view detailed descriptive statistics for all countries in any given year.
- **Heatmap:** Create an interactive heatmap to visualize and cluster relationships between different demographic factors for selected countries in a specific year.
