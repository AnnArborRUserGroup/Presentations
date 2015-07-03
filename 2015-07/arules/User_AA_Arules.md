# Association Rule Mining
Brandon Stange  
July 9, 2015  

## My Background


- Currently a Data Scientist at Trinity Health
- Previously a Data Analyst for a large physician practice
- MA Economics (Econometrics, Environmental Econ)

Brandon.Stange@gmail.com    

## Accuracy vs. Interpretability
**Maximally Accurate**

- Non-Linear
- Feature Engineering/Interaction
- Ensembling

**Maximally Interpretable**

- Rule-Based
- Single Decision Trees
- Linear/Logistic Regression

## Association Rule Uses

- Originally used for *market basket analysis*
    - Find sets of products that are often bought together
    - Improve product arrangement
    - Targeted Advertising
    - {Beer} -> {Pizza}
- Can be used for any dataset that can be represented as a binary matrix
- Traditionally unsupervised, but can target specific outcomes
- Can target more than one outcome at once

## Algorithms and Implimentations

- Apriori
    - R, Python, SQL Server, Oracle, everywhere
- Eclat
    - R, Python, C, others
- FP Growth
    - C, Python, mahout
- Graph Databases
    - neo4j, Titan, Giraph

## Arules Package Ecosystem {.flexbox .vcenter .hcenter .bigger}
![Arules Ecosystem](images/ArulesEco.jpg)

## Input Data Structure {.flexbox .vcenter}
![Input Data Format](images/DataFormat.jpg)

## Rule Interpretation (Apriori Output)


|   |  lhs  | rhs | support | confidence | lift |
|:--|:-----:|:---:|:-------:|:----------:|:----:|
|16 | {b,c} | {d} |   0.4   |     1      | 2.5  |

<br>
RHS (Outcome) = **{d}**

LHS (Inputs) = **{b,d}**
LHS occurs in **40%** of total population.

RHS occurs in **100%** of these transactions, which is **2.5** times the population at large.

## Apriori Function Call {.bigger}


```r
apriori(data,
         parameter = list(minlen=1, 
                          support=0.05, 
                          confidence=0.4, 
                          maxlen=3),
         appearance = list(rhs=outcomelist, 
                           default="lhs"),
         control = list(verbose=T))
```

## Itemset Graph Representation {.flexbox .vcenter}
![Frequent Item Graph](images/FrequentItems.png)

## Session Info {.smaller}


```r
library(dplyr)
library(readr)
library(tidyr)
library(arules)
library(arulesViz)
print(sessionInfo(),locale=F)
```

```
## R version 3.2.0 (2015-04-16)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## attached base packages:
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] arulesViz_1.0-0 arules_1.1-6    Matrix_1.2-0    tidyr_0.2.0    
## [5] dplyr_0.4.1     readr_0.1.0    
## 
## loaded via a namespace (and not attached):
##  [1] igraph_0.7.1         Rcpp_0.11.5          cluster_2.0.1       
##  [4] knitr_1.10           magrittr_1.5         MASS_7.3-40         
##  [7] munsell_0.4.2        scatterplot3d_0.3-35 colorspace_1.2-6    
## [10] lattice_0.20-31      foreach_1.4.2        highr_0.5           
## [13] stringr_1.0.0        plyr_1.8.2           tools_3.2.0         
## [16] vcd_1.3-2            parallel_3.2.0       seriation_1.0-14    
## [19] DBI_0.3.1            iterators_1.0.7      htmltools_0.2.6     
## [22] yaml_2.1.13          lazyeval_0.1.10      assertthat_0.1      
## [25] digest_0.6.8         reshape2_1.4.1       formatR_1.2         
## [28] gclus_1.3.1          codetools_0.2-11     evaluate_0.7        
## [31] rmarkdown_0.7        TSP_1.1-0            stringi_0.4-1       
## [34] scales_0.2.4
```

## Real Data Example

**490k records from New York City resturant inspections**

requires readr, dplyr, tidyr, arules, arulesviz
(https://data.cityofnewyork.us)

**Fields of interest:**

- ID, name, address, phone, etc.
- Inspection Date
- Borough
- Cuisine Description
- Violation Description
- Action

## Data Pre-Processing

1. Clean up dates and special characters
2. Apply custom violation code grouping
3. Use tidyr::gather to put data in 'long' format
4. Replace keys and measures with integer IDs
5. Convert to sparse matrix


## Pre-Processing steps 3-5 Code


```r
## 3. Use tidyr::gather to put data in 'long' format
nycs <- nycw %>%
  select(INSID, BORO, CUISINE_DESCRIPTION, VIOLATION_TYPE) %>%
  gather(MEASURE, VALUE, -INSID)
nycs$MEASURE <- nycs$VALUE
nycs$VALUE <- 1

## 4. Replace keys and measures with integer IDs
ID <- unique(nycs$INSID)
ME <- unique(nycs$MEASURE)
nycs$MEASURE<-match(nycs$MEASURE,ME)
nycs$INSID<-match(nycs$INSID,ID)

## 5. Convert to sparse matrix
sm<-sparseMatrix(i=nycs$INSID, j=nycs$MEASURE,x=nycs$VALUE,
                 dimnames=list(ID,ME),giveCsparse=T)
```


## Example Function Call {.smaller}


```r
rules <- apriori(sm2,
                   parameter = list(minlen=1, supp=0.001, conf=0.4, maxlen=4),
                   appearance = list(rhs=outcomelist, 
                                     default="lhs"),
                   control = list(verbose=T))
```

```r
outcomelist
```

```
## [1] "Food Handling"      "Rodents/Pests"      "Employee Practices"
## [4] "Temperature"        "Adminstrative"      "Poor Equipment"    
## [7] "Food Source"
```

```r
class(sm2)
```

```
## [1] "transactions"
## attr(,"package")
## [1] "arules"
```

## Results

29 rules were generated.  The top 5 are:

|   |         lhs          |       rhs       | support | confidence | lift  |
|:--|:--------------------:|:---------------:|:-------:|:----------:|:-----:|
|23 | {BROOKLYN,Caribbean} | {Rodents/Pests} |  0.008  |   0.606    | 1.398 |
|1  |    {Delicatessen}    |  {Temperature}  |  0.010  |   0.599    | 1.354 |
|5  |     {Caribbean}      | {Rodents/Pests} |  0.016  |   0.570    | 1.316 |
|35 | {MANHATTAN,Chinese}  |  {Temperature}  |  0.015  |   0.575    | 1.299 |
|2  |   {Pizza/Italian}    |  {Temperature}  |  0.012  |   0.556    | 1.256 |

## arulesViz plots

```r
plot(rules,method="grouped")
```

![](User_AA_Arules_files/figure-html/unnamed-chunk-9-1.png) 

## arulesViz plots contd

```r
plot(rules,method="paracoord")
```

![](User_AA_Arules_files/figure-html/unnamed-chunk-10-1.png) 

## arulesViz plots contd

```r
plot(rules,method="graph")
```

![](User_AA_Arules_files/figure-html/unnamed-chunk-11-1.png) 

## Arules Sequences

- Allows for pattern discovery in ordered sets of discrete data
- Ordered, not temporal (no measure of time between events)
- Right-censored, events *after* the event of interest are ignored
- arulesSequences::cspade()
- Parameters are similar: support, size, gap, window

## Resources

**Christian Borgelt's website**

Various publications and implementations of Association Rules

[www.borgelt.net](www.borgelt.net)

[Efficient Analysis of Pattern and Association Rule Mining Approaches](http://arxiv.org/ftp/arxiv/papers/1402/1402.2892.pdf)
