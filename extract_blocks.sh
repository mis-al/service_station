#!/bin/bash

# Задача решена на линуксе, надо подумать как скрипт запустить на винде. Возможно через docker
# https://docs.docker.com/desktop/install/windows-install/

WORK_DIR=~/work_dir
BLOCKS_DIR=~/blocks_dir

project_dir_name=$1
if [ -z $project_dir_name ]; then
    echo 'Plese, specify project name'
    echo "$0 <project_name>"
    exit
fi

project_dir=$WORK_DIR/$project_dir_name
if [ -d $project_dir ]; then
  echo 'Project directory exists'
else
  echo 'Please, create $project_dir and put pfd file inside'
fi

pdf_file=$project_dir/*.pdf
if [ -f $pdf_file ]; then
  echo 'PDF file detected'
else
  echo 'Please, put pfd file inside the project dir'
fi

txt_file=$project_dir/$(basename $pdf_file).txt
lost_blocks_file=$project_dir/lost_blocks.txt

echo "Settings"
echo $WORK_DIR
echo $BLOCKS_DIR
echo $project_dir
echo $pdf_file
echo $txt_file
echo $lost_blocks_file
> $lost_blocks_file

echo 'Converting pdf file...'
type pdftotext
exist_status=$?
if [ $exist_status -ne 0 ]; then
  echo "Error. Let's install poppler-utils"
  sudo apt install poppler-utils -y
fi
pdftotext -layout $pdf_file $txt_file

echo 'Extracting blocks from the file...'
block_codes=$(grep 'Код диагностики'  $txt_file | tr -s ' ' | cut -d' ' -f 6)

echo 'Searching appropriate block file...'
for i in $block_codes; do
  sleep 0.05
  pattern1=$BLOCKS_DIR/$i.smr-d
  if [ -f $pattern1 ]; then
    echo "File $pattern1 exists."
    cp pattern1 $project_dir
  else
    echo "File $pattern1 does not exist."
    pattern2=$BLOCKS_DIR/$(echo $i| cut -d'_' -f 1,2).smr-d
    if [ -f $pattern2 ]; then
      echo "File $pattern2 exists."
      #cp pattern2 $project_dir
    else
      echo "File $pattern2 does not exist."
      pattern3=$BLOCKS_DIR/$(echo $i| cut -d'_' -f 1).smr-d
      if [ -f $pattern3 ]; then
        echo "File $pattern3 exists."
        #cp pattern3 $project_dir
      else
        echo "File $pattern3 does not exist."
        echo $i >> $lost_blocks_file
        echo $pattern1 >> $lost_blocks_file
        echo $pattern2 >> $lost_blocks_file
        echo $pattern3 >> $lost_blocks_file
      fi
    fi
  fi
done