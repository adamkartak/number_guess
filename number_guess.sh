#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USER

USERSQL=$($PSQL "SELECT games_played, best_game FROM users WHERE name='$USER'")

if [[ -z $USERSQL ]] ; then
  echo "Welcome, $USER! It looks like this is your first time here."
  INSERT=$($PSQL "INSERT INTO users (name,games_played) VALUES ('$USER',0)")  
else
  echo $USERSQL | while IFS="|" read -r USER_GAMES USER_BEST
  do
    echo "Welcome back, $USER! You have played $USER_GAMES games, and your best game took $USER_BEST guesses."
  done
fi

RANDOM_NUM=$((1 + $RANDOM % 1000))

function ASK() {
  if [[ -z $1 ]] ; then
    echo "Guess the secret number between 1 and 1000:"
  else
    echo $1
  fi
  read READNUM  
}

for i in {1..10000}
do
  if [[ $i == 1 ]] ; then
    ASK
  fi

  if ! [[ "$READNUM" =~ ^[0-9]+$ ]] ; then
    ASK "That is not an integer, guess again:"
  fi

  if (( $READNUM == $RANDOM_NUM )) ; then
    echo "You guessed it in $i tries. The secret number was $RANDOM_NUM. Nice job!"
    UPD=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=LEAST(best_game,$i) WHERE name='$USER'")
    break
  else 
    if (( $READNUM > $RANDOM_NUM )) ; then
      ASK "It's lower than that, guess again:"    
    else
      ASK "It's higher than that, guess again:"
    fi
  fi

done
