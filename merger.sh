#!/bin/bash

export namefile=em_ireadmail.csv
export passfile=LDAPdata-3.csv
export fullfile=user.csv

	   join -t "," -1 1 ${namefile} -2 1 ${passfile}|awk -F, '{ print $1","$2","$3","$5 }' > ${fullfile}

more ${fullfile}
