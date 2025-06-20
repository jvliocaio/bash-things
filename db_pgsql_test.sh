echo " "
echo " "
HOSTNAME=`hostname`
PSQL="/opt/PostgreSQL/9.3/bin/psql"
PORT=5432
HOST="localhost"
DB="template1"
USER="postgres"
echo "Enter the Time in minutes ,For example if you give 10 means script will displayed what are the query is running more than 10 minutes";
read time
echo "------***WHAT ARE THE QUERY IS RUNING MORE THAN $time MINUTES***------"
$PSQL -d $DB -U $USER -p $PORT <<EOF
\pset format wrapped
SELECT pid, now() - query_start as "runtime", usename, datname, state, query
  FROM  pg_stat_activity
  WHERE now() - query_start > '$time minutes'::interval
 ORDER BY runtime DESC;

EOF

echo " "
echo " "
echo " "

echo "------***CHECKING dISK SPACE***------"
        df -h

echo " "
echo " "
echo " "

echo "------***CHECKING RAM USAGE***------"
       free -h