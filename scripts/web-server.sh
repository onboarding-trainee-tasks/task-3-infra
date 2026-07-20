#!/bin/bash

sudo /usr/local/bin/configure-alertmanager.sh \
  "${AWS_REGION}" \
  "${SMTP_SECRET_ARN}"

sudo /usr/local/bin/start-open-webui.sh \
  "${AWS_REGION}" \
  "${DB_SECRET_ARN}" \
  "${DB_HOST}" \
  "${DB_PORT}" \
  "${DB_NAME}" \
  "${DNS_NAME}"
