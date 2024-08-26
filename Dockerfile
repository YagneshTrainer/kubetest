FROM tomcat:9.0.83-jdk8
LABEL "Project"="academy"
LABEL "Author"="Yagnesh"

WORKDIR /usr/local/tomcat/
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
# Above command trys to copy the artifact file from present working directory

EXPOSE 8080
CMD ["catalina.sh", "run"]
VOLUME /usr/local/tomcat/webapps
