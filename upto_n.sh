echo -n "Enter the number: "
read n

i=1
while [ $i -le $n ]; do
	echo "$i"
	i=`expr $i + 1`
done
