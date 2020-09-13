FROM openjdk:8-jdk-alpine
MAINTAINER Vineet Agarwal

FROM maven:3.5.2-jdk-8-alpine AS MAVEN_TOOL_CHAIN
COPY pom.xml /tmp/
COPY src /tmp/src/
WORKDIR /tmp/
RUN mvn install

FROM tomcat:alpine
COPY target/*.war /vineetagarwal.war
EXPOSE 8080
ENTRYPOINT ["java","-jar","/vineetagarwal.war"]
