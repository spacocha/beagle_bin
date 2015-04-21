#! /bin/tcsh


foreach f (*.f0.mat)
 echo $f
 cat $f | grep "$1"
 cat $f | grep "$2"
end
