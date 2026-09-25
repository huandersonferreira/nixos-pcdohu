{ pkgs, lib, ... }:

# Nobreak Ragtech OneUp Nitro via Supervise 8 (versão "beta" no site da
# Ragtech; sucede o antigo Personal 6.3 que não conhecia o Nitro).
#
# Após rebuild:
#   • UI web:  http://localhost:4470
#   • Kill dos serviços do Supervise 6.3 antigos (se ainda em memória):
#       sudo pkill -f /nix/store.*ragtech-supervise-6.3
#
# Serviços rodam com WorkingDirectory=/var/lib/supervise (populado por
# supervise-setup.service com symlinks read-only + cópias writable dos
# configs em monit.cfg / client.cfg — se você editar os .cfg no /var/lib,
# eles NÃO são sobrescritos em rebuilds seguintes).

let
  supervise = pkgs.callPackage ../../pkgs/ragtech-supervise/package.nix { };
  installDir = "${supervise}/opt/supervise";
  workDir = "/var/lib/supervise";

  serviceEnv = {
    LD_LIBRARY_PATH = "${installDir}/lib:${installDir}";
    QT_PLUGIN_PATH = "${installDir}/plugins";
    # supsvc/notifysvc/shutsvc rodam headless — Qt "offscreen" evita
    # tentar abrir X11.
    QT_QPA_PLATFORM = "offscreen";
  };

  mkSvc = { description, exec, after ? [] }: {
    inherit description;
    after = after ++ [ "network.target" "supervise-setup.service" ];
    requires = [ "supervise-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = serviceEnv;
    serviceConfig = {
      Type = "simple";
      # Binário é uma cópia real dentro do workDir — realpath(argv[0])
      # resolve pra ${workDir}/${exec}, permitindo mkdir dirname/log/.
      ExecStart = "${workDir}/${exec}";
      WorkingDirectory = workDir;
      Restart = "always";
      RestartSec = 5;
    };
  };
in
{
  environment.systemPackages = [ supervise ];

  # UI web em http://<host>:4470 — libera acesso da LAN.
  # UDP 4470 é usado pelo app mobile pra descoberta local.
  networking.firewall.allowedTCPPorts = [ 4470 ];
  networking.firewall.allowedUDPPorts = [ 4470 ];

  systemd.tmpfiles.rules = [
    "d /var/lock 0755 root root - -"
    "d ${workDir} 0755 root root - -"
  ];

  # Popula /var/lib/supervise com symlinks pros assets e cópias writable
  # dos configs. Idempotente — safe rodar toda inicialização.
  systemd.services.supervise-setup = {
    description = "Populate ${workDir} for Supervise runtime";
    wantedBy = [ "multi-user.target" ];
    before = [ "supsvc.service" "notifysvc.service" "shutsvc.service" ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      dst=${workDir}
      src=${installDir}
      mkdir -p "$dst"
      cd "$dst"

      # Symlinks pra assets read-only "grandes" (lib bundled, web, plugins,
      # devices.xml, .so). Força reatualização a cada boot pra pegar novo
      # store path após rebuild.
      for f in devices.xml web plugins lib \
               config.so client.so device.so monit.so supapi.so; do
        [ -e "$src/$f" ] && ln -sfn "$src/$f" "$f"
      done

      # Executáveis principais precisam ser CÓPIAS reais (não symlinks) —
      # o binário chama realpath(argv[0]) e faz mkdir dirname/log/. Se
      # for symlink, realpath resolve pro /nix/store (read-only) e crasha.
      for f in supsvc notifysvc shutsvc cloudsvc notifygui; do
        if [ -f "$src/$f" ]; then
          rm -f "$f"
          install -m 755 "$src/$f" "$f"
        fi
      done

      # Cópias writable dos configs (preserva edições do usuário).
      for f in monit.cfg client.cfg; do
        [ -f "$f" ] || install -m 644 "$src/$f" "$f"
      done

      # log/ pode ser criado pelo binário mesmo, mas garante que existe.
      mkdir -p log
    '';
  };

  systemd.services.supsvc = mkSvc {
    description = "Ragtech Supervise Monitoring Agent";
    exec = "supsvc";
  };

  systemd.services.notifysvc = mkSvc {
    description = "Ragtech Supervise Notify Agent";
    exec = "notifysvc";
    after = [ "supsvc.service" ];
  };

  systemd.services.shutsvc = mkSvc {
    description = "Ragtech Supervise Shutdown Agent";
    exec = "shutsvc";
    after = [ "notifysvc.service" ];
  };

  # cloudsvc conecta na nuvem Ragtech via MQTT (broker configurado em
  # /var/lib/supervise/client.cfg [cloudsvc.mqtt]). É por onde o app
  # mobile relaia comandos e recebe telemetria fora da LAN.
  systemd.services.cloudsvc = mkSvc {
    description = "Ragtech Supervise Cloud Agent";
    exec = "cloudsvc";
    after = [ "supsvc.service" ];
  };
}
