##  Salescope-r-shiny

## Overview

Salescope is an interactive dashboard that helps e-commerce businesses understand their customers better and reduce churn. Regional sales directors can compare performance across different territories, while customer success managers can identify at-risk customers and evaluate which retention strategies work best. The dashboard visualizes purchasing patterns by product category, season, and customer segment to support data-driven decisions about inventory planning and marketing campaigns.

## Deployments

A stable deployment from the `main` branch can be viewed at [https://019ceae0-d475-41e0-a674-ea9bc7477980.share.connect.posit.cloud/]


## Dataset

I used the [Sales and Customer Insights](https://www.kaggle.com/datasets/imranalishahh/sales-and-customer-insights) dataset from Kaggle, which contains 10,000 customer records with purchasing behavior and engagement metrics.


## How to Run Locally

Follow these steps to set up and run the Salescope dashboard on your local machine:

### 1. Clone the Repository

```bash
git clone https://github.com/raghav9048/salescope-r-shiny.git
cd salescope-r-shiny
```

### 2. Create the Environment

Create a conda environment using the provided `environment.yml` file:

```bash
conda env create -f environment.yml
conda activate Salescope
```

### 3. Verify the Data

The dataset is already included in the repository at `data/raw/sales_and_customer_insights.csv`. You can verify it exists by checking:

```bash
ls data/raw/
```

### 4. Install Required R Packages
Open R or RStudio and run:

```R
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "readr", "bsicons", "plotly"))
```

### 5. Run the Dashboard

Start the Shiny dashboard application:

Make sure you're in the project root directory
Start R
Then, run 
shiny::runApp()

The dashboard will automatically open in your default web browser. If it does not open automatically, navigate to the URL shown in the terminal (typically `http://127.0.0.1:8000`).

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.

