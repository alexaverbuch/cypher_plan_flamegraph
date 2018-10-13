# cypher_plan_flamegraph
Uses https://github.com/spiermar/d3-flame-graph to visualize Neo4j Cypher logical plans as Flame Graphs.
Code for converting a Neo4j Cypher plan into the expected JSON isn't in this repo, but it's trivial.
The provided examples use `rows` as value, but could be any of: `time`, `db-hits`, `rows`, `page-cache-missed`, ...