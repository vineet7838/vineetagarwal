FROM tomcat:alpine
MAINTAINER Vineet Agarwal
EXPOSE 8080
COPY ./target/devopssampleapplication.war /usr/local/tomcat/webapps/
CMD /usr/local/tomcat/bin/catalina.sh run
