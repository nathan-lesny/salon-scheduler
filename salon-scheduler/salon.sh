#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to Nathan's Salon, how can I help you?"

SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")"

SALON() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED > 5 || $SERVICE_ID_SELECTED < 1 ]]
  then
    SALON "Please select an actual service..."
  fi
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWe don't have your number on record, what is your name?"
    read CUSTOMER_NAME
    ADD_CUSTOMER="$($PSQL"INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
  fi
  echo -e "\n$CUSTOMER_NAME, what time would you like your $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")?"
  read SERVICE_TIME
  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")"
  ADD_APPOINTMENT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
  echo -e "\nI have put you down for a $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") at $SERVICE_TIME, $CUSTOMER_NAME."
  exit
}

SALON
exit
