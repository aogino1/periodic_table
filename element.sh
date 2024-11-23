#!/bin/bash


if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 
fi


# Store the user argument
user_input=$1

# Database connection details
DB_NAME="periodic_table"
DB_USER="freecodecamp"


# SQL Query
query="
SELECT e.symbol, e.name, e.atomic_number, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE e.symbol = '$user_input'
   OR e.name = '$user_input'
   OR e.atomic_number = CAST(NULLIF('$user_input' ~ '^[0-9]+$', FALSE) AS INTEGER);;
"

# Execute the query
result=$(psql -U "$DB_USER" -d "$DB_NAME" -t --no-align -c "$query")

# Check if the result is empty or not
if [ -z "$result" ]; then
  echo "I could not find that element in the database."
else
  # Parse the result (assuming tab-separated columns from psql)
  while IFS=$'\|' read -r symbol name atomic_number type atomic_mass melting_point_celsius boiling_point_celsius; do
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
  done <<< "$result"
fi

# test