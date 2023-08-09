#!/usr/bin/env bash

week_day=$(date +%w)
week_day=$(( week_day + 7 ))
to_monday=$(( week_day - 1 ))
format='%m.%d'
monday=$(date -v -"${to_monday}"d +$format)
to_friday=$(( week_day - 5 ))
friday=$(date -v -"${to_friday}"d +$format)
for i in $(seq 1 2); do
  file_name=${monday}"-"${friday}
  file=${file_name}".md"
  if [ ! -f "$file" ]; then
    touch "$file"
    {
      echo "# ${file_name}"
      echo -e "\n## 本周工作"
      echo -e "\n\n## 下周重点"
    } >> "$file"
  fi
  monday=$(date -j -f $format -v+7d "${monday}" +$format)
  friday=$(date -j -f $format -v+7d "${friday}" +$format)
done   

