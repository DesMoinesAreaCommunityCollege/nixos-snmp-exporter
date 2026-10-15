{
  description = "SNMP Mibs";

  inputs = {
    nixpkgs = {
      url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      packages =
        system:
        import nixpkgs {
          inherit system;
        };
      forAllSystems = (function: nixpkgs.lib.genAttrs platforms (system: function (packages system)));

      mib-packages =
        pkgs: [
          pkgs.net-snmp.out
          self.packages.${pkgs.stdenv.hostPlatform.system}.cisco-mibs.v2
          self.packages.${pkgs.stdenv.hostPlatform.system}.cisco-mibs.v1
          self.packages.${pkgs.stdenv.hostPlatform.system}.powernet-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ianacharset-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ianaiftype-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ianaprinter-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.printer-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ubnt-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ubnt-unifi-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.ubnt-airmax-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.remotekvmdevice-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.mikrotik-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.palo-alto-mibs
          # self.packages.${pkgs.stdenv.hostPlatform.system}.informacast-mibs
          # self.packages.${pkgs.stdenv.hostPlatform.system}.liebert-mibs-1
          # self.packages.${pkgs.stdenv.hostPlatform.system}.liebert-mibs-2
          # self.packages.${pkgs.stdenv.hostPlatform.system}.anetd-mibs
          self.packages.${pkgs.stdenv.hostPlatform.system}.geist-v3-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.geist-v4-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.dns-server-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.dsg-if-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.docs-if3-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.docs-if31-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.docs-if40-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.docs-pnm-mib
          self.packages.${pkgs.stdenv.hostPlatform.system}.uri-tc-mib
        ];

      net-snmp-mibs = [
        "DISMAN-EVENT-MIB"
        "DISMAN-SCHEDULE-MIB"
        "HOST-RESOURCES-MIB"
        "HOST-RESOURCES-TYPES"
        "IF-MIB"
        "IP-FORWARD-MIB"
        "IP-MIB"
        "IPV6-ICMP-MIB"
        "IPV6-MIB"
        "IPV6-TCP-MIB"
        "IPV6-UDP-MIB"
        "NET-SNMP-AGENT-MIB"
        "NET-SNMP-EXTEND-MIB"
        "NET-SNMP-PASS-MIB"
        "NET-SNMP-VACM-MIB"
        "NOTIFICATION-LOG-MIB"
        "SNMP-COMMUNITY-MIB"
        "SNMP-FRAMEWORK-MIB"
        "SNMP-MPD-MIB"
        "SNMP-NOTIFICATION-MIB"
        "SNMP-TARGET-MIB"
        "SNMP-USER-BASED-SM-MIB"
        "SNMP-VIEW-BASED-ACM-MIB"
        "SNMPv2-MIB"
        "SNMPv2-SMI"
        "SNMPv2-TM"
        "TCP-MIB"
        "UCD-DEMO-MIB"
        "UCD-DLMOD-MIB"
        "UCD-SNMP-MIB"
        "UDP-MIB"
      ];
      ubnt-dl-url = "https://dl.ubnt-ut.com/snmp";
    in
    {
      packages = forAllSystems (
        pkgs:
        builtins.foldl' (a: b: a // b) { } [
          (builtins.mapAttrs
            (
              name: value:
              pkgs.stdenvNoCC.mkDerivation {
                name = name;
                pname = name;
                src = pkgs.fetchurl {
                  url = value.url;
                  hash = value.hash;
                };
                dontUnpack = true;
                dontPatch = true;
                dontConfigure = true;
                dontBuild = true;
                dontFixup = true;
                installPhase = ''
                  install -d $out/share/snmp/mibs
                  install -m 0444 $src $out/share/snmp/mibs/${value.mibname}
                '';
                postInstall = "";
              }
            )
            {
              powernet-mib =
                let
                  version = "4.6.0";
                  shortVersion = builtins.replaceStrings [ "." ] [ "" ] version;
                in
                {
                  mibname = "PowerNet-MIB";
                  url = "https://download.schneider-electric.com/files?p_Doc_Ref=APC_POWERNETMIB_EN&p_enDocType=Firmware&p_File_Name=powernet${shortVersion}.mib";
                  hash = "sha256-XU0ORHA3gILD3+snl9gZONRhvm6Kni9ZACyTVks0fgA=";
                };
              ianacharset-mib = {
                mibname = "IANA-CHARSET-MIB";
                url = "https://www.iana.org/assignments/ianacharset-mib/ianacharset-mib";
                hash = "sha256-VdNVMZThCOs/A24cxvjr0QaVoDASVfmbewMIJ0zMcMw=";
              };
              ianaiftype-mib = {
                mibname = "IANA-IFTYPE-MIB";
                url = "https://www.iana.org/assignments/ianaiftype-mib/ianaiftype-mib";
                hash = "sha256-xnYZLtxJLrBow6onVZkcNMBh4QPd0S5mU3lbOBO4Klk=";
              };
              ianaprinter-mib = {
                mibname = "IANA-PRINTER-MIB";
                url = "https://www.iana.org/assignments/ianaprinter-mib/ianaprinter-mib";
                hash = "sha256-LBTt+C3zZEKS+qv4JduRvdnjNaVZat6afg1R0/lv5cQ=";
              };
              ubnt-mib = {
                mibname = "UBNT-MIB";
                url = "${ubnt-dl-url}/UBNT-MIB";
                hash = "sha256-4Ar6EHXTLLq/9a93slrup9AL7Arp5CF3yCXsTbHCEco=";
              };
              ubnt-unifi-mib = {
                mibname = "UBNT-UniFi-MIB";
                url = "${ubnt-dl-url}/UBNT-UniFi-MIB";
                hash = "sha256-zwR4LSXFy2Wjb9Sorkdmbi7MM74U2e14TlOyKsWqfDg=";
              };
              printer-mib = {
                mibname = "PRINTER-MIB";
                url = "https://ftp.pwg.org/pub/pwg/pmp/mibs/rfc3805b.mib";
                hash = "sha256-eVnoqnMqOiwaTbinGoTTnfrETxiJeD0A1HiDeDf69vo=";
              };
              remotekvmdevice-mib =
                let
                  version = "2.7.0";
                in
                {
                  mibname = "RemoteKVMDevice-MIB";
                  url = "https://d3b2us605ptvk2.cloudfront.net/download/kxii/v${version}/RemoteKVMDevice-MIB.txt";
                  hash = "sha256-6S8b0qGBpbQ8BrN+WApw2ytDt4X8H7/mZ1nD6GcjH0M=";
                };
              mikrotik-mib = {
                mibname = "MIKROTIK-MIB";
                url = "https://box.mikrotik.com/f/a41daf63d0c14347a088/?dl=1";
                hash = "sha256-8AA1Xgl/aFfFJ4mKGJj93JUnTust94CBVEfq61AzTas=";
              };
              geist-v3-mib = {
                mibname = "GEIST-MIB-V3";
                url = "https://raw.githubusercontent.com/librenms/librenms/master/mibs/geist/GEIST-MIB-V3";
                hash = "sha256-+QuVZKPzbiAJhqRSsu4YXDETroXUnyL0RoU6Ss3mmsM=";
              };
              geist-v4-mib = {
                mibname = "GEIST-V4-MIB";
                url = "https://raw.githubusercontent.com/librenms/librenms/master/mibs/geist/GEIST-V4-MIB";
                hash = "sha256-tsjydHk9rXsYcThK414/NiY+zArWp9fbCioVS+xxIBs=";
              };
              dns-server-mib = {
                mibname = "DNS-SERVER-MIB";
                url = "https://raw.githubusercontent.com/Poil/MIBs/141ba7f350a739a01d8e56f2aa4a843d46cfa259/DNS-SERVER-MIB";
                hash = "sha256-TXd959duL32ky51bH94gwTtV5DaX38a2KGVEIzs7wxY=";
              };
              docs-pnm-mib = {
                mibname = "DOCS-PNM-MIB";
                url = "http://mibs.cablelabs.com/MIBs/DOCSIS/DOCS-PNM-MIB.mib";
                hash = "sha256-CuaoNGbsgaeks24dNb1/cId+cfOPzdT7hhpIp5cVpgQ=";
              };
              dsg-if-mib = {
                mibname = "DSG-IF-MIB";
                url = "http://mibs.cablelabs.com/MIBs/DOCSIS/DSG-IF-MIB.mib";
                hash = "sha256-kBNnEybswa0LF6H+LaldD40RuCyko52Q4LckCccjNZw=";
              };
              docs-if3-mib = {
                mibname = "DOCS-IF3-MIB";
                url = "http://mibs.cablelabs.com/MIBs/DOCSIS/DOCS-IF3-MIB.mib";
                hash = "sha256-71dfVEpTYYICxvSjdCvN+ejnSF40NhPSs841cSEAnFg=";
              };
              docs-if31-mib = {
                mibname = "DOCS-IF31-MIB";
                url = "http://mibs.cablelabs.com/MIBs/DOCSIS/DOCS-IF31-MIB.mib";
                hash = "sha256-IlIGlfnE2IxQjutJeQkr0oRPDbcvJ1caSGPBkNI9msU=";
              };
              docs-if40-mib = {
                mibname = "DOCS-IF40-MIB";
                url = "http://mibs.cablelabs.com/MIBs/DOCSIS/DOCS-IF40-MIB.mib";
                hash = "sha256-WCaK1akdANIRzgQRAPSACoS9QcSihB04Pm3RLikW9pw=";
              };
              uri-tc-mib = {
                mibname = "URI-TC-MIB";
                url = "https://raw.githubusercontent.com/rlaager/docsis/refs/heads/master/mibs/ietf/URI-TC-MIB";
                hash = "sha256-qu/BL0NwR2SHLs/j7olg3s5ro/qDJeKjRgJ/ruIgW1c=";
              };
            }
          )
          {
            cisco-mibs = pkgs.stdenvNoCC.mkDerivation {
              name = "cisco-mibs";
              pname = "cisco-mibs";
              src = pkgs.fetchFromGitHub {
                owner = "cisco";
                repo = "cisco-mibs";
                rev = "26b38ac1b25a38510b6bb308465dd068e79df64b";
                hash = "sha256-U1ptTVBkAVSPNL3cuLWDyLqUkiygWWfqJJuVks6Z0aA=";
              };
              outputs = [
                "v2"
                "v1"
                "out"
              ];
              dontPatch = true;
              dontConfigure = true;
              dontFixup = true;
              buildPhase = ''
                rm v1/test-mib-v1smi.my
                for mib in ${pkgs.lib.concatStringsSep " " net-snmp-mibs}
                do
                  grep --files-with-matches --null --perl-regexp "(?<!\\S)$mib DEFINITIONS" v1/* | xargs -0 -iMIB rm MIB || true
                done
                for mib in ${pkgs.lib.concatStringsSep " " net-snmp-mibs}
                do
                  grep --files-with-matches --null --perl-regexp "(?<!\\S)\\b$mib DEFINITIONS" v2/* | xargs -0 -iMIB rm MIB || true
                done
              '';
              installPhase = ''
                install -d $out
                install -d $v1/share/snmp/mibs
                install -d $v2/share/snmp/mibs
                for mib in v1/*.my
                do
                  install -m 0444 ''${mib} $v1/share/snmp/mibs/''$(basename ''${mib} .my)
                done
                for mib in v2/*.my
                do
                  install -m 0444 ''${mib} $v2/share/snmp/mibs/''$(basename ''${mib} .my)
                done
              '';
              postInstall = "";
            };
            ubnt-airmax-mib = pkgs.stdenvNoCC.mkDerivation {
              name = "ubnt-airmax-mib";
              pname = "ubnt-airmax-mib";
              src = pkgs.fetchurl {
                url = "https://dl.ubnt.com/firmwares/airos-ubnt-mib/ubnt-mib.zip";
                sha256 = "sha256-Wv/KOqcHNy1uA0NugX6c1PaFbjLWeD4SviUra+v91PY=";
              };
              setSourceRoot = "sourceRoot=`pwd`";
              nativeBuildInputs = [
                pkgs.unzip
              ];
              dontUnpack = false;
              dontPatch = true;
              dontConfigure = true;
              dontBuild = true;
              dontFixup = true;
              installPhase = ''
                install -d $out/share/snmp/mibs
                install -m 0444 UBNT-AirMAX-MIB.txt $out/share/snmp/mibs/UBNT-AirMAX-MIB
              '';
              postInstall = "";
            };
            palo-alto-mibs = pkgs.stdenvNoCC.mkDerivation {
              name = "palo-alto-mibs";
              pname = "palo-alto-mibs";
              src = pkgs.fetchurl {
                url = "https://docs.paloaltonetworks.com/content/dam/techdocs/en_US/zip/snmp-mib/pan-10-0-snmp-mib-modules.zip";
                sha256 = "sha256-POlbEN5xSJ/szO0pHbYu4GMcvugAQBR8Wu0kOsUKrv0=";
              };
              setSourceRoot = "sourceRoot=`pwd`";
              nativeBuildInputs = [
                pkgs.unzip
              ];
              dontUnpack = false;
              dontPatch = true;
              dontConfigure = true;
              dontFixup = true;
              dontBuild = true;
              installPhase = ''
                install -d $out/share/snmp/mibs
                for mib in *.my
                do
                  install -m 0444 ''${mib} $out/share/snmp/mibs/''$(basename ''${mib} .my)
                done
              '';
              postInstall = "";
            };
            # informacast-mibs = pkgs.stdenvNoCC.mkDerivation {
            #   pname = "informacast-mibs";
            #   version = "200806062101Z";
            #   src = ./informacast/mib.zip;
            #   buildInputs = [ pkgs.unzip ];
            #   dontPatch = true;
            #   dontConfigure = true;
            #   dontBuild = true;
            #   installPhase = ''
            #     install -d $out/share/snmp/mibs
            #     install -m 0444 BERBEE-APPLICATIONS-IPT-INFORMACAST.txt $out/share/snmp/mibs/BERBEE-APPLICATIONS-IPT-INFORMACAST
            #   '';
            #   dontFixup = true;
            # };
            # https://www.vertiv.com/en-in/support/software-download/monitoring/management-information-bases-mibs-for-liebert-products/
            # liebert-mibs-1 =
            #   let
            #     version = "21";
            #   in
            #   pkgs.stdenvNoCC.mkDerivation {
            #     inherit version;
            #     pname = "liebert-mibs-1";
            #     src = ./files/lgpmib-unix_rev${version}.tar;
            #     # src = pkgs.fetchurl {
            #     #   url = "https://www.vertiv.com/4930c5/globalassets/documents/software/monitoring/lgpmib-unix_rev${version}.tar";
            #     #   sha256 = "sha256-FKgreDOD1j06CXL31SWI4gfFt+vE7uTFq4jETuc4UOk=";
            #     # };
            #     setSourceRoot = "sourceRoot=`pwd`";
            #     nativeBuildInputs = [ ];
            #     dontUnpack = false;
            #     dontPatch = true;
            #     dontConfigure = true;
            #     dontFixup = true;
            #     dontBuild = true;
            #     installPhase = ''
            #       set -v
            #       install -d $out/share/snmp/mibs
            #       for mib in *.MIB
            #       do
            #         sed -n -e "s/^ *\(.*\) DEFINITIONS ::= BEGIN/\1/p" $mib
            #         install -m 0444 ''${mib} $out/share/snmp/mibs/''$(sed -n -e "s/^ *\(.*\) DEFINITIONS ::= BEGIN/\1/p" $mib)
            #       done
            #     '';
            #     postInstall = "";
            #   };
            liebert-mibs-2 = pkgs.stdenvNoCC.mkDerivation {
              name = "liebert-mibs-2";
              pname = "liebert-mibs-2";
              src = pkgs.fetchurl {
                url = "https://downloads1.vertivco.com/Communication-Cards/SNMP_MIB/MIB_for_Liebert_ISWEB-RT3_Card-Unix.tar";
                sha256 = "sha256-eByZ/M/4jaGp7O8Y0zpMa1p8u4ej9RQph6LJqRv6QC4=";
              };
              setSourceRoot = "sourceRoot=`pwd`";
              nativeBuildInputs = [ ];
              dontUnpack = false;
              dontPatch = true;
              dontConfigure = true;
              dontFixup = true;
              dontBuild = true;
              installPhase = ''
                install -d $out/share/snmp/mibs
                for mib in *.mib
                do
                  install -m 0444 ''${mib} $out/share/snmp/mibs/''$(sed -n -e "s/^ *\(.*\) DEFINITIONS ::= BEGIN/\1/p" $mib)
                done
              '';
              postInstall = "";
            };
            # anetd-mibs = pkgs.stdenvNoCC.mkDerivation {
            #   name = "anetd-mibs";
            #   pname = "anetd-mibs";
            #   src = ./files/AND-IPSPEAKER-GEN2-MIB;
            #   dontUnpack = true;
            #   dontPatch = true;
            #   dontConfigure = true;
            #   dontBuild = true;
            #   dontFixup = true;
            #   installPhase = ''
            #     install -d $out/share/snmp/mibs
            #     install -m 0444 $src $out/share/snmp/mibs/AND-IPSPEAKER-GEN2-MIB
            #   '';
            #   postInstall = "";
            # };
          }
        ]
      );
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.net-snmp
            pkgs.prometheus-snmp-exporter
          ];
          shellHook = ''
            export name="snmp-exporter"
            export MIBDIRS=${pkgs.lib.concatStringsSep ":" (map (mib: "${mib}/share/snmp/mibs") (mib-packages pkgs))}
          '';
        };
      });
      apps = forAllSystems (
        pkgs:
        let
          generate = pkgs.writeScriptBin "generate" ''
            export MIBDIRS=${pkgs.lib.concatStringsSep ":" (map (mib: "${mib}/share/snmp/mibs") (mib-packages pkgs))}
            ${pkgs.prometheus-snmp-exporter}/bin/generator generate --log.level=info "$@"
          '';
        in
        {
          default = {
            type = "app";
            program = "${generate}/bin/generate";
            meta.description = "Generate snmp_exporter configuration using the bundled MIBs";
          };
        }
      );
      nixosModules.snmp-exporter = import ./module.nix;
    };
}
