#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=user_base -t --no-align --tuples-only -c"
SECRET_NUMBER=$((RANDOM%1000))
TRIES=0

INPUT_MENU()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then 
    INPUT_MENU "That is not an integer, guess again:"
  else
    if [[ $SECRET_NUMBER == $GUESS ]]
    then
      ((TRIES++))
      if [[ -z $USER_ID ]]
      then
        TABLE_INSERT=$($PSQL "INSERT INTO user_info(username,games_played,best_game) VALUES('$INPUT',1,$TRIES)") 
      else
        if [[ $BEST_GAME > $TRIES ]]
        then
          BEST_GAME=$TRIES
        fi          
        TABLE_INSERT=$($PSQL "INSERT INTO user_info(username,game_played,best_game) VALUES('$INPUT',$((GAMES_PLAYED++)),$BEST_GAME)")
      fi
      echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"          
    else
      ((TRIES++))
      if [[ $SECRET_NUMBER > $GUESS ]]
      then             
        INPUT_MENU "It's higher than that, guess again:"
      else           
        INPUT_MENU "It's lower than that, guess again:"
      fi
    fi
  fi
}
  
MAIN_MENU()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "Enter your username:"
  read INPUT
  if [[ -z $INPUT ]]
  then
    MAIN_MENU "Username empty"
  else
    LENGTH=${#INPUT}
    echo $LENGTH
    if [[ $LENGTH -gt 22 ]]
    then
      MAIN_MENU "Username should be 22 characters max"
    else    
      USER_ID=$($PSQL "SELECT user_id FROM user_info WHERE username='$INPUT'")
      if [[ -z $USER_ID  ]]
      then
        echo "Welcome, $INPUT! It looks like this is your first time here."
      else
        GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE user_id=$USER_ID")
        BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE user_id=$USER_ID")
        echo "Welcome back, $INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      fi
      echo "Guess the secret number between 1 and 1000:" 
      INPUT_MENU
    fi
  fi
}
MAIN_MENU