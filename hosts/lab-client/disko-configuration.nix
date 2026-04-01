{
  disko.devices.disk.main = {
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };

        root = {
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };

        swap = {
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };
      };
    };
  };
}
