# Maven Central Deployment Guide

This guide explains how to deploy the Flink ClickHouse Connector artifacts to Maven Central.

## Prerequisites

### 1. Maven Central Account
- Account on [Central Portal](https://central.sonatype.com)
- Verified namespace: `io.github.therealhieu`
- User token configured in `~/.m2/settings.xml`

### 2. GPG Key Setup
- GPG key generated and uploaded to keyservers
- GPG configured in `~/.m2/settings.xml`

### 3. Maven Settings
Your `~/.m2/settings.xml` should contain:
```xml
<settings>
  <servers>
    <server>
      <id>central</id>
      <username>YOUR_USERNAME</username>
      <password>YOUR_PASSWORD</password>
    </server>
  </servers>
  <profiles>
    <profile>
      <id>gpg</id>
      <properties>
        <gpg.executable>gpg</gpg.executable>
        <gpg.passphrase>YOUR_GPG_PASSPHRASE</gpg.passphrase>
      </properties>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>gpg</activeProfile>
  </activeProfiles>
</settings>
```

## Deployment Steps

### Step 1: Checkout the Deployment Branch
```bash
git checkout hieu-publish
```

### Step 2: Build and Test Locally
```bash
# Build only the required modules
mvn clean install -pl flink-connector-clickhouse,flink-sql-connector-clickhouse -DskipTests

# Or with tests
mvn clean install -pl flink-connector-clickhouse,flink-sql-connector-clickhouse
```

### Step 3: Deploy to Maven Central Staging
Deploy only the two main modules (excluding e2e-test):

```bash
# Deploy specific modules to Central Portal
mvn clean deploy -Prelease -DskipTests \
  -pl flink-connector-clickhouse,flink-sql-connector-clickhouse
```

**Important Notes**:
- The parent POM (`flink-connector-clickhouse-parent`) is automatically included and **cannot be skipped**
- It's required for Maven dependency resolution when users add your artifacts
- Only the POM file is deployed for the parent (no JAR since it's a POM-only module)
- The `flink-connector-clickhouse-e2e-test` module is correctly excluded from deployment

### Step 4: Monitor Deployment
The deployment will output:
- A deployment ID (e.g., `12a4b8fc-c0f3-494b-a493-ab8b9e2ce813`)
- Validation status
- Any errors that need to be fixed

Example successful output:
```
[INFO] Uploaded bundle successfully, deployment name: Deployment, deploymentId: xxxxx
[INFO] Deployment xxxxx was successfully validated
[INFO] Deployment xxxxx can now be published
```

### Step 5: Publish on Central Portal
1. Login to [Central Portal](https://central.sonatype.com)
2. Navigate to **Deployments** section
3. Find your deployment by ID or status "VALIDATED"
4. Review the artifacts:
   - `flink-connector-clickhouse-1.19.0-1.0.0.jar`
   - `flink-sql-connector-clickhouse-1.19.0-1.0.0.jar`
   - Plus sources, javadocs, and signatures for each
5. Click **"Publish"** button

### Step 6: Verify Deployment
After publishing, artifacts will be available at:

#### Immediate (Staging)
Check Central Portal search immediately after publishing

#### Within 30 minutes
```
https://central.sonatype.com/artifact/io.github.therealhieu/flink-connector-clickhouse
https://central.sonatype.com/artifact/io.github.therealhieu/flink-sql-connector-clickhouse
```

#### Within 2-4 hours (Maven Central)
```
https://repo1.maven.org/maven2/io/github/therealhieu/flink-connector-clickhouse/1.19.0-1.0.0/
https://repo1.maven.org/maven2/io/github/therealhieu/flink-sql-connector-clickhouse/1.19.0-1.0.0/
```

## What Gets Deployed

When you run the deployment command, these artifacts are uploaded:

### Parent POM (Required - POM only, no JAR)
- `flink-connector-clickhouse-parent-1.19.0-1.0.0.pom`
- `flink-connector-clickhouse-parent-1.19.0-1.0.0.pom.asc` (signature)

### Core Connector Module
- `flink-connector-clickhouse-1.19.0-1.0.0.jar`
- `flink-connector-clickhouse-1.19.0-1.0.0.pom`
- `flink-connector-clickhouse-1.19.0-1.0.0-sources.jar`
- `flink-connector-clickhouse-1.19.0-1.0.0-javadoc.jar`
- Plus `.asc` signature files for each

### SQL Connector Module (Shaded)
- `flink-sql-connector-clickhouse-1.19.0-1.0.0.jar` (includes shaded dependencies)
- `flink-sql-connector-clickhouse-1.19.0-1.0.0.pom`
- `flink-sql-connector-clickhouse-1.19.0-1.0.0-sources.jar`
- `flink-sql-connector-clickhouse-1.19.0-1.0.0-javadoc.jar`
- Plus `.asc` signature files for each

### NOT Deployed
- ❌ `flink-connector-clickhouse-e2e-test` (test module excluded)

## Using the Published Artifacts

Once published, users can add these dependencies to their projects:

### Core Connector
```xml
<dependency>
    <groupId>io.github.therealhieu</groupId>
    <artifactId>flink-connector-clickhouse</artifactId>
    <version>1.19.0-1.0.0</version>
</dependency>
```

### SQL Connector (Shaded)
```xml
<dependency>
    <groupId>io.github.therealhieu</groupId>
    <artifactId>flink-sql-connector-clickhouse</artifactId>
    <version>1.19.0-1.0.0</version>
</dependency>
```

## Troubleshooting

### Common Issues

#### 1. GPG Signing Failed
- Ensure GPG key is available: `gpg --list-secret-keys`
- Check passphrase in `~/.m2/settings.xml`
- Try signing manually: `echo "test" | gpg --clearsign`

#### 2. Authentication Failed
- Verify Central Portal credentials
- Regenerate user token if needed
- Check server id matches: must be `central`

#### 3. Validation Errors
- Missing metadata: Check all POMs have description, licenses, SCM, developers
- Invalid coordinates: Ensure groupId matches verified namespace
- Missing signatures: GPG must sign all artifacts

#### 4. Deployment Not Visible
- Central Portal cache: Wait a few minutes and refresh
- Maven Central sync: Can take 2-4 hours for first deployment
- Check correct repository: https://repo1.maven.org/maven2/

### Useful Commands

```bash
# Check what will be deployed
mvn clean install -Prelease -DskipTests \
  -pl flink-connector-clickhouse,flink-sql-connector-clickhouse

# Deploy with debug output
mvn clean deploy -Prelease -DskipTests -X \
  -pl flink-connector-clickhouse,flink-sql-connector-clickhouse

# Verify GPG signing
gpg --list-secret-keys
echo "test" | gpg --clearsign
```

## Version Management

Current version: `1.19.0-1.0.0`
- `1.19.0` - Flink version compatibility
- `1.0.0` - Connector version

To update version for next release:
```bash
mvn versions:set -DnewVersion=1.19.0-1.0.1
mvn versions:commit
```

## Security Notes

� **Never commit these files:**
- GPG private keys
- Passphrases or passwords
- `gpg-batch.txt`
- Any `*.key`, `*.pem`, `*-private.asc` files

These patterns are already in `.gitignore` for safety.

## Support

For issues with:
- This connector: Create issue on [GitHub](https://github.com/therealhieu/flink-connector-clickhouse/issues)
- Central Portal: Check [documentation](https://central.sonatype.org/publish/publish-portal-upload/)
- Maven Central: Contact [Sonatype support](https://issues.sonatype.org/)