#!/bin/bash
WHERE=$(dirname "$0")
if [ $# -lt 6 ]; then
	echo Usage: $(basename "$0") '<filename.elf> <num of instructions> <num of injections> <reg to eval 1> <reg to eval 2> <Mod: 0-One Reg, 1-Random, 2-All reg> [Reg to inject (0 to 15)]' >&2
	exit 1
fi

elf="$1"
shift
inst=$1
shift
inj="$1"
shift
reg_resul="$1"
shift
reg_resul2="$1"
shift
Mod="$1"
shift
if [ -n "$1" ]; then
	Reg="$1"
	shift	
	
else
    Reg=5
fi



ramdir=/dev/shm/tempo
mkdir $ramdir
arg0="sim"
arg1="prog  $elf"

echo $inst
#Golden execution
arg2="step  $inst"
mspdebug $arg0 "$arg1" "$arg2"|sed -e 's/(//g'|sed -e 's/)//g' > $ramdir/Reg_gold.txt
tmp1=$(grep -n "Done," $ramdir/Reg_gold.txt|cut -f1 -d":")
sed -i "1,$tmp1"d $ramdir/Reg_gold.txt
sed -i '5,$d' $ramdir/Reg_gold.txt

awk '$1=="PC:" {printf $2"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG0.txt
 awk '$1=="SP:" {printf $2"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG1.txt
 awk '$1=="SR:" {printf $2"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG2.txt
 awk '$1=="R3:" {printf $2"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG3.txt
 
 awk '$3=="R4:" {printf $4"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG4.txt
 awk '$3=="R5:" {printf $4"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG5.txt
 awk '$3=="R6:" {printf $4"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG6.txt
 awk '$3=="R7:" {printf $4"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG7.txt

 awk '$5=="R8:" {printf $6"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG8.txt
 awk '$5=="R9:" {printf $6"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG9.txt
 awk '$5=="R10:" {printf $6"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG10.txt
 awk '$5=="R11:" {printf $6"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG11.txt

 awk '$7=="R12:" {printf $8"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG12.txt
 awk '$7=="R13:" {printf $8"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG13.txt
 awk '$7=="R14:" {printf $8"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG14.txt
 awk '$7=="R15:" {printf $8"\n" }' $ramdir/Reg_gold.txt > $ramdir/RG15.txt

 RG0=$(cat $ramdir/RG0.txt)
 RGtest="$(cat $ramdir/'RG'$reg_resul.txt)"
 RGtest2="$(cat $ramdir/'RG'$reg_resul2.txt)"
 
 # F0=unACE F1=SDC F2=Hang
 let Ft0=0
 let Ft1=0
 let Ft2=0
 i=0
 while [ $i -lt 16 ]; do
    j=0
    while [ $j -lt 3 ]; do
      let 'R'$i'_F'$j=0
        let j=j+1
    done
    let i=i+1
done


case $reg_resul in
    0)
       RT=PC:
       campt=2
       ;;
    1)
       RT=SP:
       campt=2
       ;;
    2)
       RT=SR:
       campt=2
       ;;
    3)
        RT=R3:
        campt=2
        ;;
    4)
       RT=R4:
       campt=3
       ;;
    5)
       RT=R5:
       campt=3
       ;;
    6)
       RT=R6:
       campt=3
       ;;
    7)
        RT=R7:
        campt=3
        ;;
    8)
       RT=R8:
       campt=4
       ;;
    9)
       RT=R9:
       campt=4
       ;;
    10)
       RT=R10:
       campt=4
       ;;
    11)
        RT=R11:
        campt=4
        ;;
    12)
       RT=R12:
       campt=5
       ;;
    13)
       RT=R13:
       campt=5
       ;;
    14)
       RT=R14:
       campt=5
       ;;
    15)
        RT=R15:
        campt=5
        ;;
    esac

case $reg_resul2 in
    0)
       RT2=PC:
       campt2=2
       ;;
    1)
       RT2=SP:
       campt2=2
       ;;
    2)
       RT2=SR:
       campt2=2
       ;;
    3)
        RT2=R3:
        campt2=2
        ;;
    4)
       RT2=R4:
       campt2=3
       ;;
    5)
       RT2=R5:
       campt2=3
       ;;
    6)
       RT2=R6:
       campt2=3
       ;;
    7)
        RT2=R7:
        campt2=3
        ;;
    8)
       RT2=R8:
       campt2=4
       ;;
    9)
       RT2=R9:
       campt2=4
       ;;
    10)
       RT2=R10:
       campt2=4
       ;;
    11)
        RT2=R11:
        campt2=4
        ;;
    12)
       RT2=R12:
       campt2=5
       ;;
    13)
       RT2=R13:
       campt2=5
       ;;
    14)
       RT2=R14:
       campt2=5
       ;;
    15)
        RT2=R15:
        campt2=5
        ;;
    esac
    
        
Tini=$(date +%s)    
echo "Start of injections"
echo "Injections in progress..."

if [ $Mod -gt 1 ]; then
    Rin=0
    echo "All Reg campaing"
else
    Rin=15
fi

while [ $Rin -le 15 ]; do
     if [ $Mod -gt 1 ]; then
         Reg=$Rin
     fi

    i=0
    while [ $i -lt $inj ]; do

     #Se obtiene una instrucción al azar y el numero de instr para finalizar programa
     inst_inj=$(( $RANDOM % $inst ))
     inst_fini=$(( $inst - $inst_inj + 3 ))
#     echo "------------------------------------Injection:"$i"-------------------------------------"
#     echo "Injection in instruction:"$inst_inj

    #Se elige registro al azar
      if [ $Mod -eq 1 ]; then
         Reg=$(( $RANDOM % 16 ))
     fi
    
#       echo "Register to inject:" $Reg
     #Se elige bit al azar  
    nb=$(( $RANDOM % 15))
    masc=$((1 << $nb))
#    echo "Bit flip:" $nb
    case $Reg in
    0)
       R=PC:
       camp=2
       ;;
    1)
       R=SP:
       camp=2
       ;;
    2)
       R=SR:
       camp=2
       ;;
    3)
        R=R3:
        camp=2
        ;;
    4)
       R=R4:
       camp=3
       ;;
    5)
       R=R5:
       camp=3
       ;;
    6)
       R=R6:
       camp=3
       ;;
    7)
        R=R7:
        camp=3
        ;;
    8)
       R=R8:
       camp=4
       ;;
    9)
       R=R9:
       camp=4
       ;;
    10)
       R=R10:
       camp=4
       ;;
    11)
        R=R11:
        camp=4
        ;;
    12)
       R=R12:
       camp=5
       ;;
    13)
       R=R13:
       camp=5
       ;;
    14)
       R=R14:
       camp=5
       ;;
    15)
        R=R15:
        camp=5
        ;;
    esac
     
     #Se obtiene el valor del registro en la instrucción a inyectar
    arg2="step  $inst_inj"
   Reg_nin=$( mspdebug $arg0 "$arg1" "$arg2"|sed -e 's/(//g'|sed -e 's/)//g'|grep $R|cut -f$camp -d":"|cut -f2 -d" ")
   val_reg_nin="0x$Reg_nin"
   val_reg_in=$(( val_reg_nin^$masc )) # Se cambia el valor del regsitro
   arg3="set $Reg $val_reg_in"
   arg4="step $inst_fini"
   mspdebug $arg0 "$arg1" "$arg2" "$arg3" "$arg4" > $ramdir/regs.txt 2> $ramdir/error.txt
   hang=$(cat /dev/shm/tempo/error.txt |cut -f1 -d":")
   
   if [ "$hang" == "sim" ]; then
        let 'R'$Reg'_F2'='R'$Reg'_F2'+1
        let Ft2=Ft2+1
 #       echo "hang1----"
    else
        tmp=$(grep -n "R3:" $ramdir/regs.txt |cut -f1 -d":"|sed '1d'|sed '$d')
        sed -i "1,$tmp"d $ramdir/regs.txt
        Last_PC=$(cat $ramdir/regs.txt|sed -e 's/(//g'|sed -e 's/)//g'|grep PC:|cut -f2 -d":"|cut -f2 -d" ")
        
        if [ "$Last_PC" != "$RG0" ]; then
            let 'R'$Reg'_F2'='R'$Reg'_F2'+1
            let Ft2=Ft2+1
  #          echo "hang2----"
        else
            Rtest=$(cat $ramdir/regs.txt|sed -e 's/(//g'|sed -e 's/)//g'|grep $RT|cut -f$campt -d":"|cut -f2 -d" ")
            Rtest2=$(cat $ramdir/regs.txt|sed -e 's/(//g'|sed -e 's/)//g'|grep $RT2|cut -f$campt2 -d":"|cut -f2 -d" ")
            if [ "$Rtest" != "$RGtest" ]; then
                let 'R'$Reg'_F1'='R'$Reg'_F1'+1
                let Ft1=Ft1+1
 #               echo "SDC----"
            elif [ "$Rtest2" != "$RGtest2" ]; then
                let 'R'$Reg'_F1'='R'$Reg'_F1'+1
                let Ft1=Ft1+1
                
            else
                let 'R'$Reg'_F0'='R'$Reg'_F0'+1
                let Ft0=Ft0+1
  #              echo "unACE----"
            fi
        
        fi
       
       
       
       #sed -i '5,$d' $ramdir/regs.txt
    fi
    
