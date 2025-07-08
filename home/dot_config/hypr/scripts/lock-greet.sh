#!/bin/bash

current_hour=$(date +"%H")
user=$(whoami)
capitalized_user=$(echo "$user" | awk '{print toupper(substr($0,1,2)) tolower(substr($0,3))}')

morning_greetings=(
	"Greetings, fair morn" 
	"Good morrow" 
	"Bright morning to thee"
	"Purer than the snow"
)
afternoon_greetings=(
	"Well met this fine afternoon"
	"Good day"
	"Greetings"
	"A pleasant afternoon"
	"Brighter than the sun"
)
evening_greetings=(
	"A pleasant eve to thee"
	"Good evening"
	"Greetings"
	"Greetings this lovely evening"
	"Finer than the ether"
)

# Select a random greeting based on the current hour
if [ $current_hour -lt 11 ]; then
    greetings=("${morning_greetings[@]}")
elif [ $current_hour -lt 18 ]; then
    greetings=("${afternoon_greetings[@]}")
else
    # If the hour is 18 or greater (evening)
    greetings=("${evening_greetings[@]}")
fi

# Pick a random greeting from the selected array
greeting=${greetings[RANDOM % ${#greetings[@]}]}

# Print the greeting with the capitalized user's name
echo "$greeting, $capitalized_user"

