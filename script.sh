#!/bin/bash

# +--------------------------------------------------------------------------------------------------+
# | git clone project                                                                                |
# +--------------------------------------------------------------------------------------------------+
git clone $1 /remote/project > /dev/null 2>&1
project_name=$(echo $1 | cut -d '/' -f5 | cut -d '.' -f1)

i=0
dir_list=()
dir_num=$(ls -l /remote/project | grep "^d" | gawk '{print $9}' | wc -l)
while [ $i -lt $dir_num ]
do
  dir_list+=("$(ls -l /remote/project | grep "^d" | gawk '{print $9}' | sed -n $((i+1))p)")
  i=$((i+1))
done

PS3="Select dir: "
select chose in ${dir_list[@]}
do
  dir=$chose
  break
done

index=$(ls /remote/project/${dir} | grep "index.html")

if [ "$index" != "index.html" ]
then
  echo "[error]: need index.html"
  rm -rf /remote/project
  exit
fi

# +--------------------------------------------------------------------------------------------------+
# | change dockerhub image                                                                           |
# +--------------------------------------------------------------------------------------------------+
#docker build -t ${project_name}:${dir} -f /remote/project/Dockerfile > /dev/null 2>&1
#docker tag ${project_name}:${dir} modo000127/${project_name}:${dir} > /dev/null 2 >&1
#docker push modo000127/${project_name}:${dir} > /dev/null 2>&1

docker build -f /remote/Project/Dockerfile -t test:manager . > /dev/null 2>&1
docker tag test:manager modo000127/test:manager # > /dev/null 2 >&1
docker push modo000127/test:manager #> /dev/null 2>&1

# +--------------------------------------------------------------------------------------------------+
# | stack deploy                                                                                     |
# +--------------------------------------------------------------------------------------------------+

while :
do
  echo "\n==============================="
  echo -n " network?"
  read network_name

  check_network=$(docker network ls -f NAME=${network_name} | tail -1 | gawk '{print $2}')
  if [ "${check_network}" == "${network_name}" ]
  then
    break
  fi
done

#docker stack rm $network_name
docker stack deploy -c /remote/project/${dir}/${network_name}.yml $network_name

# +--------------------------------------------------------------------------------------------------+
# | change project file                                                                              |
# +--------------------------------------------------------------------------------------------------+

#rm -rf /remote/project
