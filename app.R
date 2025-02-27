#Project 2
#Aashish Agrawal - aagraw10
#Ivan Madrid - imadri2
#Richard Miramontes - rmiram2
#CS 424

#load libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(leaflet)

#read in data from csv
rawdata <- read.csv(file = "hurdat2-formatted.txt")

#clear up data a little bit
rawdata$Hurricane <- as.character(rawdata$Hurricane)
rawdata$Name <- as.character(rawdata$Name)
rawdata$Date <- as.character(rawdata$Date)
rawdata$Time <- as.character(rawdata$Time)
rawdata$RecordID <- as.character(rawdata$RecordID)
rawdata$Status <- as.character(rawdata$Status)
rawdata$Lat <- as.character(rawdata$Lat)
rawdata$Long <- as.character(rawdata$Long)

############ivans data frame
newtestdata1stFile <- rawdata

temp1maxwind <- newtestdata1stFile
temp1maxwind$Date <- as.character(temp1maxwind$Date)
temp1maxwind$Date <- as.Date(temp1maxwind[["Date"]], "%Y%m%d")
temp1maxwind$Year <- as.numeric(format(temp1maxwind$Date,'%Y'))
temp1maxwind$Month <- as.numeric(format(temp1maxwind$Date,'%m'))
temp1maxwind$Day <- as.numeric(format(temp1maxwind$Date,'%d'))

tempPress1 <- rawdata
tempPress1$Date <- as.character(tempPress1$Date)
tempPress1$Date <- as.Date(tempPress1[["Date"]], "%Y%m%d")
tempPress1$AYear <- as.numeric(format(tempPress1$Date,'%Y'))
tempPress1$AMonth <- as.numeric(format(tempPress1$Date,'%m'))
tempPress1$ADay <- as.numeric(format(tempPress1$Date,'%d'))
tempPress1 <- tempPress1[tempPress1$MinPress!=-999, ]

#replace lat strings with 'N' or 'S' to proper numeric
rawdata$Lat <- sapply(rawdata$Lat, function(x) {
  if(substr(x,nchar(x),nchar(x))[1] == 'N') {
    as.numeric(substr(x,0,nchar(x)-1))
  }
  else {
    - as.numeric(substr(x,0,nchar(x)-1))
  }
})

#replace long strings with 'E' or 'W' to proper numeric
rawdata$Long <- sapply(rawdata$Long, function(x) {
  if(substr(x,nchar(x),nchar(x))[1] == 'E') {
    as.numeric(substr(x,0,nchar(x)-1))
  }
  else {
    - as.numeric(substr(x,0,nchar(x)-1))
  }
})


#get the year of the hurricane from the start string
rawdata$Year = lapply(rawdata$Hurricane, function(x){
  as.integer(substr(x,nchar(x)-3,nchar(x)))
})

#trim the whitespaces from the name
rawdata$Name <- lapply(rawdata$Name, trimws)

#make unnamed hurricanes display their year and number
rawdata$Name <- 
  paste(rawdata$Name,
        " (", 
        rawdata$Hurricane, 
        ")"
  )

#make hurricanes with only one zero have four instead(formatting reasons)
rawdata$Time[which(rawdata$Time == "0")]<- "0000"

#Convert the date column to correct format
rawdata$Date <- as.Date(rawdata$Date, format = "%Y%m%d")

#get the Minute the cyclone occurred
rawdata$Minute <- lapply(rawdata$Time, function(x){
  as.integer(substr(x,nchar(x)-1,nchar(x)))
})

#get the Hour the cyclone occurred
rawdata$Hour <- lapply(rawdata$Time, function(x){
  as.integer(substr(x,nchar(x)-3,nchar(x)-2))
})

#Convert the date column and times to datetime format
rawdata$DateandTimes <- as.POSIXct(paste(rawdata$Date, rawdata$Hour, rawdata$Minute), format = "%Y-%m-%d %H%M", tz="GMT")

#clear up data a bit
rawdata$DateandTimes <- as.character(rawdata$DateandTimes)

#add landfall info
landfalls = rawdata$Hurricane[rawdata$RecordID == " L"]
rawdata$Landfall <- lapply(rawdata$Hurricane, function(x) {
  if (x %in% landfalls) {
    TRUE
  }
  else {
    FALSE
  }
})

