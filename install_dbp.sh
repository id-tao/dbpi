#!/bin/bash

#SCRIPT SETINGS [17.03.2015]
#DRUPAL VERSION
DRUPAL='7.39'

#MODULES VERSIONS
declare -a VERSIONS
#https://www.drupal.org/project/globalredirect/git-instructions
VERSIONS[1]='7.x-1.x'
#https://www.drupal.org/project/admin_menu/git-instructions
VERSIONS[2]='7.x-3.x'
#https://www.drupal.org/project/ctools/git-instructions
VERSIONS[3]='7.x-1.x'
#https://www.drupal.org/project/token/git-instructions
VERSIONS[4]='7.x-1.x'
#https://www.drupal.org/project/views/git-instructions
VERSIONS[5]='7.x-3.x'
#https://www.drupal.org/project/pathauto/git-instructions
VERSIONS[6]='7.x-1.x'
#https://www.drupal.org/project/google_analytics/git-instructions
VERSIONS[7]='7.x-2.x'
#https://www.drupal.org/project/xmlsitemap/git-instructions
VERSIONS[8]='7.x-2.x'
#https://www.drupal.org/project/elysia_cron/git-instructions
VERSIONS[9]='7.x-2.x'
#https://www.drupal.org/project/metatag/git-instructions
VERSIONS[10]='7.x-1.x'
#https://www.drupal.org/project/wysiwyg/git-instructions
VERSIONS[11]='7.x-2.x'
#https://www.drupal.org/project/imce/git-instructions
VERSIONS[12]='7.x-1.x'
#https://www.drupal.org/project/wysiwyg_filter/git-instructions
VERSIONS[14]='7.x-1.x'
#https://www.drupal.org/project/transliteration/git-instructions
VERSIONS[15]='7.x-3.x'
#https://www.drupal.org/project/subpathauto/git-instructions
VERSIONS[16]='7.x-1.x'

read -n 1 -p "Drupal base package will be installed. Are you sure? (y/n): " AMSURE
if [ "$AMSURE" = "y" ]; then
  echo ""
  echo
  echo "=================START================"
else
  echo ""
  exit
fi
lst="git drush"
dpkg -l 2>/dev/null > ls.tmp
for items in $lst
do
  cmd=$(grep "\ $items\ " ls.tmp)
  if [ $? == 0 ]
    then
      echo "$items installed "
    else
      echo "$items NOT installed"
      echo "Install $items and try again"
      rm ls.tmp
      exit 0
  fi
done
rm ls.tmp
if [ -f "README.txt" ]; then
  rm README.txt
fi
GIT=".git/config"
if [ -f $GIT ]; then
  echo "GIT INIT - OK"
else
  git init
  echo "GIT INIT - OK"
fi
echo
echo "===============SITE SETTINGS==============="
NAME=''
while [ "$NAME" == '' ]
do
  echo "Enter project name:"
  read NAME
  echo $NAME >> README.txt
done
SANAME=''
while [ "$SANAME" == '' ]
do
  echo "Enter Site administrator login:"
  read SANAME
done
TASK=''
while [ "$TASK" == '' ]
do
  echo "Enter Taks number in lab:"
  read TASK
done
echo
echo "===============DB SETTINGS==============="
DBNAME=''
while [ "$DBNAME" == '' ]
do
  echo "Enter DB name (Will be created a new database or will be update old database):"
  read DBNAME
done
# echo "Enter DB login:"
# read LOGIN
LOGIN=''
while [ "$LOGIN" == '' ]
do
  echo "Enter DB login:"
  read LOGIN
done

PASSWORD=''
while [ "$PASSWORD" == '' ]
do
  echo "Enter DB pass:"
  PASSWORD=""
  while
  read -s -n1 BUFF
  [[ -n $BUFF ]]
  do
    # 127 - backspace ascii code
    if [[ `printf "%d\n" \'$BUFF` == 127 ]]
    then
      PASSWORD="${PASSWORD%?}"
      echo -en "\b \b"
    else
      PASSWORD=$PASSWORD$BUFF
      echo -en "*"
    fi
  done
done
echo
git add README.txt
git commit -m "Task #$TASK: Initial commit"
git checkout -b dev
git rm README.txt
git submodule add https://github.com/InternetDevels/drupal-core.git htdocs

CORE="htdocs/README.md"

if [ ! -f $CORE ]; then
  echo "Cannot download drupal core, try again"
  rm -R htdocs
  rm -R .git
  rm .gitmodules
  exit 0
fi

