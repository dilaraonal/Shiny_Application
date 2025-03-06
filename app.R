library(shiny)
library(ggplot2)

load("diet.RData") # The prepared diet.Rdata file has been uploaded
#diet.RData contains gene symbols of all genes and expression levels information according to diet categories.
diet$average_exprs <- rowMeans(diet[,-1]) # For each gene, average expression across four categories was calculated

ui <- fluidPage( #controls the layout and  appearance 
  titlePanel("Shiny App"), #title of panel
  sidebarLayout(
    mainPanel(
      tabsetPanel( # for first tab create tabset panel. 
        tabPanel("Q1: Scatter plot", #title of tab 
                 sidebarLayout( 
                   sidebarPanel( # input informations
                     radioButtons("tissue", "Select Tissue:", choices = c("Brain", "Liver")), #create radio button for select tissue
                     #select n genes for create scatter plots with genes that have highest expression levels
                     numericInput("n_genes", "Number of genes to include:", value = 100, min = 1, max = nrow(diet), step = 1)  #default value is 100 and user can change this value
                   ),
                   mainPanel( #output informations
                     plotOutput("scatterPlot"), # for output is plot use plotOutput function
                     h4("Explanation:"), # added explanation for each tab 
                     p("Here, you can select the tissue you want (brain or liver) via the radio button and observe the graph of the diet program being studied in the tissue you selected. 
                       The scatter plot created is prepared by taking the genes with the highest expression levels as reference. You can change the graph with the number of genes you want. 
                       By default, a plot is created for the 100 genes with the highest expression level.")
                   )
                 )
        ),
        tabPanel("Q2: Data Table", # for second tab 
                 sidebarLayout(
                   sidebarPanel(
                     textOutput("selected_n_genes"),
                     width = 1.5 # width of textoutput in sidebarpanel
                   ),
                   mainPanel(
                     dataTableOutput("dataTable"), # for output is table use dataTableOutput function
                     h4("Explanation:"),
                     p("Here, a data table was created using the number of genes selected to create a scatter plot in tab 1. You can also see the relevant gene symbols in the data table.
                       This data table shows 10 rows by default.
                       If you wish, you can increase the number of rows to be displayed in the upper left part")
                   )
                 )
        ),
        tabPanel("Q3: Boxplots",
                 sidebarLayout(
                   sidebarPanel(
                     selectInput("Category", "Select category:",
                                 choices = c("Brain Regular" = "brain_regular_diet", "Liver Regular" = "liver_regular_diet", "Brain LCKD" = "brain_LCKD", "Liver LCKD" = "liver_LCKD")), # select category and create boxplot
                   ),
                   mainPanel(
                     h4("Genes with Highest Expression"),
                     textOutput("HighestexprsGenes"),
                     plotOutput("boxPlot"), #  for output is boxplot use plotOutput function
                     h4("Explanation:"),
                     p("Here, the desired category (Brain normal, Brain LCKD, Liver normal, Liver LCKD) can be selected by entering the drop-down menu type.
                       Both the expression levels of all genes in the selected category can be examined with a boxplot, and the gene symbols of the 5 genes with the highest expression levels in this category can be examined.")
                   )
                 )
        )
      )
    ),
    sidebarPanel( # On the right side of the web design, there is a descriptive section about what the web application is about
      h4("About this Application"), #information of application for users
      #with p function in shinny we can write paragraph
      p("In this application, analyzes are performed using the transcriptome dataset (Okuda (2019)).
        The dataset includes mRNA levels obtained as a result of regular and LCKD diet programs in brain and liver tissues.
        Thanks to this application, in the first tab, the scatter graph can be examined to understand how the same diet programs are related to different tissues.
        In the second tab, a table containing the gene symbols and expression levels of the genes with the highest expression levels can be observed.
        In the third tab, a plot containing the gene symbols with the highest expression level in the selected category and the expression levels of all genes in that category can be examined."),
      width = 2 # width of descriptive section 
    )
  )
)
#reactive was used because it makes more sense to convert the data frame to matrix once and then call the process when necessary
server <- function(input, output) {
  diet_mat <- reactive({
    as.matrix(diet[, -1]) # Convert data frame to matrix format for when create plots matrices use more easy 
  })
  
  output$scatterPlot <- renderPlot({
    tissue <- input$tissue # input take by user which tissue is selected 
    n <- input$n_genes # n is mean that number of selected genes for display in plot
    
    # if-else function was used to select the correct columns
    if (tissue == "Brain") {
      regular <- "brain_regular_diet"
      LCKD <- "brain_LCKD"
    } else {
      regular <- "liver_regular_diet"
      LCKD <- "liver_LCKD"
    }
    # The reason why the matrix is ordered from largest to smallest is that genes with large expressions are preferred when creating plots
    order_average <- diet_mat()[order(diet_mat()[,"average_exprs"] ,decreasing = TRUE), ][1:n, ]
    
    
    ggplot(order_average, aes_string(x = regular , y = LCKD)) +  #Variable column names can be determined dynamically with the aes_string function
      geom_point(alpha = 0.5, color ="red") + 
      labs(title = paste("Regular vs LCKD Diet:", tissue), #show plot point comes which tissue
           x = "Regular Diet", y = "LCKD Diet") + 
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5)) # for title centered
    
    
  })
  
  output$dataTable <- renderDataTable({
    n <- input$n_genes #selected number of genes from first tab
    
    order_average <- diet[order(diet$average_exprs, decreasing = TRUE), ][1:n, ] # ??n this, diet data used because diet data have gene symbols column 
    # average column is remove and display others columns 
    order_average[,-ncol(diet)]
  } , options = list(pageLength = 10)) #number of display rows of datatable  
  #show selected number of genes and this information from first tab
  output$selected_n_genes <- renderText({
    paste("Number of include genes:", input$n_genes)
  } )
  
  #according to selected category show 5 genes that have highest expression level
  output$HighestexprsGenes <- renderText({
    category <- input$Category
    highest_genes <- diet[order(diet[[category]], decreasing = TRUE), ][1:5, ]
    paste("This genes have highest expression level in the selected category:",
          paste(highest_genes$gene_symbols, collapse = ","))
  })
  
  #create boxplot according to selected category
  output$boxPlot <- renderPlot({
    category <- input$Category
    
    ggplot(diet_mat(), aes_string(x = "category", y = category)) + #write selected ctaegory in x axis
      geom_boxplot(alpha = 0) +
      #geom_jitter function used because prevent of overplotting and this function necessary formation cloud of points
      geom_jitter(alpha = 0.3, 
                  color = "red") +
      labs(title = paste("Expression Levels in", category),
           y = "Expression Level", x = "Genes") +
      ylim(0, max(diet[[category]])) + #used the maximum value of a particular category in the data frame to determine the boundaries of the y-axis
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
  })
}
shinyApp(ui = ui, server = server)