#get top 10 list
temp <- rawdata[rev(order(rawdata$MaxWind)),]
temp <- head(temp[!duplicated(temp["Hurricane"]),],10)
rownames(temp) <- c()
top10 <- rawdata[which(rawdata$Name %in% temp$Name),]
top10 <- top10[rev(order(top10$MaxWind)),]

#names of hurricanes that have year >= 2005
names <- unique(rawdata[rawdata$Year >= 2005,]$Name)
names <- sapply(names, function(x){x})

#years >= 2005 in dataset
years <- unique(rawdata$Year)
years <- years[years >= 2005]

rawdata$factors <- as.factor(rawdata$Hurricane)

########### SECOND FILE ##############
#read in second file
rawdata2ndFile <- read.csv(file = "hurdat2Pacific-formatted.txt")

#cleanup
rawdata2ndFile$Hurricane <- as.character(rawdata2ndFile$Hurricane)
rawdata2ndFile$Name <- as.character(rawdata2ndFile$Name)
rawdata2ndFile$RecordID <- as.character(rawdata2ndFile$RecordID)
rawdata2ndFile$Status <- as.character(rawdata2ndFile$Status)
rawdata2ndFile$Lat <- as.character(rawdata2ndFile$Lat)
rawdata2ndFile$Long <- as.character(rawdata2ndFile$Long)

rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP012006"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP012008"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP022009"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP012010"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP012013"),]     
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP032013"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "EP072014"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP012015"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP032015"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "CP092015"),]
rawdata2ndFile <- rawdata2ndFile[which(rawdata2ndFile$Hurricane != "EP102018"),]

#Ivans data Frame
newtestdata2ndFile <- rawdata2ndFile
temp2maxwind <- newtestdata2ndFile
temp2maxwind$Date <- as.character(temp2maxwind$Date)
temp2maxwind$Date <- as.Date(temp2maxwind[["Date"]], "%Y%m%d")
temp2maxwind$Year <- as.numeric(format(temp2maxwind$Date,'%Y'))
temp2maxwind$Month <- as.numeric(format(temp2maxwind$Date,'%m'))
temp2maxwind$Day <- as.numeric(format(temp2maxwind$Date,'%d'))

tempPress2 <- rawdata2ndFile
tempPress2$Date <- as.character(tempPress2$Date)
tempPress2$Date <- as.Date(tempPress2[["Date"]], "%Y%m%d")
tempPress2$AYear <- as.numeric(format(tempPress2$Date,'%Y'))
tempPress2$AMonth <- as.numeric(format(tempPress2$Date,'%m'))
tempPress2$ADay <- as.numeric(format(tempPress2$Date,'%d'))
tempPress2 <- tempPress2[tempPress2$MinPress!=-999, ]

#replace lat strings with 'N' or 'S' to proper numeric
rawdata2ndFile$Lat <- sapply(rawdata2ndFile$Lat, function(x) {
  if(substr(x,nchar(x),nchar(x))[1] == 'N') {
    as.numeric(substr(x,0,nchar(x)-1))
  }
  else {
    - as.numeric(substr(x,0,nchar(x)-1))
  }
})

#replace long strings with 'E' or 'W' to proper numeric
rawdata2ndFile$Long <- sapply(rawdata2ndFile$Long, function(x) {
  if(substr(x,nchar(x),nchar(x))[1] == 'E') {
    as.numeric(substr(x,0,nchar(x)-1))
  }
  else {
    - as.numeric(substr(x,0,nchar(x)-1))
  }
})

#get the year of the hurricane from the start string
rawdata2ndFile$Year = lapply(rawdata2ndFile$Hurricane, function(x){
  as.integer(substr(x,nchar(x)-3,nchar(x)))
})

#trim the whitespaces from the name
rawdata2ndFile$Name <- lapply(rawdata2ndFile$Name, trimws)

#make unnamed hurricanes display their year and number
rawdata2ndFile$Name <- 
  paste(rawdata2ndFile$Name,
        " (", 
        rawdata2ndFile$Hurricane, 
        ")"
  )

#get the cyclone number of the hurricane from the start string
rawdata2ndFile$CycNum <- lapply(rawdata2ndFile$Hurricane, function(x){
  as.integer(substr(x,nchar(x)-5,nchar(x)-4))
})

