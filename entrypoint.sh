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

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
  EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
  if [[ "${EVENT_ACTION}" != "opened" ]]; then
      echo "No need to run analysis. It is already triggered by the push event."
      exit 78
  fi
fi

if [[ -z "${SONARCLOUD_URL}" ]]; then
  SONARCLOUD_URL="https://sonarcloud.io"
fi

ARGS="${INPUT_ARGS}"
if [[ "${INPUT_ORGANIZATION}" ]]; then
  ARGS="${ARGS} -Dsonar.organization=${INPUT_ORGANIZATION}"
fi
if [[ "${INPUT_PROJECTKEY}" ]]; then
  ARGS="${ARGS} -Dsonar.projectKey=${INPUT_PROJECTKEY}"
fi
if [[ "${INPUT_SOURCES}" ]]; then
  ARGS="${ARGS} -Dsonar.sources=${INPUT_SOURCES}"
fi
if [[ "${INPUT_TESTS}" ]]; then
  ARGS="${ARGS} -Dsonar.tests=${INPUT_TESTS}"
fi
if [[ "${INPUT_VERBOSE}" != "false" && "${INPUT_VERBOSE}" != "False" ]]; then
  ARGS="${ARGS} -Dsonar.verbose=true"
fi

sonar-scanner -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} -Dsonar.host.url=${SONARCLOUD_URL} ${ARGS}
