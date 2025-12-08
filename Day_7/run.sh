cpp $1 | grep -ve '^#' > .sql
cat $2 | sqscript .sql
