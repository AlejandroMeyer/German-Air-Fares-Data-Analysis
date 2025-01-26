# ✈️ German Air Fares Data Analysis

This project performs exploratory data analysis (EDA) on airfares data related to flights in Germany. The dataset includes information about departure and arrival cities, airlines, flight prices, and other related attributes. The goal of the analysis is to uncover patterns and gain valuable insights into flight prices based on various factors such as departure and arrival cities, airlines, departure time, and more.

The data used in this analysis is stored in a CSV file, with additional details about the columns in a text file. The data was sourced from Kaggle, and the link to the dataset can be found below. The `documentation.pdf` file provides an explanation of how the SQL code functions.

## Project Components

1. **Database Connection**  
   The project uses `pyodbc` to connect to a SQL Server database and retrieve airfares data from a specific table.

2. **Data Extraction**  
   Data is extracted by executing an SQL query to retrieve relevant flight information such as departure city, arrival city, airline, price, departure time, and more.

3. **Exploratory Data Analysis (EDA)**  
   The project explores various aspects of the dataset:
   - **Average Price by Route**: The average price of flights is calculated based on the departure and arrival cities.
   - **Price Distribution by Departure Hour**: The relationship between flight prices and departure times is analyzed.
   - **Price by Airline**: The average price of flights is calculated for each airline and visualized using bar plots.
   - **Price by Booking Distance**: An analysis is performed to examine how the price of a flight varies with the time left before the departure date.
   - **Price by Route and Airline**: The project analyzes the average price of flights for specific routes operated by multiple airlines.

4. **Data Visualization**  
   Visualizations such as heatmaps and bar plots are used to represent the data insights effectively. For example:
   - A heatmap displays the average flight price by departure and arrival cities.
   - A bar plot visualizes the average price of flights by airline.

5. **Supporting Documentation**  
   - A **CSV file** contains the main dataset used in the analysis.
   - A **TXT file** explains the details of each column in the dataset.
   - The data was sourced from [Kaggle's German Airfares dataset](https://www.kaggle.com/datasets).
   - The **documentation.pdf** explains how the SQL code functions and how the data was processed.

