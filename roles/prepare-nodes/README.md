# Prepare Nodes Role

This role is responsible for preparing the system configuration on all nodes (both servers and agents) before installing and configuring RKE2.

## Tasks

The main tasks performed by this role (as defined in `tasks/main.yaml`) are:

1. Enable IPv4 forwarding
2. Enable IPv6 forwarding
3. Install and configure Helm (on server nodes only)
4. Install and configure Chrony for time synchronization
5. Install nfs-common package

## Usage

This role should be applied to all nodes in the cluster (both servers and agents) as part of the initial setup process.

## Tags

- `sysctl`: Used for tasks related to system control settings (IPv4 and IPv6 forwarding)
- `addNFS`: Used for tasks related to NFS setup

## Task Details

### Enable IPv4 and IPv6 forwarding

These tasks enable IP forwarding, which is necessary for Kubernetes networking to function correctly.

### Install and configure Helm

This task is only performed on server nodes. It installs Helm and adds necessary repositories.

### Install and configure Chrony

Sets up Chrony for time synchronization across all nodes.

### Install nfs-common

Installs the nfs-common package, which is necessary for NFS functionality.

## Dependencies

- Requires the `ansible.posix` collection for the `sysctl` module.

## Notes

- The Helm installation is only performed on server nodes.
- Chrony is used for time synchronization instead of NTP.
- The `addNFS` tag allows for selective execution of NFS-related tasks.

## Potential Improvements

1. Add additional system preparations such as:
   - Disabling swap
   - Setting up required kernel modules
   - Configuring firewall rules
2. Add checks to verify the changes have been applied successfully.
3. Consider making IPv6 forwarding optional based on a variable, in case IPv6 is not used in some environments.
4. Implement more granular tagging for better task selection.
