source $(pwd)/../config.sh
source $(pwd)/../utils/log.sh
source $(pwd)/../utils/dropbox.sh

install_dropbox_uploader ${temp_dir}
config_dropbox_uploader ${dropbox_oauth_app_key} ${dropbox_oauth_app_secret} ${dropbox_oauth_refresh_token}

check_dropbox_folder "/noexist" || echo "/noexist" "noexist"
make_dropbox_folder "/exist"
make_dropbox_folder "/exist"
check_dropbox_folder "/exist" && echo "/exist" "exist"
touch homeserver-20201225-173039.tgz
dropbox_upload "/noexist" "./homeserver-20201225-173039.tgz"
dropbox_upload "/exist" "./homeserver-20201225-173039.tgz"

# Note that ${delete_file} will be the name of the file, without path.
dropbox_delete "/noexist" "homeserver-20201225-173039.tgz"
dropbox_delete "/exist" "homeserver-abc.tgz"
dropbox_delete "/exist" "homeserver-20201225-173039.tgz"
