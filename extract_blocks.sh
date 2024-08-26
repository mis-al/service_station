#!/bin/bash

# Как запустить на винде?
# 1) docker container
# https://docs.docker.com/desktop/install/windows-install/
# Увы, не установился, не подходящая OS
# 2) Виртуальная машина
# Установить ubuntu server на виртуалку
# Примаунтить рабочий каталог в ~/work_dir
# Примаунтить каталог со списком блоков в ~/blocks_dir
# Скрипт запускать через SSH или изнутри виртуалки

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
block_codes=$(grep "Код диагностики\|Diagnosis identifier"  $txt_file | tr -s ' ' | cut -d' ' -f 6)

ok='\033[32mOK\033[0m'
fail='\033[31mFAIL\033[m'
echo
echo "Searching $(echo $block_codes | tr ' ' "\n" | wc -l) appropriate block files..."
for block_code in $block_codes; do
  #sleep 0.05
  echo -n "$block_code - "
  pattern1=$BLOCKS_DIR/$block_code.???-?
  if [ -f $pattern1 ]; then
    echo -e "$ok - $pattern1"
    cp $pattern1 $project_dir
  else
    pattern2=$BLOCKS_DIR/$(echo $block_code| cut -d'_' -f 1,2).???-?
    if [ -f $pattern2 ]; then
      echo -e "$ok - $pattern2"
      cp $pattern2 $project_dir
    else
      pattern3=$BLOCKS_DIR/$(echo $block_code| cut -d'_' -f 1).???-?
      if [ -f $pattern3 ]; then
        echo -e "$ok - $pattern3"
        cp $pattern3 $project_dir
      else
        echo -e $fail
        echo $block_code >> $lost_blocks_file
        echo $pattern1 >> $lost_blocks_file
        echo $pattern2 >> $lost_blocks_file
        echo $pattern3 >> $lost_blocks_file
      fi
    fi
  fi
done

# Создать архив на вых