# Dockerfile for CVE-2026-109618/109619 (php2shell) testing
# Uses PHP 8.3.12 (vulnerable version before 8.3.36)
FROM php:8.3.12-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create session directory with proper permissions
RUN mkdir -p /tmp/sessions && chmod 777 /tmp/sessions

# Configure PHP with vulnerable settings
RUN echo "session.upload_progress.enabled = On" >> /usr/local/etc/php/php.ini && \
    echo "session.upload_progress.cleanup = Off" >> /usr/local/etc/php/php.ini && \
    echo "session.upload_progress.prefix = upload_progress_" >> /usr/local/etc/php/php.ini && \
    echo "session.upload_progress.name = PHP_SESSION_UPLOAD_PROGRESS" >> /usr/local/etc/php/php.ini && \
    echo "session.save_path = /tmp/sessions" >> /usr/local/etc/php/php.ini && \
    echo "session.serialize_handler = php" >> /usr/local/etc/php/php.ini && \
    echo "memory_limit = 128M" >> /usr/local/etc/php/php.ini && \
    echo "post_max_size = 16M" >> /usr/local/etc/php/php.ini && \
    echo "upload_max_filesize = 16M" >> /usr/local/etc/php/php.ini && \
    echo "display_errors = On" >> /usr/local/etc/php/php.ini && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/php.ini

# Create flag file
RUN echo "FLAG{php2shell_CVE_2026_109618_109619_pwned_successfully}" > /flag.txt && \
    chmod 644 /flag.txt

# Create web root structure
RUN mkdir -p /var/www/html/uploads

# Create test PHP files
RUN echo '<?php phpinfo(); ?>' > /var/www/html/index.php

# Create upload test page
RUN echo '<?php\n\
session_start();\n\
if ($_SERVER["REQUEST_METHOD"] == "POST") {\n\
    if (isset($_FILES["file"])) {\n\
        echo "File uploaded: " . $_FILES["file"]["name"] . "<br>";\n\
    }\n\
    if (isset($_SESSION["data"])) {\n\
        echo "Session data: " . $_SESSION["data"] . "<br>";\n\
    }\n\
}\n\
?>\n\
<html><body>\n\
<h1>Upload Test</h1>\n\
<form method="POST" enctype="multipart/form-data">\n\
    <input type="file" name="file"><br>\n\
    <input type="text" name="PHPSESSID" placeholder="Session ID"><br>\n\
    <input type="text" name="PHP_SESSION_UPLOAD_PROGRESS" value="test"><br>\n\
    <input type="submit" value="Upload">\n\
</form>\n\
</body></html>' > /var/www/html/upload.php

# Create a simple gadget class file
RUN echo '<?php\n\
class Pwn {\n\
    public $cmd = "cat /flag.txt";\n\
    \n\
    public function __wakeup() {\n\
        error_log("Pwn::__wakeup() called!");\n\
        if ($this->cmd) {\n\
            $output = shell_exec($this->cmd);\n\
            error_log("Command output: " . $output);\n\
            echo "<pre>EXPLOIT SUCCESS!\\n" . htmlspecialchars($output) . "</pre>";\n\
        }\n\
    }\n\
    \n\
    public function __destruct() {\n\
        error_log("Pwn::__destruct() called!");\n\
    }\n\
}\n\
?>' > /var/www/html/gadget.php

# Create a session writer endpoint for easy testing
RUN echo '<?php\n\
// This simulates an app that writes user input to session\n\
session_start();\n\
\n\
if (isset($_POST["data"])) {\n\
    $_SESSION["exploit"] = $_POST["data"];\n\
    echo "Session data written. Session ID: " . session_id() . "<br>";\n\
    echo "Session file: /tmp/sessions/sess_" . session_id() . "<br>";\n\
}\n\
\n\
if (isset($_GET["read"])) {\n\
    echo "Current session data:<br>";\n\
    var_dump($_SESSION);\n\
}\n\
?>\n\
<html><body>\n\
<h1>Session Writer</h1>\n\
<form method="POST">\n\
    <textarea name="data" rows="10" cols="50"></textarea><br>\n\
    <input type="submit" value="Write to Session">\n\
</form>\n\
<a href="?read=1">Read Session</a>\n\
</body></html>' > /var/www/html/session_writer.php

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
