# Shiny 
Shiny is an R package that allows users to build interactive web applications directly from R without needing HTML, CSS, or JavaScript. It is widely used for data visualization, dashboards, and web-based interactive reports

A Shiny app has two main components:

1️⃣ **ui (User Interface)**: Defines how the app looks (layout, input widgets, output areas).

2️⃣ **server (Backend Logic)**: Defines how inputs affect outputs (reactive calculations, plots, etc.).
```r
install.packages("shiny")
library(shiny)
ui <- ...

server <- ...

shinyApp(ui = ui, server = server)
```
# Shiny Application

Low carbohydrate ketogenic diet (LCKD) is used to treat epilepsy and obesity. Okuda (2019) collected transcriptomic samples from the livers and brains of regular-fed (chow diet) mice and LCKD-fed mice. The data is available in GEO (Gene Expression Omnibus) with the ID of GSE115342. There are four categories in the dataset, and three replicate samples in each category, making the total number of samples in the dataset 12. The categories are, chow-diet cortex, chow-diet liver, LCKD cortex, and LCKD liver.

**Okuda, T. (2019). A low-carbohydrate ketogenic diet promotes ganglioside synthesis via the transcriptional regulation of ganglioside metabolism-related genes. Scientific reports, 9(1), 7627.**

Used the transcriptome dataset from Okuda (2019). Process the data retrieved from GEO such that you calculate the averages of replicate samples for each category. Since there are four categories in the dataset (brain regular diet, liver regular diet, brain LCKD, liver LCKD), you will have a dataframe with four numeric columns (and a column providing gene symbols). Save this dataframe with the name diet.RData (Our test of your code will assume that you saved it with this name). Your Shiny app will load this data to run (there is no need to include codes in your Shiny app for the creation of the dataframe). In this homework, you will develop a Shiny web application with three tabs.


**(1)** In the first tab, the user will choose “brain” or “liver” options through a radio button, and a scatter plot will be plotted between regular-diet and LCKD expressions for that tissue. For each gene, calculate their average expression across the four categories, and include in your plot only n genes with the highest average expression. n will also be an input, with default value being 100. 

**(2)** This tab will provide the expression data for the selected genes in (1) (with the input n) as a data table. i.e. if n is 100, a table with 100 rows and four columns will be shown. 

**(3)** A drop-down menu type input will provide options for the users to choose one of the four categories in the dataset. For the selected category, another tab will tell users that “five genes with the highest expression in the selected category are: …” (the gene symbols for the five genes will be provided). Also, the same tab will provide a boxplot of the expression values of all the genes in that category.

