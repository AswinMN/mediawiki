## Install MOSIP Sandbox on AWS using Terraform

### Setup
1. Obtain a domain name for the sandbox using AWS Route53, example, `abc.com`.  This is required to access sandbox externally.

1. Install latest version of terraform. 

1. Set the following environment variables:
    ```
    export AWS_ACCESS_KEY_ID=<>
    export AWS_SECRET_ACCESS_KEY=<>
    export TF_LOG=DEBUG
    export TF_LOG_PATH=tf.log  
    ```
1. On AWS EC2 admin console generate a key pair called `aswin`.  Download the private key `aswin.pem` to your local `~/.ssh` folder. Make sure the permission of `~/.ssh/aswin.pem` is set to 600. 

1. Generate a new set of RSA key pairs with default names `id_rsa` and `id_rsa.pub` and place them in current folder. Do not give any passphrase. These keys are exchanged between sandbox console and cluster machines.
    ```
    $ ssh-keygen -t rsa -f ./id_rsa
    ```
1. Modify `sandbox_name` in `variables.tf` as per your setup.  The name here is informational and will be added as tag to the instance.  It is recommended this name matches subdomain name for easy reference (see below).  Example, `sandbox_name` is `staging` and subdomain is `staging.abc.com`. 

1. If you are doing performance testing and prefer higher IOPS SSD on sandbox console, modify `iops` and `volume_type` in `console.tf`. Example:
    ```
    ebs_block_device  { 
      device_name = "/dev/sdf"
      iops = 3000
      volume_type = "io1"
      volume_size = 128
      delete_on_termination = true 
    } 
    ```

There are other variables, do not modify them unless you have a good understanding of the scripts and their impact on Ansible scripts. 

### Install

1. Run terraform:

    ```
1. Open the "Hosted Zones" on AWS admin console. Your domain name (e.g. `abc.com`) should be listed there.  Assign a subdomain like `test.abc.com` to point to public IP address ('A') of sandbox console machine on AWS Route53 Console.  Use this subdomain as `sandbox_domain_name` in Ansible scripts.

