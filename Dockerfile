FROM openjdk:8-jdk-alpine

VOLUME /tmp

ARG JAR_FILE

COPY ${JAR_FILE} app.jar

HEALTHCHECK --interval=10s --timeout=3s --retries=2 CMD wget --spider -T 3 -q http://127.0.0.1:22022/actuator/health

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar","--db.host=mysql","--db.password=${DB_PASSWORD}"]