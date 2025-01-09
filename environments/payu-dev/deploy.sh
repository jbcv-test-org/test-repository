# Switch payu-dev version

### Update payu-dev
DEV_ENV_ALIAS="${ENVIRONMENT}"-dev
CURRENT_DEV_MODULE=$( get_aliased_module "${MODULE_NAME}"/dev "${MODULE_PATH}" )
NEXT_DEV_ENV="${ENVIRONMENT}-${VERSION_TO_MODIFY}"

echo "Updating dev environment to ${NEXT_DEV_ENV}"
write_modulerc_stable "${VERSION_TO_MODIFY}" "dev" "${CONDA_MODULE_PATH}" "${MODULE_NAME}"
symlink_atomic_update "${CONDA_INSTALLATION_PATH}"/envs/"${DEV_ENV_ALIAS}" "${NEXT_DEV_ENV}"
symlink_atomic_update "${CONDA_SCRIPT_PATH}"/"${DEV_ENV_ALIAS}".d "${NEXT_DEV_ENV}".d

# Remove old versions of payu-dev
# List of modulefiles
payu_dev_versions=$(ls "${CONDA_MODULE_PATH}" | grep -E '^dev-[0-9]{8}T[0-9]{6}Z-.*')
# Order by date, and remove the 2 latest versions
old_versions=$(echo "$payu_dev_versions" | sort -r | tail -n +3)

echo "::notice::Removed payu/dev versions: $old_versions"
echo "Previous dev version: $CURRENT_DEV_MODULE"

# For each version
for old_version in $old_versions; do
    # Check old version is not an empty string
    if [ -z "$old_version" ]; then
        echo "Old version is empty string - Check payu_dev_versions list"
        continue
    fi
    # Remove modulefiles
    echo "${CONDA_MODULE_PATH}"/"${old_version}"
    #rm -rf "${CONDA_MODULE_PATH}"/"${old_version}"
    # Remove script directories
    echo "${CONDA_SCRIPT_PATH}"/"${ENVIRONMENT}"-"${old_version}".d
    #rm -rf "${CONDA_SCRIPT_PATH}"/"${old_version}".d
    # Remove squashfs files
    echo "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}"-"${old_version}".sqsh
    #rm -rf "${CONDA_INSTALLATION_PATH}"/envs/"${old_version}".sqsh
    # Remove conda environment symlink
    echo "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}"-"${old_version}"
    # unlink "${CONDA_INSTALLATION_PATH}"/envs/"${old_version}"
done

# Alternatively could store tar of old payu-dev environments in /scratch/ location
# so delete is not permanent, however unlikely need payu-dev environments?
# How avoid the risks of rm -rf commands?