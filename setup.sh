#! /bin/bash

# reference 1 (docker volume): https://docs.docker.com/engine/reference/commandline/volume_create/#driver-specific-options
# reference 2 (docker postgresql): https://docs.docker.com/engine/examples/postgresql_service/#using-the-container-volumes

#### API 서버 자동 배포 스크립트 ####

# install Docker on server
sudo apt-get update
sudo apt-get install docker.io
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 방화벽 만지기
sudo ufw app list
sudo ufw allow OpenSSH
echo -e "y" | sudo ufw enable

# PostgreSQL 도커 서버 올리기
## 도커 빌드하기: api:postgres ##
docker volume create postgres_volume
docker volume create postgres_log
docker volume create postgres_lib

cd ./config/postgres
docker build -t api:postgres .
docker run -d \
  --name api-db \
  -v postgres_volume:/etc/postgresql \
  -v postgres_log:/var/log/postgresql \
  -v postgres_lib:/var/lib/postgresql \
  --restart=unless-stopped \
  -p 5432:5432 \
  api:postgres

# PostgreSQL 연결 확인하기: psql -h localhost -p 5432 -d <db-name> -U <username> --password

# 데이터베이스 포트 방화벽에서 열기
sudo ufw allow 5432
