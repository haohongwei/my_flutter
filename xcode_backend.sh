BUILD_MODE=${CONFIGURATION}
# 根文件
ROOT_PATH="$(dirname $0)"
# 编译目录
BUILD_PATH="${ROOT_PATH}/build_ios/${BUILD_MODE}"
# 存放产物的目录
PRODUCT_PATH="${BUILD_PATH}/BUILD_MODE"

# 存放产物的Git地址
PRODUCT_GIT_URL="git@github.com:haohongwei/FlutterCI_FlutterProduction.git"

# podSpec的名称
Flutter_APPFRAMEWORK_PODSPEC_NAME="my_flutter.podspec"

temp=${PRODUCT_GIT_URL##*/}

# Git的目录
PRODUCT_GIT_DIR="${ROOT_PATH}/.ios/${temp%.*}"
# Git存放产物的目录
PRODUCT_GIT_BUILD_DIR="${PRODUCT_GIT_DIR}/${BUILD_MODE}"

echo "PRODUCT_GIT_DIR  ${PRODUCT_GIT_DIR}"

current_path="$PWD"
echo "current_path  ${current_path}"


flutter_copy_packages() {
    echo "================================="
    echo "Start copy flutter app plugin"
    MYDIR=`dirname $0`

    local flutter_appframework="App.framework"
    local flutter_appframework_podspec="${Flutter_APPFRAMEWORK_PODSPEC_NAME}"
    local flutter_appframework_plist="AppFrameworkInfo.plist"
    local flutter_appframework_path="${MYDIR}/.ios/Flutter/"

    local flutter_flutterframework_path="${MYDIR}/.ios/Flutter/engine/"
    local flutter_flutterframework="engine"
    
    local flutter_plugin_registrant="FlutterPluginRegistrant"
    local flutter_plugin_registrant_path="${MYDIR}/.ios/Flutter/${flutter_plugin_registrant}"
    echo "copy 'flutter_plugin_registrant' from '${flutter_plugin_registrant_path}' to '${PRODUCT_PATH}/${flutter_plugin_registrant}'"

    if [ -d "${PRODUCT_GIT_DIR}" ]; then
      rm -rf ${PRODUCT_GIT_DIR}
    fi
  
    mkdir -p "$PRODUCT_GIT_DIR"

    git clone "$PRODUCT_GIT_URL" "$PRODUCT_GIT_DIR"

    if [ -d "${PRODUCT_GIT_BUILD_DIR}" ]; then
      rm -rf ${PRODUCT_GIT_BUILD_DIR}
    fi

    mkdir -p "$PRODUCT_GIT_BUILD_DIR"

    cp -rf -- "${flutter_appframework_path}${flutter_appframework}" "${PRODUCT_GIT_BUILD_DIR}"
    cp -rf -- "${flutter_appframework_path}${flutter_appframework_podspec}" "${PRODUCT_GIT_BUILD_DIR}"
    cp -rf -- "${flutter_appframework_path}${flutter_appframework_plist}" "${PRODUCT_GIT_BUILD_DIR}"

    cp -rf -- "${flutter_flutterframework_path}" "${PRODUCT_GIT_BUILD_DIR}/${flutter_flutterframework}"


    cp -rf -- "${flutter_plugin_registrant_path}" "${PRODUCT_GIT_BUILD_DIR}/${flutter_plugin_registrant}"

    local flutter_plugin="${ROOT_PATH}/.flutter-plugins"
    if [ -e $flutter_plugin ]; then
        OLD_IFS="$IFS"
        IFS="="
        cat ${flutter_plugin} | while read plugin; do
            local plugin_info=($plugin)


            	local plugin_name=${plugin_info[0]}
           	 echo "Start copy ${plugin_name}"
            	local plugin_path=${plugin_info[1]}

            	if [ -e ${plugin_path} ]; then
                	local plugin_path_ios="${plugin_path}ios"
                	if [ -e ${plugin_path_ios} ]; then
                   	 if [ -s ${plugin_path_ios} ]; then
                        	echo "copy plugin 'plugin_name' from '${plugin_path_ios}' to '${PRODUCT_GIT_BUILD_DIR}/${plugin_name}'"
                        	cp -rf ${plugin_path_ios} "${PRODUCT_GIT_BUILD_DIR}/${plugin_name}"
                    	fi
                	fi
	fi
	done

        IFS="$OLD_IFS"
    fi

    echo "Finish copy flutter app plugin"
}

upload_product() {
    echo "================================="
    echo "upload product"

    echo "${PRODUCT_PATH}"
    echo "PRODUCT_GIT_DIR"
    echo "${PRODUCT_GIT_DIR}"
    echo "PRODUCT_GIT_DIR_Finish"

    pushd ${ROOT_PATH}
    local app_version=$(./get_version.sh)
    echo "Start copy ${app_version}"
    popd

    pushd ${PRODUCT_GIT_DIR}
    git lfs track "Flutter" 
    git add .
    git commit -m "Flutter product ${app_version}"
    
    git push

    popd 
}

flutter_copy_packages
upload_product
