# Builds image upon the existing rocker/hadleyverse image
FROM rocker/hadleyverse

# Example of installing a library
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpqxx-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Example of installing additional R packages
RUN install2.r --error \
    -r "https://cran.rstudio.com" \
    RCurl