#make unnamed hurricanes display their year and number
rawdata2ndFile$Name[which(rawdata2ndFile$Name == "UNNAMED")] <- 
  paste("UNNAMED (", 
        rawdata2ndFile$Hurricane[which(rawdata2ndFile$Name == "UNNAMED")], 
        ")"
  )

#get the day the cyclone occurred
rawdata2ndFile$Day <- lapply(rawdata2ndFile$Date, function(x){
  as.integer(substr(x,nchar(x)-1,nchar(x)))
})

#get the month the cyclone occurred
rawdata2ndFile$Month <- lapply(rawdata2ndFile$Date, function(x){
  as.integer(substr(x,nchar(x)-3,nchar(x)-2))
})

#get the Minute the cyclone occurred
rawdata2ndFile$Minute <- lapply(rawdata2ndFile$Time, function(x){
  as.integer(substr(x,nchar(x)-1,nchar(x)))
})

#get the Hour the cyclone occurred
rawdata2ndFile$Hour <- lapply(rawdata2ndFile$Time, function(x){
  as.integer(substr(x,nchar(x)-3,nchar(x)-2))
})

#Convert the date column and times to datetime format
rawdata2ndFile$DateandTimes <- as.POSIXct(paste(rawdata2ndFile$Date, rawdata2ndFile$Hour, rawdata2ndFile$Minute), format = "%Y-%m-%d %H%M", tz="GMT")

#clear up data a bit
rawdata2ndFile$DateandTimes <- as.character(rawdata2ndFile$DateandTimes)

rawdata2ndFile$factors <- as.factor(rawdata2ndFile$Hurricane)

#add landfall info
landfalls2 = rawdata2ndFile$Hurricane[rawdata2ndFile$RecordID == " L"]
rawdata2ndFile$Landfall <- lapply(rawdata2ndFile$Hurricane, function(x) {
  if (x %in% landfalls2) {
    TRUE
  }
  else {
    FALSE
  }
})

######################################

ui <- dashboardPage(
  dashboardHeader(title = "CS 424 Project 2"),
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Dashboard", tabName ="dashboard", icon = icon("dashboard")),
      menuItem("Page Info",tabName = "til", startExpanded = F, textOutput("il"), textOutput("il2"),textOutput("il3"), textOutput("il4")),
      menuItem("Infromation on file format",tabName = "lit",startExpanded = F, textOutput("li"))
      
      
    )
  ),
  dashboardBody(
    fluidRow(
      #Atlantic Map
      box(
        width = 6, 
        title = "Atlantic Hurricane Map", 
        selectInput(
          "pickFilter", 
          "Select How to Filter Hurricanes (since 2005): ", 
          choices = c("Current Season", "All", "Year", "Individual", "Top 10", "Max Wind Speed", "Minimum Pressure", "Day")
        ),
        checkboxInput(
          "filterByLandfall",
          "Filter by Landfall?",
          value = FALSE
        ),
        checkboxInput(
          "madeLandfall",
          "Made Landfall?",
          value = FALSE
        ),
        uiOutput("picker"),
        leafletOutput("atlanticMap")
      ),
      #Pacific Map
      box(
        width = 6, 
        title = "Pacific Hurricane Map", 
        selectInput(
          "pickFilter2", 
          "Select How to Filter Hurricanes (since 2005): ", 
          choices = c("Current Season", "All", "Year", "Individual", "Top 10", "Max Wind Speed", "Minimum Pressure")
        ),
        checkboxInput(
          "filterByLandfall2",
          "Filter by Landfall?",
          value = FALSE
        ),
        checkboxInput(
          "madeLandfall2",
          "Made Landfall?",
          value = FALSE
        ),
        uiOutput("picker2"),
        leafletOutput("pacificMap"),)
    ),
    fluidRow(
      #Atlantic
      box(width = 6, title = "Atlantic Hurricane List", selectInput("orderFilter", "Select how to Order the Hurricane List: ", choices = c("Chronologically", "Alphabetically", "Max Wind Speed", "Minimum Pressure")),DT::dataTableOutput("orderHurricane") ),
      #Pacific
      box(width = 6, title = "Pacific Hurricane List", selectInput("orderFilter2", "Select how to Order the Hurricane List: ", choices = c("Chronologically", "Alphabetically", "Max Wind Speed", "Minimum Pressure")),DT::dataTableOutput("orderHurricane2") )
    ),
    fluidRow(
      box(width = 12,
          mainPanel(width = 6, 
                    tabsetPanel(
                      tabPanel("(Alt)Hurricane by Year(2005-2018)",      
                               ##Atlantic year chart
                               box( width = 12,title = "Hurricane by Year", status = "primary", solidHeader = TRUE, plotOutput("hurricanesYearlyHistogram", height = 360)   
                               )
                      ),
                      tabPanel("(Alt)Hurricane by Status(2005-2018)",
                               ##Atlantic Status chart
                               box( width = 12,title = "Hurricane by Status", status = "primary", solidHeader = TRUE, plotOutput("hurricanesByStatusHistogram", height = 360)   
                               )
                      )
                    )
          ),
          mainPanel(width = 6, 
                    tabsetPanel(
                      tabPanel("(Pt)Hurricane by Year(2005-2018)",      
                               ##APacific year chart
                               box( width = 12,title = "Hurricane by Year", status = "primary", solidHeader = TRUE, plotOutput("hurricanesYearlyHistogramPacific", height = 360)   
                               )
                      ),
                      tabPanel("(Pt)Hurricane by Status(2005-2018)",
                               ##Pacific Status chart
                               box( width = 12,title = "Hurricane by Status", status = "primary", solidHeader = TRUE, plotOutput("hurricanesByStatusHistogramPacific", height = 360)   
                               )
                      )
                    )
          )
      )
    ),
    fluidRow(box(width = 4, title= "Atlantic Max windSpeeds", selectInput("AtlanticPick", "Select Year",choices = c(unique(temp1maxwind$Year))),plotOutput("AtlanticPlot") ),
             box(width = 4, title = "Atlantic and Pacific Max WindSpeed",plotOutput("AtlPacPlot")),
             box(width = 4, title= "Pacific Max windSpeeds", selectInput("PacificPick", "Select Year",choices = c(unique(temp2maxwind$Year))),plotOutput("PacificPlot"))
             ),
    fluidRow(box(width = 4, title= "Atlantic MinPressure", selectInput("AtlanticPressurePick", "Select Year",choices = c(unique(tempPress1$AYear))),plotOutput("AtlanticPressurePlot") ),
             box(width = 4, title = "Atlantic and Pacific MinPressure",plotOutput("AtlPacPressurePlot")),
             box(width = 4, title= "Pacific MinPressure", selectInput("PacificPressurePick", "Select Year",choices = c(unique(tempPress2$AYear))),plotOutput("PacificPressurePlot"))
    )
  )
)

