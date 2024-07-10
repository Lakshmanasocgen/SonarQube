sonarqube java17 amazon linux aws.sh

sudo yum update -y

sudo yum install -y java-17-amazon-corretto-devel

java -version

visudo

#line no 108 paste

sonar   ALL=(ALL)       ALL

#line no 111 paste

sonar         ALL=(ALL)       NOPASSWD: ALL

sudo amazon-linux-extras install postgresql14 -y

sudo yum install -y postgresql postgresql-server

sudo /usr/bin/postgresql-setup --initdb

sudo systemctl enable postgresql

vim /var/lib/pgsql/data/postgresql.conf    // uncoment line number 60 and replace as  listen_addresses = '*'

systemctl restart postgresql

su - postgres
createdb sonarqube
psql

alter user postgres with password 'CloudGen@123';
CREATE USER sonarqube WITH PASSWORD 'CloudGen@123';
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonarqube;
\q
exit

cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
unzip sonarqube-9.9.4.87374.zip
mv sonarqube-*/ /opt/sonarqube

sudo vim /opt/sonarqube/conf/sonar.properties      //copy the below lines from 48 to 64 and paste at 410th line

## Database details
sonar.jdbc.username=sonarqube
sonar.jdbc.password=CloudGen@123
sonar.jdbc.url-jdbc:postgresql://localhost/sonarqube


##How you will access SonarQube web UI
sonar.web.host=0.0.0.0
sonar.web.post=9000

##Java options
sonar.web.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError

##Also add the following Elasticsearch storage paths 
sonar.path.data=/var/sonarqube/data 
sonar.path.temp=/var/sonarqube/temp

#:wq (save & exit)

sudo useradd sonar 
sudo passwd sonar       CloudGen@123


chown -R sonar:sonar /opt/sonarqube
mkdir -p /var/sonarqube
chown -R sonar:sonar /var/sonarqube

##### Next #####

sudo vim /etc/systemd/system/sonarqube.service

[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
LimitNOFILE=65536
LimitNPROC=4096
User=sonar
Group=sonar
Restart=on-failue

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube
systemctl status sonarqube.service


#Firewall rules to allow SonarQube Access
# Below Steps only on On-Premises, No Need in AWS.
sudo systemctl status firewalld 
sudo systemctl start firewalld
sudo systemctl status firewalld
sudo firewall-cmd --permanent --add-port=9000/tcp && sudo firewall-cmd --reload



Access the Web User Interface

http://server-ip:9000
