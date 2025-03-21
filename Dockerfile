# 의존성 다운로드 및 gradle 빌드를 위한 설정 파일 세팅
FROM eclipse-temurin:21-jdk-jammy AS base
WORKDIR /app

# gradle wrapper와 설정 파일 복사
# gradle wrapper는 gradle을 설치하지 않아도 프로젝트를 빌드할 수 있도록 해줌
COPY gradlew settings.gradle build.gradle ./
COPY gradle/ ./gradle
# 실행 권한 추가
RUN chmod +x gradlew

# 의존성 다운로드 (도커 캐싱을 활용하기 위해 소스 코드 복사 전에 실행)
RUN ./gradlew dependencies --no-daemon

# 소스 코드 복사
COPY src ./src

# 소스 코드 빌드 스테이징
FROM base AS build
RUN ./gradlew build --no-daemon

# 빌드된 jar 파일을 실행하는 스테이징
FROM eclipse-temurin:21-jre-jammy AS production
EXPOSE 8080
COPY --from=build /app/build/libs/*[^plain].jar /spring-petclinic.jar
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]