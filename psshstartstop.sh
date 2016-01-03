#!/bin/bash

# a single colon means Option has a single required argument.
# A double colon means option has an optional argument.

usage () { echo "Usage 
		mytest -a [start|stop|copy|zap|chage]  -f [file] -e [prod|staging|london] -u [ user ] ";
		 exit 0; 
	} 

if [ $# -eq 0 ]
then
	echo "Incorrect args"
	usage
fi


while getopts "a::f::e::u:" opt; do
  case $opt in
    a)
      echo "-a was triggered! Parameter : $OPTARG" >&2

	case $OPTARG in
	"start")
		action="start"
		;;
	"stop")
		#echo "stop was called"
		action="stop"

		;;
	"status")
		echo "status was called"
		action="status"
		;;
	"whoami")
		echo "whoami was called."
		action="whoami"
		;;
	"copy")
		echo "copy was called "
		action="copy"
		;;
	"zap")
		echo "zap was called "
		action="zap"
		;;
	"uptime")
		echo "uptime was called"
		action="uptime"
		;;
	"reboot")
		echo "reboot was called"
		action="reboot"
		;;
	"chaged")
		echo "chaged  was called"
		action="chaged"
		;;
	"chagel")
		echo "chagel  was called"
		action="chagel"
		;;



	esac
      ;;

    f)
	echo "File was specified $OPTARG"
	file=$OPTARG
	;;
    e)
	echo "environment was passed in  $OPTARG"
	envi=$OPTARG
	;;
    u)
	echo "user was   $OPTARG"
	user=$OPTARG
	;;

    *)
	echo "No valid arguments was passed "
	usage 
	;;

    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Invalid option: -$OPTARG" 
      ;;
  esac
done

shift $((OPTIND-1))

	echo "*******  action = [$action], file =  [$file], environment =[$envi] , user=[$user]  *********"
	if [ "$envi" == "" ]
	then
		echo "No environment was passed"
	fi
	case $action in
		"start")
			echo "start was called - with file $file"
			if [ -z $file ]
			then
				echo "No file !  Incorrect args "
				usage
			fi
	                ./pssh -h $file -P -A -l cloudanalytics   -t 600  -o /tmp/results_folder nohup IBM/LogAnalysis/utilities/unity.sh -start

		;;
		"stop")
			echo "stop was called - with file $file"
			if [ -z $file ]
			then
				echo "No file !  Incorrect args "
				usage
			fi
	                ./pssh -h $file -P -A -l cloudanalytics  -t 120 -o /tmp/results_folder nohup IBM/LogAnalysis/utilities/unity.sh -stop

		;;

		"copy")
			echo "copy was called with file $file"
			if [ -z $file ]
			then
				echo "No file !  Incorrect args "
				usage
			fi
		        ./pscp -h $file  -A -l cloudadmin unityzap.sh  /tmp/
			;;

		"zap")
			echo "zap was called with file $file"
			if [ -z $file ]
			then
				echo "No file !  Incorrect args "
				usage
			fi
		        ./pssh -h $file  -P  -A -l cloudadmin -x sudo /tmp/unityzap.sh
			;;


		"status")
			if [ -z $file ]
			then
				echo "No file !  Incorrect args "
				usage
			fi
			echo "status was called - with file $file"
	                ./pssh -h $file -P -A -l cloudanalytics  -t 60 -o /tmp/results_folder nohup IBM/LogAnalysis/utilities/unity.sh -status
			;;

		"whoami")
			echo "whoami was called, file = $file ,user = $user"
			if [ "$file" == "" ]
			then
				echo "Please pass in a valid file to process "
				usage
			fi
			if [ "$user" == "" ]
			then
				echo "Please pass in user, i.e cloudadmin, or cloudanalytics"
				usage
			fi
			 
                	./pssh -h $file  -P  -A -l $user  whoami
			;;
		"uptime")
			echo "Uptime was called, user =$user"
			if [ "$user" == "" ]
			then
				echo "Please pass in user, i.e cloudadmin, or cloudanalytics"
				usage
			fi
                	./pssh -h $file  -P  -A -l $user  uptime
			;;
		"reboot")
                	./pssh -h $file  -P  -A -l cloudadmin  sudo reboot 
			;;

		"chagel")
			echo " chagel was called - with file $file"
			# Sashi - note that the cloudanalytics and root - need the sudo access.
			# or else this will fail.
		        #./pssh -h prodhosts.txt  -P  -A -l cloudadmin  chage -l   cloudadmin
			#./pssh -h prodhosts.txt  -P  -A -l cloudadmin  sudo chage -l   cloudanalytics
                	#./pssh -h prodhosts.txt  -P  -A -l cloudadmin  sudo chage -l   root

		        ./pssh -h europehosts.txt  -P  -A -l cloudadmin  chage -l   cloudadmin
			./pssh -h europehosts.txt  -P  -A -l cloudadmin  sudo chage -l   cloudanalytics
                	./pssh -h europehosts.txt  -P  -A -l cloudadmin  sudo chage -l   root

	
			;;
	
		"chaged")
			echo " chaged was called - with file $file"
		            #./pssh -h prodhosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-30" cloudadmin
			    #./pssh -h prodhosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-30" cloudanalytics
                	    #./pssh -h prodhosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-30" root

                #./pssh -h europehosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-25" cloudadmin
                #./pssh -h europehosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-25" cloudanalytics
                #./pssh -h europehosts.txt  -P  -A -l cloudadmin  sudo chage -d   "2015-06-25" root


                ./pssh -h staginghosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-26" cloudadmin
                ./pssh -h staginghosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-26" cloudanalytics
                ./pssh -h staginghosts.txt  -P  -A -l cloudadmin  sudo chage -d  "2015-06-26" root

		;;

		*) 
			echo "Action  [$action] is not supported yet ! Fix it. "
			echo  $action
			usage
	esac

