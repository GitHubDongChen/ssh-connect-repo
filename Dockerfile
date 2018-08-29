FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
COPY ${STATUS_SCRIPT} status.sh
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD /bin/bash /status.sh
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar","--db.host=mysql","--db.password=${DB_PASSWORD}"]