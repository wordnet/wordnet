#!/usr/bin/env bash

set -e

# Go to the deploy path
if [ ! -d "/var/www/wordnet/production/releases" ]; then
  echo "! ERROR: not set up."
  echo "The directory '/var/www/wordnet/production/releases' does not exist on the server."
  echo "You may need to run 'setup' first."
  exit 15
fi

# Check releases path
if [ ! -d "/var/www/wordnet/production/releases" ]; then
  echo "! ERROR: not set up."
  echo "The directory '/var/www/wordnet/production/releases' does not exist on the server."
  echo "You may need to run 'setup' first."
  exit 16
fi

# Check lockfile
if [ -e "/var/www/wordnet/production/deploy.lock" ]; then
  echo "! ERROR: another deployment is ongoing."
  echo "The file '/var/www/wordnet/production/deploy.lock' was found."
  echo "If no other deployment is ongoing, delete the file to continue."
  exit 17
fi

# Determine $previous_path and other variables
[ -h "/var/www/wordnet/production/current" ] && [ -d "/var/www/wordnet/production/current" ] && previous_path=$(cd "/var/www/wordnet/production/current" >/dev/null && pwd -LP)
build_path="./tmp/build-`date +%s`$RANDOM"
touch "/var/www/wordnet/production/last_version"
version=$((`cat "/var/www/wordnet/production/last_version" 2>/dev/null`+1))
release_path="/var/www/wordnet/production/releases/$version"

# Export git config
export GIT_SSH_KEY="/home/wordnet/.ssh/wordnet-production"
export GIT_SSH="/usr/bin/skylab-git-ssh"

# Sanity check
if [ -e "$build_path" ]; then
  echo "! ERROR: Path already exists."
  exit 18
fi


# Bootstrap script (in deployer)
(
  echo "-----> Creating a temporary build path"
  echo \$\ touch\ \"/var/www/wordnet/production/deploy.lock\" &&
touch "/var/www/wordnet/production/deploy.lock" &&
  echo \$\ mkdir\ -p\ \"\$build_path\" &&
mkdir -p "$build_path" &&
  echo \$\ cd\ \"\$build_path\" &&
cd "$build_path"
) &&

