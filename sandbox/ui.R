library(shiny)
library(DT)

fluidPage(
	titlePanel("UC Berkley Admissions"),
	
	mainPanel(
		tabsetPanel(
			id = 'dataset',
			tabPanel("Sample Bank", 
					 
					 DT::dataTableOutput("banking.df_data"),
					 br(),
					 actionButton("viewBtn","View"),
					 br(),
					 actionButton("saveBtn","Save"),
					 br(),
					 DT::dataTableOutput("updated.df")
			))))