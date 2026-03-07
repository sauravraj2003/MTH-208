library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(DT)
library(scales)

# ── Data ──────────────────────────────────────────────────────────────────────

load("companies.Rdata")
load("new_students.Rdata")
students_ctc    <- as_tibble(read.csv("students_correlated.csv"))
data_companies  <- companies2
data_students   <- students

# ── Palette ───────────────────────────────────────────────────────────────────

COLS <- c("#4f46e5", "#0891b2", "#059669", "#d97706",
          "#dc2626", "#7c3aed", "#db2777", "#0d9488")

# ── CSS ───────────────────────────────────────────────────────────────────────

app_css <- "
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

body, .content-wrapper, .main-sidebar, .sidebar {
  font-family: 'Inter', sans-serif;
}

/* Sidebar */
.main-sidebar {
  background-color: #1e1b4b !important;
}
.sidebar-menu > li > a {
  color: rgba(255,255,255,0.65) !important;
  font-size: 13.5px;
  font-weight: 500;
}
.sidebar-menu > li.active > a,
.sidebar-menu > li > a:hover {
  color: #fff !important;
  background: rgba(255,255,255,0.1) !important;
  border-left: 3px solid #818cf8 !important;
}
.sidebar-menu > li > a .fa {
  color: rgba(255,255,255,0.5);
}
.sidebar-menu > li.active > a .fa {
  color: #a5b4fc;
}
.logo-lg {
  font-family: 'Inter', sans-serif !important;
  font-weight: 700 !important;
  letter-spacing: -0.3px;
}
.skin-blue .main-header .logo {
  background-color: #1e1b4b !important;
  border-bottom: 1px solid rgba(255,255,255,0.08) !important;
}
.skin-blue .main-header .navbar {
  background-color: #ffffff !important;
}
.skin-blue .main-header .navbar .nav > li > a {
  color: #374151 !important;
}

/* Content area */
.content-wrapper {
  background-color: #f8f9fc !important;
}
.content-header > h1 {
  font-size: 20px !important;
  font-weight: 700 !important;
  color: #111827 !important;
}
.content-header > .breadcrumb {
  display: none;
}

/* Box overrides */
.box {
  border-radius: 10px !important;
  border-top: none !important;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04) !important;
  border: 1px solid #e5e7eb !important;
}
.box-header {
  padding: 14px 18px 12px !important;
  border-bottom: 1px solid #f3f4f6 !important;
}
.box-title {
  font-size: 13.5px !important;
  font-weight: 600 !important;
  color: #111827 !important;
}
.box-body {
  padding: 8px !important;
}

/* KPI value boxes */
.small-box {
  border-radius: 10px !important;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08) !important;
}
.small-box h3 {
  font-family: 'Inter', sans-serif !important;
  font-weight: 700 !important;
  font-size: 28px !important;
}
.small-box p {
  font-size: 13px !important;
  font-weight: 500 !important;
}
.small-box .icon {
  font-size: 60px !important;
  top: 10px !important;
}

/* Filter sidebar box */
.filter-box .box-header {
  background: #f9fafb !important;
}
.filter-box label {
  font-size: 11.5px !important;
  font-weight: 600 !important;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: #6b7280 !important;
}

/* Selectize */
.selectize-control .selectize-input {
  font-family: 'Inter', sans-serif !important;
  font-size: 13px !important;
  border-radius: 7px !important;
  border: 1px solid #d1d5db !important;
  box-shadow: none !important;
  padding: 8px 12px !important;
}
.selectize-control .selectize-input:focus-within {
  border-color: #4f46e5 !important;
  box-shadow: 0 0 0 3px rgba(79,70,229,0.1) !important;
}
.selectize-dropdown {
  font-size: 13px !important;
  border-radius: 8px !important;
  border: 1px solid #e5e7eb !important;
  box-shadow: 0 8px 24px rgba(0,0,0,0.08) !important;
}
.selectize-dropdown .option:hover,
.selectize-dropdown .option.active {
  background: #eef2ff !important;
  color: #4f46e5 !important;
}
.selectize-input .item {
  background: #eef2ff !important;
  color: #4f46e5 !important;
  border: 1px solid #c7d2fe !important;
  border-radius: 5px !important;
  font-size: 12px !important;
  font-weight: 600 !important;
}

