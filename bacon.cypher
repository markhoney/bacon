// https://www.imdb.com/interfaces/

// https://datasets.imdbws.com/name.basics.tsv.gz
// nconst	primaryName	birthYear	deathYear	primaryProfession	knownForTitles
// nm0000001	Fred Astaire	1899	1987	soundtrack,actor,miscellaneous	tt0072308,tt0053137,tt0050419,tt0043044

// https://datasets.imdbws.com/title.basics.tsv.gz
// tconst	titleType	primaryTitle	originalTitle	isAdult	startYear	endYear	runtimeMinutes	genres
// tt0000001	short	Carmencita	Carmencita	0	1894	\N	1	Documentary,Short


// https://datasets.imdbws.com/title.principals.tsv.gz
// tconst	ordering	nconst	category	job	characters
// tt0000001	1	nm1588970	self	\N	["Self"]

// dbms.directories.import

// CREATE DATABASE bacon;

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'https://datasets.imdbws.com/name.basics.tsv.gz' AS row FIELDTERMINATOR '\t'
MERGE(n:Name {id: row.nconst, name: row.primaryName})
RETURN count(n);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'https://datasets.imdbws.com/title.basics.tsv.gz' AS row FIELDTERMINATOR '\t'
MERGE(t:Title {id: row.tconst, name: row.primaryTitle})
RETURN count(t);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'https://datasets.imdbws.com/title.principals.tsv.gz' AS row FIELDTERMINATOR '\t'
WHERE row.category IN ['actor', 'actress', 'self']
MATCH (n:Name {id: row.nconst})
MATCH (t:Title {id: row.tconst})
MERGE (n)-[r:APPEARS_IN]->(t)
RETURN count(*);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///name.basics.tsv.gz' AS row FIELDTERMINATOR '\t'
MERGE(n:Name {id: row.nconst, name: row.primaryName})
RETURN count(n);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///title.basics.tsv.gz' AS row FIELDTERMINATOR '\t'
MERGE(t:Title {id: row.tconst, name: row.primaryTitle})
RETURN count(t);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///title.principals.tsv.gz' AS row FIELDTERMINATOR '\t'
WHERE row.category IN ['actor', 'actress', 'self']
MATCH (n:Name {id: row.nconst})
MATCH (t:Title {id: row.tconst})
MERGE (n)-[r:WORKED_ON]->(t)
RETURN count(*);


MATCH (Kevin:Name {id: 'nm0000102'}),(Al:Person {name: 'Al Pacino'}), p = shortestPath((Kevin)-[:WORKED_ON*]-(Al))
WHERE ALL (r IN relationships(p) WHERE EXISTS (r.role))
RETURN p

// sudo rm -R /usr/local/var/neo4j/data/databases/neo4j/
// neo4j-admin import --nodes=Name=name.basics.headers.tsv,name.basics.tsv.gz --nodes=Title=title.basics.headers.tsv,title.basics.tsv.gz --relationships=WORKED_ON=title.principals.headers.tsv,title.principals.tsv.gz --delimiter="\t" --array-delimiter="," --skip-bad-relationships --quote=^
// neo4j start