server <- function(input, output) {
  
  #If User selected a certain option do something to Atlantic map
  output$picker <- renderUI({
    if(input$pickFilter == "Year") {
      selectInput("userFilter", "Select Year", choices = years)
    }
    else if(input$pickFilter == "Individual") {
      selectInput("userFilter", "Select Hurricane", choices = names)
    }
    else if(input$pickFilter == "Day") {
      dateInput("userFilter", "Date: ", value = "2002-09-10", format = "mm/dd/yy")
    }
    else {
      
    }
  })
  
  #If user selected a certain option do something to Pacific Map
  output$picker2 <- renderUI({
    if(input$pickFilter2 == "Year") {
      selectInput("userFilter2", "Select Year", choices = years)
    }
    else if(input$pickFilter2 == "Individual") {
      selectInput("userFilter2", "Select Hurricane", choices = names)
    }
    else {
      
    }
  })
  
  #For the antlantic map
  rawdataFiltered <- reactive({
    rawdataTemp <- rawdata
    if(input$filterByLandfall == TRUE) {
      if(input$madeLandfall == FALSE) {
        rawdataTemp <- rawdataTemp[which(rawdataTemp$Landfall == FALSE),]
      }
      else {
        rawdataTemp <- rawdataTemp[which(rawdataTemp$Landfall == TRUE),]
      }
    }
    if(input$pickFilter == "Current Season") {
      rawdataFiltered <- rawdataTemp[rawdataTemp$Year == 2018,]
    }
    else if(input$pickFilter == "All") {
      rawdataFiltered <- rawdataTemp[rawdataTemp$Year >= 2005,]
    }
    else if(input$pickFilter == "Year") {
      rawdataFiltered <- rawdataTemp[rawdataTemp$Year == input$userFilter,]
    }
    else if(input$pickFilter == "Individual") {
      rawdataFiltered <- rawdataTemp[rawdataTemp$Name == input$userFilter,]
    }
    else if(input$pickFilter == "Top 10") {
      rawdataFiltered <- top10
    }
    else if (input$pickFilter == "Day"){
      days = rawdataTemp$Hurricane[rawdataTemp$Date == input$userFilter]
      rawdataTemp$isDay <- lapply(rawdataTemp$Hurricane, function(x) {
        if (x %in% days) {
          TRUE
        }
        else {
          FALSE
        }
      })
      rawdataFiltered <- rawdataTemp[which(rawdataTemp$isDay == TRUE),]
    }
    else if(input$pickFilter == "Max Wind Speed"){
      mWindSpeed <- as.data.frame(lapply(rawdata, unlist))
      attach(mWindSpeed)
      mWindSpeed <- mWindSpeed[order(-MaxWind),]
      detach(mWindSpeed)
      comparison <- head(mWindSpeed, 1)
      mWindSpeed <- mWindSpeed[mWindSpeed$Hurricane == comparison$Hurricane,]
      rawdataFiltered <- mWindSpeed
    }
    else if(input$pickFilter == "Minimum Pressure"){
      rawdata <- rawdata[rawdata$MinPress > 0,]
      mPressure <- as.data.frame(lapply(rawdata, unlist))
      attach(mPressure)
      mPressure <- mPressure[order(MinPress),]
      detach(mPressure)
      comparison <- head(mPressure, 1)
      mPressure <- mPressure[mPressure$Hurricane == comparison$Hurricane,]
      rawdataFiltered <- mPressure
    }
    rawdataFiltered
  })  
  
  #For the Pacific Map
  rawdataFiltered2 <- reactive({
    rawdataTemp <- rawdata2ndFile
    if(input$filterByLandfall2 == TRUE) {
      if(input$madeLandfall2 == FALSE) {
        rawdataTemp <- rawdataTemp[which(rawdataTemp$Landfall == FALSE),]
      }
      else {
        rawdataTemp <- rawdataTemp[which(rawdataTemp$Landfall == TRUE),]
      }
    }
    if(input$pickFilter2 == "Current Season") {
      rawdataFiltered2 <- rawdataTemp[rawdataTemp$Year == 2018,]
    }
    else if(input$pickFilter2 == "All") {
      rawdataFiltered2 <- rawdataTemp[rawdataTemp$Year >= 2005,]
    }
    else if(input$pickFilter2 == "Year") {
      rawdataFiltered2 <- rawdataTemp[rawdataTemp$Year == input$userFilter2,]
    }
    else if(input$pickFilter2 == "Individual") {
      rawdataFiltered2 <- rawdataTemp[rawdataTemp$Name == input$userFilter2,]
    }
    else if(input$pickFilter2 == "Top 10") {
      rawdataFiltered2 <- top10
    }
    else if(input$pickFilter2 == "Max Wind Speed"){
      mWindSpeed <- as.data.frame(lapply(rawdataTemp, unlist))
      attach(mWindSpeed)
      mWindSpeed <- mWindSpeed[order(-MaxWind),]
      detach(mWindSpeed)
      comparison <- head(mWindSpeed, 1)
      mWindSpeed <- mWindSpeed[mWindSpeed$Hurricane == comparison$Hurricane,]
      rawdataFiltered2 <- mWindSpeed
    }
    else if(input$pickFilter2 == "Minimum Pressure"){
      rawdataTemp <- rawdataTemp[rawdataTemp$MinPress > 0,]
      mPressure <- as.data.frame(lapply(rawdataTemp, unlist))
      attach(mPressure)
      mPressure <- mPressure[order(MinPress),]
      detach(mPressure)
      comparison <- head(mPressure, 1)
      mPressure <- mPressure[mPressure$Hurricane == comparison$Hurricane,]
      rawdataFiltered2 <- mPressure
    }
    rawdataFiltered2
  })  
  
  #Map for the atlantic data
  output$atlanticMap <- renderLeaflet({
    map <- leaflet()
    map <- addTiles(map)
    pal <- colorFactor(topo.colors(length(unique(rawdata$Hurricane))), rawdata$factors)
    map <- addCircleMarkers(map = map, data = rawdataFiltered(), group = ~Name, lat = ~Lat, lng = ~Long, color = ~pal(factors), radius = ~2*log(MaxWind))
    for(factor in levels(rawdataFiltered()$factors)) {
      map <- addPolylines(map, data=rawdataFiltered()[rawdataFiltered()$factors==factor,], lat=~Lat, lng=~Long, color = ~pal(factors), weight = ~2*log(MaxWind), group = ~Name)
    }
    map <- addLayersControl(map = map, overlayGroups = rawdataFiltered()$Name)
    map
  })
  
  #Map for the pacific data
  output$pacificMap <- renderLeaflet({
    map <- leaflet()
    map <- addTiles(map)
    pal <- colorFactor(topo.colors(length(unique(rawdata2ndFile$Hurricane))), rawdata2ndFile$factors)
    map <- addCircleMarkers(map = map, data = rawdataFiltered2(), group = ~Name, lat = ~Lat, lng = ~Long, color = ~pal(factors), radius = ~2*log(MaxWind))
    for(factor in levels(rawdataFiltered2()$factors)) {
      map <- addPolylines(map, data=rawdataFiltered2()[rawdataFiltered2()$factors==factor,], lat=~Lat, lng=~Long, color = ~pal(factors), weight = ~2*log(MaxWind), group = ~Name)
    }
    map <- addLayersControl(map = map, overlayGroups = rawdataFiltered2()$Name)
    map
  })
  
#for the first file
  orderdataFiltered <- reactive({
    if(input$orderFilter == "Chronologically"){
      chronological <- as.data.frame(lapply(rawdata, unlist))
      attach(chronological)
      chronological <- chronological[order(DateandTimes),]
      detach(chronological)
      chronological <- subset(chronological, select = c(Hurricane, Name, DateandTimes))
      orderdataFiltered <- chronological
    }
    else if(input$orderFilter == "Alphabetically"){
      alphabetic <- as.data.frame(lapply(rawdata, unlist))
      attach(alphabetic)
      alphabetic <- alphabetic[order(Name),]
      detach(alphabetic)
      alphabetic <- subset(alphabetic, select = c(Hurricane, Name, DateandTimes))
      alphabetic <- alphabetic[!duplicated(alphabetic$Hurricane),]
      orderdataFiltered <- alphabetic
    }
    else if(input$orderFilter == "Max Wind Speed"){
      mWindSpeed <- as.data.frame(lapply(rawdata, unlist))
      attach(mWindSpeed)
      mWindSpeed <- mWindSpeed[order(-MaxWind),]
      detach(mWindSpeed)
      mWindSpeed <- subset(mWindSpeed, select = c(Hurricane, Name, MaxWind))
      mWindSpeed <- mWindSpeed[!duplicated(mWindSpeed$Hurricane),]
      orderdataFiltered <- mWindSpeed
    }
    else if(input$orderFilter == "Minimum Pressure"){
      rawdata <- rawdata[rawdata$MinPress > 0,]
      mPressure <- as.data.frame(lapply(rawdata, unlist))
      attach(mPressure)
      mPressure <- mPressure[order(MinPress),]
      detach(mPressure)
      mPressure <- subset(mPressure, select = c(Hurricane, Name, MinPress))
      mPressure <- mPressure[!duplicated(mPressure$Hurricane),]
      orderdataFiltered <- mPressure
    }
    orderdataFiltered
  })
  
#for the second file
  orderdataFiltered2 <- reactive({
    if(input$orderFilter2 == "Chronologically"){
      chronological <- as.data.frame(lapply(rawdata2ndFile, unlist))
      attach(chronological)
      chronological <- chronological[order(DateandTimes),]
      detach(chronological)
      chronological <- subset(chronological, select = c(Hurricane, Name, DateandTimes))
      orderdataFiltered2 <- chronological
    }
    else if(input$orderFilter2 == "Alphabetically"){
      alphabetic <- as.data.frame(lapply(rawdata2ndFile, unlist))
      attach(alphabetic)
      alphabetic <- alphabetic[order(Name),]
      detach(alphabetic)
      alphabetic <- subset(alphabetic, select = c(Hurricane, Name, DateandTimes))
      alphabetic <- alphabetic[!duplicated(alphabetic$Hurricane),]
      orderdataFiltered2 <- alphabetic
    }
    else if(input$orderFilter2 == "Max Wind Speed"){
      mWindSpeed <- as.data.frame(lapply(rawdata2ndFile, unlist))
      attach(mWindSpeed)
      mWindSpeed <- mWindSpeed[order(-MaxWind),]
      detach(mWindSpeed)
      mWindSpeed <- subset(mWindSpeed, select = c(Hurricane, Name, MaxWind))
      mWindSpeed <- mWindSpeed[!duplicated(mWindSpeed$Hurricane),]
      orderdataFiltered2 <- mWindSpeed
    }
    else if(input$orderFilter2 == "Minimum Pressure"){
      rawdata2ndFile <- rawdata2ndFile[rawdata2ndFile$MinPress > 0,]
      mPressure <- as.data.frame(lapply(rawdata2ndFile, unlist))
      attach(mPressure)
      mPressure <- mPressure[order(MinPress),]
      detach(mPressure)
      mPressure <- subset(mPressure, select = c(Hurricane, Name, MinPress))
      mPressure <- mPressure[!duplicated(mPressure$Hurricane),]
      orderdataFiltered2 <- mPressure
    }
    orderdataFiltered2
  })
  
  
  output$orderHurricane <- DT::renderDataTable({
    as.data.frame(orderdataFiltered())
  })
  
  output$orderHurricane2 <- DT::renderDataTable({
    as.data.frame(orderdataFiltered2())
  })
  
  output$hurricanesYearlyHistogram <- renderPlot({
    ## graph for total hurricanes in a year##
    ##get rid of duplicates and greater than year:2005
    temp <- rawdata[rev(order(rawdata$MaxWind)),]
    temp <- temp[!duplicated(temp["Hurricane"]),]
    temp <- temp[temp$Year >= 2005,]
    year <- as.integer(temp$Year)
    years<- factor(year)
    p <- ggplot(temp) + aes(x = years) + geom_bar(color = "black", fill="blue") + theme_dark()
    p
  })
  
  output$hurricanesByStatusHistogram <- renderPlot({
    ## graph for total hurricanes in a specific Status##
    ##get rid of duplicates and greater than year:2005##
    temp <- rawdata[rev(order(rawdata$MaxWind)),]
    temp <- temp[!duplicated(temp["Hurricane"]),]
    temp <- temp[temp$Year >= 2005,]
    q <- ggplot(temp) + aes(x = Status) + geom_bar(color = "black", fill="blue")  + theme_dark()
    q
  })
  
  output$hurricanesYearlyHistogramPacific <- renderPlot({
    ## graph for total hurricanes in a year##
    ##get rid of duplicates and greater than year:2005
    temp2 <- rawdata2ndFile[rev(order(rawdata2ndFile$MaxWind)),]
    temp2 <- temp2[!duplicated(temp2["Hurricane"]),]
    temp2 <- temp2[temp2$Year >= 2005,]
    year2 <- as.integer(temp2$Year)
    years2<- factor(year2)
    p <- ggplot(temp2) + aes(x = years2) + geom_bar(color = "black", fill="maroon") + theme_dark()
    p
  })
  
  output$hurricanesByStatusHistogramPacific <- renderPlot({
    ## graph for total hurricanes in a specific Status##
    temp2 <- rawdata2ndFile[rev(order(rawdata2ndFile$MaxWind)),]
    temp2 <- temp2[!duplicated(temp2["Hurricane"]),]
    temp2 <- temp2[temp2$Year >= 2005,]
    q <- ggplot(temp2) + aes(x = Status) + geom_bar(color = "black", fill="maroon")  + theme_dark()
    q
  })
  
  pickAtl <- reactive({
    temp1maxwind <- temp1maxwind[temp1maxwind$Year == input$AtlanticPick,]
    temp1maxwind
  })
  
  output$AtlanticPlot <- renderPlot({
    r1 <- aggregate(pickAtl()$MaxWind~pickAtl()$Date,pickAtl(), max)
    colnames(r1) <- c('date', 'wind')
    r1$wind <- as.integer(r1$wind)
    windplot1 <- ggplot(r1, aes(x= date, y= wind))  + geom_point() + geom_line(color='blue') + scale_x_date(date_labels = " %b %d") + theme(axis.text.x = element_text(angle = 0)) 
    windplot1
  })
  
  pickPac <- reactive({
    temp2maxwind <- temp2maxwind[temp2maxwind$Year == input$PacificPick,]
    temp2maxwind
  })
  
  output$PacificPlot <- renderPlot({
    r <- aggregate(pickPac()$MaxWind~pickPac()$Date,pickPac(), max)
    colnames(r) <- c('date', 'wind')
    r$wind <- as.integer(r$wind)
    windplot <- ggplot(r, aes(x= date, y= wind))  + geom_point() + geom_line(color='red') + scale_x_date(date_labels = " %b %d") + theme(axis.text.x = element_text(angle = 0)) 
    windplot
  })
  
  output$AtlPacPlot <- renderPlot({
    r <- aggregate(pickPac()$MaxWind~pickPac()$Date,pickPac(), max)
    colnames(r) <- c('date', 'wind')
    r$wind <- as.integer(r$wind)
    
    r1 <- aggregate(pickAtl()$MaxWind~pickAtl()$Date,pickAtl(), max)
    colnames(r1) <- c('date', 'wind')
    r1$wind <- as.integer(r1$wind)
    
    
    both <- ggplot() + 
      geom_line(data=r, aes(x=date, y=wind), color='red') + 
      geom_line(data=r1, aes(x=date, y=wind), color='blue') + 
      geom_point() + 
      scale_x_date(date_labels = " %b %d") + 
      theme(axis.text.x = element_text(angle = 0))
    both 
  })
  #next are for Pressure line plots
  pickAtlPress <- reactive({
    tempPress1 <- tempPress1[tempPress1$AYear == input$AtlanticPressurePick,]
    tempPress1
  })
  
  output$AtlanticPressurePlot <- renderPlot({
    p1 <- aggregate(pickAtlPress()$MinPress~pickAtlPress()$Date,pickAtlPress(), min)
    colnames(p1) <- c('date', 'pressure')
    p1$pressure <- as.integer(p1$pressure)
    pressureplot1 <- ggplot(p1, aes(x= date, y= pressure))  + geom_point() + geom_line(color='blue') + scale_x_date(date_labels = " %b %d") + theme(axis.text.x = element_text(angle = 0)) 
    pressureplot1
  })
  
  pickPacPress <- reactive({
    tempPress2 <- tempPress2[tempPress2$AYear == input$PacificPressurePick,]
    tempPress2
  })
  
  output$PacificPressurePlot <- renderPlot({
    p2 <- aggregate(pickPacPress()$MinPress~pickPacPress()$Date,pickPacPress(), min)
    colnames(p2) <- c('date', 'pressure')
    p2$pressure <- as.integer(p2$pressure)
    pressureplot2 <- ggplot(p2, aes(x= date, y= pressure))  + geom_point() + geom_line(color='red') + scale_x_date(date_labels = " %b %d") + theme(axis.text.x = element_text(angle = 0)) 
    pressureplot2
  })
  
  output$AtlPacPressurePlot <- renderPlot({
    p2 <- aggregate(pickPacPress()$MinPress~pickPacPress()$Date,pickPacPress(), min)
    colnames(p2) <- c('date', 'pressure')
    p2$pressure <- as.integer(p2$pressure)
    
    p1 <- aggregate(pickAtlPress()$MinPress~pickAtlPress()$Date,pickAtlPress(), min)
    colnames(p1) <- c('date', 'pressure')
    p1$pressure <- as.integer(p1$pressure)
    
    
    both <- ggplot() + 
      geom_line(data=p2, aes(x=date, y=pressure), color='red') + 
      geom_line(data=p1, aes(x=date, y=pressure), color='blue') + 
      geom_point() + 
      scale_x_date(date_labels = " %b %d") + 
      theme(axis.text.x = element_text(angle = 0))
    both 
    
    
  })
  output$li <- renderText({
    #total litter text
    text2 <- as.character("www.aoml.noaa.gov/hrd/hurdat/hurdat2-format-may2015.pdf")
    text2
  })
  output$il <- renderText({
    ##about this project
    text1 <- as.character("Coded By: Ivan M., Richard M., Aashish A.")
    text1
  })
  output$il2 <- renderText({
    ##about this project
    text3 <- as.character("Libraries: shiny,shinydashboard,leaflet,ggplot2")
    text3
  })
  output$il3 <- renderText({
    ##about this project
    text3 <- as.character("Data_Source:")
    text3
  })
  output$il4 <- renderText({
    ##about this project
    text3 <- as.character("http://www.nhc.noaa.gov/data/#hurdat")
    text3
  })
}

shinyApp(ui = ui, server = server)