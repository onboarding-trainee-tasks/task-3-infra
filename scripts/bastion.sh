#!/bin/bash

sudo /usr/local/bin/init-database.sh \
  "${AWS_REGION}" \
  "${DB_SECRET_ARN}" \
  "${DB_HOST}" \
  "${DB_PORT}" \
  "${DB_NAME}"
