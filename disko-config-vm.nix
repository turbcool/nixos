{
  disko.devices.disk.vda = {
    type = "disk";
    device = "/dev/vda";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "root";
          start = "1MiB";
          end = "10GiB";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        }
        {
          name = "home";
          start = "10GiB";
          end = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        }
      ];
    };
  };
}
