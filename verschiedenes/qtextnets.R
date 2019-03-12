library("quanteda")
library("tidyr")
library("dplyr")
library("scales")
library("ggplot2")
library("igraph")
library("ggraph")
theme_set(theme_bw())

# check conditions for maxdocs / maxfeatures with different data

#testdata <- data.frame(user = c("Bob", "Mike", "Steve", "Mary"), text = c("This is why I don't like Monday", "I think Monday works", "I don't care if Monday is blue", "The TV was the color of the sky"), stringsAsFactors = F)
#testdata <- data.frame(user = c("Bob", "Mike", "Steve", "Mary"), text = c("a b c d", "c d e f", "a b e f", "x y z"), stringsAsFactors = F)
#testcorpus <- corpus(testdata, text_field = "text")
#summary(testcorpus)

#testdata <- scan("sherlock_sample.txt", what = "char", sep = "\n")
#testcorpus <- corpus_reshape(corpus(testdata), to = "sentences")
#mydfm <- dfm(testcorpus)

# Network of documents and terms
textplot_mixednet <- function(mydfm, maxdocs = 10, main = "Document Feature Mixednet")
{
  if (maxdocs > ndoc(mydfm)) maxdocs <- ndoc(mydfm)
  mixednet <- convert(mydfm, to = "data.frame") %>% 
    sample_n(maxdocs) %>% 
    gather(key = "term", value = "weight", -document) %>% 
    filter(weight >= 1) %>% 
    arrange(document)
  mixedgraph <- graph_from_data_frame(mixednet, directed = F, )
  V(mixedgraph)$type <- bipartite_mapping(mixedgraph)$type # make bipartite
  ggraph(mixedgraph, layout = "graphopt") +
    geom_edge_link(aes(alpha = ..index..)) +
    geom_node_point() +
    geom_node_label(aes(label = name, fill = type)) +
    scale_fill_manual(values = c("#E69F00", "#999999"), 
                      name = "Node Type",
                      breaks = c("TRUE", "FALSE"),
                      labels = c("Feature", "Document")) +
    xlab("") +
    ylab("") +
    ggtitle(main)
}

# Networks of terms only
textplot_termnet <- function(mydfm, main = "Termnet")
{
  termnet <- fcm(mydfm) %>% 
    convert(to = "matrix")
  termgraph <- graph_from_adjacency_matrix(termnet, mode = "undirected", weighted = T)
  ggraph(termgraph, layout = "graphopt") +
    geom_edge_fan(aes(alpha = ..index..)) +
    geom_node_point() +
    geom_node_label(aes(label = name)) +
    xlab("") +
    ylab("") +
    ggtitle(main)
}

# Network of documents only
textplot_docnet <- function(mydfm, main = "Docnet")
{
  docnet <- dfm_weight(mydfm, scheme = "prop") %>% 
    textstat_dist(margin = "documents", method = "euclidean", upper = T, diag = T) %>% 
    as.matrix(.) %>% 
    rescale(to = c(1,0)) %>% 
    round(.)
  docgraph <- graph_from_adjacency_matrix(docnet, mode = "undirected", weighted = T, diag = F)
  ggraph(docgraph, layout = "circle") + 
    geom_edge_fan(aes(alpha = ..index..)) +
    geom_node_point() + 
    geom_node_label(aes(label = name)) +
    xlab("") +
    ylab("") +
    ggtitle(main)
}
