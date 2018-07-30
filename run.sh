#!/bin/bash

# db specific settings
postgres_host="${postgres_host:-localhost}"
postgres_port="${postgres_port:-5432}"
postgres_db="${postgres_db:-postgres}"
postgres_user="${postgres_user:-postgres}"
postgres_password="${postgres_password:-password}"

# liquibase specific settings
liquibase_command="${liquibase_command:-update}"
liquibase_context="${liquibase_context:-!dev}"
liquibase_changelog_file="${liquibase_changelog_file}"

# jdbc specific settings
jdbc_url="${jdbc_url:-jdbc:postgresql://$postgres_host:$postgres_port/$postgres_db}"

function start_message() {
  echo "starting liquibase run, with values:"
  echo "Postgres host: $postgres_host, port: $postgres_port, db: $postgres_db, user: $postgres_user"
  echo "liquibase cmd: $liquibase_command, context: $liquibase_context"
  echo
}

function check_postgres() {
  echo "checking db host: $postgres_host"
  # wait for postgres to be up and accepting connections
  until nc -z $postgres_host $postgres_port; do
      echo "Postgres is not available - sleeping"
      sleep 1
  done

  echo "Postgres is up on host $postgres_host!"
  echo
}

function create_liquibase_properties() {
  echo "building liquibase properties file"

  [[ -z "$liquibase_changelog_file" ]] && \
    liquibase_changelog_file=$(find /source_root -name 'dbchang*' | head -n 1)

  cat <<EOF > /workspace/liquibase.properties
    classpath: /opt/jdbc/postgres-jdbc.jar
    driver: org.postgresql.Driver
    url: $jdbc_url
    username: $postgres_user
    password: $postgres_password
    changeLogFile: $liquibase_changelog_file
    logLevel: info
EOF
}

function run_liquibase() {
  echo "liquibase context is: $liquibase_context"
  cd /workspace

  liquibase --contexts=$liquibase_context $liquibase_command
}

start_message
check_postgres
sleep 1
create_liquibase_properties
run_liquibase