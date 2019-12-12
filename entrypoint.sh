#!/bin/bash
# Deskription: Script to install hybris accelerator on docker execution
# Date: 13/08/2018
# Author: Helisandro Krepel
# Maintainer: Paulo Henrique dos Santos


###################### CONSTANTS #######################
LOG_FILE="$DOCKER_HOME/entrypoint.log"
########################################################


####################### METHODS ######################K#
extract_hybris(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris directories (hybris)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_VERSION" 'hybris/*' -d "$HYBRIS_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris directories (installer)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_VERSION" 'installer/*' -d "$HYBRIS_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris directories (build-tools)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_VERSION" 'build-tools/*' -d "$HYBRIS_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris directories (licenses)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_VERSION" 'licenses/*' -d "$HYBRIS_DIR/"  >> "$LOG_FILE"

    rm -rf "$HYBRIS_DIR/hybris/bin/platform/resources/ant/sonar.xml" >> "$LOG_FILE"
}

extract_java(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Java" >> "$LOG_FILE"
    cd "$DOCKER_HOME"
    sudo tar -zxvf "$JAVA_VERSION_FILE"  >> "$LOG_FILE"
    sudo mv jdk1.8.0_211/ /usr/lib/jvm/java-8-oracle/ >> "$LOG_FILE"
}

set_java(){
    java_home=`echo "$JAVA_HOME"`
    if [ "$java_home" = "" ]; then
        
        extract_java
        
        export JAVA_HOME=/usr/lib/jvm/java-8-oracle/  >> "$LOG_FILE"
        source ~/.bashrc
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Setting JAVA_HOME ($JAVA_HOME)" >> "$LOG_FILE"
    else
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - JAVA_HOME ($JAVA_HOME)" >> "$LOG_FILE"
    fi;
}

set_git(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - GIT Config" >> "$LOG_FILE"
    mkdir -p $HYBRIS_DIR_CUSTOM
    cd "$HYBRIS_DIR_CUSTOM"
    git config --global user.name "$DEVELOPER_NAME"
    git config --global user.email "$DEVELOPER_EMAIL"
    git config --global core.filemode false
    git config --global core.excludesfile ~/.gitignore
    git config --global alias.lg "log --graph --abbrev-commit --decorate --date=iso --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%cd)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --since=7.days"
    git config --global alias.st "status -sb"
    git config --global merge.ours.driver true
    git config --global pull.ff only
    git config --global merge.ff false
    git config --global http.sslVerify false
    
    echo -e "Host bitbucket.fh.com.br\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
    
    git init >> "$LOG_FILE"
    git remote add origin <repos_url>
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Adding repos clcc" >> "$LOG_FILE"
    git fetch origin $BRANCH_NAME:$BRANCH_NAME >> "$LOG_FILE"
    git checkout $BRANCH_NAME
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Checkout branch $BRANCH_NAME" >> "$LOG_FILE"
}

copy_installer(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Copping recipes folder to default hybris installer folder" >> "$LOG_FILE"
    cd $HYBRIS_DIR_CUSTOM >> "$LOG_FILE"
    cp -R recipes $HYBRIS_DIR/installer >> "$LOG_FILE"
}

copy_db_driver(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Coping mysql driver" >> "$LOG_FILE"
    cp "$DOCKER_HOME/$DB_DRIVER" "$HYBRIS_DIR/hybris/bin/platform/lib/dbdriver/"
}

copy_ssh_keys(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Coping SSH keys to home" >> "$LOG_FILE"
    cd $HYBRIS_DIR
    cp -R ssh_keys/id_rsa $DOCKER_HOME/.ssh >> "$LOG_FILE"
    cp -R ssh_keys/id_rsa.pub $DOCKER_HOME/.ssh >> "$LOG_FILE"
}

run_grunt(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Installing Grunt" >> "$LOG_FILE"
    cd $HYBRIS_DIR_CUSTOM/hybris/bin/custom/storefront/web
    sudo npm install -g grunt >> "$LOG_FILE"
    # grunt >> "$LOG_FILE"
}

run_npm(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Running Npm" >> "$LOG_FILE"
    cd $HYBRIS_DIR_CUSTOM/hybris/bin/custom/storefront/web
    npm i >> "$LOG_FILE"
    npm run start >> "$LOG_FILE"
}

resolve_conflicts(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Fixing files conflicts" >> "$LOG_FILE"
    rm -rf "$HYBRIS_DIR/hybris/config" >> "$LOG_FILE"
}

run_installer(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Installing Recipe ($RECIPE)" >> "$LOG_FILE"
    cd "$HYBRIS_DIR/installer"
    ./install.sh -r "$RECIPE" >> "$LOG_FILE"
    
    if [ "$INITIALIZE" = 'true' ]; then
        ./install.sh -r "$RECIPE" initialize >> "$LOG_FILE"
    fi;
}

reset_git(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Reseting Git" >> "$LOG_FILE"
    cd $HYBRIS_DIR_CUSTOM >> "$LOG_FILE"
    git reset HEAD --hard >> "$LOG_FILE"
}
########################################################


######################### MAIN #########################
if [ "$1" = 'run' ]; then
    
    if [ ! -d "$HYBRIS_DIR/hybris/config" ]; then
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Changing permition at $HYBRIS_DIR to $HYBRIS_USER" >> "$LOG_FILE"
        sudo chown -R "$HYBRIS_USER":"$HYBRIS_USER" "$HYBRIS_DIR"  >> "$LOG_FILE"
        sudo chown -R "$HYBRIS_USER":"$HYBRIS_USER" "$DOCKER_HOME"  >> "$LOG_FILE"
        
        extract_hybris
        
        set_java
        
        copy_ssh_keys
        
        set_git
        
        # copy_installer
        
        resolve_conflicts
        
        copy_db_driver
        
        run_installer
        
        reset_git
        
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - ant clean all" >> "$LOG_FILE"
        /etc/init.d/hybris ant_clean_all >> "$LOG_FILE"
        
        run_grunt
        
        run_npm
        
        echo "##### Finished... Next Step: do your job! :) #####"  >> "$LOG_FILE"
        echo "##### P.S. Hybris is stopped #####"  >> "$LOG_FILE"
        # /etc/init.d/hybris debug
        
    else
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Hybris Directories (hybris, installer) already exists" >> "$LOG_FILE"
        
        if [ "$INITIALIZE" = 'true' ]; then
            echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Installing Recipe ($RECIPE)" >> "$LOG_FILE"
            cd "$HYBRIS_DIR/installer"
            ./install.sh -r "$RECIPE" >> "$LOG_FILE"
            ./install.sh -r "$RECIPE" initialize >> "$LOG_FILE"
        fi;
    fi;
    
    sleep infinity
fi;
########################################################
