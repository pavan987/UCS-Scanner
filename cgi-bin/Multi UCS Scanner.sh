#!/bin/bash
echo "Content-type: text/plain\n"
#echo "Transfer-Encoding: chunked"
echo ""

 if [ "$REQUEST_METHOD" != "GET" ]; then
        echo "<hr>Script Error:"\
             "<br>Usage error, cannot complete request, REQUEST_METHOD!=GET."\
             "<br>Check your FORM declaration and be sure to use METHOD=\"GET\".<hr>"
        exit 1
  fi
 
  # If no search arguments, exit gracefully now.
  if [ -z "$QUERY_STRING" ]; then
        exit 0
  else
     # No looping this time, just extract the data you are looking for with sed:
     mode=`echo "$QUERY_STRING" | sed -n 's/^.*Mode=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

if [ $mode -eq 1 ] ; then

     network=`echo "$QUERY_STRING" | sed -n 's/^.*val_x=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
     subnet=`echo "$QUERY_STRING" | sed -n 's/^.*val_y=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
alldetail=`/usr/local/bin/sipcalc $network $subnet`
#endip=`echo $alldetail | sed -n 's/.*Usable range.*-.*- \(.*\) -$/\1/p'`
startip=`echo $alldetail | sed -n 's/.*Usable range.*- \(.*\) -.*-$/\1/p'`
#startip="10.106.22.48"
#size="20"
size=`echo $alldetail | sed -n 's/.*Addresses in network *- \([0-9]*\).*$/\1/p'`
echo "Please Wait ... Scanning in Progress"
a=`echo $startip | sed -n 's/\([0-9]*\)\.[0-9]*\.[0-9]*\.[0-9]*/\1/p'`
b=`echo $startip | sed -n 's/[0-9]*\.\([0-9]*\)\.[0-9]*\.[0-9]*/\1/p'`
c=`echo $startip | sed -n 's/[0-9]*\.[0-9]*\.\([0-9]*\)\.[0-9]*/\1/p'`
d=`echo $startip | sed -n 's/[0-9]*\.[0-9]*\.[0-9]*\.\([0-9]*\)/\1/p'`

for (( i=0; i<=$size-2; i++ ))
do

cmd="$a.$b.$c.$d"
output=`/usr/bin/curl -k --compressed https://$cmd`

search="ucsm/ucsm.jnlp"
search1="images/kvm_styles.css"
search2="Cisco Integrated Management Controller Login"
search3="Multi_UCS"
result=`echo $output | grep -c "$search"`
result1=`echo $output | grep -c "$search1"`
result2=`echo $output | grep -c "$search2"`
result3=`echo $output | grep -c "$search3"`

if [ $result == 1 ] ; then
echo "$cmd -> UCS Manager (Cluster/FI) "
elif [ $result1 == 1 ] ; then
echo "$cmd -> UCS Managed CIMC "
elif [ $result2 == 1 ] ; then
echo "$cmd -> UCS Standalone Rack"
elif [ $result3 -gt 0 ] ; then
echo "$cmd -> UCS Central"
else
echo "$cmd -> Unknown"
#else
#echo "$cmd not working"
fi

d=$[$[$d+1] % 256]
if [ "$d" == "0" ]; then
	c=$[$[$c+1] % 256]	
if [ "$c" == "0" ]; then
        b=$[$[$b+1] % 256]
if [ "$b" == "0" ]; then
        a=$[$[$a+1] % 256]
fi
fi
fi

done

elif [ $mode -eq 2 ] ; then

     startip=`echo "$QUERY_STRING" | sed -n 's/^.*val_a=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
     size=`echo "$QUERY_STRING" | sed -n 's/^.*val_b=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
echo "Please Wait ... Scanning in Progress"
a=`echo $startip | sed -n 's/\([0-9]*\)\.[0-9]*\.[0-9]*\.[0-9]*/\1/p'`
b=`echo $startip | sed -n 's/[0-9]*\.\([0-9]*\)\.[0-9]*\.[0-9]*/\1/p'`
c=`echo $startip | sed -n 's/[0-9]*\.[0-9]*\.\([0-9]*\)\.[0-9]*/\1/p'`
d=`echo $startip | sed -n 's/[0-9]*\.[0-9]*\.[0-9]*\.\([0-9]*\)/\1/p'`

for (( i=0; i<$size; i++ ))
do

cmd="$a.$b.$c.$d"
output=`/usr/bin/curl -k --compressed https://$cmd`

search="ucsm/ucsm.jnlp"
search1="images/kvm_styles.css"
search2="Cisco Integrated Management Controller Login"
search3="Multi_UCS"
result=`echo $output | grep -c "$search"`
result1=`echo $output | grep -c "$search1"`
result2=`echo $output | grep -c "$search2"`
result3=`echo $output | grep -c "$search3"`

if [ $result == 1 ] ; then
echo "$cmd -> UCS Manager (Cluster/FI) "
elif [ $result1 == 1 ] ; then
echo "$cmd -> UCS Managed CIMC "
elif [ $result2 == 1 ] ; then
echo "$cmd -> UCS Standalone Rack"
elif [ $result3 -gt 0 ] ; then
echo "$cmd -> UCS Central"
else
echo "$cmd -> Unknown"
#else
#echo "$cmd not working"
fi

d=$[$[$d+1] % 256]
if [ "$d" == "0" ]; then
	c=$[$[$c+1] % 256]	
if [ "$c" == "0" ]; then
        b=$[$[$b+1] % 256]
if [ "$b" == "0" ]; then
        a=$[$[$a+1] % 256]
fi
fi
fi

done


fi

fi
