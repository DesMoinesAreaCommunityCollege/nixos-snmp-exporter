{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.jcollie.snmp-exporter;
  format = pkgs.formats.yaml { };
  generator-yml = format.generate "generator.yml" cfg.settings;
  generator = pkgs.linkFarm "generator" [
    {
      name = "generator.yml";
      path = generator-yml;
    }
  ];
in
{
  options = {
    jcollie.snmp-exporter = {
      enable = lib.mkEnableOption "snmp-exporter";
      package = lib.mkPackageOption pkgs "prometheus-snmp-exporter" { };
      mib-packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      module-concurrency = lib.mkOption {
        type = lib.types.ints.positive;
        default = 1;
      };
      listen-address = lib.mkOption {
        type = lib.types.str;
        default = ":9116";
        example = "[::1]:9116";
        description = ''
          Address passed to snmp_exporter's --web.listen-address. The default
          binds every interface; set a loopback address when only a local
          Prometheus scrapes it. Note that snmp_exporter will poll any target
          asked of it using the configured community, so it should not be
          reachable more widely than necessary.
        '';
      };
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = format.type;
        };
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    jcollie.snmp-exporter.settings = {
      version = lib.mkDefault 2;
    };
    systemd.services.prometheus-snmp-exporter = {
      description = "SNMP exporter";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        MIBDIRS = lib.makeSearchPath "share/snmp/mibs" cfg.mib-packages;
      };
      preStart = ''
        cd ${generator}
        ${lib.getExe' cfg.package "generator"} generate --no-fail-on-parse-errors --output-path=/run/snmp-exporter/snmp.yml
      '';
      serviceConfig = {
        RuntimeDirectory = "snmp-exporter";
        ProtectHome = true;
        ExecStart = "${lib.getExe' cfg.package "snmp_exporter"} --web.listen-address=${cfg.listen-address} --snmp.module-concurrency=${toString cfg.module-concurrency} --config.file=/run/snmp-exporter/snmp.yml";
      };
    };
  };
}
