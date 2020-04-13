#!/bin/bash

set -e

if [[ -z "${SONAR_TOKEN}" ]]; then
  echo "Set the SONAR_TOKEN env variable."
  exit 1
fi

if [[ -f "pom.xml" ]]; then
  echo "Maven project detected. You should run the goal 'org.sonarsource.scanner.maven:sonar' during build rather than using this GitHub Action."
  exit 1
fi

if [[ -f "build.gradle" ]]; then
  echo "Gradle project detected. You should use the SonarQube plugin for Gradle during build rather than using this GitHub Action."
  exit 1
fi

if [[ -z "${SONARCLOUD_URL}" ]]; then
  SONARCLOUD_URL="https://sonarcloud.io"
fi

ARGUMENTS="${INPUT_OPTIONS}"
if [[ "${INPUT_ORGANIZATION}" ]]; then
  ARGUMENTS="${ARGUMENTS} -Dsonar.organization=${INPUT_ORGANIZATION}"
fi
if [[ "${INPUT_PROJECTKEY}" ]]; then
  ARGUMENTS="${ARGUMENTS} -Dsonar.projectKey=${INPUT_PROJECTKEY}"
fi
if [[ "${INPUT_SOURCES}" ]]; then
  ARGUMENTS="${ARGUMENTS} -Dsonar.sources=${INPUT_SOURCES}"
fi
if [[ "${INPUT_TESTS}" ]]; then
  ARGUMENTS="${ARGUMENTS} -Dsonar.tests=${INPUT_TESTS}"
fi
if [[ "${INPUT_VERBOSE}" != "false" && "${INPUT_VERBOSE}" != "False" ]]; then
  ARGUMENTS="${ARGUMENTS} -Dsonar.verbose=true"
fi

sonar-scanner -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} -Dsonar.host.url=${SONARCLOUD_URL} ${ARGUMENTS}
