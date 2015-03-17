#!/bin/bash

#SCRIPT SETINGS [17.03.2015]
#DRUPAL VERSION
DRUPAL='7.34'

#MODULES VERSIONS

#https://www.drupal.org/project/globalredirect/git-instructions
GLOBALREDIRECT='7.x-1.x'
#https://www.drupal.org/project/admin_menu/git-instructions
ADMIN_MENU='7.x-3.x'
#https://www.drupal.org/project/ctools/git-instructions
CTOOLS='7.x-1.x'
#https://www.drupal.org/project/token/git-instructions
TOKEN='7.x-1.x'
#https://www.drupal.org/project/views/git-instructions
VIEWS='7.x-3.x'
#https://www.drupal.org/project/pathauto/git-instructions
PATHAUTO='7.x-1.x'
#https://www.drupal.org/project/google_analytics/git-instructions
GOOGLE_ANALYTICS='7.x-2.x'
#https://www.drupal.org/project/xmlsitemap/git-instructions
XMLSITEMAP='7.x-2.x'
#https://www.drupal.org/project/elysia_cron/git-instructions
ELYSIA_CRON='7.x-2.x'
#https://www.drupal.org/project/metatag/git-instructions
METATAG='7.x-1.x'
#https://www.drupal.org/project/wysiwyg/git-instructions
WYSIWYG='7.x-2.x'
#https://www.drupal.org/project/imce/git-instructions
IMCE='7.x-1.x'
#https://www.drupal.org/project/wysiwyg_filter/git-instructions
WYSIWYG_FILTER='7.x-1.x'
#https://www.drupal.org/project/transliteration/git-instructions
TRANSLITERATION='7.x-3.x'
#https://www.drupal.org/project/subpathauto/git-instructions
SUBPATHAUTO='7.x-1.x'
#TINYMCE='4.1.9'

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
rm README.txt
GIT=".git/config"
if [ -f $GIT ]; then
  echo "GIT INIT - OK"
else
  git init
  echo "GIT INIT - OK"
fi
echo
echo "===============SITE SETTINGS==============="
echo "Project name"
read NAME
echo $NAME >> README.txt
echo "Site administrator login"
read SANAME
echo "Taks number in lab"
read TASK
if [ $TASK == "" ]; then
  $TASK=1
fi
echo
echo "===============DB SETTINGS==============="
echo "DB name"
read DBNAME
echo "DB login"
read LOGIN
echo "DB pass"
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
echo

git add README.txt
git commit -m "Task #$TASK: Initial commit"
git checkout -b dev
git rm README.txt
git submodule add https://github.com/InternetDevels/drupal-core.git htdocs

wget http://ftp.drupal.org/files/projects/drupal-$DRUPAL.tar.gz
tar xvzf drupal-$DRUPAL.tar.gz
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

echo "# Ignore configuration files that may contain sensitive information." >> .gitignore
echo "sites/*/settings*.php" >> .gitignore
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
git add sites/default/
cp .htaccess htdocs/.htaccess
rm .htaccess
cd htdocs/
git checkout 7.x
ln -s ../sites
drush site-install standard --account-name=$SANAME --account-pass=$PASSWORD --db-url=mysql://$LOGIN:$PASSWORD@localhost:/$DBNAME
cd ../
git submodule add --branch $GLOBALREDIRECT http://git.drupal.org/project/globalredirect.git sites/all/modules/contrib/globalredirect
git submodule add --branch $ADMIN_MENU http://git.drupal.org/project/admin_menu.git sites/all/modules/contrib/admin_menu
git submodule add --branch $CTOOLS http://git.drupal.org/project/ctools.git sites/all/modules/contrib/ctools
git submodule add --branch $TOKEN http://git.drupal.org/project/token.git sites/all/modules/contrib/token
git submodule add --branch $VIEWS http://git.drupal.org/project/views.git sites/all/modules/contrib/views
git submodule add --branch $PATHAUTO http://git.drupal.org/project/pathauto.git sites/all/modules/contrib/pathauto
git submodule add --branch $GOOGLE_ANALYTICS http://git.drupal.org/project/google_analytics.git sites/all/modules/contrib/google_analytics
git submodule add --branch $XMLSITEMAP http://git.drupal.org/project/xmlsitemap.git sites/all/modules/contrib/xmlsitemap
git submodule add --branch $ELYSIA_CRON http://git.drupal.org/project/elysia_cron.git sites/all/modules/contrib/elysia_cron
git submodule add --branch $METATAG http://git.drupal.org/project/metatag.git sites/all/modules/contrib/metatag
git submodule add --branch $WYSIWYG http://git.drupal.org/project/wysiwyg.git sites/all/modules/contrib/wysiwyg
git submodule add --branch $IMCE http://git.drupal.org/project/imce.git sites/all/modules/contrib/imce
git submodule add --branch $WYSIWYG_FILTER http://git.drupal.org/project/wysiwyg_filter.git sites/all/modules/contrib/wysiwyg_filter
git submodule add --branch $TRANSLITERATION http://git.drupal.org/project/transliteration.git sites/all/modules/contrib/transliteration
git submodule add --branch $SUBPATHAUTO http://git.drupal.org/project/subpathauto.git sites/all/modules/contrib/subpathauto
cd htdocs/
drush dis color toolbar shortcut rdf update_manager
drush en ctools token metatag views views_ui admin_menu admin_menu_toolbar elysia_cron pathauto page_manager ctools_custom_content imce wysiwyg wysiwyg_filter globalredirect transliteration subpathauto
drush cc all
cd ../
echo
echo '========INSTALLATION COMPLETE========'
echo 'Your login - '$SANAME
echo 'Your password' - $PASSWORD