#     echo "-------------------------------End injection----------------------------------------"

  let i=i+1
  done
    let 'Perc_R'$Reg'_F0'='R'$Reg'_F0'*100/$inj
    let 'Perc_R'$Reg'_F1'='R'$Reg'_F1'*100/$inj
    let 'Perc_R'$Reg'_F2'='R'$Reg'_F2'*100/$inj
  
let Rin=Rin+1
done

Tend=$(date +%s)
let Ttot=$Tend-$Tini
echo "Time in seg:"
echo $Ttot
  
  printf "Reg\t|unACE\t\tSDC\t\tHang\t\t|Tot\n" > "$ramdir/Result.txt"
     echo "---------------------------------------------------------------" >> "$ramdir/Result.txt"
     let i=0
     while [ $i -lt 16 ]; do
        let un='R'$i'_F0'
        let sd='R'$i'_F1'
        let ha='R'$i'_F2'
        let tot=un+sd+ha
        printf "%d \t|%d\t\t%d\t\t%d\t\t|%d\n" "$i" "$un" "$sd" "$ha" "$tot">> "$ramdir/Result.txt"
     
        let i=i+1
     done
     echo "---------------------------------------------------------------" >> "$ramdir/Result.txt"
     let tot=Ft0+Ft1+Ft2
     printf "Tot\t|%d\t\t%d\t\t%d\t\t|%d\n" "$Ft0" "$Ft1" "$Ft2" "$tot">> "$ramdir/Result.txt"
     cat $ramdir/Result.txt
     
     printf "Reg\tunACE\t\tSDC\t\tHang\t\tTot\n" > "$ramdir/Result.dat"
     let i=0
     while [ $i -lt 16 ]; do
        let un='R'$i'_F0'
        let sd='R'$i'_F1'
        let ha='R'$i'_F2'
        let tot=un+sd+ha
        printf "%d \t%d\t\t%d\t\t%d\t\t%d\n" "$i" "$un" "$sd" "$ha" "$tot">> "$ramdir/Result.dat"     
        let i=i+1
     done
     cp $ramdir/Result.dat .
     cp $ramdir/Result.txt .
     
        
    rm -r $ramdir
    echo " "
     
   #  printf "5 \t|%d\t\t%d\t\t%d\n" "$R5_F0" "$R5_F1" "$R5_F2" >> "$ramdir/Result.txt"
   # printf "%d" "$Ft0" > "$ramdir/unACE.txt"
   # echo $Ft1
   # echo $Ft2
