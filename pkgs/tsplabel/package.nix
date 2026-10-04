{ writers, python3Packages }:

# CLI standalone pra imprimir na impressora TSPL (POS Label Printer 0416:5011).
# Fase 1: texto + código de barras + QR via comandos TSPL nativos.
# Fase 2 (futura): PDF/PNG → bitmap dithered → TSPL BITMAP command.
writers.writePython3Bin "tsplabel" {
  libraries = with python3Packages; [
    pillow
    qrcode
    python-barcode
  ];
  flakeIgnore = [ "E501" ];
} (builtins.readFile ./tsplabel.py)
