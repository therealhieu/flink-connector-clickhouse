#!/bin/bash

# Maven Central Deployment Script
# Deploys only flink-connector-clickhouse and flink-sql-connector-clickhouse

echo "================================================"
echo "Flink ClickHouse Connector - Maven Central Deploy"
echo "================================================"
echo ""
echo "This will deploy:"
echo "  - flink-connector-clickhouse"
echo "  - flink-sql-connector-clickhouse"
echo ""
echo "Prerequisites:"
echo "  ✓ Maven settings.xml configured"
echo "  ✓ GPG key available"
echo "  ✓ Central Portal account"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Deployment cancelled."
    exit 1
fi

echo ""
echo "Step 1: Building modules..."
echo "----------------------------"
mvn clean install -pl flink-connector-clickhouse,flink-sql-connector-clickhouse -DskipTests

if [ $? -ne 0 ]; then
    echo "Build failed! Please fix errors and try again."
    exit 1
fi

echo ""
echo "Step 2: Deploying to Maven Central..."
echo "--------------------------------------"
mvn clean deploy -Prelease -DskipTests \
  -pl flink-connector-clickhouse,flink-sql-connector-clickhouse

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✅ Deployment Successful!"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "1. Login to https://central.sonatype.com"
    echo "2. Find your deployment in 'Deployments' section"
    echo "3. Click 'Publish' to release to Maven Central"
    echo ""
    echo "Artifacts will be available at:"
    echo "  https://repo1.maven.org/maven2/io/github/therealhieu/"
    echo ""
else
    echo ""
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi