#!/bin/bash
neo4j-admin import --nodes=Name=name.basics.headers.tsv,name.basics.tsv.gz --nodes=Title=title.basics.headers.tsv,title.basics.tsv.gz --relationships=WORKED_ON=title.principals.headers.tsv,title.principals.tsv.gz --delimiter="\t" --array-delimiter="," --skip-bad-relationships --quote=^
