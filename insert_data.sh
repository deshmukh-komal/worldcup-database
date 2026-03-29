#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear tables
$PSQL "TRUNCATE TABLE games, teams;"

while IFS=',' read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != "year" ]]
  then
    # winner id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'" | head -n 1)

    if [[ -z $WINNER_ID ]]
    then
      WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id" | head -n 1)
    fi

    # opponent id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'" | head -n 1)

    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id" | head -n 1)
    fi

    # insert game
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS);"
  fi
done < games.csv