wget http://ftp.drupal.org/files/projects/drupal-$DRUPAL.tar.gz
tar xvzf drupal-$DRUPAL.tar.gz
if [ ! -f "drupal-$DRUPAL/sites/default/default.settings.php" ]; then
  echo "Cannot download drupal files, try again"
  rm -R htdocs
  rm -R .git
  rm .gitmodules
  rm drupal-$DRUPAL.tar.gz
  exit 0
fi
rm drupal-$DRUPAL.tar.gz
cd drupal-$DRUPAL
cp -R sites ../sites
cp .htaccess ../
cd ../
rm -R drupal-$DRUPAL
rm sites/README.txt
rm sites/all/modules/README.txt
rm sites/all/themes/README.txt
rm sites/example.sites.php

mkdir sites/all/modules/custom
mkdir sites/all/modules/contrib
mkdir sites/all/libraries
mkdir sites/default/files
chmod 777 -R sites/default/files

cp sites/default/default.settings.php sites/default/settings.php

echo '$databases = array (' >> sites/default/settings.php
echo "  'default' =>" >> sites/default/settings.php
echo "  array (" >> sites/default/settings.php
echo "    'default' =>" >> sites/default/settings.php
echo "    array (" >> sites/default/settings.php
echo "      'database' => '$DBNAME'," >> sites/default/settings.php
echo "      'username' => '$LOGIN'," >> sites/default/settings.php
echo "      'password' => '$PASSWORD'," >> sites/default/settings.php
echo "      'host' => 'localhost'," >> sites/default/settings.php
echo "      'port' => ''," >> sites/default/settings.php
echo "      'driver' => 'mysql'," >> sites/default/settings.php
echo "      'prefix' => ''," >> sites/default/settings.php
echo "    )," >> sites/default/settings.php
echo "  )," >> sites/default/settings.php
echo ");" >> sites/default/settings.php

git add sites/default/
cp .htaccess htdocs/.htaccess
rm .htaccess
cd htdocs/
git checkout 7.x
ln -s ../sites
drush site-install standard --account-name=$SANAME --account-pass=$PASSWORD --db-url=mysql://$LOGIN:$PASSWORD@localhost:/$DBNAME -y
cd ../
echo
echo '============== INSTALLING MODULES ==============='
echo
DMODULES="globalredirect admin_menu ctools token views pathauto google_analytics xmlsitemap elysia_cron metatag wysiwyg imce wysiwyg_filter transliteration subpathauto"
MODNUM=0
for MOD in $DMODULES
do
  MODNUM=$MODNUM+1
  echo "[$MOD]"
  echo "submodule add --branch ${VERSIONS[$MODNUM]} http://git.drupal.org/project/$MOD.git sites/all/modules/contrib/$MOD"
  git submodule add --branch ${VERSIONS[$MODNUM]} http://git.drupal.org/project/$MOD.git sites/all/modules/contrib/$MOD
  if [[ -f "sites/all/modules/contrib/$MOD/$MOD.module" || -f "sites/all/modules/contrib/$MOD/README.txt" || -f "sites/all/modules/contrib/$MOD/$MOD.info" ]]
  then
    echo
  else
    echo
    echo "Cannot download $MOD module"
    echo
  fi
done
sed -e 's/dependencies\[\]\s\=\stoken/;\ dependencies[]\ =\ token/' -i "sites/all/modules/contrib/metatag/metatag.info"
cd htdocs/
drush dis color toolbar shortcut rdf update_manager -y
drush en ctools token metatag views views_ui admin_menu admin_menu_toolbar elysia_cron pathauto page_manager ctools_custom_content imce wysiwyg wysiwyg_filter globalredirect transliteration subpathauto -y
drush cc all
cd ../

echo "# Ignore configuration files that may contain sensitive information." >> .gitignore
echo "sites/default/*settings.php" >> .gitignore
echo "" >> .gitignore
echo "# Ignore paths that contain user-generated content." >> .gitignore
echo "sites/*/files" >> .gitignore
echo "sites/*/private" >> .gitignore
echo "robots.txt" >> .gitignore
echo "*.htaccess" >> .gitignore
echo "*.html" >> .gitignore
echo "*.sql" >> .gitignore
echo "*.sass-cache" >> .gitignore
git add .gitignore
sed -e 's/\;\sdependencies/dependencies/' -i "sites/all/modules/contrib/metatag/metatag.info"

chmod 777 htdocs
chmod 777 sites
chmod 777 .git
chmod 777 .gitignore
chmod 777 .gitmodules

echo
echo '========INSTALLATION COMPLETE========'
echo 'Your login - '$SANAME
echo 'Your password' - $PASSWORD
