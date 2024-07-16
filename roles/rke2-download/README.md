# RKE2 Download Role

This role is responsible for downloading and setting up the RKE2 binary on all nodes in the cluster.

## Tasks

The main tasks performed by this role (as defined in `tasks/main.yaml`) are:

1. Create a directory for the RKE2 binary
2. Check if RKE2 binary already exists
3. Remove old RKE2 binary if necessary
4. Download the RKE2 binary with version-specific name
5. Create a symlink to the version-specific binary
6. Set executable permissions on the RKE2 binary

## Variables

This role uses the following variables, which are defined in `inventory/group_vars/all.yaml`:

- `rke2_install_dir`: The directory where the RKE2 binary will be installed
- `rke2_binary_url`: The URL from which to download the RKE2 binary
- `rke2_version`: The version of RKE2 to install
- `force_rke2_download`: A boolean flag to force re-download of the RKE2 binary

## Tags

This role doesn't use specific tags, but it's part of the overall RKE2 installation process.

## Notes

- The role now uses version-specific naming for the RKE2 binary, allowing for easier version management.
- A symlink is created to the version-specific binary, allowing for easy updates and rollbacks.
- The `force_rke2_download` variable allows for forced re-download of the RKE2 binary, useful for upgrades or troubleshooting.

## Potential Improvements

1. Implement a version check to only download if a newer version is available.
2. Add error handling for download failures.
3. Implement a rollback mechanism in case of failed upgrades.
4. Add support for different architectures (e.g., arm64).
5. Implement a cleanup task to remove old versions of the RKE2 binary.
