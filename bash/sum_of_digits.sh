echo -n "Enter the number: "
read num

sum=0
while [ $num -ne 0 ]; do
	r=`expr $num % 10`
	sum=`expr $sum + $r`
	num=`expr $num / 10`
done

echo "Sum: $sum"
