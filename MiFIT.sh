#!/bin/sh
WHERE=$(dirname "$0")
 if [ -z $DISPLAY ]
  then
    DIALOG=dialog
 else
   DIALOG=dialog
 fi
 $DIALOG --title "MiFIT" --textbox $WHERE/intro.txt 10 70
 
 

FILE=`$DIALOG --stdout --backtitle "Program to test" --title "Please choose a file" --fselect $WHERE/ 18 48`

case $? in
	0)
		;;
	1)
		echo "Cancel pressed."
		exit 0
		;;
	255)
        
		echo "Box closed."
		exit 0;;
esac

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

$DIALOG --title "Instructions" --backtitle "Total instructions" --clear \
        --inputbox "Enter the total number of instructions per execution" 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    num_inst=$(cat $tempfile)
    ;;
  1)
    echo "Cancel pressed."
    exit 0
    ;;
  255)
    if test -s $tempfile ; then
      num_inst=$(cat $tempfile)
    else
      echo "ESC pressed."
      exit 0
    fi
    ;;
esac


$DIALOG --title "Injections" --backtitle "Number of injections" --clear \
        --inputbox "Enter the number of injections" 16 51 2> $tempfile
retval=$?
case $retval in
  0)
    num_injec=$(cat $tempfile)
    ;;
  1)
    echo "Cancel pressed."
    exit 0
    ;;
  255)
    if test -s $tempfile ; then
      num_injec=$(cat $tempfile)
    else
      echo "ESC pressed."
      exit 0
    fi
    ;;
esac

 $DIALOG --clear --title "Campaing mode" --backtitle "Campaing mode" \
        --menu "Choose the mode:" 20 51 4 \
        0 "One register" \
        1 "Ramdon register"  \
        2 "All register" 2> $tempfile

retval=$?

case $retval in
  0)
    mod=$(cat $tempfile);;
  1)
    echo "Cancel pressed."
    exit 0
    ;;
  255)
    echo "ESC pressed."
    exit 0
    ;;
esac

selreg() { 
    $DIALOG  --radiolist "$1" 0 0 0 0 "PC" off 1 "SP" off 2 "SR" off 3 "R3" off 4 "R4" off\
    5 "R5" on 6 "R6" off 7 "R7" off 8 "R8" off 9 "R9" off 10 "R10" off 11 "R11" off 12 "R12" off\
    13 "R13" off 14 "R14" off 15 "R15" off
    
    }

if [ "$mod" = "0" ]; then    
    selreg "Choose Register" 2> $tempfile
    retval=$?
    case $retval in
    0)
        Reg=$(cat $tempfile);;
    1)
        echo "Cancel pressed."
        exit 0
        ;;
    255)
        echo "ESC pressed."
        exit 0
        ;;
    esac
fi

$DIALOG --clear --title "Results" \
        --menu "Choose where the results are:" 20 51 4 \
        0 "In one register" 1 "In two registers"\
        2 "In RAM"  2> $tempfile

retval=$?
case $retval in
  0)
    res=$(cat $tempfile);;
  1)
    echo "Cancel pressed."
    exit 0
    ;;
  255)
    echo "ESC pressed."
    exit 0
    ;;
esac

case $res in
    0)
        selreg "Choose register" 2> $tempfile
        retval=$?
        case $retval in
        0)
            Reg_res1=$(cat $tempfile)
            Reg_res2=$Reg_res1
            ;;
        1)
            echo "Cancel pressed."
            exit 0
            ;;
        255)
            echo "ESC pressed."
            exit 0
            ;;
        esac
        ;;
    1)
        selreg "Choose register one" 2> $tempfile
        retval=$?
        case $retval in
        0)
            Reg_res1=$(cat $tempfile)
            ;;
        1)
            echo "Cancel pressed."
            exit 0
            ;;
        255)
            echo "ESC pressed."
            exit 0
            ;;
        esac
        selreg "Choose register two" 2> $tempfile
        retval=$?
        case $retval in
        0)
            Reg_res2=$(cat $tempfile)
            ;;
        1)
            echo "Cancel pressed."
            exit 0
            ;;
        255)
            echo "ESC pressed."
            exit 0
            ;;
        esac
        ;;
    2)
        selreg "Choose register with memory address" 2> $tempfile
        retval=$?
        case $retval in
        0)
            Reg_dirmem=$(cat $tempfile)
            ;;
        1)
            echo "Cancel pressed."
            exit 0
            ;;
        255)
            echo "ESC pressed."
            exit 0
            ;;
        esac
        
        $DIALOG --title "Size" --backtitle "Size in memory" --clear \
        --inputbox "Enter the size in Bytes" 16 51 2> $tempfile
        retval=$?
        case $retval in
           0)
                size=$(cat $tempfile)
            ;;
           1)
            echo "Cancel pressed."
            exit 0
            ;;
        255)
            if test -s $tempfile ; then
                size=$(cat $tempfile)
            else
                echo "ESC pressed."
                exit 0
            fi
        ;;
        esac
        
        ;;
esac
  
clear
 
$DIALOG --title "Graph results" --backtitle "Graph results" \
--yesno "Do you want to graph the results?" 7 60
response=$? 
clear
if [ "$res" = "2" ]; then
    bash $WHERE/MSPFITmem.sh $FILE $num_inst $num_injec $Reg_dirmem $size $mod $Reg
else   
    bash $WHERE/MSPFIT.sh $FILE $num_inst $num_injec $Reg_res1 $Reg_res2 $mod $Reg
fi
gnuplot $WHERE/graph


case $response in
   0) convert -colorspace sRGB -density 300 output.eps -background white -flatten -resize 1024x1024  output.png
    fim output.png
    rm output.png
   ;;
   1) echo " ";;
   255) echo "[ESC] key pressed.";;
esac


#  read -p "Graph results? " -n 1 -r
# 
#     if [[  $REPLY =~ ^[Yy]$ ]]
#     then
#         convert -colorspace sRGB -density 300 output.eps -background white -flatten -resize 1024x1024  output.png
#        # feh output.png&
#        fim output.png
#     fi
echo " "

# echo $FILE
# echo $num_inst
# echo $num_injec
# echo $mod
# echo $Reg
# echo $res
# echo $Reg_res1
# echo $Reg_res2
# echo $Reg_dirmem
# echo $size