# Build
(
  echo
  echo "-----> Building application"
  echo \$\ cd\ \"\$build_path\" &&
cd "$build_path" &&
  (

                  if [ ! -d "/var/www/wordnet/production/scm/objects" ]; then
                    echo "-----> Cloning the Git repository"
                    echo \$\ git\ clone\ \"https://github.com/wordnet/wordnet.git\"\ \"/var/www/wordnet/production/scm\"\ --bare &&
git clone "https://github.com/wordnet/wordnet.git" "/var/www/wordnet/production/scm" --bare
                  else
                    echo "-----> Fetching new git commits"
                    echo \$\ \(cd\ \"/var/www/wordnet/production/scm\"\ \&\&\ git\ fetch\ \"https://github.com/wordnet/wordnet.git\"\ \"master:master\"\ --force\) &&
(cd "/var/www/wordnet/production/scm" && git fetch "https://github.com/wordnet/wordnet.git" "master:master" --force)
                  fi &&
                  echo "-----> Using git branch 'master'" &&
                  echo \$\ git\ clone\ \"/var/www/wordnet/production/scm\"\ .\ --recursive\ --branch\ \"master\" &&
git clone "/var/www/wordnet/production/scm" . --recursive --branch "master" &&

                  echo "-----> Using this git commit" &&
                  echo &&
                  echo \$\ git\ --no-pager\ log\ --format\=\"\%aN\ \(\%h\):\%n\>\ \%s\"\ -n\ 1 &&
git --no-pager log --format="%aN (%h):%n> %s" -n 1 &&
                  echo \$\ rm\ -rf\ .git &&
rm -rf .git &&
                  echo
                
) &&
 (

                  echo "-----> Symlinking shared paths"
                  echo \$\ mkdir\ -p\ \".\" &&
mkdir -p "." &&
echo \$\ mkdir\ -p\ \"./config\" &&
mkdir -p "./config" &&
echo \$\ rm\ -rf\ \"./.env\" &&
rm -rf "./.env" &&
echo \$\ ln\ -s\ \"/var/www/wordnet/production/shared/.env\"\ \"./.env\" &&
ln -s "/var/www/wordnet/production/shared/.env" "./.env" &&
echo \$\ rm\ -rf\ \"./log\" &&
rm -rf "./log" &&
echo \$\ ln\ -s\ \"/var/www/wordnet/production/shared/log\"\ \"./log\" &&
ln -s "/var/www/wordnet/production/shared/log" "./log" &&
echo \$\ rm\ -rf\ \"./tmp\" &&
rm -rf "./tmp" &&
echo \$\ ln\ -s\ \"/var/www/wordnet/production/shared/tmp\"\ \"./tmp\" &&
ln -s "/var/www/wordnet/production/shared/tmp" "./tmp" &&
echo \$\ rm\ -rf\ \"./config/database.yml\" &&
rm -rf "./config/database.yml" &&
echo \$\ ln\ -s\ \"/var/www/wordnet/production/shared/config/database.yml\"\ \"./config/database.yml\" &&
ln -s "/var/www/wordnet/production/shared/config/database.yml" "./config/database.yml"
                
) &&
 (

                  echo "-----> Installing gem dependencies using Bundler"
                  echo \$\ mkdir\ -p\ \"/var/www/wordnet/production/shared/bundle\" &&
mkdir -p "/var/www/wordnet/production/shared/bundle"
                  echo \$\ mkdir\ -p\ \"./vendor\" &&
mkdir -p "./vendor"
                  echo \$\ ln\ -s\ \"/var/www/wordnet/production/shared/bundle\"\ \"./vendor/bundle\" &&
ln -s "/var/www/wordnet/production/shared/bundle" "./vendor/bundle"
                  echo \$\ bundle\ install\ --without\ development:test\ --path\ \"./vendor/bundle\"\ --deployment\  &&
bundle install --without development:test --path "./vendor/bundle" --deployment 
                
) &&
 (

                  echo "-----> Generating upstart scripts"
                  echo \$\ sudo\ mkdir\ -p\ \"/etc/init\" &&
sudo mkdir -p "/etc/init"
                  echo \$\ sudo\ rm\ -f\ /etc/init/wordnet-production.conf &&
sudo rm -f /etc/init/wordnet-production.conf
                  echo \$\ sudo\ rm\ -f\ /etc/init/wordnet-production-\*.conf &&
sudo rm -f /etc/init/wordnet-production-*.conf
                SKYLAB_WORKER_web=0
# generate master conf file
echo "Generating /etc/init/wordnet-production.conf"
printf '
pre-start script

bash << "EOF"
  mkdir -p /var/www/wordnet/production/current/log
  chown -R wordnet /var/www/wordnet/production/current/log
EOF

end script

start on runlevel [2345]

stop on runlevel [016]
' | sudo sh -c "cat > /etc/init/wordnet-production.conf"
                
                  cat Procfile | grep -v '^#' | grep -v '^ *$' | (while read line; do
                    name=${line%:*}
                    proc=${line#*:}

                    echo "Generating /etc/init/wordnet-production-${name}.conf"
                    sudo printf '
                start on starting wordnet-production
                stop on stopping wordnet-production
                ' | sudo sh -c "cat > /etc/init/wordnet-production-${name}.conf"

                    eval num=\$$(echo "SKYLAB_WORKER_$name")
                    if [ -z "$num" ]; then
                      num="1"
                    fi

                    if [ "$num" != "0" ]; then
                      for i in $(seq "$num"); do
                        echo "Generating /etc/init/wordnet-production-${name}-${i}.conf"

                        if [ "$name" = "web" ]; then
                          port=$((5000 + $i))
                          command=$(echo "$proc" | sed "s/\$PORT/$port/")
                        else
                          command="$proc"
                        fi

                        sudo printf "
                start on starting wordnet-production-${name}
                stop on stopping wordnet-production-${name}
                respawn

                exec su - wordnet -c 'cd /var/www/wordnet/production/current; skylab-run ${command} >> /var/www/wordnet/production/current/log/${name}.${i}.log 2>&1'

                " | sudo sh -c "cat > /etc/init/wordnet-production-${name}-${i}.conf"
                      done
                    fi

                  done)
                
) &&
 (

          if [ -e "/var/www/wordnet/production/current/db/schema.rb" ]; then
            count=`(
              diff -r "/var/www/wordnet/production/current/db/schema.rb" "./db/schema.rb" 2>/dev/null
            ) | wc -l`

            if [ "$((count))" = "0" ]; then
              
                    echo "-----> DB schema unchanged; skipping DB migration"
                  
            else
              
                    echo "-----> $((count)) changes found, migrating database"
                    echo \$\ skylab-run\ rake\ db:migrate &&
skylab-run rake db:migrate
                  
            fi
          else
            
                    echo "-----> Migrating database"
                    echo \$\ skylab-run\ rake\ db:migrate &&
skylab-run rake db:migrate
                  
          fi
        
) &&
 (

          if [ -e "/var/www/wordnet/production/current/public/assets/" ]; then
            count=`(
              diff -r "/var/www/wordnet/production/current/vendor/assets/" "./vendor/assets/" 2>/dev/null
diff -r "/var/www/wordnet/production/current/app/assets/" "./app/assets/" 2>/dev/null
diff -r "/var/www/wordnet/production/current/Gemfile.lock" "./Gemfile.lock" 2>/dev/null
            ) | wc -l`

            if [ "$((count))" = "0" ]; then
              
                    echo "-----> Skipping asset precompilation"
                    echo \$\ cp\ -R\ \"/var/www/wordnet/production/current/public/assets\"\ \"./public/assets\" &&
cp -R "/var/www/wordnet/production/current/public/assets" "./public/assets"
                  
            else
              
                    echo "-----> $((count)) changes found, precompiling asset files"
                    echo \$\ skylab-run\ rake\ assets:precompile &&
skylab-run rake assets:precompile
                  
            fi
          else
            
                    echo "-----> Precompiling asset files"
                    echo \$\ skylab-run\ rake\ assets:precompile &&
skylab-run rake assets:precompile
                  
          fi
        
)
) &&

# Rename to the real release path, then symlink 'current'
(
  echo "-----> Build finished"
  echo "-----> Moving build to $release_path"
  echo \$\ mv\ \"\$build_path\"\ \"\$release_path\" &&
mv "$build_path" "$release_path" &&

  echo "-----> Updating the /var/www/wordnet/production/current symlink" &&
  echo \$\ ln\ -nfs\ \"\$release_path\"\ \"/var/www/wordnet/production/current\" &&
ln -nfs "$release_path" "/var/www/wordnet/production/current"
) &&

# Restaart
(
  echo
  echo "-----> Restarting application"
  (

                  echo "-----> Restarting passenger"
                  echo \$\ touch\ /var/www/wordnet/production/current/tmp/restart.txt &&
touch /var/www/wordnet/production/current/tmp/restart.txt
                
) &&
 (

                  echo "-----> Restarting wordnet-production services"
                  echo \$\ sudo\ start\ wordnet-production\ \|\|\ sudo\ restart\ wordnet-production &&
sudo start wordnet-production || sudo restart wordnet-production
                
)
) &&

# Complete, clean & unlock
(
  echo "-----> Cleaning up old releases (keeping 5)"
  echo \$\ cd\ \"/var/www/wordnet/production/releases\"\ \|\|\ exit\ 15 &&
cd "/var/www/wordnet/production/releases" || exit 15
  echo \$\ count\=\`ls\ -1d\ \[0-9\]\*\ \|\ sort\ -rn\ \|\ wc\ -l\` &&
count=`ls -1d [0-9]* | sort -rn | wc -l`
  echo \$\ remove\=\$\(\(count\ \>\ 5\ \?\ count\ -\ 5\ :\ 0\)\) &&
remove=$((count > 5 ? count - 5 : 0))
  echo \$\ ls\ -1d\ \[0-9\]\*\ \|\ sort\ -rn\ \|\ tail\ -n\ \$remove\ \|\ xargs\ rm\ -rf\ \{\} &&
ls -1d [0-9]* | sort -rn | tail -n $remove | xargs rm -rf {}

  echo \$\ rm\ -f\ \"/var/www/wordnet/production/deploy.lock\" &&
rm -f "/var/www/wordnet/production/deploy.lock"
  echo \$\ echo\ \"\$version\"\ \>\ \"/var/www/wordnet/production/last_version\" &&
echo "$version" > "/var/www/wordnet/production/last_version"
  echo "-----> Done. Deployed v$version"
) ||

# Failed deployment
(
  echo "! ERROR: Deploy failed."
  echo "-----> Cleaning up build"
  [ -e "$build_path" ] && (
    echo \$\ rm\ -rf\ \"\$build_path\" &&
rm -rf "$build_path"
  )
  [ -e "$release_path" ] && (
    echo "Deleting release"
    echo \$\ rm\ -rf\ \"\$release_path\" &&
rm -rf "$release_path"
  )
  (
    echo "Unlinking current"
    echo "$previous_path"
    [ -n "$previous_path" ] && echo \$\ ln\ -nfs\ \"\$previous_path\"\ \"/var/www/wordnet/production/current\" &&
ln -nfs "$previous_path" "/var/www/wordnet/production/current" || true
  )

  # Unlock
  echo \$\ rm\ -f\ \"/var/www/wordnet/production/deploy.lock\" &&
rm -f "/var/www/wordnet/production/deploy.lock"
  exit 19
)