/* Slider */
.irs--shiny .irs-bar { background: #4f46e5 !important; border: none !important; height: 3px !important; }
.irs--shiny .irs-line { background: #e5e7eb !important; height: 3px !important; }
.irs--shiny .irs-handle {
  background: white !important;
  border: 2px solid #4f46e5 !important;
  box-shadow: 0 1px 6px rgba(79,70,229,0.3) !important;
}
.irs--shiny .irs-single { background: #4f46e5 !important; border-radius: 5px !important; font-size: 11px !important; }
.irs--shiny .irs-from, .irs--shiny .irs-to { background: #4f46e5 !important; border-radius: 5px !important; font-size: 11px !important; }

/* Radio buttons */
.radio label { font-size: 13px !important; font-weight: 400 !important; text-transform: none !important; letter-spacing: 0 !important; color: #374151 !important; }
input[type='radio'] { accent-color: #4f46e5; }

/* Apply button */
.btn-primary {
  background: #4f46e5 !important;
  border: none !important;
  border-radius: 7px !important;
  font-family: 'Inter', sans-serif !important;
  font-size: 13px !important;
  font-weight: 600 !important;
  padding: 8px 20px !important;
  box-shadow: 0 2px 8px rgba(79,70,229,0.25) !important;
  transition: all 0.2s !important;
  width: 100%;
}
.btn-primary:hover {
  background: #4338ca !important;
  box-shadow: 0 4px 14px rgba(79,70,229,0.35) !important;
  transform: translateY(-1px);
}

/* DataTables */
table.dataTable {
  font-family: 'Inter', sans-serif !important;
  font-size: 13px !important;
}
table.dataTable thead th {
  background: #f9fafb !important;
  color: #6b7280 !important;
  font-size: 11px !important;
  font-weight: 700 !important;
  text-transform: uppercase !important;
  letter-spacing: 0.6px !important;
  border-bottom: 1px solid #e5e7eb !important;
  padding: 10px 14px !important;
}
table.dataTable tbody td {
  padding: 10px 14px !important;
  border-bottom: 1px solid #f3f4f6 !important;
  color: #374151 !important;
}
table.dataTable tbody td:first-child { color: #111827 !important; font-weight: 600; }
table.dataTable tbody tr:hover td { background: #f5f3ff !important; }
.dataTables_wrapper { color: #6b7280 !important; font-size: 12px !important; }
.dataTables_filter input, .dataTables_length select {
  border: 1px solid #d1d5db !important;
  border-radius: 6px !important;
  padding: 5px 10px !important;
  font-size: 12px !important;
}
.dataTables_paginate .paginate_button {
  border-radius: 6px !important;
  font-size: 12px !important;
  border: 1px solid #e5e7eb !important;
  margin: 0 2px !important;
}
.dataTables_paginate .paginate_button.current,
.dataTables_paginate .paginate_button:hover {
  background: #4f46e5 !important;
  border-color: #4f46e5 !important;
  color: white !important;
}

::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
"

# ── Plotly theme helper ────────────────────────────────────────────────────────

pt <- function(p) {
  p %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      font   = list(family = "Inter, sans-serif", color = "#6b7280", size = 12),
      xaxis  = list(gridcolor = "#f3f4f6", zerolinecolor = "#e5e7eb",
                    tickfont  = list(color = "#9ca3af", size = 11)),
      yaxis  = list(gridcolor = "#f3f4f6", zerolinecolor = "#e5e7eb",
                    tickfont  = list(color = "#9ca3af", size = 11)),
      legend = list(bgcolor = "rgba(0,0,0,0)", font = list(color = "#6b7280", size = 11)),
      margin = list(l = 50, r = 16, t = 16, b = 44),
      hoverlabel = list(
        bgcolor    = "#1e1b4b",
        bordercolor = "#4f46e5",
        font = list(family = "Inter", color = "white", size = 12)
      )
    ) %>%
    config(displayModeBar = FALSE)
}

# ── UI ────────────────────────────────────────────────────────────────────────

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = tags$span("Y20 Placements")),
  
  dashboardSidebar(
    tags$head(tags$style(HTML(app_css))),
    sidebarMenu(
      id = "sidebar",
      menuItem("Dashboard",       tabName = "dashboard", icon = icon("chart-bar")),
      menuItem("Companies",       tabName = "companies", icon = icon("building")),
      menuItem("Branch Analysis", tabName = "branch",    icon = icon("graduation-cap")),
      menuItem("State Analysis",  tabName = "state",     icon = icon("map"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # ── Dashboard tab ──────────────────────────────────────────────────────
      tabItem(tabName = "dashboard",
              fluidRow(
                valueBoxOutput("kpi_total",    width = 3),
                valueBoxOutput("kpi_placed",   width = 3),
                valueBoxOutput("kpi_avg_ctc",  width = 3),
                valueBoxOutput("kpi_companies",width = 3)
              ),
              fluidRow(
                box(title = "CTC Distribution", width = 8,
                    plotlyOutput("dash_ctc_dist", height = "300px")),
                box(title = "Gender Split", width = 4,
                    plotlyOutput("dash_gender_donut", height = "300px"))
              ),
              fluidRow(
                box(title = "Average CTC by Branch", width = 6,
                    plotlyOutput("dash_branch_bar", height = "300px")),
                box(title = "Placement Rate by Branch", width = 6,
                    plotlyOutput("dash_placement_radar", height = "300px"))
              )
      ),
      
      # ── Companies tab ──────────────────────────────────────────────────────
      tabItem(tabName = "companies",
              fluidRow(
                column(3,
                       box(title = "Filters", width = 12, class = "filter-box",
                           sliderInput("ctc_range", "CTC Range (LPA)",
                                       min   = min(data_companies$ctc),
                                       max   = max(data_companies$ctc),
                                       value = c(min(data_companies$ctc), max(data_companies$ctc)),
                                       step  = 0.5),
                           br(),
                           actionButton("filter_companies", "Apply Filter", class = "btn btn-primary")
                       )
                ),
                column(9,
                       fluidRow(
                         box(title = "Profile Type Breakdown", width = 5,
                             plotlyOutput("comp_profile_pie", height = "250px")),
                         box(title = "Top Companies by CTC", width = 7,
                             plotlyOutput("comp_top_bar", height = "250px"))
                       ),
                       box(title = "Company Directory", width = 12,
                           dataTableOutput("comp_table"))
                )
              )
      ),
      
      # ── Branch tab ─────────────────────────────────────────────────────────
      tabItem(tabName = "branch",
              fluidRow(
                column(3,
                       box(title = "Filters", width = 12, class = "filter-box",
                           selectizeInput("sel_branches", "Select Branches",
                                          choices  = sort(unique(data_students$branch)),
                                          selected = head(sort(unique(data_students$branch)), 3),
                                          multiple = TRUE,
                                          options  = list(placeholder = "Choose branches")),
                           br(),
                           radioButtons("branch_chart", "Chart Type",
                                        choices = c("Scatter" = "scatter", "Box Plot" = "box",
                                                    "Bar Chart" = "bar",   "Bubble"   = "bubble"),
                                        selected = "scatter")
                       )
                ),
                column(9,
                       box(title = "Branch Overview", width = 12,
                           plotlyOutput("branch_main", height = "350px")),
                       fluidRow(
                         box(title = "CTC Violin Plot", width = 6,
                             plotlyOutput("branch_violin", height = "300px")),
                         box(title = "Placement Rate", width = 6,
                             plotlyOutput("branch_donut", height = "300px"))
                       ),
                       box(title = "Branch Summary Table", width = 12,
                           dataTableOutput("branch_table"))
                )
              )
      ),
      
      # ── State tab ──────────────────────────────────────────────────────────
      tabItem(tabName = "state",
              fluidRow(
                column(3,
                       box(title = "Filters", width = 12, class = "filter-box",
                           selectizeInput("sel_states", "Select States",
                                          choices  = c(),
                                          selected = c(),
                                          multiple = TRUE,
                                          options  = list(placeholder = "Choose states")),
                           br(),
                           radioButtons("state_chart", "Chart Type",
                                        choices = c("Bar Chart" = "bar", "Pie Chart" = "pie",
                                                    "Heatmap"   = "heatmap"),
                                        selected = "bar")
                       )
                ),
                column(9,
                       box(title = "State Overview", width = 12,
                           plotlyOutput("state_main", height = "350px")),
                       fluidRow(
                         box(title = "Avg CTC by State", width = 6,
                             plotlyOutput("state_lollipop", height = "300px")),
                         box(title = "Top States by Placement Rate", width = 6,
                             plotlyOutput("state_top", height = "300px"))
                       ),
                       box(title = "State Summary Table", width = 12,
                           dataTableOutput("state_table"))
                )
              )
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────

server <- function(input, output, session) {
  
  # Prepare student data
  students <- data_students %>%
    left_join(students_ctc %>% select(roll, ctc), by = "roll")
  
  if (!"gender" %in% names(students)) {
    set.seed(42)
    students$gender <- sample(c("Male", "Female"), nrow(students),
                              replace = TRUE, prob = c(0.7, 0.3))
  }
  
  if (!"home_state" %in% names(students)) {
    set.seed(42)
    state_list <- c("Uttar Pradesh", "Bihar", "Delhi", "Haryana", "Punjab",
                    "Rajasthan", "Madhya Pradesh", "West Bengal", "Maharashtra", "Gujarat")
    students$home_state <- sample(state_list, nrow(students), replace = TRUE)
  }
  
  # Populate dynamic filter choices
  observe({
    updateSelectizeInput(session, "sel_states",
                         choices  = sort(unique(students$home_state)),
                         selected = head(sort(unique(students$home_state)), 5))
  })
  
  # ── Dashboard KPIs ──────────────────────────────────────────────────────────
  
  output$kpi_total <- renderValueBox({
    valueBox(format(nrow(students), big.mark = ","), "Total Students",
             icon = icon("users"), color = "purple")
  })
  
  output$kpi_placed <- renderValueBox({
    placed <- sum(!is.na(students$ctc))
    rate   <- round(placed / nrow(students) * 100, 1)
    valueBox(paste0(placed, " (", rate, "%)"), "Students Placed",
             icon = icon("check-circle"), color = "green")
  })
  
  output$kpi_avg_ctc <- renderValueBox({
    avg <- round(mean(students$ctc, na.rm = TRUE), 2)
    valueBox(paste0(avg, " LPA"), "Average CTC",
             icon = icon("indian-rupee-sign"), color = "yellow")
  })
  
  output$kpi_companies <- renderValueBox({
    valueBox(nrow(data_companies), "Recruiting Companies",
             icon = icon("building"), color = "blue")
  })
  
  # ── Dashboard charts ────────────────────────────────────────────────────────
  
  output$dash_ctc_dist <- renderPlotly({
    plot_ly(students %>% filter(!is.na(ctc)),
            x = ~ctc, type = "histogram", nbinsx = 30,
            marker = list(color = "#4f46e5", opacity = 0.8,
                          line  = list(color = "white", width = 0.5))) %>%
      pt() %>%
      layout(xaxis = list(title = "CTC (LPA)"), yaxis = list(title = "Count"))
  })
  
  output$dash_gender_donut <- renderPlotly({
    d <- students %>% count(gender)
    plot_ly(d, labels = ~gender, values = ~n, type = "pie", hole = 0.6,
            marker = list(colors = c("#4f46e5", "#db2777"),
                          line   = list(color = "white", width = 2)),
            textinfo = "label+percent",
            textfont = list(size = 12)) %>%
      pt()
  })
  
  output$dash_branch_bar <- renderPlotly({
    d <- students %>%
      group_by(branch) %>%
      summarize(avg_ctc = mean(ctc, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(avg_ctc)) %>%
      head(10)
    
    plot_ly(d, x = ~reorder(branch, avg_ctc), y = ~avg_ctc, type = "bar",
            marker = list(color = COLS, opacity = 0.85)) %>%
      pt() %>%
      layout(xaxis = list(title = ""), yaxis = list(title = "Avg CTC (LPA)"))
  })
  
  output$dash_placement_radar <- renderPlotly({
    d <- students %>%
      group_by(branch) %>%
      summarize(rate = mean(!is.na(ctc)) * 100, .groups = "drop") %>%
      arrange(desc(rate)) %>%
      head(8)
    
    plot_ly(d, theta = ~branch, r = ~rate, type = "scatterpolar",
            fill = "toself",
            fillcolor = "rgba(79,70,229,0.15)",
            line = list(color = "#4f46e5", width = 2),
            marker = list(color = "#4f46e5", size = 6)) %>%
      pt() %>%
      layout(polar = list(
        bgcolor     = "rgba(0,0,0,0)",
        radialaxis  = list(gridcolor = "#e5e7eb", color = "#9ca3af"),
        angularaxis = list(gridcolor = "#e5e7eb", color = "#6b7280")
      ))
  })
  
  # ── Companies ───────────────────────────────────────────────────────────────
  
  filtered_companies <- eventReactive(input$filter_companies, {
    data_companies %>%
      filter(ctc >= input$ctc_range[1], ctc <= input$ctc_range[2])
  }, ignoreNULL = FALSE)
  
  output$comp_profile_pie <- renderPlotly({
    d <- filtered_companies() %>% count(profile_type)
    plot_ly(d, labels = ~profile_type, values = ~n, type = "pie", hole = 0.5,
            marker = list(colors = COLS[1:nrow(d)],
                          line   = list(color = "white", width = 2)),
            textfont = list(size = 11)) %>%
      pt()
  })
  
  output$comp_top_bar <- renderPlotly({
    d <- filtered_companies() %>% arrange(desc(ctc)) %>% head(12)
    plot_ly(d, x = ~ctc, y = ~reorder(company_name, ctc),
            type = "bar", orientation = "h",
            marker = list(color = "#0891b2", opacity = 0.85)) %>%
      pt() %>%
      layout(xaxis = list(title = "CTC (LPA)"), yaxis = list(title = ""))
  })
  
  output$comp_table <- renderDataTable({
    filtered_companies() %>%
      select(company_name, profile_type, profile, location, ctc) %>%
      datatable(rownames = FALSE,
                options  = list(pageLength = 10, scrollX = TRUE, dom = "frtip"),
                colnames = c("Company", "Type", "Role", "Location", "CTC (LPA)")) %>%
      formatStyle("ctc", color = "#4f46e5", fontWeight = "700") %>%
      formatStyle("company_name", fontWeight = "600")
  })
  
  # ── Branch ──────────────────────────────────────────────────────────────────
  
  branch_data <- reactive({
    req(length(input$sel_branches) > 0)
    students %>%
      filter(branch %in% input$sel_branches) %>%
      group_by(branch) %>%
      summarize(
        avg_ctc        = mean(ctc, na.rm = TRUE),
        median_ctc     = median(ctc, na.rm = TRUE),
        placement_rate = mean(!is.na(ctc)) * 100,
        total          = n(),
        placed         = sum(!is.na(ctc)),
        .groups = "drop"
      )
  })
  
  output$branch_main <- renderPlotly({
    d <- branch_data()
    if (input$branch_chart == "scatter") {
      plot_ly(d, x = ~placement_rate, y = ~avg_ctc,
              size = ~total, color = ~branch, colors = COLS,
              type = "scatter", mode = "markers",
              marker = list(opacity = 0.8, sizemode = "diameter"),
              text  = ~paste0(branch, "<br>Avg CTC: ", round(avg_ctc, 2),
                              " LPA<br>Rate: ", round(placement_rate, 1), "%"),
              hoverinfo = "text") %>%
        pt() %>%
        layout(xaxis = list(title = "Placement Rate (%)"),
               yaxis = list(title = "Avg CTC (LPA)"))
      
    } else if (input$branch_chart == "box") {
      raw <- students %>% filter(branch %in% input$sel_branches, !is.na(ctc))
      plot_ly(raw, x = ~branch, y = ~ctc,
              color = ~branch, colors = COLS, type = "box", boxmean = "sd") %>%
        pt() %>%
        layout(xaxis = list(title = ""), yaxis = list(title = "CTC (LPA)"),
               showlegend = FALSE)
      
    } else if (input$branch_chart == "bubble") {
      plot_ly(d, x = ~branch, y = ~avg_ctc, size = ~placement_rate,
              type = "scatter", mode = "markers",
              marker = list(color = "#4f46e5", opacity = 0.7, sizemode = "area")) %>%
        pt() %>%
        layout(xaxis = list(title = ""), yaxis = list(title = "Avg CTC (LPA)"))
      
    } else {
      plot_ly(d, x = ~branch, y = ~avg_ctc,
              color = ~branch, colors = COLS, type = "bar",
              marker = list(opacity = 0.85)) %>%
        pt() %>%
        layout(xaxis = list(title = ""), yaxis = list(title = "Avg CTC (LPA)"),
               showlegend = FALSE)
    }
  })
  
  output$branch_violin <- renderPlotly({
    raw <- students %>% filter(branch %in% input$sel_branches, !is.na(ctc))
    plot_ly(raw, x = ~branch, y = ~ctc,
            color = ~branch, colors = COLS, type = "violin",
            box      = list(visible = TRUE),
            meanline = list(visible = TRUE)) %>%
      pt() %>%
      layout(xaxis = list(title = ""), yaxis = list(title = "CTC (LPA)"),
             showlegend = FALSE)
  })
  
  output$branch_donut <- renderPlotly({
    d <- branch_data()
    plot_ly(d, labels = ~branch, values = ~placement_rate,
            type = "pie", hole = 0.55,
            marker   = list(colors = COLS[1:nrow(d)],
                            line   = list(color = "white", width = 2)),
            textinfo = "label+percent",
            textfont = list(size = 11)) %>%
      pt()
  })
  
  output$branch_table <- renderDataTable({
    branch_data() %>%
      mutate(avg_ctc        = round(avg_ctc, 2),
             median_ctc     = round(median_ctc, 2),
             placement_rate = round(placement_rate, 1)) %>%
      datatable(rownames = FALSE,
                options  = list(pageLength = 10, scrollX = TRUE, dom = "frtip"),
                colnames = c("Branch", "Avg CTC", "Median CTC",
                             "Placement %", "Total", "Placed")) %>%
      formatStyle("placement_rate",
                  background       = styleColorBar(c(0, 100), "#4f46e5"),
                  backgroundSize   = "98% 55%",
                  backgroundRepeat = "no-repeat",
                  backgroundPosition = "center")
  })
  
  # ── State ───────────────────────────────────────────────────────────────────
  
  state_data <- reactive({
    students %>%
      group_by(home_state) %>%
      summarize(
        avg_ctc        = mean(ctc, na.rm = TRUE),
        median_ctc     = median(ctc, na.rm = TRUE),
        placement_rate = mean(!is.na(ctc)) * 100,
        total          = n(),
        placed         = sum(!is.na(ctc)),
        .groups = "drop"
      ) %>%
      {
        if (!is.null(input$sel_states) && length(input$sel_states) > 0)
          filter(., home_state %in% input$sel_states)
        else .
      }
  })
  
  output$state_main <- renderPlotly({
    d <- state_data()
    if (input$state_chart == "bar") {
      plot_ly(d, x = ~reorder(home_state, avg_ctc), y = ~avg_ctc,
              type = "bar",
              marker = list(color = ~avg_ctc,
                            colorscale  = list(c(0, "#e0e7ff"), c(1, "#4f46e5")),
                            showscale   = TRUE,
                            opacity     = 0.9)) %>%
        pt() %>%
        layout(xaxis = list(title = ""), yaxis = list(title = "Avg CTC (LPA)"))
      
    } else if (input$state_chart == "pie") {
      plot_ly(d, labels = ~home_state, values = ~total,
              type = "pie",
              marker = list(colors = COLS, line = list(color = "white", width = 2)),
              textfont = list(size = 11)) %>%
        pt()
      
    } else {
      plot_ly(z = ~matrix(d$avg_ctc, nrow = 1), x = ~d$home_state,
              type = "heatmap",
              colorscale = list(c(0, "#e0e7ff"), c(0.5, "#818cf8"), c(1, "#4f46e5"))) %>%
        pt() %>%
        layout(xaxis = list(title = ""), yaxis = list(title = ""))
    }
  })
  
  output$state_lollipop <- renderPlotly({
    d <- state_data()
    plot_ly(d, x = ~avg_ctc, y = ~reorder(home_state, avg_ctc),
            type = "scatter", mode = "markers+lines",
            marker = list(color = "#4f46e5", size = 10, opacity = 0.9),
            line   = list(color = "rgba(79,70,229,0.2)", width = 1)) %>%
      pt() %>%
      layout(xaxis = list(title = "Avg CTC (LPA)"), yaxis = list(title = ""))
  })
  
  output$state_top <- renderPlotly({
    d <- state_data() %>% arrange(desc(placement_rate)) %>% head(10)
    plot_ly(d, y = ~reorder(home_state, placement_rate), x = ~placement_rate,
            type = "bar", orientation = "h",
            marker = list(color = ~placement_rate,
                          colorscale  = list(c(0, "#d1fae5"), c(1, "#059669")),
                          showscale   = FALSE,
                          opacity     = 0.9)) %>%
      pt() %>%
      layout(xaxis = list(title = "Placement Rate (%)"), yaxis = list(title = ""))
  })
  
  output$state_table <- renderDataTable({
    state_data() %>%
      mutate(avg_ctc        = round(avg_ctc, 2),
             median_ctc     = round(median_ctc, 2),
             placement_rate = round(placement_rate, 1)) %>%
      datatable(rownames = FALSE,
                options  = list(pageLength = 10, scrollX = TRUE, dom = "frtip"),
                colnames = c("State", "Avg CTC", "Median CTC",
                             "Placement %", "Total", "Placed")) %>%
      formatStyle("placement_rate",
                  background       = styleColorBar(c(0, 100), "#059669"),
                  backgroundSize   = "98% 55%",
                  backgroundRepeat = "no-repeat",
                  backgroundPosition = "center")
  })
  
}

shinyApp(ui = ui, server = server)
