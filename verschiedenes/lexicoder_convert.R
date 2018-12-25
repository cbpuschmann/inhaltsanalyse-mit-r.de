# Internal function 
nodes2list <- function(node, dict = list()){
  nodes <- XML::xpathSApply(node, "cnode")
  if (length(nodes)) {
    for (i in seq_along(nodes)) {
      values <- XML::xmlGetAttr(nodes[[i]], name = "name")
      dict[[values]] <- nodes2list(nodes[[i]], dict[[values]])
    }
  } else {
    dict <- unname(XML::xpathSApply(node, "pnode/@name"))
  }
  return(dict)
}

xml <- XML::xmlParse("policy_agendas_english.lcd") # one of the files in from http://www.lexicoder.com/docs/LTDjun2013.zip
root <- XML::xpathSApply(xml, "/dictionary/cnode")
dict <- lapply(root, nodes2list)
dict <- lapply(dict, function(x) stringr::str_trim(tolower(x)))
dict <- lapply(dict, function(x) stringi::stri_enc_toutf8(x))
keys <- rep(NA, length(dict))
for (i in seq_along(root)) {
  keys[i] <- XML::xmlGetAttr(root[[i]], name = "name")
}
names(dict) <- keys
dictLexic2Topics <- dict
rm(dict, i, keys, root, xml)
#save(dictLexic2Topics, file="policy_agendas_english.RData")