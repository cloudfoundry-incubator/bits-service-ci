#!/bin/bash -e

call_version_info=false

function main {
    cmd $@
    init
    authenticate
    # echo ${call_version_info}
    if [ ${call_version_info} == true ]
    then
        latest_version
    else
        uplaod
    fi
}

function init {
    export API_KEY=$(lpass show "Shared-Flintstone"/"ci-eirini-resources" --password)
    export RESOURCE_INSTANCE_ID=$(lpass show "Shared-Flintstone"/"ci-eirini-resources" --username)
    export ENDPOINT=$(lpass show "Shared-Flintstone"/"ci-eirini-resources" --url)
}

function authenticate {
    printf "[INFO] Do authenticate \n"
    export ACCESS_TOKEN=$(\
      curl -X "POST" "https://iam.bluemix.net/oidc/token" \
           -H 'Accept: application/json' \
           -H 'Content-Type: application/x-www-form-urlencoded' \
           --data-urlencode "apikey=${API_KEY}" \
           --data-urlencode "response_type=cloud_iam" \
           --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
           -s \
           | jq '.["access_token"]' \
           | tr -d '"')

    if [ -z ${ACCESS_TOKEN} ]
    then
        printf "[ERROR] Not authenticated! \n"
        exit 1
    else
        printf "[INFO] Succesful authenticated!\n"
    fi
}

function uplaod {
    printf "[INFO] Start upload file eirinifs_v${EIRINI_TAR_VERSION}.tar ... \n"
    curl -X "PUT" "${ENDPOINT}/eirinifs_v${EIRINI_TAR_VERSION}.tar" \
         -H "Authorization: bearer $(echo ${ACCESS_TOKEN} | tr -d '"')" \
         -H "Content-Type: application/octet-stream" \
         --data-binary @$HOME/workspace/eirini-release/eirinifs.tar \
         --progress-bar \
         | tee -a "/tmp/eirini-upload.log" ; test ${PIPESTATUS[0]} -eq 0

    printf "[INFO] Finished the upload of the file eirinifs_v${EIRINI_TAR_VERSION}.tar! \n"
}

function latest_version {
    curl "${ENDPOINT}" \
         -H "Authorization: Bearer $(echo ${ACCESS_TOKEN} | tr -d '"')" \
         -H "ibm-service-instance-id: ${RESOURCE_INSTANCE_ID}" \
         -s
}

function cmd {
    # printf "[DEBUG] args check\n"
    # echo "Args 1 = $1"
    #  echo "Args 2 = $2"
    version_number=""=$2
    while [ "$1" != "" ]; do
        case $1 in
            -v | --file-version )       shift
                                        EIRINI_TAR_VERSION=${version_number}
                                        ;;
            -i | --file-version-info )  call_version_info=true
                                        ;;
            -h | --help )               echo "usage: ./upload_to_object_store.sh -i list all the eisting onjects."
                                        echo "usage: ./upload_to_object_store.sh -v <file version > upload the file."
                                        exit
                                        ;;
            * )                         usage
                                        exit 1
        esac
    shift
    done

}
# start
if [ -z ${1} ]
then
    main "-h"
else
    main $@
fi
