FROM eclipse-temurin:21-jdk-jammy as base
WORKDIR /app
COPY gradlew settings.gradle build.gradle ./
COPY gradle/ ./gradle
RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon
COPY src ./src

FROM base as build
RUN ./gradlew build --no-daemon


FROM eclipse-temurin:21-jre-jammy as production
EXPOSE 8080
COPY --from=build /app/build/libs/*[^plain].jar /spring-petclinic.jar
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]