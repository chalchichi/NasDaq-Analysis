FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y

# install R packages required
# (change it dependeing on the packages you need)
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', repos='http://cran.rstudio.com/')"

# copy the app to the image
COPY . /

# select port
EXPOSE 3838


# run app
CMD R -e 'shiny::runApp("global.R", port = 3838, host = "0.0.0.0")'
