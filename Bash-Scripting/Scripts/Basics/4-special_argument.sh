name=$1

user=$(whoami)
date=$(date)
whereami=$(pwd)

echo "Hello $name"

echo "You are currently logged in as $user.You are in the $whereami and the time is $date"

