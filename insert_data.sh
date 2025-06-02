#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Process the csv file and all columns
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Add to teams table (Winners)
  # Do not read the first line
  if [[ $WINNER != "winner" ]]
  then
    # Check for a duplicate entry
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # If duplicate is not found look for empty row
    if [[ -z $W_TEAM_ID ]]
    then
      # Insert value
      INSERT_NAME_W=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_NAME_W == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # Get new winner team_id
      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
  fi

  # Add to teams table (Opponents)
  # Do not read the first line
  if [[ $OPPONENT != "opponent" ]]
  then
    # Check for a duplicate in opponents
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # If duplicate is not found look for empty row
    if [[ -z $O_TEAM_ID ]]
    then
      # Insert value
      INSERT_NAME_O=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_NAME_O == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      # Get new opponent team_id
      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
  # Add in games table - $ROUND is a string, remember single quote marks!
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_TEAM_ID, $O_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS);" 
done