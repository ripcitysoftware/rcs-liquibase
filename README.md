# RCS Liquibase 

This container is built off of the [https://github.com/kilna/liquibase-postgres-docker](kilna/liquibase-postgres) 
container. `rcs-liquibase` is designed to wait for your DB host to be up and running before
running liquibase. By default, the liquibase `update` command will be run. See the Variables
section below for which variables can be set.

You can use this container to work with a database running in another container or running
on a dedicated host (bare-metal or VM).

## Usage in a docker-compose file:
```yaml
services:
  my-postgres:
    container_name: my-postgres
    volumes:
      # https://stackoverflow.com/questions/26598738/how-to-create-user-database-in-script-for-docker-postgres
      - ./database:/docker-entrypoint-initdb.d/
    image: postgres:latest
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    restart: always
    
  setup-db:
    container_name: setup-db
    image: rcs/rcs-liquibase
    environment:
      - liquibase_context=dev
      - postgres_host=my-postgres
    volumes:
      - ../:/source_root
```

The `postgres_host` is the name of the `my-postgres` container defined in the docker-compose file.
There's no db username/password defined because we are using the default `postgres` username
and `password` password (do not use this in a production environment).

The `rcs/rcs-liquibase` container will look for a Liquibase change log file starting with `dbchange`.

## Variables

### PostgreSQL specific properties
* postgres_host="${postgres_host:-localhost}"
* postgres_port="${postgres_port:-5432}"
* postgres_db="${postgres_db:-postgres}"
* postgres_user="${postgres_user:-postgres}"
* postgres_password="${postgres_password:-password}"

### Liquibase specific properties
* liquibase_command="${liquibase_command:-update}"
* liquibase_context="${liquibase_context:-!dev}"
* liquibase_changelog_file="${liquibase_changelog_file}"
  
### JDBC specific properties
* jdbc_url="${jdbc_url:-jdbc:postgresql://$postgres_host:$postgres_port/$postgres_db}"
