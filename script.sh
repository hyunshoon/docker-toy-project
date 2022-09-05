#!/bin/bash

# +--------------------------------------------------------------------------------------------------+
# | git clone project                                                                                |
# +--------------------------------------------------------------------------------------------------+

git_dir="/home/rapa/docker_cluster"
git_repo="https://github.com/hyunshoon/docker-toy-project.git"
git pull $git_repo $git_dir > /dev/null 2>&1
project_name=$(echo $git_repo | cut -d '/' -f5 | cut -d '.' -f1)

i=0
dir_list=()
dir_num=$(ls -l $git_dir | grep "^d" | gawk '{print $9}' | wc -l)
while [ $i -lt $dir_num ]
do
  dir_list+=("$(ls -l $git_dir | grep "^d" | gawk '{print $9}' | sed -n $((i+1))p)")
  i=$((i+1))
done

PS3="Select update service: "
select service in ${dir_list[@]}
do
  dir=$service
  break
done

echo "check point"

index=$(ls ${git_dir}/${dir} | grep "index.html")

if [ "$index" != "index.html" ]
then
  echo "[error]: need index.html"
  rm -rf /remote/project
  exit
fi

# +--------------------------------------------------------------------------------------------------+
# | change dockerhub image                                                                           |
# +--------------------------------------------------------------------------------------------------+
docker build -t ${dir}:test ${git_dir}/${dir}/ > /dev/null 2>&1
docker tag ${dir}:test 211.183.3.103:9999/public-repo/${dir}:test > /dev/null 2 >&1
echo "${dir}:1.5 211.183.3.103:9999/public-repo/${dir}:1.5"
docker push 211.183.3.103:9999/public-repo/${dir}:1.5 > /dev/null 2 >&1


# +--------------------------------------------------------------------------------------------------+
# | stack deploy                                                                                     |
# +--------------------------------------------------------------------------------------------------+

echo "\n==============================="
echo -n "What is service name?"
read service_name


#docker stack rm $network_name
docker stack deploy -c ${git_dir}/${dir}/${service_name}.yml $service_name

# +--------------------------------------------------------------------------------------------------+
# | change project file                                                                              |
# +--------------------------------------------------------------------------------------------------+

#rm -rf /remote/project
