# openlmis-elmis-comp

Tools and data gathered in comparing the OpenLMIS/master branch and eLMIS/master branch.

## code

### OpenLMIS code changed in eLMIS stats

Requires:  eLMIS/master as elmis-master branch and OpenLMIS/master as master branch
To generate:  `git diff --numstat --diff-filter=M master..elmis-master`
Output:  file openlmis-code-changed-stats.xls

## db

This compares the OpenLMIS/master schema with the eLMIS/master schema as generated from fresh builds.

### Steps to generating schema diff:
1. Pre-req: Get OpenLMIS and eLMIS, and apgdiff
2. Build OpenLMIS/master DB schema with `gradle clean setupdb`
3. Dump OpenLMIS schema:  `pg_dump -s open_lmis > openlmis-db.sql`
4. Build eLMIS/master DB schema with `gradle clean setupdb setupExtensions`
5. Dump eLMIS schema: `pg_dump -s open_lmis > elmis-db.sql`
6. Generate schema diff with agpdiff:  `java -jar agpdiff.jar --ignore-starts-with openlmis-db.sql elmis-db-sql > openlmis-to-elmis-db-upgrade.sql`

### Steps to getting DB schema difference stats:
1. Change to db dir of this project
2. `chmod u+x dbStats.sh`
3. `./dbStats.sh`
