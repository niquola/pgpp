requires plv8 and postgres
connection string in src/plv8.js


```
# load to postgres
coffee load.coffee -n | psql test && echo 'select generate_tables()' | psql test

# run tests
node_modules/jasmine-node/bin/jasmine-node spec --watch --coffee
```
