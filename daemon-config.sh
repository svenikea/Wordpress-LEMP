#! /bin/bash 

if [ "$TRAVIS" == "true" ]; 
then # For Travis
  mkdir /tmp/docker
  sudo systemctl stop docker
  echo '{"cgroup-parent":"/actions_job","storage-driver":"vfs", "debug": true}' | sudo tee /etc/docker/daemon.json
  sudo systemctl start docker
else # For Github ACtion 
  mkdir /tmp/docker
  sudo systemctl stop docker
  echo '{"cgroup-parent":"/actions_job","storage-driver":"vfs", "debug": true}' | sudo tee /etc/docker/daemon.json
  sudo systemctl start docker
fi
