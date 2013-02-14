#!/bin/sh

# script configuration
POLL_INTERVAL=5                         # number of seconds to wait between to cycles

BROADCAST_IP="192.168.1.255"            # Broadcast IP address of the network
NAS_IP="192.168.1.101"                  # IP address of the NAS to wake
NAS_MAC="6C:62:6D:79:CA:D0"             # MAC address of the NAS to wake
WOL_PORT="9"                            # Usually 7 or 9

# IP addresses of the devices to be polled, separated by a space character)
# (Attention: IP addresses shall be static!)
# The script will ensure that the NAS is awake, whenever one of the
# devices having the latter IP addresses is online
# PC2, PC3 WLAN, PC3 LAN
CHECK_ONLINE="1"
IP_ADDRS="192.168.1.102 192.168.1.103 192.168.1.104"

# Time of the day at which the NAS shall always by awake
# (even if none of the above mentionned devices are online)
# This may be required in order to ensure that the NAS performs
# some administrative tasks (e.g. backup)
# format: "hh:mm"
CHECK_WAKE_TIME="1"
WAKE_TIME="11:50"

# Curfew:
# Time of the day at which the NAS shall never be waken up
# (even if some of the above mentionned devices are online)
CHECK_CURFEW_ACTIVE="1"
BEG_POLL_CURFEW="22:00"
END_POLL_CURFEW="7:00"

# Used utilities
DATE="/bin/date"
PING="/bin/ping"
WOL="/usr/sbin/wol"

# Constants
NB_SEC_IN_DAY="86400"

# Initialization of variables
next_wake_timestamp=`$DATE -d "2030-01-01 00:00" +%s`



##################################
# Returns true if the current time is within the timeslot
# provided as parameter.
#
# Param 1: Start of the timeslot (format: "hh:mm")
# Param 2: End of the timeslot (format: "hh:mm"). If End=Beg, 
#	   the timeslot is considered to last the whole day.
# Return: 0 if the current time is within the timeslot 
################################## 
isInTimeSlot() {

	local startTime
	local endTime
        startTime="$1"
        endTime="$2"

	local nbSecInDay
	nbSecInDay="86400"

	local currentTimestamp
	local startTimestamp
	local endTimestamp

	currentTimestamp=`$DATE +"%s"`
	#startTimestamp=`$DATE -j -f "%H:%M:%S" "$startTime:00" +"%s"`
	#endTimestamp=`$DATE -j -f "%H:%M:%S" "$endTime:00" +"%s"`

	startTimestamp=`$DATE -d "$startTime:00" +"%s"`
	endTimestamp=`$DATE -d "$endTime:00" +"%s"`

	if [ "$endTimestamp" -le "$startTimestamp" ]; then
		if [ "$currentTimestamp" -gt "$startTimestamp" ]; then
			endTimestamp=`expr $endTimestamp + $nbSecInDay`
		else
			startTimestamp=`expr $startTimestamp - $nbSecInDay`
		fi
	fi

	echo "`$DATE +"%H:%M:%S` is not in timeslot [ $startTime , $endTime ]"

	if [ "$currentTimestamp" -gt "$startTimestamp" -a "$currentTimestamp" -le "$endTimestamp" ]; then
		return 0
	else
		return 1
	fi
}



while true
do

        # Wait until next poll
        sleep $POLL_INTERVAL

	echo "---------------------"

        # Check if the NAS is already awake
        if ping -c 1 -t 1 $NAS_IP > /dev/null; then
                echo "NAS is already ONLINE"
                continue
        else
                echo "NAS is OFFLINE"
        fi

        # Initialize variable stating if NAS shall be waken
        wake_nas="0"

        # Check if any device requiring the NAS to be awake is online

	# Only wake NAS if we are not within the curfew timeslot        
	isInTimeSlot "$BEG_POLL_CURFEW" "$END_POLL_CURFEW"
	inTimeSlot=$?
	if [ $CHECK_CURFEW_ACTIVE -eq "0" -o $inTimeSlot -eq "1" ]; then
		if [ $CHECK_ONLINE -eq "1" ]; then
        	       	for ip_addr in $IP_ADDRS; do
                	       	if $PING -c 1 -t 1 $ip_addr > /dev/null ; then
                        	       	wake_nas="1"
                                	echo "Online device detected: $ip_addr"
	       	                        break # Checking the other devices skipped to save time
	               	        fi
        	        done
       		fi
	else
		echo "Within curfew timeslot"
       	fi

        # Check if it is time to wake NAS
	if [ $CHECK_WAKE_TIME -eq "1" ]; then
		# Record current time
        	current_timestamp=`$DATE +%s`

                # Check if wake time is reached
       	        if [ $next_wake_timestamp -le $current_timestamp ]; then
               	        wake_nas="1"
                       	echo "Time to wake up !!!"
                fi

                # Compute next wake timestamp
       	        next_wake_timestamp=`$DATE -d "$WAKE_TIME" +%s`
               	# If the next wake time is tomorrow
                if [ $next_wake_timestamp -le $current_timestamp ]; then
       	                next_wake_timestamp=`expr $next_wake_timestamp + $NB_SEC_IN_DAY`
                fi
       	fi

        # Wake NAS if required
        if [ "$wake_nas" -eq "1" ]; then
                echo "Waking NAS"
                $WOL -i $BROADCAST_IP -p $WOL_PORT $NAS_MAC
        else
                echo "No need to wake NAS"
        fi
done

####################################################################
# Change Notes:
#
# 2012-12-07:
#	- Script creation
# 2012-12-08:
#     - Do not poll the following devices if one is online
# 2012-12-10:
#	- Do not wake NAS during curfew
####################################################################