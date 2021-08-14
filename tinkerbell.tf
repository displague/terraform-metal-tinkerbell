provider "tinkerbell" {
  grpc_authority = "127.0.0.1:42113"
  cert_url       = "http://127.0.0.1:42114/cert"
}

resource "tinkerbell_hardware" "foo" {
  data = jsonencode({
    id = "b91059ff-f174-46e6-bbc9-fd3a789f883f",
    metadata = {
      facility = {
        facility_code     = "sjc1"
        plan_slug         = "c3.small.x86"
        plan_version_slug = ""
      }
      instance = {}
      state    = ""
    }
    network = {
      interfaces = [
        {
          dhcp = {
            arch = "x86_64"
            ip = {
              address = "192.168.1.5"
              gateway = "192.168.1.1"
              netmask = "255.255.255.248"
            }
            mac  = "${module.tinkerbell.worker_mac_addr[0]}"
            uefi = false
          }
          netboot = {
            allow_pxe      = true
            allow_workflow = true
          }
        }
      ]
    }
  })
}

resource "tinkerbell_template" "foo" {
  name    = "foo"
  content = <<EOF
version: "0.1"
name: Ubuntu_Focal
global_timeout: 1800
tasks:
  - name: "os-installation"
    worker: "{{.device_1}}"
    volumes:
      - /dev:/dev
      - /dev/console:/dev/console
      - /lib/firmware:/lib/firmware:ro
    actions:
      - name: "stream-ubuntu-image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
        timeout: 600
        environment:
          DEST_DISK: /dev/sda
          IMG_URL: "http://192.168.1.1:8080/tink-ubuntu-2004-cloud-init.raw.gz"
          COMPRESSED: true
      - name: "fix-serial"
        image: quay.io/tinkerbell-actions/cexec:v1.0.0
        timeout: 90
        pid: host
        environment:
          BLOCK_DEVICE: /dev/sda1
          FS_TYPE: ext4
          CHROOT: y
          DEFAULT_INTERPRETER: "/bin/sh -c"
          CMD_LINE: "sed -e 's|ttyS0|ttyS1,115200|g' -i /etc/default/grub.d/50-cloudimg-settings.cfg ; update-grub"
      - name: "kexec-ubuntu"
        image: quay.io/tinkerbell-actions/kexec:v1.0.0
        timeout: 90
        pid: host
        environment:
          BLOCK_DEVICE: /dev/sda1
          FS_TYPE: ext4
EOF
}

resource "tinkerbell_workflow" "foo" {
  template  = tinkerbell_template.foo.id
  hardwares = <<EOF
{"device_1":"${module.tinkerbell.worker_mac_addr[0]}"}
EOF

  depends_on = [
    tinkerbell_hardware.foo,
  ]
}
