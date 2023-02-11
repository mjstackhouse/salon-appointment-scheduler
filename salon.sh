#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n--- Stack Salon ---\n"
echo -e "\nWhat kind of appointment would you like to book?"

BOOK_APPOINTMENT() {
  # Asking for and storing service type chosen in SERVICE_ID_SELECTED and SERVICE_NAME
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "\n$SERVICE_ID) $SERVICE_NAME\n"
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_EXISTS ]]
  then
    while [[ -z $SERVICE_ID_EXISTS ]]
    do
      echo -e "\nPlease input a valid service number."
      SERVICES=$($PSQL "SELECT * FROM services")
      echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo -e "\n$SERVICE_ID) $SERVICE_NAME\n"
      done
      read SERVICE_ID_SELECTED
      SERVICE_ID_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    done
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # Asking for and storing the customer's name and phone number in CUSTOMER_NAME and CUSTOMER_PHONE (and in the database as well)
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_PHONE_EXISTS ]]
  then
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  
  # Asking for and storing the customer's appointment time in SERVICE_TIME and in the database
  echo -e "\nWhen would you like to book your appointment?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Removing extra whitespace
  SERVICE_TIME_FORMATTED=$(echo "$SERVICE_TIME" | sed -E 's/^ *| *$//g')
  CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')
  SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -E 's/^ *| *$//g')

  # Printing appointment confirmation
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
}

BOOK_APPOINTMENT