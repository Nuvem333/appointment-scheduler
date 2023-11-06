#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
    else 
    echo -e "\nWelcome to My Salon, how can I help you?\n" 
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
    echo "$SERVICE_ID) $NAME"

  done
  read SERVICE_ID_SELECTED

  # get customers selected service
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if not available
  if [[ -z $SERVICE_ID ]]
    then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"

    else
    # get customer number
    echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
      then
      # get customer name
      echo -e "\nI don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME

      # insert new customer 
      INSERT_CUSTOMER_RES=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi  

    # get appointments time
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME_FORMATTED?\n"
    read SERVICE_TIME
  fi  

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # insert appointments
  INSERT_APPOINTMENT_RES=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

  # get service info
  SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")

  SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ //')

  echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED.\n"
}

MAIN_MENU
