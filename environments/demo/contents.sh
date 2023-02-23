MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
touch /var/www/html/index.html
echo "<h1>contents-app</h1>" | tee /var/www/html/index.html
--==MYBOUNDARY==