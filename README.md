requires plv8 and postgres
alias n=coffee

n load.coffee -n | psql test && echo 'select generate_tables()' | psql test
